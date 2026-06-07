(in-package #:immortal-coil)

(-> dialog-case (dialog-condition dialog-id) branch)
(defun dialog-case (condition target)
  (make-branch :condition condition :target target))

(-> dialog-default (dialog-id) branch)
(defun dialog-default (target)
  (dialog-case t target))

(-> make-fallback-branch () branch)
(defun make-fallback-branch ()
  (dialog-default *runtime-fallback-node-id*))

(-> ensure-dialog-case (t) branch)
(defun ensure-dialog-case (value)
  (if (branch-p value)
      value
      (progn
        (runtime-warn "Expected a dialog case, got: ~s" value)
        (make-fallback-branch))))

(-> ensure-dialog-cases (list) vector)
(defun ensure-dialog-cases (cases)
  (coerce (mapcar #'ensure-dialog-case cases) 'vector))

(-> dialog-branch (dialog-id &rest branch) dialog-id)
(defun dialog-branch (id &rest cases)
  (unless cases
    (runtime-warn "Branch node needs at least one case: ~a" id)
    (setf cases (list (make-fallback-branch))))
  (add-node (make-node :id id
                       :kind :branch
                       :text ""
                       :branches (ensure-dialog-cases cases)))
  id)
