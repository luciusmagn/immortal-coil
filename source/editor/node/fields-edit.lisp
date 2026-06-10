(in-package #:immortal-coil)

;;; Node field editing

(defparameter *editor-node-field-value-max-length* 160)


;;; Field descriptors

(defclass editor-field ()
  ((key
    :initarg :key
    :reader editor-field-key
    :type editor-node-field)
   (label
    :initarg :label
    :reader editor-field-label
    :type string)
   (reader
    :initarg :reader
    :reader editor-field-reader
    :type runtime-function)))

(defclass editor-string-field (editor-field) ())
(defclass editor-optional-number-field (editor-field) ())
(defclass editor-count-field (editor-field) ())
(defclass editor-boolean-field (editor-field) ())
(defclass editor-minigame-field (editor-field) ())

(-> editor-node-field-value-string (t) string)
(defun editor-node-field-value-string (value)
  (cond
    ((null value) "")
    ((keywordp value)
     (string-downcase (prin1-to-string value)))
    (t
     (princ-to-string value))))

(defgeneric field-editable-p (field)
  (:documentation "True when FIELD takes typed input rather than toggling.")
  (:method ((field editor-field)) t)
  (:method ((field editor-boolean-field)) nil))

(defgeneric field-prime-string (field node)
  (:documentation "Initial buffer content for FIELD read from NODE.")
  (:method ((field editor-field) node)
    (editor-node-field-value-string
     (funcall (editor-field-reader field) node)))
  (:method ((field editor-boolean-field) node)
    (if (funcall (editor-field-reader field) node) "t" "nil")))


;;; Field instances and per-node field sets

(defparameter *editor-speaker-field*
  (make-instance 'editor-string-field
                 :key :speaker
                 :label "SPEAKER"
                 :reader #'node-speaker))

(defparameter *editor-response-key-field*
  (make-instance 'editor-string-field
                 :key :response-key
                 :label "RESPONSE KEY"
                 :reader #'node-response-key))

(defparameter *editor-min-value-field*
  (make-instance 'editor-optional-number-field
                 :key :min-value
                 :label "MIN"
                 :reader #'node-min-value))

(defparameter *editor-max-value-field*
  (make-instance 'editor-optional-number-field
                 :key :max-value
                 :label "MAX"
                 :reader #'node-max-value))

(defparameter *editor-max-length-field*
  (make-instance 'editor-count-field
                 :key :max-length
                 :label "MAX LENGTH"
                 :reader #'node-max-length))

(defparameter *editor-allow-empty-field*
  (make-instance 'editor-boolean-field
                 :key :allow-empty
                 :label "ALLOW EMPTY"
                 :reader #'node-allow-empty-p))

(defparameter *editor-minigame-id-field*
  (make-instance 'editor-minigame-field
                 :key :minigame
                 :label "MINIGAME"
                 :reader #'node-minigame))

(defgeneric node-editable-fields (node)
  (:documentation "Editor detail field descriptors for NODE.")
  (:method ((node node))
    #())
  (:method ((node say-node))
    (vector *editor-speaker-field*))
  (:method ((node number-input-node))
    (vector *editor-response-key-field*
            *editor-min-value-field*
            *editor-max-value-field*))
  (:method ((node string-input-node))
    (vector *editor-response-key-field*
            *editor-max-length-field*
            *editor-allow-empty-field*))
  (:method ((node minigame-node))
    (vector *editor-minigame-id-field*)))

(-> editor-node-fields (node) vector)
(defun editor-node-fields (node)
  (node-editable-fields node))


;;; Edit state

(-> reset-editor-node-fields-edit-state () t)
(defun reset-editor-node-fields-edit-state ()
  (setf *editor-node-fields-node-id* nil
        *editor-node-fields-field-index* 0)
  (clrhash *editor-node-fields-buffers*)
  t)

(-> editor-node-fields-count () nonnegative-integer)
(defun editor-node-fields-count ()
  (if (and *editor-node-fields-node-id*
           (node-exists-p *editor-node-fields-node-id*))
      (length (editor-node-fields (find-node *editor-node-fields-node-id*)))
      0))

(-> editor-node-selected-field () (option editor-field))
(defun editor-node-selected-field ()
  (let ((count (editor-node-fields-count)))
    (when (plusp count)
      (let ((fields (editor-node-fields
                     (find-node *editor-node-fields-node-id*))))
        (aref fields
              (min (max 0 *editor-node-fields-field-index*)
                   (1- count)))))))

(-> editor-node-field-buffer (editor-node-field) string)
(defun editor-node-field-buffer (key)
  (gethash key *editor-node-fields-buffers* ""))

(defun (setf editor-node-field-buffer) (value key)
  (setf (gethash key *editor-node-fields-buffers*) value))

(-> editor-field-buffer (editor-field) string)
(defun editor-field-buffer (field)
  (editor-node-field-buffer (editor-field-key field)))

(-> editor-node-field-prime (node editor-field) t)
(defun editor-node-field-prime (node field)
  (setf (editor-node-field-buffer (editor-field-key field))
        (field-prime-string field node))
  t)

(-> editor-start-node-fields-edit () boolean)
(defun editor-start-node-fields-edit ()
  (if (and *editor-active-p* *state*)
      (let* ((node (current-node))
             (fields (editor-node-fields node)))
        (if (plusp (length fields))
            (progn
              (reset-editor-node-fields-edit-state)
              (setf *editor-mode* :edit-node-fields
                    *editor-node-fields-node-id* (node-id node)
                    *editor-node-fields-field-index* 0
                    *editor-status-message* "EDITOR: EDITING DETAILS")
              (loop for field across fields
                    do (editor-node-field-prime node field))
              (play-choice-switch)
              t)
            (progn
              (setf *editor-status-message* "EDITOR: NO NODE DETAILS")
              (play-choice-switch)
              nil)))
      nil))

(defmethod node-start-detail-edit ((node say-node))
  (editor-start-node-fields-edit))

(defmethod node-start-detail-edit ((node input-node))
  (editor-start-node-fields-edit))

(defmethod node-start-detail-edit ((node minigame-node))
  (editor-start-node-fields-edit))

(-> editor-node-field-trim (string) string)
(defun editor-node-field-trim (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> editor-node-selected-field-editable-p () boolean)
(defun editor-node-selected-field-editable-p ()
  (let ((field (editor-node-selected-field)))
    (and field
         (field-editable-p field))))

(-> editor-node-selected-field-buffer () string)
(defun editor-node-selected-field-buffer ()
  (let ((field (editor-node-selected-field)))
    (if field
        (editor-field-buffer field)
        "")))

(defun (setf editor-node-selected-field-buffer) (value)
  (let ((field (editor-node-selected-field)))
    (if field
        (setf (editor-node-field-buffer (editor-field-key field)) value)
        value)))

(-> editor-append-node-field-character (character) boolean)
(defun editor-append-node-field-character (char)
  (when (editor-node-selected-field-editable-p)
    (let ((buffer (editor-node-selected-field-buffer)))
      (and (< (length buffer) *editor-node-field-value-max-length*)
           (progn
             (setf (editor-node-selected-field-buffer)
                   (concatenate 'string buffer (string char)))
             (play-input-click)
             t)))))

(-> editor-delete-node-field-character () boolean)
(defun editor-delete-node-field-character ()
  (when (editor-node-selected-field-editable-p)
    (let ((buffer (editor-node-selected-field-buffer)))
      (when (plusp (length buffer))
        (setf (editor-node-selected-field-buffer)
              (subseq buffer 0 (1- (length buffer))))
        (play-choice-switch)
        t))))

(-> drain-editor-node-fields-input () t)
(defun drain-editor-node-fields-input ()
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-node-field-character char))
  (when (is-key-pressed-p +key-backspace+)
    (editor-delete-node-field-character)))


;;; Buffer parsing

(-> editor-node-field-parse-integer (string) (option integer))
(defun editor-node-field-parse-integer (text)
  (let ((trimmed (editor-node-field-trim text)))
    (unless (zerop (length trimmed))
      (handler-case
          (multiple-value-bind (value end)
              (parse-integer trimmed)
            (when (= end (length trimmed))
              value))
        (error () nil)))))

(-> editor-node-field-parse-optional-number (editor-node-field)
    (values boolean (option number)))
(defun editor-node-field-parse-optional-number (key)
  (let* ((raw (editor-node-field-buffer key))
         (trimmed (editor-node-field-trim raw)))
    (cond
      ((or (zerop (length trimmed))
           (string-equal trimmed "nil"))
       (values t nil))
      (t
       (let ((value (editor-node-field-parse-integer raw)))
         (values (not (null value)) value))))))

(-> editor-node-field-parse-required-nonnegative
    (editor-node-field)
    (values boolean nonnegative-integer))
(defun editor-node-field-parse-required-nonnegative (key)
  (let ((value (editor-node-field-parse-integer
                (editor-node-field-buffer key))))
    (values (and value (>= value 0))
            (or value 0))))

(-> editor-node-field-parse-boolean (editor-node-field)
    (values boolean boolean))
(defun editor-node-field-parse-boolean (key)
  (let ((value (editor-node-field-trim (editor-node-field-buffer key))))
    (cond
      ((member value '("t" "true" "yes" "1") :test #'string-equal)
       (values t t))
      ((member value '("nil" "false" "no" "0" "") :test #'string-equal)
       (values t nil))
      (t
       (values nil nil)))))

(-> editor-node-field-keyword-value (editor-node-field)
    (option minigame-id))
(defun editor-node-field-keyword-value (key)
  (let ((value (editor-node-field-trim (editor-node-field-buffer key))))
    (unless (zerop (length value))
      (let ((name (if (char= (char value 0) #\:)
                      (subseq value 1)
                      value)))
        (when (plusp (length name))
          (intern (string-upcase name) :keyword))))))

(-> editor-node-field-text-value (editor-node-field) string)
(defun editor-node-field-text-value (key)
  (editor-node-field-trim (editor-node-field-buffer key)))


;;; Per-kind validation, draft writing, and apply

(defgeneric node-fields-valid-p (node)
  (:documentation "True when the edited detail buffers parse for NODE.")
  (:method ((node node))
    t)
  (:method ((node number-input-node))
    (multiple-value-bind (min-valid-p min-value)
        (editor-node-field-parse-optional-number :min-value)
      (multiple-value-bind (max-valid-p max-value)
          (editor-node-field-parse-optional-number :max-value)
        (and (plusp (length (editor-node-field-text-value :response-key)))
             min-valid-p
             max-valid-p
             (or (not (and min-value max-value))
                 (<= min-value max-value))))))
  (:method ((node string-input-node))
    (multiple-value-bind (length-valid-p max-length)
        (editor-node-field-parse-required-nonnegative :max-length)
      (multiple-value-bind (boolean-valid-p allow-empty-p)
          (editor-node-field-parse-boolean :allow-empty)
        (declare (ignore allow-empty-p))
        (and (plusp (length (editor-node-field-text-value :response-key)))
             length-valid-p
             (plusp max-length)
             boolean-valid-p))))
  (:method ((node minigame-node))
    (not (null (editor-node-field-keyword-value :minigame)))))

(defgeneric node-fields-invalid-message (node)
  (:documentation "Status line shown when NODE's detail buffers do not parse.")
  (:method ((node node))
    "EDITOR: DETAILS INVALID")
  (:method ((node number-input-node))
    "EDITOR: RESPONSE KEY OR BOUNDS INVALID")
  (:method ((node string-input-node))
    "EDITOR: STRING FIELD INVALID")
  (:method ((node minigame-node))
    "EDITOR: MINIGAME REQUIRED"))

(defgeneric node-write-fields-edit (node stream)
  (:documentation "Write the detail edit for NODE as draft setter forms.")
  (:method ((node node) stream)
    (declare (ignore stream))
    nil)
  (:method ((node say-node) stream)
    (format stream "~&(dialog-set-speaker ~s ~s)~2%"
            (node-id node)
            (editor-node-field-text-value :speaker)))
  (:method ((node number-input-node) stream)
    (multiple-value-bind (min-valid-p min-value)
        (editor-node-field-parse-optional-number :min-value)
      (declare (ignore min-valid-p))
      (multiple-value-bind (max-valid-p max-value)
          (editor-node-field-parse-optional-number :max-value)
        (declare (ignore max-valid-p))
        (format stream "~&(dialog-set-response-key ~s ~s)~%"
                (node-id node)
                (editor-node-field-text-value :response-key))
        (format stream "(dialog-set-number-bounds ~s ~s ~s)~2%"
                (node-id node)
                min-value
                max-value))))
  (:method ((node string-input-node) stream)
    (multiple-value-bind (length-valid-p max-length)
        (editor-node-field-parse-required-nonnegative :max-length)
      (declare (ignore length-valid-p))
      (multiple-value-bind (boolean-valid-p allow-empty-p)
          (editor-node-field-parse-boolean :allow-empty)
        (declare (ignore boolean-valid-p))
        (format stream "~&(dialog-set-response-key ~s ~s)~%"
                (node-id node)
                (editor-node-field-text-value :response-key))
        (format stream "(dialog-set-string-max-length ~s ~d)~%"
                (node-id node)
                max-length)
        (format stream "(dialog-set-string-allow-empty ~s ~s)~2%"
                (node-id node)
                allow-empty-p))))
  (:method ((node minigame-node) stream)
    (format stream "~&(dialog-set-minigame ~s ~s)~2%"
            (node-id node)
            (editor-node-field-keyword-value :minigame))))

(defgeneric node-apply-fields-edit (node)
  (:documentation "Apply the edited detail buffers to NODE in memory.")
  (:method ((node node))
    nil)
  (:method ((node say-node))
    (node-set-speaker node (editor-node-field-text-value :speaker)))
  (:method ((node number-input-node))
    (multiple-value-bind (min-valid-p min-value)
        (editor-node-field-parse-optional-number :min-value)
      (declare (ignore min-valid-p))
      (multiple-value-bind (max-valid-p max-value)
          (editor-node-field-parse-optional-number :max-value)
        (declare (ignore max-valid-p))
        (node-set-response-key node
                               (editor-node-field-text-value :response-key))
        (node-set-number-bounds node min-value max-value))))
  (:method ((node string-input-node))
    (multiple-value-bind (length-valid-p max-length)
        (editor-node-field-parse-required-nonnegative :max-length)
      (declare (ignore length-valid-p))
      (multiple-value-bind (boolean-valid-p allow-empty-p)
          (editor-node-field-parse-boolean :allow-empty)
        (declare (ignore boolean-valid-p))
        (node-set-response-key node
                               (editor-node-field-text-value :response-key))
        (node-set-string-max-length node max-length)
        (node-set-string-allow-empty node allow-empty-p))))
  (:method ((node minigame-node))
    (node-set-minigame node
                       (editor-node-field-keyword-value :minigame))))


;;; Save flow

(-> editor-append-node-fields-edit (dialog-id node) boolean)
(defun editor-append-node-fields-edit (node-id node)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; detail edit for ~s~%" node-id)
          (node-write-fields-edit node stream))
        t)
    (error (condition)
      (runtime-warn "Could not append editor detail edit: ~a" condition)
      nil)))

(-> editor-finish-node-fields-edit (node) t)
(defun editor-finish-node-fields-edit (node)
  (node-apply-fields-edit node)
  (setf *editor-status-message* "EDITOR: DETAILS SAVED")
  (reset-editor-node-fields-edit-state)
  (setf *editor-mode* :play)
  (play-start-confirm)
  t)

(-> editor-save-node-fields-edit () boolean)
(defun editor-save-node-fields-edit ()
  (let* ((node-id *editor-node-fields-node-id*)
         (node (and node-id
                    (node-exists-p node-id)
                    (find-node node-id))))
    (cond
      ((null node)
       (setf *editor-status-message* "EDITOR: NODE MISSING")
       (play-choice-switch)
       nil)
      ((not (node-fields-valid-p node))
       (setf *editor-status-message*
             (node-fields-invalid-message node))
       (play-choice-switch)
       nil)
      ((editor-append-node-fields-edit node-id node)
       (editor-finish-node-fields-edit node))
      (t
       (setf *editor-status-message* "EDITOR: DETAIL SAVE FAILED")
       (play-choice-switch)
       nil))))

(-> editor-cancel-node-fields-edit () boolean)
(defun editor-cancel-node-fields-edit ()
  (reset-editor-node-fields-edit-state)
  (setf *editor-mode* :play
        *editor-status-message* "EDITOR: DETAIL EDIT CANCELED")
  (play-choice-switch)
  t)


;;; Field adjustment

(defgeneric field-adjust (field direction)
  (:documentation "Adjust FIELD with left/right input; true when handled.")
  (:method ((field editor-field) direction)
    (declare (ignore direction))
    nil)
  (:method ((field editor-boolean-field) direction)
    (declare (ignore direction))
    (let ((key (editor-field-key field)))
      (multiple-value-bind (valid-p value)
          (editor-node-field-parse-boolean key)
        (declare (ignore valid-p))
        (setf (editor-node-field-buffer key)
              (if value "nil" "t"))
        (play-choice-switch)
        t)))
  (:method ((field editor-minigame-field) direction)
    (let ((ids (registered-minigame-ids))
          (key (editor-field-key field)))
      (when ids
        (let* ((current (editor-node-field-keyword-value key))
               (position (or (position current ids) 0))
               (next (nth (mod (+ position direction) (length ids)) ids)))
          (setf (editor-node-field-buffer key)
                (editor-node-field-value-string next))
          (play-choice-switch)
          t)))))

(-> editor-node-fields-adjust-selected (navigation-direction) boolean)
(defun editor-node-fields-adjust-selected (direction)
  (let ((field (editor-node-selected-field)))
    (and field
         (field-adjust field direction))))

(-> update-editor-node-fields-edit () boolean)
(defun update-editor-node-fields-edit ()
  (drain-editor-node-fields-input)
  (let ((panel (active-editor-panel))
        (direction (editor-vertical-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-node-fields-edit))
      ((editor-control-key-pressed-p +key-s+)
       (editor-save-node-fields-edit))
      ((is-key-pressed-p +key-tab+)
       (panel-move-selection panel 1))
      ((and direction
            (panel-move-selection panel direction))
       t)
      ((is-key-pressed-p +key-left+)
       (editor-node-fields-adjust-selected -1))
      ((is-key-pressed-p +key-right+)
       (editor-node-fields-adjust-selected 1))
      ((string-submit-pressed-p)
       (editor-save-node-fields-edit))
      (t t))))


;;; Panel registration

(defclass editor-node-fields-panel (editor-panel) ())

(register-editor-panel
 (make-instance 'editor-node-fields-panel :mode :edit-node-fields))

(defmethod panel-update ((panel editor-node-fields-panel) dt)
  (declare (ignore dt))
  (update-editor-node-fields-edit))

(defmethod panel-save ((panel editor-node-fields-panel))
  (editor-save-node-fields-edit))

(defmethod panel-item-count ((panel editor-node-fields-panel))
  (editor-node-fields-count))

(defmethod panel-selected-index ((panel editor-node-fields-panel))
  *editor-node-fields-field-index*)

(defmethod (setf panel-selected-index) (value (panel editor-node-fields-panel))
  (setf *editor-node-fields-field-index* value))
