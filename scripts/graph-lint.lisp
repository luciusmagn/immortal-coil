;;; Graph lint for the bundled story graph.
;;;
;;; Loads the full graph through the real loader, then checks that every
;;; string target resolves to a node, that minigame outcome maps point at
;;; real nodes, and that outcome maps only name outcomes their minigame
;;; declares as possible. The same checks are the seed for future orphan
;;; detection.
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
  (let ((definition (find-minigame-definition (node-minigame node)
                                              :warn-p nil)))
    (loop for (outcome target) on (node-minigame-outcomes node) by #'cddr
          do (setf problems (lint-check-target problems id outcome target))
             (when (and definition
                        (not (member outcome
                                     (minigame-possible-outcomes definition))))
              (push (format nil "~s maps ~s, which ~s never finishes with"
                            id outcome (node-minigame node))
                    problems)))
    (when (and definition
               (null (node-minigame-outcomes node))
               (set-difference (minigame-possible-outcomes definition)
                               '(:success :failure))
               (null (node-failure-target node)))
      (push (format nil "~s leaves ~s outcomes unmapped with no failure target"
                    id (node-minigame node))
            problems)))
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
