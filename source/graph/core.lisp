(in-package #:immortal-coil)

(-> add-node (node) node)
(defun add-node (node)
  (let* ((id (node-id node))
         (previous-source (gethash id *node-sources*))
         (new-source (current-dialog-source-name)))
    (when (and previous-source
               (not (dialog-source-same-p previous-source new-source)))
      (record-dialog-conflict id previous-source new-source))
    (setf (gethash id *node-sources*) new-source))
  (setf (node-enter-effects node)
        (combine-node-enter-effects node))
  (remhash (node-id node) *pending-node-enter-effects*)
  (setf *last-dialog-node-id* (node-id node))
  (setf (gethash (node-id node) *nodes*) node))

(-> ensure-runtime-fallback-node () node)
(defun ensure-runtime-fallback-node ()
  (or (gethash *runtime-fallback-node-id* *nodes*)
      (let ((node (make-node :id *runtime-fallback-node-id*
                             :kind :text
                             :text "the thread goes dark.")))
        (add-node node)
        node)))

(-> node-exists-p (t) boolean)
(defun node-exists-p (id)
  (not (null (gethash id *nodes*))))

(-> resolve-node-id (t) dialog-id)
(defun resolve-node-id (id)
  (if (node-exists-p id)
      id
      (progn
        (runtime-warn "Unknown story node: ~a" id)
        (node-id (ensure-runtime-fallback-node)))))

(-> find-node (t) node)
(defun find-node (id)
  (or (gethash id *nodes*)
      (progn
        (runtime-warn "Unknown story node: ~a" id)
        (ensure-runtime-fallback-node))))

(-> reset-dialog-graph () t)
(defun reset-dialog-graph ()
  (reset-nodes)
  (setf *story-start-node* nil
        *last-dialog-node-id* nil
        *dev-save-override* nil
        *dialog-conflicts* nil))
