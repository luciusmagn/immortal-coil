(in-package #:immortal-coil)

;;; Conversation entry editing

(defparameter *editor-conversation-speaker-max-length* 80)
(defparameter *editor-conversation-text-max-length* 900)

(-> reset-editor-conversation-entry-edit-state () t)
(defun reset-editor-conversation-entry-edit-state ()
  (setf *editor-conversation-entry-node-id* nil
        *editor-conversation-entry-index* 0
        *editor-conversation-entry-field-index* 0
        *editor-conversation-entry-side* :left
        *editor-conversation-entry-speaker-buffer* ""
        *editor-conversation-entry-text-buffer* "")
  t)

(-> editor-conversation-selected-field () editor-conversation-entry-field)
(defun editor-conversation-selected-field ()
  (aref *editor-conversation-entry-fields*
        (min (max 0 *editor-conversation-entry-field-index*)
             (1- (length *editor-conversation-entry-fields*)))))

(-> editor-current-conversation-entry (node)
    (values (option conversation-entry) nonnegative-integer))
(defun editor-current-conversation-entry (node)
  (let ((index (conversation-current-index node)))
    (values (when (plusp (conversation-entry-count node))
              (aref (node-conversation node) index))
            index)))

(-> editor-start-conversation-entry-edit () boolean)
(defun editor-start-conversation-entry-edit ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (if (eq (node-kind node) :conversation)
            (multiple-value-bind (entry index)
                (editor-current-conversation-entry node)
              (if entry
                  (progn
                    (setf *editor-mode* :edit-conversation-entry
                          *editor-conversation-entry-node-id* (node-id node)
                          *editor-conversation-entry-index* index
                          *editor-conversation-entry-field-index* 0
                          *editor-conversation-entry-side*
                          (conversation-entry-side entry)
                          *editor-conversation-entry-speaker-buffer*
                          (conversation-entry-speaker entry)
                          *editor-conversation-entry-text-buffer*
                          (conversation-entry-text entry)
                          *editor-status-message*
                          "EDITOR: EDITING CONVERSATION LINE")
                    (play-choice-switch)
                    t)
                  (progn
                    (setf *editor-status-message*
                          "EDITOR: CONVERSATION IS EMPTY")
                    (play-choice-switch)
                    nil)))
            (progn
              (setf *editor-status-message*
                    "EDITOR: NOT A CONVERSATION NODE")
              (play-choice-switch)
              nil)))
      nil))

(-> editor-trim-conversation-input (string) string)
(defun editor-trim-conversation-input (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> editor-conversation-selected-buffer () string)
(defun editor-conversation-selected-buffer ()
  (case (editor-conversation-selected-field)
    (:speaker *editor-conversation-entry-speaker-buffer*)
    (:text *editor-conversation-entry-text-buffer*)
    (t "")))

(defun (setf editor-conversation-selected-buffer) (value)
  (case (editor-conversation-selected-field)
    (:speaker
     (setf *editor-conversation-entry-speaker-buffer* value))
    (:text
     (setf *editor-conversation-entry-text-buffer* value))
    (t
     value)))

(-> editor-conversation-field-editable-p () boolean)
(defun editor-conversation-field-editable-p ()
  (not (eq (editor-conversation-selected-field) :side)))

(-> editor-conversation-selected-max-length () nonnegative-integer)
(defun editor-conversation-selected-max-length ()
  (case (editor-conversation-selected-field)
    (:text *editor-conversation-text-max-length*)
    (t *editor-conversation-speaker-max-length*)))

(-> editor-append-conversation-character (character) boolean)
(defun editor-append-conversation-character (char)
  (when (editor-conversation-field-editable-p)
    (let ((buffer (editor-conversation-selected-buffer)))
      (and (< (length buffer)
              (editor-conversation-selected-max-length))
           (progn
             (setf (editor-conversation-selected-buffer)
                   (concatenate 'string buffer (string char)))
             (play-input-click)
             t)))))

(-> editor-delete-conversation-character () boolean)
(defun editor-delete-conversation-character ()
  (when (editor-conversation-field-editable-p)
    (let ((buffer (editor-conversation-selected-buffer)))
      (when (plusp (length buffer))
        (setf (editor-conversation-selected-buffer)
              (subseq buffer 0 (1- (length buffer))))
        (play-choice-switch)
        t))))

(-> drain-editor-conversation-input () t)
(defun drain-editor-conversation-input ()
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-conversation-character char))
  (when (is-key-pressed-p +key-backspace+)
    (editor-delete-conversation-character)))

(-> editor-toggle-conversation-side () boolean)
(defun editor-toggle-conversation-side ()
  (setf *editor-conversation-entry-side*
        (case *editor-conversation-entry-side*
          (:left :right)
          (t :left)))
  (play-choice-switch)
  t)

(-> editor-write-set-conversation-entry-form
    (t dialog-id nonnegative-integer conversation-side string string)
    t)
(defun editor-write-set-conversation-entry-form (stream
                                                 node-id
                                                 entry-index
                                                 side
                                                 speaker
                                                 text)
  (format stream
          "~&(dialog-set-conversation-entry ~s ~d ~s ~s~%                               ~s)~2%"
          node-id
          entry-index
          side
          speaker
          text))

(-> editor-write-insert-conversation-entry-form
    (t dialog-id nonnegative-integer conversation-side string string)
    t)
(defun editor-write-insert-conversation-entry-form (stream
                                                    node-id
                                                    entry-index
                                                    side
                                                    speaker
                                                    text)
  (format stream
          "~&(dialog-insert-conversation-entry ~s ~d ~s ~s~%                                  ~s)~2%"
          node-id
          entry-index
          side
          speaker
          text))

(-> editor-append-conversation-entry-edit
    (dialog-id nonnegative-integer conversation-side string string)
    boolean)
(defun editor-append-conversation-entry-edit (node-id
                                              entry-index
                                              side
                                              speaker
                                              text)
  (handler-case
      (let ((path (editor-append-pathname node-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: conversation entry edit ~d in ~s~%"
                  entry-index
                  node-id)
          (editor-write-set-conversation-entry-form stream
                                                    node-id
                                                    entry-index
                                                    side
                                                    speaker
                                                    text))
        t)
    (error (condition)
      (runtime-warn "Could not append editor conversation edit: ~a" condition)
      nil)))

(-> editor-append-conversation-entry-insert
    (dialog-id nonnegative-integer conversation-side string string)
    boolean)
(defun editor-append-conversation-entry-insert (node-id
                                                entry-index
                                                side
                                                speaker
                                                text)
  (handler-case
      (let ((path (editor-append-pathname node-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: conversation entry insert ~d in ~s~%"
                  entry-index
                  node-id)
          (editor-write-insert-conversation-entry-form stream
                                                       node-id
                                                       entry-index
                                                       side
                                                       speaker
                                                       text))
        t)
    (error (condition)
      (runtime-warn "Could not append editor conversation insert: ~a"
                    condition)
      nil)))

(-> editor-reset-conversation-entry-display
    (dialog-id nonnegative-integer)
    t)
(defun editor-reset-conversation-entry-display (node-id entry-index)
  (when (and *state*
             (equal (play-state-current-id *state*) node-id))
    (setf (play-state-conversation-index *state*) entry-index
          (play-state-elapsed *state*) 0.0
          (play-state-type-delay *state*) 0.0
          (play-state-visible-count *state*) 0))
  t)

(-> editor-apply-conversation-entry-edit
    (dialog-id nonnegative-integer conversation-side string string)
    t)
(defun editor-apply-conversation-entry-edit (node-id
                                             entry-index
                                             side
                                             speaker
                                             text)
  (dialog-set-conversation-entry node-id entry-index side speaker text)
  (editor-reset-conversation-entry-display node-id entry-index)
  (setf *editor-status-message*
        (format nil "EDITOR: CONVERSATION LINE ~d SAVED"
                (1+ entry-index)))
  (reset-editor-conversation-entry-edit-state)
  (setf *editor-mode* :play)
  (play-start-confirm)
  t)

(-> editor-conversation-entry-text-value () string)
(defun editor-conversation-entry-text-value ()
  (editor-trim-conversation-input *editor-conversation-entry-text-buffer*))

(-> editor-conversation-entry-speaker-value () string)
(defun editor-conversation-entry-speaker-value ()
  (editor-trim-conversation-input
   *editor-conversation-entry-speaker-buffer*))

(-> editor-save-conversation-entry-edit () boolean)
(defun editor-save-conversation-entry-edit ()
  (let ((node-id *editor-conversation-entry-node-id*)
        (entry-index *editor-conversation-entry-index*)
        (side *editor-conversation-entry-side*)
        (speaker (editor-conversation-entry-speaker-value))
        (text (editor-conversation-entry-text-value)))
    (cond
      ((zerop (length text))
       (setf *editor-status-message* "EDITOR: CONVERSATION TEXT REQUIRED")
       (play-choice-switch)
       nil)
      ((and node-id
            (editor-append-conversation-entry-edit node-id
                                                   entry-index
                                                   side
                                                   speaker
                                                   text))
       (editor-apply-conversation-entry-edit node-id
                                             entry-index
                                             side
                                             speaker
                                             text))
      (t
       (setf *editor-status-message*
             "EDITOR: CONVERSATION SAVE FAILED")
       (play-choice-switch)
       nil))))

(-> editor-cancel-conversation-entry-edit () boolean)
(defun editor-cancel-conversation-entry-edit ()
  (reset-editor-conversation-entry-edit-state)
  (setf *editor-mode* :play
        *editor-status-message* "EDITOR: CONVERSATION EDIT CANCELED")
  (play-choice-switch)
  t)

(-> update-editor-conversation-entry-edit () boolean)
(defun update-editor-conversation-entry-edit ()
  (drain-editor-conversation-input)
  (let ((panel (active-editor-panel))
        (direction (editor-vertical-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-conversation-entry-edit))
      ((editor-control-key-pressed-p +key-s+)
       (editor-save-conversation-entry-edit))
      ((is-key-pressed-p +key-tab+)
       (panel-move-selection panel 1))
      ((and direction
            (panel-move-selection panel direction))
       t)
      ((and (eq (editor-conversation-selected-field) :side)
            (or (is-key-pressed-p +key-left+)
                (is-key-pressed-p +key-right+)))
       (editor-toggle-conversation-side))
      ((string-submit-pressed-p)
       (editor-save-conversation-entry-edit))
      (t t))))

(-> editor-next-conversation-side (node) conversation-side)
(defun editor-next-conversation-side (node)
  (multiple-value-bind (entry index)
      (editor-current-conversation-entry node)
    (declare (ignore index))
    (case (and entry (conversation-entry-side entry))
      (:left :right)
      (t :left))))

(-> editor-conversation-insert-index (node) nonnegative-integer)
(defun editor-conversation-insert-index (node)
  (if (plusp (conversation-entry-count node))
      (1+ (conversation-current-index node))
      0))

(-> editor-add-conversation-entry-after-current () boolean)
(defun editor-add-conversation-entry-after-current ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (if (eq (node-kind node) :conversation)
            (let* ((node-id (node-id node))
                   (entry-index (editor-conversation-insert-index node))
                   (side (editor-next-conversation-side node))
                   (speaker (string-downcase (symbol-name side)))
                   (text "new line."))
              (if (editor-append-conversation-entry-insert node-id
                                                           entry-index
                                                           side
                                                           speaker
                                                           text)
                  (progn
                    (dialog-insert-conversation-entry node-id
                                                      entry-index
                                                      side
                                                      speaker
                                                      text)
                    (editor-reset-conversation-entry-display node-id
                                                             entry-index)
                    (setf *editor-status-message*
                          (format nil "EDITOR: ADDED LINE ~d"
                                  (1+ entry-index)))
                    (play-start-confirm)
                    (editor-start-conversation-entry-edit)
                    t)
                  (progn
                    (setf *editor-status-message*
                          "EDITOR: CONVERSATION INSERT FAILED")
                    (play-choice-switch)
                    nil)))
            (progn
              (setf *editor-status-message*
                    "EDITOR: ADD LINE NEEDS CONVERSATION NODE")
              (play-choice-switch)
              nil)))
      nil))

(defgeneric node-start-detail-edit (node)
  (:documentation "Open the detail editor panel that fits NODE.
Panels register their methods next to their own start functions.")
  (:method ((node node))
    (declare (ignore node))
    (if (fboundp 'editor-start-node-fields-edit)
        (funcall (symbol-function 'editor-start-node-fields-edit))
        (progn
          (setf *editor-status-message* "EDITOR: NO NODE DETAILS")
          (play-choice-switch)
          nil)))
  (:method ((node conversation-node))
    (editor-start-conversation-entry-edit))
  (:method ((node choice-node))
    (editor-start-choice-option-edit)))

(-> editor-start-node-detail-edit () boolean)
(defun editor-start-node-detail-edit ()
  (if (and *editor-active-p* *state*)
      (node-start-detail-edit (current-node))
      nil))

(defgeneric node-add-detail (node)
  (:documentation "Add the natural detail row for NODE.")
  (:method ((node node))
    (editor-add-choice-option-to-current))
  (:method ((node conversation-node))
    (editor-add-conversation-entry-after-current)))

(-> editor-add-node-detail () boolean)
(defun editor-add-node-detail ()
  (if (and *editor-active-p* *state*)
      (node-add-detail (current-node))
      nil))


;;; Panel registration

(defclass editor-conversation-entry-panel (editor-panel) ())

(register-editor-panel
 (make-instance 'editor-conversation-entry-panel
                :mode :edit-conversation-entry))

(defmethod panel-update ((panel editor-conversation-entry-panel) dt)
  (declare (ignore dt))
  (update-editor-conversation-entry-edit))

(defmethod panel-save ((panel editor-conversation-entry-panel))
  (editor-save-conversation-entry-edit))

(defmethod panel-item-count ((panel editor-conversation-entry-panel))
  (length *editor-conversation-entry-fields*))

(defmethod panel-selected-index ((panel editor-conversation-entry-panel))
  *editor-conversation-entry-field-index*)

(defmethod (setf panel-selected-index)
    (value (panel editor-conversation-entry-panel))
  (setf *editor-conversation-entry-field-index* value))
