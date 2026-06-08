(in-package #:immortal-coil)

;;; State

(defstruct editor-history-frame
  (node-id          *runtime-fallback-node-id* :type dialog-id)
  (store-checkpoint 0 :type nonnegative-integer))

(defvar *editor-active-p* nil)
(defvar *editor-history* nil)
(defvar *editor-target-name* nil)
(defvar *editor-status-message* nil)
(defvar *editor-suppress-history-p* nil)
(defvar *editor-mode* :play)
(defvar *editor-text-buffer* "")
(defvar *editor-edit-node-id* nil)
(defvar *editor-text-backspace-held-seconds* 0.0)
(defvar *editor-text-backspace-repeat-accumulator* 0.0)
(defvar *editor-store-overlay-p* nil)
(defvar *editor-help-overlay-p* nil)
(defvar *editor-insert-kind* :text)
(defvar *editor-insert-action* :insert)
(defvar *editor-insert-menu-selected-index* 0)
(defvar *editor-choice-option-node-id* nil)
(defvar *editor-choice-option-index* 0)
(defvar *editor-choice-option-field-index* 0)
(defvar *editor-choice-option-target-kind* :id)
(defvar *editor-choice-option-label-buffer* "")
(defvar *editor-choice-option-target-buffer* "")
(defvar *editor-choice-option-visible-buffer* "t")
(defvar *editor-choice-option-enabled-buffer* "t")

(defparameter *editor-draft-script-path* "game/editor-drafts.lisp")
(defparameter *editor-placeholder-text* "newly inserted editor text.")
(defparameter *editor-text-max-length* 1200)
(defparameter *editor-insert-kinds*
  #(:text :say :choice :conversation :number :string))
(defparameter *editor-choice-option-fields*
  #(:label :target-kind :target :visible :enabled))

(-> editor-control-down-p () boolean)
(defun editor-control-down-p ()
  (or (is-key-down-p +key-left-control+)
      (is-key-down-p +key-right-control+)))

(-> editor-control-key-pressed-p (integer) boolean)
(defun editor-control-key-pressed-p (key)
  (and (editor-control-down-p)
       (is-key-pressed-p key)))

(-> editor-active-p () boolean)
(defun editor-active-p ()
  *editor-active-p*)

(-> reset-editor-state () t)
(defun reset-editor-state ()
  (setf *editor-active-p* nil
        *editor-history* nil
        *editor-target-name* nil
        *editor-status-message* nil
        *editor-suppress-history-p* nil
        *editor-mode* :play
        *editor-text-buffer* ""
        *editor-edit-node-id* nil
        *editor-text-backspace-held-seconds* 0.0
        *editor-text-backspace-repeat-accumulator* 0.0
        *editor-store-overlay-p* nil
        *editor-help-overlay-p* nil
        *editor-insert-kind* :text
        *editor-insert-action* :insert
        *editor-insert-menu-selected-index* 0
        *editor-choice-option-node-id* nil
        *editor-choice-option-index* 0
        *editor-choice-option-field-index* 0
        *editor-choice-option-target-kind* :id
        *editor-choice-option-label-buffer* ""
        *editor-choice-option-target-buffer* ""
        *editor-choice-option-visible-buffer* "t"
        *editor-choice-option-enabled-buffer* "t")
  (when (fboundp 'reset-editor-store-edit-state)
    (funcall (symbol-function 'reset-editor-store-edit-state)))
  t)


;;; Session lifecycle

(-> editor-session-manifest-paths ((option t) list) list)
(defun editor-session-manifest-paths (manifest-path manifest-paths)
  (cond
    (manifest-paths
     manifest-paths)
    (manifest-path
     (list manifest-path))
    (t
     *dialog-manifest-paths*)))

(-> start-editor-session
    (&key (:manifest-path (option t))
          (:manifest-paths list)
          (:target-name string)
          (:draft-script-path (option t)))
    t)
(defun start-editor-session (&key manifest-path
                                  manifest-paths
                                  target-name
                                  draft-script-path)
  (stop-title-music)
  (stop-story-music)
  (when draft-script-path
    (setf *editor-draft-script-path* draft-script-path))
  (load-dialog-graph (editor-session-manifest-paths manifest-path
                                                    manifest-paths)
                     nil)
  (reset-particles)
  (reset-play-state *story-start-node*)
  (dialog-store-clear-history)
  (setf *save-current-game-p* nil
        *editor-active-p* t
        *editor-history* nil
        *editor-target-name* target-name
        *editor-status-message* "EDITOR: PLAYING GRAPH"
        *editor-mode* :play
        *editor-text-buffer* ""
        *editor-edit-node-id* nil
        *editor-text-backspace-held-seconds* 0.0
        *editor-text-backspace-repeat-accumulator* 0.0
        *editor-store-overlay-p* nil
        *editor-help-overlay-p* nil
        *editor-insert-kind* :text
        *editor-insert-action* :insert
        *editor-insert-menu-selected-index* 0
        *editor-choice-option-node-id* nil
        *editor-choice-option-index* 0
        *editor-choice-option-field-index* 0
        *editor-choice-option-target-kind* :id
        *editor-choice-option-label-buffer* ""
        *editor-choice-option-target-buffer* ""
        *editor-choice-option-visible-buffer* "t"
        *editor-choice-option-enabled-buffer* "t"
        *mode* :game
        *game-fade-elapsed* 0.0
        *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0)
  (when (fboundp 'reset-editor-store-edit-state)
    (funcall (symbol-function 'reset-editor-store-edit-state)))
  t)

(-> start-base-game-editor () t)
(defun start-base-game-editor ()
  (start-editor-session :manifest-path "game/manifest.lisp"
                        :target-name "BASE GAME"
                        :draft-script-path "game/editor-drafts.lisp"))

(-> start-mod-editor-session (t &key (:target-name string)
                                (:draft-script-path (option t)))
    t)
(defun start-mod-editor-session (manifest-path
                                 &key
                                   (target-name "MOD")
                                   draft-script-path)
  (start-editor-session :manifest-paths (list "game/manifest.lisp"
                                              manifest-path)
                        :target-name target-name
                        :draft-script-path draft-script-path))


;;; Navigation history

(-> editor-record-navigation-frame () (option editor-history-frame))
(defun editor-record-navigation-frame ()
  (when (and *editor-active-p*
             (not *editor-suppress-history-p*)
             *state*)
    (let ((frame (make-editor-history-frame
                  :node-id (play-state-current-id *state*)
                  :store-checkpoint (dialog-store-checkpoint))))
      (push frame *editor-history*)
      frame)))

(-> editor-before-jump (t) t)
(defun editor-before-jump (target-id)
  (declare (ignore target-id))
  (editor-record-navigation-frame))

(-> restore-editor-history-frame (editor-history-frame) t)
(defun restore-editor-history-frame (frame)
  (dialog-store-rewind-to (editor-history-frame-store-checkpoint frame))
  (setf (play-state-current-id *state*) (editor-history-frame-node-id frame)
        (play-state-elapsed *state*) 0.0
        (play-state-type-delay *state*) 0.0
        (play-state-visible-count *state*) 0
        (play-state-selected-index *state*) 0
        (play-state-conversation-index *state*) 0
        (play-state-input-buffer *state*) ""))

(-> editor-return-to-previous-node () boolean)
(defun editor-return-to-previous-node ()
  (let ((frame (pop *editor-history*)))
    (if frame
        (let ((*editor-suppress-history-p* t))
          (restore-editor-history-frame frame)
          (setf *editor-status-message* "EDITOR: REWOUND")
          (play-choice-switch)
          t)
        (progn
          (setf *editor-status-message* "EDITOR: NO PREVIOUS NODE")
          (play-choice-switch)
          nil))))


;;; Overlay data

(-> editor-target-next-label ((option dialog-target)) (option string))
(defun editor-target-next-label (target)
  (when target
    (dialog-target-label target)))

(-> editor-choice-next-label (node) (option string))
(defun editor-choice-next-label (node)
  (let ((choice (selected-active-choice node)))
    (when choice
      (dialog-target-label (choice-target choice)))))

(-> editor-minigame-next-label (node) (option string))
(defun editor-minigame-next-label (node)
  (format nil "success ~a / failure ~a"
          (dialog-target-label (node-success-target node))
          (dialog-target-label (node-failure-target node))))

(-> editor-next-label (node) (option string))
(defun editor-next-label (node)
  (case (node-kind node)
    ((:text :say :conversation)
     (editor-target-next-label (node-next node)))
    (:choice
     (editor-choice-next-label node))
    ((:number :string)
     (editor-target-next-label (node-target node)))
    (:branch
     (editor-target-next-label (matching-branch-target node)))
    (:minigame
     (editor-minigame-next-label node))
    (t nil)))

(-> editor-insert-kind-label (&optional editor-insert-kind) string)
(defun editor-insert-kind-label (&optional (kind *editor-insert-kind*))
  (string-upcase (symbol-name kind)))

(-> editor-current-insert-kind () editor-insert-kind)
(defun editor-current-insert-kind ()
  (aref *editor-insert-kinds*
        (min (max 0 *editor-insert-menu-selected-index*)
             (1- (length *editor-insert-kinds*)))))

(-> editor-select-insert-kind (editor-insert-kind) editor-insert-kind)
(defun editor-select-insert-kind (kind)
  (setf *editor-insert-kind* kind)
  kind)

(-> editor-clamp-insert-menu-selection () nonnegative-integer)
(defun editor-clamp-insert-menu-selection ()
  (setf *editor-insert-menu-selected-index*
        (min (max 0 *editor-insert-menu-selected-index*)
             (1- (length *editor-insert-kinds*)))))

(-> editor-open-insert-menu (&optional editor-insert-action) boolean)
(defun editor-open-insert-menu (&optional (action :insert))
  (let ((position (or (position *editor-insert-kind* *editor-insert-kinds*)
                      0)))
    (setf *editor-mode* :insert
          *editor-insert-action* action
          *editor-insert-menu-selected-index* position
          *editor-status-message*
          (if (eq action :replace)
              "EDITOR: REPLACE TYPE"
              "EDITOR: INSERT TYPE"))
    (play-choice-switch)
    t))

(-> editor-open-replace-menu () boolean)
(defun editor-open-replace-menu ()
  (editor-open-insert-menu :replace))

(-> editor-close-insert-menu (string) boolean)
(defun editor-close-insert-menu (message)
  (setf *editor-mode* :play
        *editor-insert-action* :insert
        *editor-status-message* message)
  (play-choice-switch)
  t)

(-> editor-cancel-insert-menu () boolean)
(defun editor-cancel-insert-menu ()
  (editor-close-insert-menu "EDITOR: INSERT CANCELED"))

(-> editor-move-insert-selection (integer) boolean)
(defun editor-move-insert-selection (direction)
  (setf *editor-insert-menu-selected-index*
        (mod (+ *editor-insert-menu-selected-index* direction)
             (length *editor-insert-kinds*))
        *editor-status-message*
        (format nil "EDITOR: INSERT ~a"
                (editor-insert-kind-label (editor-current-insert-kind))))
  (play-choice-switch)
  t)

(-> editor-cycle-insert-kind () boolean)
(defun editor-cycle-insert-kind ()
  (let* ((position (or (position *editor-insert-kind* *editor-insert-kinds*)
                       0))
         (next-position (mod (1+ position)
                             (length *editor-insert-kinds*)))
         (kind (aref *editor-insert-kinds* next-position)))
    (setf *editor-insert-menu-selected-index* next-position
          *editor-status-message*
          (format nil "EDITOR: INSERT ~a" (editor-insert-kind-label kind)))
    (editor-select-insert-kind kind)
    (play-choice-switch)
    t))
