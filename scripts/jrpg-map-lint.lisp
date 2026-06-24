;;; JRPG map generation lint for the bundled story graph.
;;;
;;; Loads the story through the real dialog loader, then generates many
;;; JRPG city, street, and overworld maps. Fails if any required door,
;;; landmark, bridge, or finish is missing or unreachable from the start.
;;;
;;; Run headless:
;;;   sbcl --eval '(require :asdf)' \
;;;        --eval '(asdf:load-system :immortal-coil)' \
;;;        --load scripts/jrpg-map-lint.lisp

(in-package #:immortal-coil)

(defparameter *jrpg-map-lint-samples* 300)

(defun jrpg-map-lint-cell (rows x y)
  (and (<= 0 y)
       (< y (length rows))
       (<= 0 x)
       (< x (length (aref rows y)))
       (char (aref rows y) x)))

(defun jrpg-map-lint-passable-p (rows blockers x y)
  (let ((cell (jrpg-map-lint-cell rows x y)))
    (and cell
         (not (member cell blockers :test #'char=)))))

(defun jrpg-map-lint-find-glyphs (rows glyph)
  (let ((found nil))
    (loop for y below (length rows)
          do (loop for x below (length (aref rows y))
                   when (char= (char (aref rows y) x) glyph)
                     do (push (list x y) found)))
    found))

(defun jrpg-map-lint-reachable-cells (rows start-x start-y blockers)
  (let ((seen (make-hash-table :test #'equal))
        (queue (list (list start-x start-y))))
    (setf (gethash (list start-x start-y) seen) t)
    (loop while queue
          for position = (pop queue)
          do (destructuring-bind (x y) position
               (dolist (offset '((1 0) (-1 0) (0 1) (0 -1)))
                 (destructuring-bind (dx dy) offset
                   (let ((next-x (+ x dx))
                         (next-y (+ y dy)))
                     (when (and (jrpg-map-lint-passable-p
                                 rows blockers next-x next-y)
                                (not (gethash (list next-x next-y) seen)))
                       (setf (gethash (list next-x next-y) seen) t)
                       (setf queue (nconc queue
                                          (list (list next-x next-y))))))))))
    seen))

(defun jrpg-map-lint-require-reachable (rows seen label glyph)
  (let ((positions (jrpg-map-lint-find-glyphs rows glyph)))
    (unless positions
      (error "~a missing ~c" label glyph))
    (unless (some (lambda (position)
                    (gethash position seen))
                  positions)
      (error "~a cannot reach any ~c" label glyph))))

(defun jrpg-map-lint-call (name &rest arguments)
  (unless (fboundp name)
    (error "JRPG map generator ~s is not loaded" name))
  (apply (symbol-function name) arguments))

(defun jrpg-map-lint-city (seed)
  (multiple-value-bind (rows start-x start-y)
      (jrpg-map-lint-call 'jrpg-gen-city 27 13
                          (list #\A #\M #\Q #\D #\S #\P)
                          (list #\C)
                          seed
                          (list #\A #\M #\Q #\D #\S #\P)
                          (list #\C))
    (let* ((rows (coerce rows 'vector))
           (seen (jrpg-map-lint-reachable-cells rows start-x start-y
                                                '(#\#)))
           (label (format nil "city seed ~d" seed)))
      (dolist (glyph '(#\A #\M #\Q #\D #\S #\P #\C))
        (jrpg-map-lint-require-reachable rows seen label glyph)))))

(defun jrpg-map-lint-street (sample)
  (multiple-value-bind (rows start-x start-y)
      (jrpg-map-lint-call 'jrpg-gen-streets 34 18 #\! (list #\R))
    (let* ((rows (coerce rows 'vector))
           (seen (jrpg-map-lint-reachable-cells rows start-x start-y
                                                '(#\#)))
           (label (format nil "street sample ~d" sample)))
      (dolist (glyph '(#\! #\R))
        (jrpg-map-lint-require-reachable rows seen label glyph)))))

(defun jrpg-map-lint-overworld (sample)
  (multiple-value-bind (rows start-x start-y)
      (jrpg-map-lint-call 'jrpg-gen-overworld 34 18 #\! (list #\R #\T #\S))
    (let* ((rows (coerce rows 'vector))
           (seen (jrpg-map-lint-reachable-cells rows start-x start-y
                                                '(#\^ #\~ #\#)))
           (label (format nil "overworld sample ~d" sample)))
      (dolist (glyph '(#\! #\R #\T #\S #\B))
        (jrpg-map-lint-require-reachable rows seen label glyph)))))

(defun lint-jrpg-maps ()
  (loop for seed from 1 to *jrpg-map-lint-samples*
        do (jrpg-map-lint-city seed))
  (loop for sample from 1 to *jrpg-map-lint-samples*
        do (jrpg-map-lint-street sample))
  (loop for sample from 1 to *jrpg-map-lint-samples*
        do (jrpg-map-lint-overworld sample))
  (format t "~&JRPG MAPS OK (~d samples per generator)~%"
          *jrpg-map-lint-samples*))

(handler-case
    (progn
      (load-dialog-graph)
      (lint-jrpg-maps))
  (error (condition)
    (format t "~&JRPG MAPS FAIL: ~a~%" condition)
    (sb-ext:exit :code 1)))
