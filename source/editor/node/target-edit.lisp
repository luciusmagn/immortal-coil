(in-package #:immortal-coil)

;;; Node target editing

(defparameter *editor-node-target-value-max-length* 180)

(-> reset-editor-node-target-edit-state () t)
(defun reset-editor-node-target-edit-state ()
  (setf *editor-node-target-node-id* nil
        *editor-node-target-field-index* 0)
  (clrhash *editor-node-target-value-buffers*)
  (clrhash *editor-node-target-kind-buffers*)
  t)

(defgeneric node-target-fields (node)
  (:documentation "Editable link fields for NODE in the target editor.")
  (:method ((node node)) #())
  (:method ((node linear-node)) #(:next))
  (:method ((node input-node)) #(:target))
  (:method ((node minigame-node)) #(:success :failure)))

(-> editor-node-target-fields (node) vector)
(defun editor-node-target-fields (node)
  (node-target-fields node))

(-> editor-node-target-field-count () nonnegative-integer)
(defun editor-node-target-field-count ()
  (if (and *editor-node-target-node-id*
           (node-exists-p *editor-node-target-node-id*))
      (length (editor-node-target-fields
               (find-node *editor-node-target-node-id*)))
      0))

(-> editor-node-target-selected-field () (option editor-node-target-field))
(defun editor-node-target-selected-field ()
  (let ((count (editor-node-target-field-count)))
    (when (plusp count)
      (let ((fields (editor-node-target-fields
                     (find-node *editor-node-target-node-id*))))
        (aref fields
              (min (max 0 *editor-node-target-field-index*)
                   (1- count)))))))

(-> editor-node-target-field-value (node editor-node-target-field) (option t))
(defun editor-node-target-field-value (node field)
  (case field
    (:next (node-next node))
    (:target (node-target node))
    (:success (node-success-target node))
    (:failure (node-failure-target node))))

(-> editor-node-target-field-required-p (node editor-node-target-field)
    boolean)
(defun editor-node-target-field-required-p (node field)
  (declare (ignore node))
  (not (eq field :next)))

(-> editor-node-target-buffer-value (editor-node-target-field) string)
(defun editor-node-target-buffer-value (field)
  (gethash field *editor-node-target-value-buffers* ""))

(defun (setf editor-node-target-buffer-value) (value field)
  (setf (gethash field *editor-node-target-value-buffers*) value))

(-> editor-node-target-buffer-kind (editor-node-target-field)
    editor-choice-target-kind)
(defun editor-node-target-buffer-kind (field)
  (gethash field *editor-node-target-kind-buffers* :id))

(defun (setf editor-node-target-buffer-kind) (value field)
  (setf (gethash field *editor-node-target-kind-buffers*) value))

(-> editor-node-target-prime-field (node editor-node-target-field) t)
(defun editor-node-target-prime-field (node field)
  (let ((target (editor-node-target-field-value node field)))
    (setf (editor-node-target-buffer-kind field)
          (editor-choice-target-kind target)
          (editor-node-target-buffer-value field)
          (editor-choice-option-target-input target)))
  t)

(-> editor-start-node-target-edit () boolean)
(defun editor-start-node-target-edit ()
  (if (and *editor-active-p* *state*)
      (let* ((node (current-node))
             (fields (editor-node-target-fields node)))
        (if (plusp (length fields))
            (progn
              (reset-editor-node-target-edit-state)
              (setf *editor-mode* :edit-node-target
                    *editor-node-target-node-id* (node-id node)
                    *editor-node-target-field-index* 0
                    *editor-status-message* "EDITOR: EDITING LINKS")
              (loop for field across fields
                    do (editor-node-target-prime-field node field))
              (play-choice-switch)
              t)
            (progn
              (setf *editor-status-message*
                    "EDITOR: NODE HAS NO EDITABLE LINKS")
              (play-choice-switch)
              nil)))
      nil))

(-> editor-node-target-selected-buffer () string)
(defun editor-node-target-selected-buffer ()
  (let ((field (editor-node-target-selected-field)))
    (if field
        (editor-node-target-buffer-value field)
        "")))

(defun (setf editor-node-target-selected-buffer) (value)
  (let ((field (editor-node-target-selected-field)))
    (if field
        (setf (editor-node-target-buffer-value field) value)
        value)))

(-> editor-append-node-target-character (character) boolean)
(defun editor-append-node-target-character (char)
  (let ((buffer (editor-node-target-selected-buffer)))
    (and (< (length buffer) *editor-node-target-value-max-length*)
         (progn
           (setf (editor-node-target-selected-buffer)
                 (concatenate 'string buffer (string char)))
           (play-input-click)
           t))))

(-> editor-delete-node-target-character () boolean)
(defun editor-delete-node-target-character ()
  (let ((buffer (editor-node-target-selected-buffer)))
    (when (plusp (length buffer))
      (setf (editor-node-target-selected-buffer)
            (subseq buffer 0 (1- (length buffer))))
      (play-choice-switch)
      t)))

(-> drain-editor-node-target-input () t)
(defun drain-editor-node-target-input ()
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-node-target-character char))
  (when (is-key-pressed-p +key-backspace+)
    (editor-delete-node-target-character)))

(-> editor-toggle-node-target-kind () boolean)
(defun editor-toggle-node-target-kind ()
  (let ((field (editor-node-target-selected-field)))
    (when field
      (setf (editor-node-target-buffer-kind field)
            (case (editor-node-target-buffer-kind field)
              (:id :function)
              (t :id)))
      (play-choice-switch)
      t)))

(-> editor-node-target-trim (string) string)
(defun editor-node-target-trim (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> editor-node-target-field-target-value
    (editor-node-target-field)
    (option dialog-target))
(defun editor-node-target-field-target-value (field)
  (let ((trimmed (editor-node-target-trim
                  (editor-node-target-buffer-value field))))
    (cond
      ((zerop (length trimmed))
       nil)
      ((eq (editor-node-target-buffer-kind field) :id)
       trimmed)
      (t
       (editor-choice-input-symbol trimmed)))))

(-> editor-node-target-field-valid-p
    (node editor-node-target-field)
    boolean)
(defun editor-node-target-field-valid-p (node field)
  (or (not (editor-node-target-field-required-p node field))
      (not (null (editor-node-target-field-target-value field)))))

(-> editor-write-set-node-target-field-form
    (t dialog-id editor-node-target-field (option dialog-target))
    t)
(defun editor-write-set-node-target-field-form (stream node-id field target)
  (case field
    (:next
     (editor-write-set-next-form stream node-id target))
    (:target
     (format stream "~&(dialog-set-target ~s " node-id)
     (editor-write-target stream target)
     (format stream ")~2%"))
    (:success
     (format stream "~&(dialog-set-minigame-success ~s " node-id)
     (editor-write-target stream target)
     (format stream ")~2%"))
    (:failure
     (format stream "~&(dialog-set-minigame-failure ~s " node-id)
     (editor-write-target stream target)
     (format stream ")~2%"))))

(-> editor-append-node-target-edit
    (dialog-id node)
    boolean)
(defun editor-append-node-target-edit (node-id node)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; link edit for ~s~%" node-id)
          (loop for field across (editor-node-target-fields node)
                do (editor-write-set-node-target-field-form
                    stream
                    node-id
                    field
                    (editor-node-target-field-target-value field))))
        t)
    (error (condition)
      (runtime-warn "Could not append editor link edit: ~a" condition)
      nil)))

(-> editor-apply-node-target-field
    (dialog-id editor-node-target-field (option dialog-target))
    t)
(defun editor-apply-node-target-field (node-id field target)
  (case field
    (:next
     (dialog-set-next node-id target))
    (:target
     (when target
       (dialog-set-target node-id target)))
    (:success
     (when target
       (dialog-set-minigame-success node-id target)))
    (:failure
     (when target
       (dialog-set-minigame-failure node-id target))))
  t)

(-> editor-apply-node-target-edit (dialog-id node) t)
(defun editor-apply-node-target-edit (node-id node)
  (loop for field across (editor-node-target-fields node)
        do (editor-apply-node-target-field
            node-id
            field
            (editor-node-target-field-target-value field)))
  (setf *editor-status-message* "EDITOR: LINKS SAVED")
  (reset-editor-node-target-edit-state)
  (setf *editor-mode* :play)
  (play-start-confirm)
  t)

(-> editor-save-node-target-edit () boolean)
(defun editor-save-node-target-edit ()
  (let* ((node-id *editor-node-target-node-id*)
         (node (and node-id
                    (node-exists-p node-id)
                    (find-node node-id))))
    (cond
      ((null node)
       (setf *editor-status-message* "EDITOR: NODE MISSING")
       (play-choice-switch)
       nil)
      ((not (loop for field across (editor-node-target-fields node)
                  always (editor-node-target-field-valid-p node field)))
       (setf *editor-status-message* "EDITOR: REQUIRED LINK MISSING")
       (play-choice-switch)
       nil)
      ((editor-append-node-target-edit node-id node)
       (editor-apply-node-target-edit node-id node))
      (t
       (setf *editor-status-message* "EDITOR: LINK SAVE FAILED")
       (play-choice-switch)
       nil))))

(-> editor-cancel-node-target-edit () boolean)
(defun editor-cancel-node-target-edit ()
  (reset-editor-node-target-edit-state)
  (setf *editor-mode* :play
        *editor-status-message* "EDITOR: LINK EDIT CANCELED")
  (play-choice-switch)
  t)

(-> update-editor-node-target-edit () boolean)
(defun update-editor-node-target-edit ()
  (drain-editor-node-target-input)
  (let ((panel (active-editor-panel))
        (direction (editor-vertical-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-node-target-edit))
      ((editor-control-key-pressed-p +key-s+)
       (editor-save-node-target-edit))
      ((is-key-pressed-p +key-tab+)
       (panel-move-selection panel 1))
      ((and direction
            (panel-move-selection panel direction))
       t)
      ((or (is-key-pressed-p +key-left+)
           (is-key-pressed-p +key-right+))
       (editor-toggle-node-target-kind))
      ((string-submit-pressed-p)
       (editor-save-node-target-edit))
      (t t))))


;;; Panel registration

(defclass editor-node-target-panel (editor-panel) ())

(register-editor-panel
 (make-instance 'editor-node-target-panel :mode :edit-node-target))

(defmethod panel-update ((panel editor-node-target-panel) dt)
  (declare (ignore dt))
  (update-editor-node-target-edit))

(defmethod panel-save ((panel editor-node-target-panel))
  (editor-save-node-target-edit))

(defmethod panel-item-count ((panel editor-node-target-panel))
  (editor-node-target-field-count))

(defmethod panel-selected-index ((panel editor-node-target-panel))
  *editor-node-target-field-index*)

(defmethod (setf panel-selected-index) (value (panel editor-node-target-panel))
  (setf *editor-node-target-field-index* value))
