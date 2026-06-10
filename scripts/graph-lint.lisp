;;; Graph lint for the bundled story graph.
;;;
;;; Loads the full graph through the real loader, then checks that every
;;; string target resolves to a node, including each id in a minigame
;;; node's declared outcomes list. The outcomes list is what makes
;;; minigame destinations visible to tools; it is also the seed for
;;; future orphan detection.
;;;
;;; Run headless:
;;;   sbcl --eval '(require :asdf)' \
;;;        --eval '(asdf:load-system :immortal-coil)' \
;;;        --load scripts/graph-lint.lisp

(in-package #:immortal-coil)

(defun lint-check-target (problems id what target)
  (when (and (stringp target)
             (not (node-exists-p target)))
    (push (format nil "~s ~s -> missing ~s" id what target) problems))
  problems)

(defun lint-minigame-outcomes (problems id node)
  (dolist (target (node-minigame-outcomes node))
    (setf problems (lint-check-target problems id :outcome target)))
  problems)

(defun lint-dialog-graph ()
  (let ((problems nil)
        (count 0))
    (maphash
     (lambda (id node)
       (incf count)
       (setf problems (lint-check-target problems id :next (node-next node)))
       (setf problems (lint-check-target problems id :target (node-target node)))
       (setf problems (lint-check-target problems id :success
                                         (node-success-target node)))
       (setf problems (lint-check-target problems id :failure
                                         (node-failure-target node)))
       (loop for choice across (node-choices node)
             do (setf problems (lint-check-target problems id :choice
                                                  (choice-target choice))))
       (when (typep node 'minigame-node)
         (setf problems (lint-minigame-outcomes problems id node))))
     *nodes*)
    (format t "~&NODES ~d START ~a BUNDLES ~d~%"
            count *story-start-node* (loaded-dialog-bundle-count))
    (if problems
        (progn
          (format t "~&LINT FAIL:~%")
          (dolist (problem (sort problems #'string<))
            (format t "  ~a~%" problem))
          (sb-ext:exit :code 1))
        (format t "~&LINT OK~%"))))

(load-dialog-graph)
(lint-dialog-graph)
