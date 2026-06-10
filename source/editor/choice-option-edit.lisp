(in-package #:immortal-coil)

;;; Choice option editing

(defparameter *editor-choice-option-value-max-length* 160)

(-> reset-editor-choice-option-edit-state () t)
(defun reset-editor-choice-option-edit-state ()
  (setf *editor-choice-option-node-id* nil
        *editor-choice-option-index* 0
        *editor-choice-option-field-index* 0
        *editor-choice-option-target-kind* :id
        *editor-choice-option-label-buffer* ""
        *editor-choice-option-target-buffer* ""
        *editor-choice-option-visible-buffer* "t"
        *editor-choice-option-enabled-buffer* "t")
  t)

(-> editor-choice-option-selected-field () editor-choice-option-field)
(defun editor-choice-option-selected-field ()
  (aref *editor-choice-option-fields*
        (min (max 0 *editor-choice-option-field-index*)
             (1- (length *editor-choice-option-fields*)))))

(-> editor-choice-target-kind (t) editor-choice-target-kind)
(defun editor-choice-target-kind (target)
  (if (stringp target)
      :id
      :function))

(-> editor-hook-input-string (t) string)
(defun editor-hook-input-string (value)
  (cond
    ((null value)
     "nil")
    ((eq value t)
     "t")
    ((stringp value)
     value)
    ((symbolp value)
     (string-downcase (symbol-name value)))
    ((function-expression-p value)
     (let ((name (second value)))
       (if (symbolp name)
           (string-downcase (symbol-name name))
           "")))
    (t
     "")))

(-> editor-choice-option-target-input (t) string)
(defun editor-choice-option-target-input (target)
  (if (stringp target)
      target
      (editor-hook-input-string target)))

(-> editor-start-choice-option-edit () boolean)
(defun editor-start-choice-option-edit ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (multiple-value-bind (choice choice-index)
            (editor-selected-choice-link node)
          (if (and choice choice-index)
              (progn
                (setf *editor-mode* :edit-choice-option
                      *editor-choice-option-node-id* (node-id node)
                      *editor-choice-option-index* choice-index
                      *editor-choice-option-field-index* 0
                      *editor-choice-option-target-kind*
                      (editor-choice-target-kind (choice-target choice))
                      *editor-choice-option-label-buffer*
                      (choice-label choice)
                      *editor-choice-option-target-buffer*
                      (editor-choice-option-target-input
                       (choice-target choice))
                      *editor-choice-option-visible-buffer*
                      (editor-hook-input-string
                       (choice-condition choice))
                      *editor-choice-option-enabled-buffer*
                      (editor-hook-input-string
                       (choice-enabled-condition choice))
                      *editor-status-message* "EDITOR: EDITING OPTION")
                (play-choice-switch)
                t)
              (progn
                (setf *editor-status-message*
                      "EDITOR: NO VISIBLE OPTION")
                (play-choice-switch)
                nil))))
      nil))

(-> editor-trim-choice-option-input (string) string)
(defun editor-trim-choice-option-input (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> editor-choice-input-symbol (string) symbol)
(defun editor-choice-input-symbol (text)
  (intern (string-upcase text) (find-package "IMMORTAL-COIL")))

(-> editor-choice-option-predicate-value (string) dialog-condition)
(defun editor-choice-option-predicate-value (text)
  (let ((trimmed (editor-trim-choice-option-input text)))
    (cond
      ((or (zerop (length trimmed))
           (string-equal trimmed "t"))
       t)
      ((string-equal trimmed "nil")
       nil)
      (t
       (editor-choice-input-symbol trimmed)))))

(-> editor-choice-option-target-value () (option dialog-target))
(defun editor-choice-option-target-value ()
  (let ((trimmed (editor-trim-choice-option-input
                  *editor-choice-option-target-buffer*)))
    (cond
      ((zerop (length trimmed))
       nil)
      ((eq *editor-choice-option-target-kind* :id)
       trimmed)
      (t
       (editor-choice-input-symbol trimmed)))))

(-> editor-choice-option-label-value () string)
(defun editor-choice-option-label-value ()
  (editor-trim-choice-option-input *editor-choice-option-label-buffer*))

(-> editor-choice-option-target-kind-label () string)
(defun editor-choice-option-target-kind-label ()
  (case *editor-choice-option-target-kind*
    (:function "FUNCTION")
    (t "NODE ID")))

(-> editor-toggle-choice-option-target-kind () boolean)
(defun editor-toggle-choice-option-target-kind ()
  (setf *editor-choice-option-target-kind*
        (case *editor-choice-option-target-kind*
          (:id :function)
          (t :id)))
  (play-choice-switch)
  t)

(-> editor-choice-option-selected-buffer () string)
(defun editor-choice-option-selected-buffer ()
  (case (editor-choice-option-selected-field)
    (:label *editor-choice-option-label-buffer*)
    (:visible *editor-choice-option-visible-buffer*)
    (:enabled *editor-choice-option-enabled-buffer*)
    (:target *editor-choice-option-target-buffer*)
    (t "")))

(defun (setf editor-choice-option-selected-buffer) (value)
  (case (editor-choice-option-selected-field)
    (:label
     (setf *editor-choice-option-label-buffer* value))
    (:visible
     (setf *editor-choice-option-visible-buffer* value))
    (:enabled
     (setf *editor-choice-option-enabled-buffer* value))
    (:target
     (setf *editor-choice-option-target-buffer* value))
    (t
     value)))

(-> editor-choice-option-field-editable-p () boolean)
(defun editor-choice-option-field-editable-p ()
  (not (eq (editor-choice-option-selected-field) :target-kind)))

(-> editor-append-choice-option-character (character) boolean)
(defun editor-append-choice-option-character (char)
  (when (editor-choice-option-field-editable-p)
    (let ((buffer (editor-choice-option-selected-buffer)))
      (and (< (length buffer) *editor-choice-option-value-max-length*)
           (progn
             (setf (editor-choice-option-selected-buffer)
                   (concatenate 'string buffer (string char)))
             (play-input-click)
             t)))))

(-> editor-delete-choice-option-character () boolean)
(defun editor-delete-choice-option-character ()
  (when (editor-choice-option-field-editable-p)
    (let ((buffer (editor-choice-option-selected-buffer)))
      (when (plusp (length buffer))
        (setf (editor-choice-option-selected-buffer)
              (subseq buffer 0 (1- (length buffer))))
        (play-choice-switch)
        t))))

(-> drain-editor-choice-option-input () t)
(defun drain-editor-choice-option-input ()
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-choice-option-character char))
  (when (is-key-pressed-p +key-backspace+)
    (editor-delete-choice-option-character)))

(-> editor-cancel-choice-option-edit () boolean)
(defun editor-cancel-choice-option-edit ()
  (reset-editor-choice-option-edit-state)
  (setf *editor-mode* :play
        *editor-status-message* "EDITOR: OPTION EDIT CANCELED")
  (play-choice-switch)
  t)

(-> editor-append-choice-option-edit
    (dialog-id nonnegative-integer string dialog-target dialog-condition dialog-condition)
    boolean)
(defun editor-append-choice-option-edit (node-id
                                         choice-index
                                         label
                                         target
                                         visible-predicate
                                         enabled-predicate)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; option edit ~d in ~s~%"
                  choice-index
                  node-id)
          (editor-write-set-choice-label-form stream
                                              node-id
                                              choice-index
                                              label)
          (editor-write-set-choice-target-form stream
                                               node-id
                                               choice-index
                                               target)
          (editor-write-set-choice-visible-predicate-form stream
                                                          node-id
                                                          choice-index
                                                          visible-predicate)
          (editor-write-set-choice-enabled-predicate-form stream
                                                          node-id
                                                          choice-index
                                                          enabled-predicate))
        t)
    (error (condition)
      (runtime-warn "Could not append editor option edit: ~a" condition)
      nil)))

(-> editor-apply-choice-option-edit
    (dialog-id nonnegative-integer string dialog-target dialog-condition dialog-condition)
    t)
(defun editor-apply-choice-option-edit (node-id
                                        choice-index
                                        label
                                        target
                                        visible-predicate
                                        enabled-predicate)
  (dialog-set-choice-label node-id choice-index label)
  (dialog-set-choice-target node-id choice-index target)
  (dialog-set-choice-visible-predicate node-id choice-index visible-predicate)
  (dialog-set-choice-enabled-predicate node-id choice-index enabled-predicate)
  (setf *editor-status-message*
        (format nil "EDITOR: OPTION ~d SAVED" (1+ choice-index)))
  (reset-editor-choice-option-edit-state)
  (setf *editor-mode* :play)
  (play-start-confirm)
  t)

(-> editor-save-choice-option-edit () boolean)
(defun editor-save-choice-option-edit ()
  (let ((target (editor-choice-option-target-value))
        (label (editor-choice-option-label-value)))
    (cond
      ((zerop (length label))
       (setf *editor-status-message* "EDITOR: OPTION LABEL REQUIRED")
       (play-choice-switch)
       nil)
      ((not target)
       (setf *editor-status-message* "EDITOR: OPTION TARGET REQUIRED")
       (play-choice-switch)
       nil)
      (t
       (let ((node-id *editor-choice-option-node-id*)
             (choice-index *editor-choice-option-index*)
             (visible-predicate
               (editor-choice-option-predicate-value
                *editor-choice-option-visible-buffer*))
             (enabled-predicate
               (editor-choice-option-predicate-value
                *editor-choice-option-enabled-buffer*)))
         (if (and node-id
                  (editor-append-choice-option-edit node-id
                                                    choice-index
                                                    label
                                                    target
                                                    visible-predicate
                                                    enabled-predicate))
             (editor-apply-choice-option-edit node-id
                                              choice-index
                                              label
                                              target
                                              visible-predicate
                                              enabled-predicate)
             (progn
               (setf *editor-status-message*
                     "EDITOR: OPTION SAVE FAILED")
               (play-choice-switch)
               nil)))))))

(-> update-editor-choice-option-edit () boolean)
(defun update-editor-choice-option-edit ()
  (drain-editor-choice-option-input)
  (let ((panel (active-editor-panel))
        (direction (editor-vertical-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-choice-option-edit))
      ((editor-control-key-pressed-p +key-s+)
       (editor-save-choice-option-edit))
      ((is-key-pressed-p +key-tab+)
       (panel-move-selection panel 1))
      ((and direction
            (panel-move-selection panel direction))
       t)
      ((and (eq (editor-choice-option-selected-field) :target-kind)
            (or (is-key-pressed-p +key-left+)
                (is-key-pressed-p +key-right+)))
       (editor-toggle-choice-option-target-kind))
      ((string-submit-pressed-p)
       (editor-save-choice-option-edit))
      (t t))))


;;; Panel registration

(defclass editor-choice-option-panel (editor-panel) ())

(register-editor-panel
 (make-instance 'editor-choice-option-panel :mode :edit-choice-option))

(defmethod panel-update ((panel editor-choice-option-panel) dt)
  (declare (ignore dt))
  (update-editor-choice-option-edit))

(defmethod panel-save ((panel editor-choice-option-panel))
  (editor-save-choice-option-edit))

(defmethod panel-item-count ((panel editor-choice-option-panel))
  (length *editor-choice-option-fields*))

(defmethod panel-selected-index ((panel editor-choice-option-panel))
  *editor-choice-option-field-index*)

(defmethod (setf panel-selected-index) (value (panel editor-choice-option-panel))
  (setf *editor-choice-option-field-index* value))
