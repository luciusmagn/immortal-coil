(in-package #:immortal-coil)

(-> current-node () node)
(defun current-node ()
  (let ((node (find-node (play-state-current-id *state*))))
    (unless (equal (play-state-current-id *state*)
                   (node-id node))
      (setf (play-state-current-id *state*) (node-id node)))
    node))

(-> reset-play-state (&optional t) t)
(defun reset-play-state (&optional (id *story-start-node*))
  (reset-dialog-store)
  (ensure-runtime-fallback-node)
  (setf *state* (make-play-state
                 :current-id (resolve-node-id
                              (or id *runtime-fallback-node-id*))
                 :elapsed 0.0
                 :type-delay *game-start-type-delay-seconds*
                 :visible-count 0
                 :selected-index 0
                 :input-buffer ""))
  (apply-node-enter-effects (current-node)))

(-> jump-to-node (t) t)
(defun jump-to-node (id)
  (setf (play-state-current-id *state*) (resolve-node-id id)
        (play-state-elapsed *state*) 0.0
        (play-state-type-delay *state*) 0.0
        (play-state-visible-count *state*) 0
        (play-state-selected-index *state*) 0
        (play-state-input-buffer *state*) "")
  (apply-node-enter-effects (current-node))
  (save-current-game-maybe))
