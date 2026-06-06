(in-package #:immortal-coil)

(defparameter *template-variable-trim-characters*
  '(#\Space #\Tab #\Newline #\Return))

(defun dialog-template-value-string (value)
  (typecase value
    (string value)
    (character (string value))
    (t (princ-to-string value))))

(defun substitute-dialog-variable (key fallback)
  (let ((trimmed-key (string-trim *template-variable-trim-characters* key)))
    (if (zerop (length trimmed-key))
        fallback
        (multiple-value-bind (value present-p)
            (dialog-store-get trimmed-key)
          (if present-p
              (dialog-template-value-string value)
              fallback)))))

(defun substitute-dialog-variables (text)
  (with-output-to-string (stream)
    (do ((index 0))
        ((>= index (length text)))
      (let ((char (char text index)))
        (if (char= char #\{)
            (let ((end (position #\} text :start (1+ index))))
              (if end
                  (let ((fallback (subseq text index (1+ end)))
                        (key      (subseq text (1+ index) end)))
                    (write-string (substitute-dialog-variable key fallback)
                                  stream)
                    (setf index (1+ end)))
                  (progn
                    (write-char char stream)
                    (incf index))))
            (progn
              (write-char char stream)
              (incf index)))))))

(defun node-display-text (node)
  (substitute-dialog-variables (node-text node)))

(defun choice-display-label (choice)
  (substitute-dialog-variables (choice-label choice)))
