(in-package #:immortal-coil)

(-> save-play-state-data () save-data)
(defun save-play-state-data ()
  (list :version 1
        :current-id (play-state-current-id *state*)
        :visible-count (play-state-visible-count *state*)
        :selected-index (play-state-selected-index *state*)
        :input-buffer (play-state-input-buffer *state*)
        :dialog-store (dialog-store-alist)
        :particle-field (particle-field-state-data)))

(-> save-data-current-id (save-data) t)
(defun save-data-current-id (data)
  (getf data :current-id))

(-> valid-save-data-p (t) boolean)
(defun valid-save-data-p (data)
  (and (listp data)
       (= (or (getf data :version) 0) 1)
       (stringp (save-data-current-id data))))

(-> save-data-nonnegative-integer (save-data keyword) nonnegative-integer)
(defun save-data-nonnegative-integer (data key)
  (let ((value (getf data key)))
    (if (integerp value)
        (max 0 value)
        0)))

(-> save-data-string (save-data keyword) string)
(defun save-data-string (data key)
  (let ((value (getf data key)))
    (if (stringp value)
        value
        "")))
