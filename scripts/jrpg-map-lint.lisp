;;; JRPG map generation lint for the bundled story graph.
;;;
;;; Loads the story through the real dialog loader, then generates many
;;; JRPG city, street, and overworld maps. Fails if any required door,
;;; landmark, bridge, or finish is missing or unreachable from the start,
;;; and if the generated layout loses its expected town/street/world shape.
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

(defun jrpg-map-lint-count-glyph (rows glyph)
  (loop for row across rows
        sum (loop for cell across row
                  count (char= cell glyph))))

(defun jrpg-map-lint-cell-char= (rows x y glyph)
  (let ((cell (jrpg-map-lint-cell rows x y)))
    (and cell (char= cell glyph))))

(defun jrpg-map-lint-require-count-at-least (rows label glyph minimum)
  (let ((count (jrpg-map-lint-count-glyph rows glyph)))
    (when (< count minimum)
      (error "~a has only ~d ~c cells; expected at least ~d"
             label count glyph minimum))))

(defun jrpg-map-lint-require-count-exactly (rows label glyph expected)
  (let ((count (jrpg-map-lint-count-glyph rows glyph)))
    (unless (= count expected)
      (error "~a has ~d ~c cells; expected exactly ~d"
             label count glyph expected))))

(defun jrpg-map-lint-border-count (rows glyph)
  (let* ((height (length rows))
         (width (length (aref rows 0)))
         (count 0))
    (loop for x below width
          do (when (char= (char (aref rows 0) x) glyph)
               (incf count))
             (when (char= (char (aref rows (1- height)) x) glyph)
               (incf count)))
    (loop for y from 1 below (1- height)
          do (when (char= (char (aref rows y) 0) glyph)
               (incf count))
             (when (char= (char (aref rows y) (1- width)) glyph)
               (incf count)))
    count))

(defun jrpg-map-lint-require-border-count-at-least (rows label glyph minimum)
  (let ((count (jrpg-map-lint-border-count rows glyph)))
    (when (< count minimum)
      (error "~a has only ~d border ~c cells; expected at least ~d"
             label count glyph minimum))))

(defun jrpg-map-lint-open-cell-p (rows blockers x y)
  (let ((cell (jrpg-map-lint-cell rows x y)))
    (and cell
         (not (member cell blockers :test #'char=)))))

(defun jrpg-map-lint-horizontal-open-band-count (rows blockers minimum-run)
  (loop for y below (length rows)
        count (loop with run = 0
                    for x below (length (aref rows y))
                    maximize (if (jrpg-map-lint-open-cell-p rows blockers x y)
                                 (incf run)
                                 (setf run 0))
                      into longest
                    finally (return (>= longest minimum-run)))))

(defun jrpg-map-lint-vertical-open-band-count (rows blockers minimum-run)
  (let ((width (length (aref rows 0)))
        (height (length rows)))
    (loop for x below width
          count (loop with run = 0
                      for y below height
                      maximize (if (jrpg-map-lint-open-cell-p rows blockers x y)
                                   (incf run)
                                   (setf run 0))
                        into longest
                      finally (return (>= longest minimum-run))))))

(defun jrpg-map-lint-require-open-bands (rows label blockers
                                         horizontal-min horizontal-count
                                         vertical-min vertical-count)
  (let ((h-count (jrpg-map-lint-horizontal-open-band-count
                  rows blockers horizontal-min))
        (v-count (jrpg-map-lint-vertical-open-band-count
                  rows blockers vertical-min)))
    (when (< h-count horizontal-count)
      (error "~a has only ~d broad horizontal street bands; expected at least ~d"
             label h-count horizontal-count))
    (when (< v-count vertical-count)
      (error "~a has only ~d broad vertical street bands; expected at least ~d"
             label v-count vertical-count))))

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

(defun jrpg-map-lint-require-start-passable (rows blockers start-x start-y label)
  (unless (jrpg-map-lint-passable-p rows blockers start-x start-y)
    (error "~a starts on blocked cell ~s at ~d,~d"
           label (jrpg-map-lint-cell rows start-x start-y) start-x start-y)))

(defun jrpg-map-lint-require-city-door-frontage (rows label glyph)
  (dolist (position (jrpg-map-lint-find-glyphs rows glyph))
    (destructuring-bind (x y) position
      (let ((left  (jrpg-map-lint-cell-char= rows (1- x) y #\#))
            (right (jrpg-map-lint-cell-char= rows (1+ x) y #\#))
            (up    (jrpg-map-lint-cell-char= rows x (1- y) #\#))
            (front (jrpg-map-lint-cell-char= rows x (- y 2) #\#))
            (down  (jrpg-map-lint-cell-char= rows x (1+ y) #\#)))
        (unless up
          (error "~a doorway ~c at ~d,~d is not below a building front"
                 label glyph x y))
        (unless front
          (error "~a doorway ~c at ~d,~d is below a roof edge, not a front wall"
                 label glyph x y))
        (when (or left right down)
          (error "~a doorway ~c at ~d,~d is embedded in a roof or side wall"
                 label glyph x y))))))

(defun jrpg-map-lint-call (name &rest arguments)
  (unless (fboundp name)
    (error "JRPG map generator ~s is not loaded" name))
  (apply (symbol-function name) arguments))

(defun jrpg-map-lint-city (seed)
  (multiple-value-bind (rows start-x start-y)
      (jrpg-map-lint-call 'jrpg-gen-city 35 17
                          (list #\A #\M #\Q #\D #\S #\P)
                          (list #\C)
                          seed
                          (list #\A #\M #\Q #\D #\S #\P)
                          (list #\C))
    (let* ((rows (coerce rows 'vector))
           (seen (jrpg-map-lint-reachable-cells rows start-x start-y
                                                '(#\#)))
           (label (format nil "city seed ~d" seed)))
      (jrpg-map-lint-require-start-passable rows '(#\#) start-x start-y label)
      (jrpg-map-lint-require-count-at-least rows label #\# 150)
      (jrpg-map-lint-require-count-at-least rows label #\. 300)
      (jrpg-map-lint-require-count-at-least rows label #\+ 4)
      (jrpg-map-lint-require-border-count-at-least rows label #\# 80)
      (dolist (glyph '(#\A #\M #\Q #\D #\S #\P #\C))
        (jrpg-map-lint-require-count-exactly rows label glyph 1)
        (jrpg-map-lint-require-reachable rows seen label glyph))
      (dolist (glyph '(#\A #\M #\Q #\D #\S #\P))
        (jrpg-map-lint-require-city-door-frontage rows label glyph)))))

(defun jrpg-map-lint-street-case (sample width height waypoints label-prefix)
  (multiple-value-bind (rows start-x start-y)
      (jrpg-map-lint-call 'jrpg-gen-streets width height #\! waypoints)
    (let* ((rows (coerce rows 'vector))
           (seen (jrpg-map-lint-reachable-cells rows start-x start-y
                                                '(#\#)))
           (label (format nil "~a street sample ~d" label-prefix sample)))
      (jrpg-map-lint-require-start-passable rows '(#\#) start-x start-y label)
      (jrpg-map-lint-require-count-at-least
       rows label #\# (max 120 (floor (* width height 3) 10)))
      (jrpg-map-lint-require-count-at-least
       rows label #\. (max 180 (floor (* width height 2) 5)))
      (jrpg-map-lint-require-count-at-least rows label #\+ 4)
      (jrpg-map-lint-require-open-bands
       rows label '(#\#)
       (max 16 (floor width 2)) 3
       (max 6 (floor height 3)) 2)
      (dolist (glyph (cons #\! waypoints))
        (jrpg-map-lint-require-count-exactly rows label glyph 1)
        (jrpg-map-lint-require-reachable rows seen label glyph)))))

(defun jrpg-map-lint-street (sample)
  (jrpg-map-lint-street-case sample 34 18 (list #\R) "studio")
  (jrpg-map-lint-street-case sample 32 16 nil "wilde")
  (jrpg-map-lint-street-case sample 38 20 (list #\R) "flight"))

(defun jrpg-map-lint-overworld (sample)
  (multiple-value-bind (rows start-x start-y)
      (jrpg-map-lint-call 'jrpg-gen-overworld 34 18 #\! (list #\R #\T #\S))
    (let* ((rows (coerce rows 'vector))
           (seen (jrpg-map-lint-reachable-cells rows start-x start-y
                                                '(#\^ #\~ #\#)))
           (label (format nil "overworld sample ~d" sample)))
      (jrpg-map-lint-require-start-passable rows '(#\^ #\~ #\#)
                                            start-x start-y label)
      (jrpg-map-lint-require-count-at-least rows label #\, 20)
      (jrpg-map-lint-require-count-at-least rows label #\~ 20)
      (jrpg-map-lint-require-count-at-least rows label #\^ 20)
      (jrpg-map-lint-require-count-at-least rows label #\f 15)
      (dolist (glyph '(#\! #\R #\T #\S #\B))
        (jrpg-map-lint-require-count-exactly rows label glyph 1)
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
