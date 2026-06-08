(in-package #:immortal-coil)

;;; State editing

(defvar *editor-store-selected-index* 0)
(defvar *editor-store-key-buffer* "")
(defvar *editor-store-value-buffer* "")
(defvar *editor-store-edit-phase* :key)

(defparameter *editor-store-key-max-length* 80)
(defparameter *editor-store-value-max-length* 240)

(-> reset-editor-store-edit-state () t)
(defun reset-editor-store-edit-state ()
  (setf *editor-store-selected-index* 0
        *editor-store-key-buffer* ""
        *editor-store-value-buffer* ""
        *editor-store-edit-phase* :key)
  t)

(-> editor-store-entry-count () nonnegative-integer)
(defun editor-store-entry-count ()
  (length (dialog-store-snapshot)))

(-> editor-clamp-store-selection () nonnegative-integer)
(defun editor-clamp-store-selection ()
  (let ((count (editor-store-entry-count)))
    (setf *editor-store-selected-index*
          (if (plusp count)
              (min *editor-store-selected-index* (1- count))
              0))))

(-> editor-selected-store-entry () (option cons))
(defun editor-selected-store-entry ()
  (let* ((entries (dialog-store-snapshot))
         (count (length entries)))
    (when (plusp count)
      (nth (min *editor-store-selected-index* (1- count)) entries))))

(-> editor-move-store-selection (integer) boolean)
(defun editor-move-store-selection (direction)
  (let ((count (editor-store-entry-count)))
    (when (> count 1)
      (setf *editor-store-selected-index*
            (mod (+ *editor-store-selected-index* direction) count))
      (play-choice-switch)
      t)))

(-> editor-store-selection-direction () (option navigation-direction))
(defun editor-store-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(-> editor-store-value-input-string (t) string)
(defun editor-store-value-input-string (value)
  (typecase value
    (string value)
    (null "nil")
    (t (princ-to-string value))))

(-> editor-start-store-edit (&key (:new-key-p boolean)) boolean)
(defun editor-start-store-edit (&key new-key-p)
  (let ((entry (unless new-key-p
                 (editor-selected-store-entry))))
    (setf *editor-store-overlay-p* t
          *editor-mode* :edit-store
          *editor-store-key-buffer* (if entry
                                        (princ-to-string (first entry))
                                        "")
          *editor-store-value-buffer* (if entry
                                          (editor-store-value-input-string
                                           (rest entry))
                                          "")
          *editor-store-edit-phase* (if entry :value :key)
          *editor-status-message* "EDITOR: EDITING STATE")
    (play-choice-switch)
    t))

(-> editor-trim-store-input (string) string)
(defun editor-trim-store-input (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> editor-parse-store-integer (string) (option integer))
(defun editor-parse-store-integer (text)
  (handler-case
      (multiple-value-bind (value end)
          (parse-integer text)
        (when (= end (length text))
          value))
    (error () nil)))

(-> editor-parse-store-value (string) t)
(defun editor-parse-store-value (text)
  (let ((trimmed (editor-trim-store-input text)))
    (cond
      ((string= trimmed "nil")
       nil)
      ((string= trimmed "t")
       t)
      ((editor-parse-store-integer trimmed))
      (t
       trimmed))))

(-> editor-append-store-character (character) boolean)
(defun editor-append-store-character (char)
  (let* ((key-phase-p (eq *editor-store-edit-phase* :key))
         (buffer (if key-phase-p
                     *editor-store-key-buffer*
                     *editor-store-value-buffer*))
         (max-length (if key-phase-p
                         *editor-store-key-max-length*
                         *editor-store-value-max-length*)))
    (and (< (length buffer) max-length)
         (progn
           (if key-phase-p
               (setf *editor-store-key-buffer*
                     (concatenate 'string buffer (string char)))
               (setf *editor-store-value-buffer*
                     (concatenate 'string buffer (string char))))
           (play-input-click)
           t))))

(-> editor-delete-store-character () boolean)
(defun editor-delete-store-character ()
  (let* ((key-phase-p (eq *editor-store-edit-phase* :key))
         (buffer (if key-phase-p
                     *editor-store-key-buffer*
                     *editor-store-value-buffer*)))
    (when (plusp (length buffer))
      (if key-phase-p
          (setf *editor-store-key-buffer*
                (subseq buffer 0 (1- (length buffer))))
          (setf *editor-store-value-buffer*
                (subseq buffer 0 (1- (length buffer)))))
      (play-choice-switch)
      t)))

(-> drain-editor-store-input () t)
(defun drain-editor-store-input ()
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (editor-append-store-character char))
  (when (is-key-pressed-p +key-backspace+)
    (editor-delete-store-character)))

(-> editor-cancel-store-edit () boolean)
(defun editor-cancel-store-edit ()
  (setf *editor-mode* :play
        *editor-store-key-buffer* ""
        *editor-store-value-buffer* ""
        *editor-store-edit-phase* :key
        *editor-status-message* "EDITOR: STATE EDIT CANCELED")
  (play-choice-switch)
  t)

(-> editor-select-store-key (string) t)
(defun editor-select-store-key (key)
  (loop for entry in (dialog-store-snapshot)
        for index from 0
        when (equal (first entry) key)
          do (setf *editor-store-selected-index* index)
             (return)))

(-> editor-save-store-edit () boolean)
(defun editor-save-store-edit ()
  (let ((key (editor-trim-store-input *editor-store-key-buffer*)))
    (if (zerop (length key))
        (progn
          (setf *editor-status-message* "EDITOR: STATE KEY REQUIRED")
          (play-choice-switch)
          nil)
        (let ((value (editor-parse-store-value *editor-store-value-buffer*)))
          (setf (dialog-value key) value
                *editor-mode* :play
                *editor-store-key-buffer* ""
                *editor-store-value-buffer* ""
                *editor-store-edit-phase* :key
                *editor-status-message*
                (format nil "EDITOR: STATE SET ~a" key))
          (editor-select-store-key key)
          (play-start-confirm)
          t))))

(-> editor-advance-store-edit-phase () boolean)
(defun editor-advance-store-edit-phase ()
  (if (eq *editor-store-edit-phase* :key)
      (progn
        (setf *editor-store-edit-phase* :value)
        (play-choice-switch)
        t)
      (editor-save-store-edit)))

(-> update-editor-store-edit () boolean)
(defun update-editor-store-edit ()
  (drain-editor-store-input)
  (cond
    ((or (is-key-pressed-p +key-escape+)
         (editor-control-key-pressed-p +key-g+))
     (editor-cancel-store-edit))
    ((editor-control-key-pressed-p +key-s+)
     (editor-save-store-edit))
    ((or (string-submit-pressed-p)
         (is-key-pressed-p +key-tab+))
     (editor-advance-store-edit-phase))
    (t t)))

(-> editor-delete-selected-store-entry () boolean)
(defun editor-delete-selected-store-entry ()
  (let ((entry (editor-selected-store-entry)))
    (if entry
        (let ((key (first entry)))
          (dialog-store-remove key)
          (editor-clamp-store-selection)
          (setf *editor-status-message*
                (format nil "EDITOR: STATE REMOVED ~a" key))
          (play-start-confirm)
          t)
        (progn
          (setf *editor-status-message* "EDITOR: STATE EMPTY")
          (play-choice-switch)
          nil))))

(-> update-editor-store-overlay-controls () boolean)
(defun update-editor-store-overlay-controls ()
  (when *editor-store-overlay-p*
    (let ((direction (editor-store-selection-direction)))
      (cond
        ((and direction
              (editor-move-store-selection direction))
         t)
        ((or (is-key-pressed-p +key-f4+)
             (editor-control-key-pressed-p +key-e+))
         (editor-start-store-edit))
        ((or (is-key-pressed-p +key-f5+)
             (editor-control-key-pressed-p +key-n+))
         (editor-start-store-edit :new-key-p t))
        ((or (is-key-pressed-p +key-delete+)
             (editor-control-key-pressed-p +key-d+))
         (editor-delete-selected-store-entry))))))
