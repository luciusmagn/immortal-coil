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
                    *editor-text-backspace-held-seconds* 0.0
                    *editor-text-backspace-repeat-accumulator* 0.0
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

(-> editor-delete-text-characters (nonnegative-integer) boolean)
(defun editor-delete-text-characters (count)
  (when (and (plusp count)
             (plusp (length *editor-text-buffer*)))
    (let ((new-length (max 0 (- (length *editor-text-buffer*) count))))
      (setf *editor-text-buffer*
            (subseq *editor-text-buffer* 0 new-length)))
    (play-choice-switch)
    t))

(-> reset-editor-text-backspace-repeat () t)
(defun reset-editor-text-backspace-repeat ()
  (setf *editor-text-backspace-held-seconds* 0.0
        *editor-text-backspace-repeat-accumulator* 0.0)
  t)

(-> editor-text-backspace-interval () seconds)
(defun editor-text-backspace-interval ()
  (max 0.025
       (- 0.13 (* *editor-text-backspace-held-seconds* 0.04))))

(-> editor-text-backspace-repeat-count (seconds) nonnegative-integer)
(defun editor-text-backspace-repeat-count (dt)
  (cond
    ((not (is-key-down-p +key-backspace+))
     (reset-editor-text-backspace-repeat)
     0)
    ((is-key-pressed-p +key-backspace+)
     (reset-editor-text-backspace-repeat)
     1)
    (t
     (incf *editor-text-backspace-held-seconds* dt)
     (if (< *editor-text-backspace-held-seconds* 0.26)
         0
         (let ((interval (editor-text-backspace-interval))
               (count 0))
           (incf *editor-text-backspace-repeat-accumulator* dt)
           (loop while (>= *editor-text-backspace-repeat-accumulator*
                           interval)
                 do (incf count)
                    (decf *editor-text-backspace-repeat-accumulator*
                          interval))
           count)))))

(-> editor-delete-text-character () boolean)
(defun editor-delete-text-character ()
  (editor-delete-text-characters 1))

(-> editor-delete-text-repeat (seconds) boolean)
(defun editor-delete-text-repeat (dt)
  (editor-delete-text-characters
   (editor-text-backspace-repeat-count dt)))

(-> drain-editor-text-input (seconds) t)
(defun drain-editor-text-input (dt)
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-text-character char))
  (editor-delete-text-repeat dt))

(-> editor-cancel-text-edit () boolean)
(defun editor-cancel-text-edit ()
  (setf *editor-mode* :play
        *editor-text-buffer* ""
        *editor-edit-node-id* nil
        *editor-text-backspace-held-seconds* 0.0
        *editor-text-backspace-repeat-accumulator* 0.0
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
                *editor-text-backspace-held-seconds* 0.0
                *editor-text-backspace-repeat-accumulator* 0.0
                *editor-status-message* "EDITOR: TEXT SAVED")
          (play-start-confirm)
          t)
        (progn
          (setf *editor-status-message* "EDITOR: TEXT SAVE FAILED")
          (play-choice-switch)
          nil))))

(-> update-editor-text-edit (seconds) boolean)
(defun update-editor-text-edit (dt)
  (drain-editor-text-input dt)
  (cond
    ((or (is-key-pressed-p +key-escape+)
         (editor-control-key-pressed-p +key-g+))
     (editor-cancel-text-edit))
    ((or (string-submit-pressed-p)
         (editor-control-key-pressed-p +key-s+))
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

(-> editor-toggle-help-overlay () boolean)
(defun editor-toggle-help-overlay ()
  (setf *editor-help-overlay-p* (not *editor-help-overlay-p*)
        *editor-status-message*
        (if *editor-help-overlay-p*
            "EDITOR: HELP SHOWN"
            "EDITOR: HELP HIDDEN"))
  (play-choice-switch)
  t)

(-> editor-close-help-overlay () boolean)
(defun editor-close-help-overlay ()
  (setf *editor-help-overlay-p* nil
        *editor-status-message* "EDITOR: HELP HIDDEN")
  (play-choice-switch)
  t)

(-> update-editor-help-overlay-controls () boolean)
(defun update-editor-help-overlay-controls ()
  (cond
    ((editor-control-key-pressed-p +key-h+)
     (editor-toggle-help-overlay))
    (*editor-help-overlay-p*
     (when (or (is-key-pressed-p +key-escape+)
               (editor-control-key-pressed-p +key-g+))
       (editor-close-help-overlay))
     t)
    (t nil)))

(-> editor-insert-selection-direction () (option navigation-direction))
(defun editor-insert-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(-> editor-confirm-insert-menu () boolean)
(defun editor-confirm-insert-menu ()
  (let ((kind (editor-current-insert-kind)))
    (editor-select-insert-kind kind)
    (setf *editor-mode* :play)
    (case *editor-insert-action*
      (:replace
       (setf *editor-insert-action* :insert)
       (editor-replace-current-node kind))
      (t
       (editor-insert-node-at-current-link kind)))))

(-> update-editor-insert-menu () boolean)
(defun update-editor-insert-menu ()
  (let ((direction (editor-insert-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-insert-menu))
      ((and direction
            (editor-move-insert-selection direction))
       t)
      ((confirm-pressed-p)
       (editor-confirm-insert-menu))
      (t t))))

(-> update-editor-controls (&optional seconds) boolean)
(defun update-editor-controls (&optional (dt (get-frame-time)))
  (when *editor-active-p*
    (case *editor-mode*
      (:insert
       (update-editor-insert-menu))
      (:edit-text
       (update-editor-text-edit dt))
      (:edit-store
       (update-editor-store-edit))
      (:edit-choice-option
       (update-editor-choice-option-edit))
      (:edit-conversation-entry
       (update-editor-conversation-entry-edit))
      (t
       (cond
         ((update-editor-help-overlay-controls)
          t)
         ((or (is-key-pressed-p +key-page-up+)
              (editor-control-key-pressed-p +key-b+))
          (editor-return-to-previous-node)
          t)
         ((or (is-key-pressed-p +key-insert+)
              (editor-control-key-pressed-p +key-i+))
          (editor-open-insert-menu))
         ((editor-control-key-pressed-p +key-r+)
          (editor-open-replace-menu))
         ((editor-control-key-pressed-p +key-a+)
          (editor-add-node-detail))
         ((editor-control-key-pressed-p +key-p+)
          (editor-cycle-current-minigame))
         ((editor-control-key-pressed-p +key-f+)
          (editor-cycle-current-particles))
         ((editor-control-key-pressed-p +key-m+)
          (editor-cycle-current-music))
         ((or (is-key-pressed-p +key-f3+)
              (editor-control-key-pressed-p +key-s+))
          (editor-toggle-store-overlay))
         ((update-editor-store-overlay-controls)
          t)
         ((editor-control-key-pressed-p +key-o+)
          (editor-start-node-detail-edit))
         ((and (or (is-key-pressed-p +key-delete+)
                   (editor-control-key-pressed-p +key-d+))
               (not *editor-store-overlay-p*))
          (editor-delete-current-node))
         ((or (is-key-pressed-p +key-f2+)
              (editor-control-key-pressed-p +key-e+))
          (editor-start-text-edit))
         ((is-key-pressed-p +key-f6+)
          (editor-cycle-insert-kind)))))))
