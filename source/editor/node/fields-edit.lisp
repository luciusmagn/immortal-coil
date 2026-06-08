(in-package #:immortal-coil)

;;; Node field editing

(defparameter *editor-node-field-value-max-length* 160)

(-> reset-editor-node-fields-edit-state () t)
(defun reset-editor-node-fields-edit-state ()
  (setf *editor-node-fields-node-id* nil
        *editor-node-fields-field-index* 0)
  (clrhash *editor-node-fields-buffers*)
  t)

(-> editor-node-fields (node) vector)
(defun editor-node-fields (node)
  (case (node-kind node)
    (:say
     #(:speaker))
    (:number
     #(:response-key :min-value :max-value))
    (:string
     #(:response-key :max-length :allow-empty))
    (:minigame
     #(:minigame))
    (t #())))

(-> editor-node-fields-count () nonnegative-integer)
(defun editor-node-fields-count ()
  (if (and *editor-node-fields-node-id*
           (node-exists-p *editor-node-fields-node-id*))
      (length (editor-node-fields (find-node *editor-node-fields-node-id*)))
      0))

(-> editor-node-selected-field () (option editor-node-field))
(defun editor-node-selected-field ()
  (let ((count (editor-node-fields-count)))
    (when (plusp count)
      (let ((fields (editor-node-fields
                     (find-node *editor-node-fields-node-id*))))
        (aref fields
              (min (max 0 *editor-node-fields-field-index*)
                   (1- count)))))))

(-> editor-node-field-buffer (editor-node-field) string)
(defun editor-node-field-buffer (field)
  (gethash field *editor-node-fields-buffers* ""))

(defun (setf editor-node-field-buffer) (value field)
  (setf (gethash field *editor-node-fields-buffers*) value))

(-> editor-node-field-value-string (t) string)
(defun editor-node-field-value-string (value)
  (cond
    ((null value) "")
    ((keywordp value)
     (string-downcase (prin1-to-string value)))
    (t
     (princ-to-string value))))

(-> editor-node-field-current-value (node editor-node-field) t)
(defun editor-node-field-current-value (node field)
  (case field
    (:speaker (node-speaker node))
    (:response-key (node-response-key node))
    (:min-value (node-min-value node))
    (:max-value (node-max-value node))
    (:max-length (node-max-length node))
    (:allow-empty (node-allow-empty-p node))
    (:minigame (node-minigame node))))

(-> editor-node-field-prime (node editor-node-field) t)
(defun editor-node-field-prime (node field)
  (setf (editor-node-field-buffer field)
        (case field
          (:allow-empty
           (if (node-allow-empty-p node) "t" "nil"))
          (t
           (editor-node-field-value-string
            (editor-node-field-current-value node field)))))
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

(-> editor-node-fields-move-field (integer) boolean)
(defun editor-node-fields-move-field (direction)
  (let ((count (editor-node-fields-count)))
    (when (plusp count)
      (setf *editor-node-fields-field-index*
            (mod (+ *editor-node-fields-field-index* direction)
                 count))
      (play-choice-switch)
      t)))

(-> editor-node-fields-selection-direction ()
    (option navigation-direction))
(defun editor-node-fields-selection-direction ()
  (cond
    ((is-key-pressed-p +key-down+) 1)
    ((is-key-pressed-p +key-up+) -1)))

(-> editor-node-field-trim (string) string)
(defun editor-node-field-trim (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> editor-node-selected-field-editable-p () boolean)
(defun editor-node-selected-field-editable-p ()
  (not (eq (editor-node-selected-field) :allow-empty)))

(-> editor-node-selected-field-buffer () string)
(defun editor-node-selected-field-buffer ()
  (let ((field (editor-node-selected-field)))
    (if field
        (editor-node-field-buffer field)
        "")))

(defun (setf editor-node-selected-field-buffer) (value)
  (let ((field (editor-node-selected-field)))
    (if field
        (setf (editor-node-field-buffer field) value)
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
(defun editor-node-field-parse-optional-number (field)
  (let* ((raw (editor-node-field-buffer field))
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
(defun editor-node-field-parse-required-nonnegative (field)
  (let ((value (editor-node-field-parse-integer
                (editor-node-field-buffer field))))
    (values (and value (>= value 0))
            (or value 0))))

(-> editor-node-field-parse-boolean (editor-node-field)
    (values boolean boolean))
(defun editor-node-field-parse-boolean (field)
  (let ((value (editor-node-field-trim (editor-node-field-buffer field))))
    (cond
      ((member value '("t" "true" "yes" "1") :test #'string-equal)
       (values t t))
      ((member value '("nil" "false" "no" "0" "") :test #'string-equal)
       (values t nil))
      (t
       (values nil nil)))))

(-> editor-node-field-keyword-value (editor-node-field)
    (option minigame-id))
(defun editor-node-field-keyword-value (field)
  (let ((value (editor-node-field-trim (editor-node-field-buffer field))))
    (unless (zerop (length value))
      (let ((name (if (char= (char value 0) #\:)
                      (subseq value 1)
                      value)))
        (when (plusp (length name))
          (intern (string-upcase name) :keyword))))))

(-> editor-node-field-text-value (editor-node-field) string)
(defun editor-node-field-text-value (field)
  (editor-node-field-trim (editor-node-field-buffer field)))

(-> editor-node-fields-values-valid-p (node) boolean)
(defun editor-node-fields-values-valid-p (node)
  (case (node-kind node)
    (:number
     (multiple-value-bind (min-valid-p min-value)
         (editor-node-field-parse-optional-number :min-value)
       (multiple-value-bind (max-valid-p max-value)
           (editor-node-field-parse-optional-number :max-value)
         (and (plusp (length (editor-node-field-text-value :response-key)))
              min-valid-p
              max-valid-p
              (or (not (and min-value max-value))
                  (<= min-value max-value))))))
    (:string
     (multiple-value-bind (length-valid-p max-length)
         (editor-node-field-parse-required-nonnegative :max-length)
       (multiple-value-bind (boolean-valid-p allow-empty-p)
           (editor-node-field-parse-boolean :allow-empty)
         (declare (ignore allow-empty-p))
         (and (plusp (length (editor-node-field-text-value :response-key)))
              length-valid-p
              (plusp max-length)
              boolean-valid-p))))
    (:minigame
     (not (null (editor-node-field-keyword-value :minigame))))
    (t t)))

(-> editor-node-fields-invalid-message (node) string)
(defun editor-node-fields-invalid-message (node)
  (case (node-kind node)
    (:number "EDITOR: RESPONSE KEY OR BOUNDS INVALID")
    (:string "EDITOR: STRING FIELD INVALID")
    (:minigame "EDITOR: MINIGAME REQUIRED")
    (t "EDITOR: DETAILS INVALID")))

(-> editor-write-node-fields-edit (t dialog-id node) t)
(defun editor-write-node-fields-edit (stream node-id node)
  (case (node-kind node)
    (:say
     (format stream "~&(dialog-set-speaker ~s ~s)~2%"
             node-id
             (editor-node-field-text-value :speaker)))
    (:number
     (multiple-value-bind (min-valid-p min-value)
         (editor-node-field-parse-optional-number :min-value)
       (declare (ignore min-valid-p))
       (multiple-value-bind (max-valid-p max-value)
           (editor-node-field-parse-optional-number :max-value)
         (declare (ignore max-valid-p))
         (format stream "~&(dialog-set-response-key ~s ~s)~%"
                 node-id
                 (editor-node-field-text-value :response-key))
         (format stream "(dialog-set-number-bounds ~s ~s ~s)~2%"
                 node-id
                 min-value
                 max-value))))
    (:string
     (multiple-value-bind (length-valid-p max-length)
         (editor-node-field-parse-required-nonnegative :max-length)
       (declare (ignore length-valid-p))
       (multiple-value-bind (boolean-valid-p allow-empty-p)
           (editor-node-field-parse-boolean :allow-empty)
         (declare (ignore boolean-valid-p))
         (format stream "~&(dialog-set-response-key ~s ~s)~%"
                 node-id
                 (editor-node-field-text-value :response-key))
         (format stream "(dialog-set-string-max-length ~s ~d)~%"
                 node-id
                 max-length)
         (format stream "(dialog-set-string-allow-empty ~s ~s)~2%"
                 node-id
                 allow-empty-p))))
    (:minigame
     (format stream "~&(dialog-set-minigame ~s ~s)~2%"
             node-id
             (editor-node-field-keyword-value :minigame)))))

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
          (editor-write-node-fields-edit stream node-id node))
        t)
    (error (condition)
      (runtime-warn "Could not append editor detail edit: ~a" condition)
      nil)))

(-> editor-apply-node-fields-edit (dialog-id node) t)
(defun editor-apply-node-fields-edit (node-id node)
  (case (node-kind node)
    (:say
     (dialog-set-speaker node-id (editor-node-field-text-value :speaker)))
    (:number
     (multiple-value-bind (min-valid-p min-value)
         (editor-node-field-parse-optional-number :min-value)
       (declare (ignore min-valid-p))
       (multiple-value-bind (max-valid-p max-value)
           (editor-node-field-parse-optional-number :max-value)
         (declare (ignore max-valid-p))
         (dialog-set-response-key node-id
                                  (editor-node-field-text-value
                                   :response-key))
         (dialog-set-number-bounds node-id min-value max-value))))
    (:string
     (multiple-value-bind (length-valid-p max-length)
         (editor-node-field-parse-required-nonnegative :max-length)
       (declare (ignore length-valid-p))
       (multiple-value-bind (boolean-valid-p allow-empty-p)
           (editor-node-field-parse-boolean :allow-empty)
         (declare (ignore boolean-valid-p))
         (dialog-set-response-key node-id
                                  (editor-node-field-text-value
                                   :response-key))
         (dialog-set-string-max-length node-id max-length)
         (dialog-set-string-allow-empty node-id allow-empty-p))))
    (:minigame
     (dialog-set-minigame node-id
                          (editor-node-field-keyword-value :minigame))))
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
      ((not (editor-node-fields-values-valid-p node))
       (setf *editor-status-message*
             (editor-node-fields-invalid-message node))
       (play-choice-switch)
       nil)
      ((editor-append-node-fields-edit node-id node)
       (editor-apply-node-fields-edit node-id node))
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

(-> editor-cycle-node-minigame-field (navigation-direction) boolean)
(defun editor-cycle-node-minigame-field (direction)
  (let ((ids (registered-minigame-ids)))
    (when ids
      (let* ((current (editor-node-field-keyword-value :minigame))
             (position (or (position current ids) 0))
             (next (nth (mod (+ position direction) (length ids)) ids)))
        (setf (editor-node-field-buffer :minigame)
              (editor-node-field-value-string next))
        (play-choice-switch)
        t))))

(-> editor-toggle-node-boolean-field () boolean)
(defun editor-toggle-node-boolean-field ()
  (multiple-value-bind (valid-p allow-empty-p)
      (editor-node-field-parse-boolean :allow-empty)
    (declare (ignore valid-p))
    (setf (editor-node-field-buffer :allow-empty)
          (if allow-empty-p "nil" "t"))
    (play-choice-switch)
    t))

(-> editor-node-fields-adjust-selected (navigation-direction) boolean)
(defun editor-node-fields-adjust-selected (direction)
  (case (editor-node-selected-field)
    (:allow-empty
     (editor-toggle-node-boolean-field))
    (:minigame
     (editor-cycle-node-minigame-field direction))
    (t nil)))

(-> update-editor-node-fields-edit () boolean)
(defun update-editor-node-fields-edit ()
  (drain-editor-node-fields-input)
  (let ((direction (editor-node-fields-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-node-fields-edit))
      ((editor-control-key-pressed-p +key-s+)
       (editor-save-node-fields-edit))
      ((is-key-pressed-p +key-tab+)
       (editor-node-fields-move-field 1))
      ((and direction
            (editor-node-fields-move-field direction))
       t)
      ((is-key-pressed-p +key-left+)
       (editor-node-fields-adjust-selected -1))
      ((is-key-pressed-p +key-right+)
       (editor-node-fields-adjust-selected 1))
      ((string-submit-pressed-p)
       (editor-save-node-fields-edit))
      (t t))))
