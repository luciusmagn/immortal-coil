(in-package #:immortal-coil)

;;; Model

(defvar *state* nil)
(defvar *playtime-seconds* 0.0)
(defvar *save-current-game-function* nil)
(defvar *save-current-game-p* nil)

(defstruct play-state
  (current-id          *runtime-fallback-node-id* :type dialog-id)
  (elapsed             0.0 :type seconds)
  (type-delay          0.0 :type seconds)
  (visible-count       0 :type nonnegative-integer)
  (selected-index      0 :type nonnegative-integer)
  (choice-preview-index 0 :type nonnegative-integer)
  (choice-preview-elapsed 0.0 :type seconds)
  (choice-preview-visible-count 0 :type nonnegative-integer)
  (conversation-index  0 :type nonnegative-integer)
  (input-buffer        "" :type string)
  (journal-entries     nil :type list)
  (journal-open-p      nil :type boolean)
  (journal-scroll      0 :type nonnegative-integer)
  (journal-visit-index 0 :type nonnegative-integer)
  (journal-recorded    nil :type list))


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
                 :choice-preview-index 0
                 :choice-preview-elapsed 0.0
                 :choice-preview-visible-count 0
                 :conversation-index 0
                 :input-buffer ""
                 :journal-entries nil
                 :journal-open-p nil
                 :journal-scroll 0
                 :journal-visit-index 0
                 :journal-recorded nil))
  (when (fboundp 'journal-begin-node-visit)
    (funcall (symbol-function 'journal-begin-node-visit)
             (current-node)))
  (apply-node-enter-effects (current-node)))

(-> editor-before-jump-maybe (dialog-id) boolean)
(defun editor-before-jump-maybe (resolved-id)
  (or (not (fboundp 'editor-before-jump))
      (not (null (funcall (symbol-function 'editor-before-jump)
                          resolved-id)))))

(-> jump-to-node (t) boolean)
(defun jump-to-node (id)
  (if (null *state*)
      (progn
        (runtime-warn "Cannot jump to ~s without a play state." id)
        nil)
      (let ((resolved-id (resolve-node-id id)))
        (when (or (equal (play-state-current-id *state*) resolved-id)
                  (editor-before-jump-maybe resolved-id))
          (setf (play-state-current-id *state*) resolved-id
                (play-state-elapsed *state*) 0.0
                (play-state-type-delay *state*) 0.0
                (play-state-visible-count *state*) 0
                (play-state-selected-index *state*) 0
                (play-state-choice-preview-index *state*) 0
                (play-state-choice-preview-elapsed *state*) 0.0
                (play-state-choice-preview-visible-count *state*) 0
                (play-state-conversation-index *state*) 0
                (play-state-input-buffer *state*) ""
                (play-state-journal-open-p *state*) nil
                (play-state-journal-scroll *state*) 0
                (play-state-journal-recorded *state*) nil)
          (when (fboundp 'journal-begin-node-visit)
            (funcall (symbol-function 'journal-begin-node-visit)
                     (current-node)))
          (apply-node-enter-effects (current-node))
          (save-current-game-maybe)
          t))))

(-> jump-to-dialog-target (t) boolean)
(defun jump-to-dialog-target (target)
  (jump-to-node (resolve-dialog-target target)))
