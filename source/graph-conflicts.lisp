(in-package #:immortal-coil)

(-> dialog-source-name (t) string)
(defun dialog-source-name (source)
  (source-designator-name source))

(-> current-dialog-source-name () string)
(defun current-dialog-source-name ()
  (dialog-source-name *current-dialog-source*))

(-> dialog-source-same-p (t t) boolean)
(defun dialog-source-same-p (left right)
  (string= (dialog-source-name left)
           (dialog-source-name right)))

(-> record-dialog-conflict (dialog-id t t) dialog-conflict)
(defun record-dialog-conflict (node-id previous-source new-source)
  (let ((conflict (make-dialog-conflict
                   :node-id node-id
                   :previous-source previous-source
                   :new-source new-source
                   :resolution :latest-wins)))
    (push conflict *dialog-conflicts*)
    (runtime-warn "Dialog node conflict for ~a: ~a replaced by ~a."
                  node-id
                  (dialog-source-name previous-source)
                  (dialog-source-name new-source))
    conflict))
