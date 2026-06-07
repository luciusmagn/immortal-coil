(in-package #:immortal-coil)

(-> node-existing-enter-effects (dialog-id) list)
(defun node-existing-enter-effects (id)
  (let ((node (gethash id *nodes*)))
    (when node
      (node-enter-effects node))))

(-> node-pending-enter-effects (dialog-id) list)
(defun node-pending-enter-effects (id)
  (gethash id *pending-node-enter-effects*))

(-> combine-node-enter-effects (node) list)
(defun combine-node-enter-effects (node)
  (let ((id (node-id node)))
    (append (node-existing-enter-effects id)
            (node-pending-enter-effects id)
            (node-enter-effects node))))
