(in-package #:immortal-coil)

;;; Model

(defvar *state* nil)
(defvar *save-current-game-function* nil)
(defvar *save-current-game-p* nil)

(defstruct play-state
  (current-id          *runtime-fallback-node-id* :type dialog-id)
  (elapsed             0.0 :type seconds)
  (type-delay          0.0 :type seconds)
  (visible-count       0 :type nonnegative-integer)
  (selected-index      0 :type nonnegative-integer)
  (conversation-index  0 :type nonnegative-integer)
  (input-buffer        "" :type string))


;;; Save hook

(-> save-current-game-maybe () t)
(defun save-current-game-maybe ()
  (when (and *save-current-game-p*
             *save-current-game-function*)
    (handler-case
        (funcall *save-current-game-function*)
      (error (condition)
        (runtime-warn "Could not save game: ~a" condition)))))


;;; Navigation

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
                 :conversation-index 0
                 :input-buffer ""))
  (apply-node-enter-effects (current-node)))

(-> jump-to-node (t) t)
(defun jump-to-node (id)
  (let ((resolved-id (resolve-node-id id)))
    (when (and *state*
               (not (equal (play-state-current-id *state*) resolved-id))
               (fboundp 'editor-before-jump))
      (funcall (symbol-function 'editor-before-jump) resolved-id))
    (setf (play-state-current-id *state*) resolved-id
          (play-state-elapsed *state*) 0.0
          (play-state-type-delay *state*) 0.0
          (play-state-visible-count *state*) 0
          (play-state-selected-index *state*) 0
          (play-state-conversation-index *state*) 0
          (play-state-input-buffer *state*) "")
    (apply-node-enter-effects (current-node))
    (save-current-game-maybe)))

(-> jump-to-dialog-target (t) t)
(defun jump-to-dialog-target (target)
  (jump-to-node (resolve-dialog-target target)))
