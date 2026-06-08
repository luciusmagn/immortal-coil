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

(-> editor-active-p () boolean)
(defun editor-active-p ()
  *editor-active-p*)

(-> reset-editor-state () t)
(defun reset-editor-state ()
  (setf *editor-active-p* nil
        *editor-history* nil
        *editor-target-name* nil
        *editor-status-message* nil
        *editor-suppress-history-p* nil)
  t)


;;; Session lifecycle

(-> start-editor-session (&key (:manifest-path t) (:target-name string)) t)
(defun start-editor-session (&key manifest-path target-name)
  (stop-title-music)
  (stop-story-music)
  (load-dialog-graph (list manifest-path))
  (reset-particles)
  (reset-play-state *story-start-node*)
  (dialog-store-clear-history)
  (setf *save-current-game-p* nil
        *editor-active-p* t
        *editor-history* nil
        *editor-target-name* target-name
        *editor-status-message* "EDITOR: PLAYING GRAPH"
        *mode* :game
        *game-fade-elapsed* 0.0
        *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0)
  t)

(-> start-base-game-editor () t)
(defun start-base-game-editor ()
  (start-editor-session :manifest-path "game/manifest.lisp"
                        :target-name "BASE GAME"))


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

(-> update-editor-controls () boolean)
(defun update-editor-controls ()
  (when (and *editor-active-p*
             (is-key-pressed-p +key-page-up+))
    (editor-return-to-previous-node)
    t))


;;; Overlay data

(-> editor-choice-next-id (node) (option dialog-id))
(defun editor-choice-next-id (node)
  (let ((choice (selected-active-choice node)))
    (when choice
      (choice-target choice))))

(-> editor-minigame-next-label (node) (option string))
(defun editor-minigame-next-label (node)
  (format nil "success ~a / failure ~a"
          (node-success-target node)
          (node-failure-target node)))

(-> editor-next-label (node) (option string))
(defun editor-next-label (node)
  (case (node-kind node)
    ((:text :say :conversation)
     (node-next node))
    (:choice
     (editor-choice-next-id node))
    ((:number :string)
     (node-target node))
    (:branch
     (matching-branch-target node))
    (:minigame
     (editor-minigame-next-label node))
    (t nil)))


;;; Rendering

(-> draw-editor-right-text (string scalar nonnegative-integer t) t)
(defun draw-editor-right-text (text y size color)
  (let ((width (text-width text size)))
    (draw-text-at text
                  (- +virtual-width+ 28 width)
                  y
                  size
                  color)))

(-> draw-editor-overlay () t)
(defun draw-editor-overlay ()
  (when (and *editor-active-p* *state*)
    (let* ((node (current-node))
           (color (make-color 255 255 255 178))
           (dim-color (make-color 255 255 255 118))
           (next-label (editor-next-label node)))
      (draw-text-at "EDITOR"
                    28
                    22
                    14
                    color)
      (draw-text-at (format nil "~a" (node-id node))
                    28
                    42
                    12
                    dim-color)
      (when next-label
        (draw-editor-right-text (format nil "NEXT ~a" next-label)
                                22
                                12
                                dim-color))
      (draw-text-at (format nil "PGUP BACK  ~d"
                            (length *editor-history*))
                    28
                    (- +virtual-height+ 34)
                    12
                    dim-color)
      (when *editor-status-message*
        (draw-editor-right-text *editor-status-message*
                                (- +virtual-height+ 34)
                                12
                                dim-color)))))
