(in-package #:immortal-coil)

;;; Text editing

(-> editor-node-text-editable-p (node) boolean)
(defun editor-node-text-editable-p (node)
  (not (null (member (node-kind node)
                     '(:text :say :choice :number :string :minigame)))))

(-> editor-start-text-edit () boolean)
(defun editor-start-text-edit ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (if (editor-node-text-editable-p node)
            (progn
              (setf *editor-mode* :edit-text
                    *editor-edit-node-id* (node-id node)
                    *editor-text-buffer* (node-text node)
                    *editor-status-message* "EDITOR: EDITING TEXT")
              (play-choice-switch)
              t)
            (progn
              (setf *editor-status-message* "EDITOR: TEXT NOT EDITABLE")
              (play-choice-switch)
              nil)))
      nil))

(-> editor-append-text-character (character) boolean)
(defun editor-append-text-character (char)
  (and (< (length *editor-text-buffer*) *editor-text-max-length*)
       (progn
         (setf *editor-text-buffer*
               (concatenate 'string *editor-text-buffer* (string char)))
         (play-input-click)
         t)))

(-> editor-delete-text-character () boolean)
(defun editor-delete-text-character ()
  (when (plusp (length *editor-text-buffer*))
    (setf *editor-text-buffer*
          (subseq *editor-text-buffer* 0 (1- (length *editor-text-buffer*))))
    (play-choice-switch)
    t))

(-> drain-editor-text-input () t)
(defun drain-editor-text-input ()
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-text-character char))
  (when (is-key-pressed-p +key-backspace+)
    (editor-delete-text-character)))

(-> editor-cancel-text-edit () boolean)
(defun editor-cancel-text-edit ()
  (setf *editor-mode* :play
        *editor-text-buffer* ""
        *editor-edit-node-id* nil
        *editor-status-message* "EDITOR: TEXT EDIT CANCELED")
  (play-choice-switch)
  t)

(-> editor-reset-current-text-display (dialog-id) t)
(defun editor-reset-current-text-display (node-id)
  (when (and *state*
             (equal (play-state-current-id *state*) node-id))
    (setf (play-state-elapsed *state*) 0.0
          (play-state-type-delay *state*) 0.0
          (play-state-visible-count *state*) 0)))

(-> editor-save-text-edit () boolean)
(defun editor-save-text-edit ()
  (let ((node-id *editor-edit-node-id*)
        (text *editor-text-buffer*))
    (if (and node-id
             (node-exists-p node-id)
             (editor-append-text-rewrite node-id text))
        (progn
          (dialog-set-text node-id text)
          (editor-reset-current-text-display node-id)
          (setf *editor-mode* :play
                *editor-text-buffer* ""
                *editor-edit-node-id* nil
                *editor-status-message* "EDITOR: TEXT SAVED")
          (play-start-confirm)
          t)
        (progn
          (setf *editor-status-message* "EDITOR: TEXT SAVE FAILED")
          (play-choice-switch)
          nil))))

(-> update-editor-text-edit () boolean)
(defun update-editor-text-edit ()
  (drain-editor-text-input)
  (cond
    ((is-key-pressed-p +key-escape+)
     (editor-cancel-text-edit))
    ((string-submit-pressed-p)
     (editor-save-text-edit))
    (t t)))


;;; Controls

(-> editor-toggle-store-overlay () boolean)
(defun editor-toggle-store-overlay ()
  (setf *editor-store-overlay-p* (not *editor-store-overlay-p*)
        *editor-status-message*
        (if *editor-store-overlay-p*
            "EDITOR: STATE SHOWN"
            "EDITOR: STATE HIDDEN"))
  (play-choice-switch)
  t)

(-> update-editor-controls () boolean)
(defun update-editor-controls ()
  (when *editor-active-p*
    (if (eq *editor-mode* :edit-text)
        (update-editor-text-edit)
        (cond
          ((is-key-pressed-p +key-page-up+)
           (editor-return-to-previous-node)
           t)
          ((is-key-pressed-p +key-insert+)
           (editor-insert-text-node-after-current))
          ((is-key-pressed-p +key-f2+)
           (editor-start-text-edit))
          ((is-key-pressed-p +key-f3+)
           (editor-toggle-store-overlay))))))
