(in-package #:immortal-coil)

(-> string-input-max-length (node) nonnegative-integer)
(defun string-input-max-length (node)
  (or (node-max-length node) 32))

(-> string-input-character-p (character) boolean)
(defun string-input-character-p (char)
  (and (or (graphic-char-p char)
           (char= char #\Space))
       (not (char= char #\Rubout))))

(-> append-string-input (node character) boolean)
(defun append-string-input (node char)
  (append-input-character char (string-input-max-length node)))

(-> drain-string-input (node) t)
(defun drain-string-input (node)
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (append-string-input node char))
  (when (is-key-pressed-p +key-backspace+)
    (delete-input-character)))

(-> string-submit-pressed-p () boolean)
(defun string-submit-pressed-p ()
  (or (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-kp-enter+)))

(-> string-input-value () string)
(defun string-input-value ()
  (string-trim '(#\Space #\Tab #\Newline #\Return)
               (play-state-input-buffer *state*)))

(-> string-input-valid-p (node string) boolean)
(defun string-input-valid-p (node value)
  (or (node-allow-empty-p node)
      (plusp (length value))))

(-> submit-string-node (node) t)
(defun submit-string-node (node)
  (let ((value (string-input-value)))
    (if (string-input-valid-p node value)
        (progn
          (setf (dialog-value (node-response-key node)) value)
          (jump-to-node (node-target node)))
        (play-choice-switch))))

(-> update-string-node (node) t)
(defun update-string-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (drain-string-input node)
     (when (string-submit-pressed-p)
       (submit-string-node node)))))
