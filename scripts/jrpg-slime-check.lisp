(require :asdf)
(let ((quicklisp-setup (merge-pathnames "quicklisp/setup.lisp"
                                        (user-homedir-pathname))))
  (when (probe-file quicklisp-setup)
    (load quicklisp-setup)))
(asdf:load-system :immortal-coil)
(load "game/jrpg/state.lisp")
(load "game/jrpg/combat.lisp")

(in-package #:immortal-coil)

(defun jrpg-slime-check-fail (control &rest arguments)
  (error "~?" control arguments))

(defun jrpg-slime-check-assert (condition control &rest arguments)
  (unless condition
    (apply #'jrpg-slime-check-fail control arguments)))

(defun jrpg-slime-check-valid-cell-p (cell)
  (member cell '(#\. #\# #\* #\+) :test #'char=))

(defun jrpg-slime-check-row-populated-p (row)
  (find-if (lambda (cell)
             (not (char= cell #\.)))
           row))

(defun jrpg-slime-check ()
  (let ((width (length (aref *jrpg-slime-sprite* 0))))
    (jrpg-slime-check-assert
     (>= (length *jrpg-slime-sprite*) 12)
     "slime sprite is too short")
    (jrpg-slime-check-assert
     (>= width 16)
     "slime sprite is too narrow")
    (loop for row across *jrpg-slime-sprite*
          for index from 0
          do (jrpg-slime-check-assert
              (= (length row) width)
              "slime row ~d has width ~d instead of ~d"
              index
              (length row)
              width)
             (jrpg-slime-check-assert
              (jrpg-slime-check-row-populated-p row)
              "slime row ~d is empty"
              index)
             (loop for cell across row
                   do (jrpg-slime-check-assert
                       (jrpg-slime-check-valid-cell-p cell)
                       "invalid slime sprite cell: ~s"
                       cell))))
  (format t "jrpg slime check passed~%"))

(jrpg-slime-check)
