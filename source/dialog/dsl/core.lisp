(in-package #:immortal-coil)

(-> dialog-start (dialog-id) dialog-id)
(defun dialog-start (id)
  (setf *story-start-node* id))

(-> dialog-text (dialog-id string &key (:next (option dialog-id))) dialog-id)
(defun dialog-text (id text &key next)
  (add-node (make-node :id id
                       :kind :text
                       :text text
                       :next next))
  id)

(-> dialog-required-link ((option dialog-id) dialog-id string) dialog-id)
(defun dialog-required-link (target id warning-text)
  (or target
      (progn
        (runtime-warn "~a: ~a" warning-text id)
        *runtime-fallback-node-id*)))

(-> dialog-set-next (dialog-id dialog-id) dialog-id)
(defun dialog-set-next (node-id next-id)
  (setf (node-next (find-node node-id)) next-id)
  node-id)
