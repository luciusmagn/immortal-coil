(in-package #:immortal-coil)

(defun negative-number-input-allowed-p (node)
  (or (null (node-min-value node))
      (minusp (node-min-value node))))

(defun number-input-character-p (node char)
  (let ((buffer (play-state-input-buffer *state*)))
    (or (digit-char-p char)
        (and (char= char #\-)
             (zerop (length buffer))
             (negative-number-input-allowed-p node)))))

(defun append-input-character (char max-length)
  (when (< (length (play-state-input-buffer *state*)) max-length)
    (setf (play-state-input-buffer *state*)
          (concatenate 'string
                       (play-state-input-buffer *state*)
                       (string char)))
    (play-input-click)))

(defun append-number-input (char)
  (append-input-character char 12))

(defun delete-input-character ()
  (let ((buffer (play-state-input-buffer *state*)))
    (when (plusp (length buffer))
      (setf (play-state-input-buffer *state*)
            (subseq buffer 0 (1- (length buffer))))
      (play-choice-switch))))

(defun delete-number-input-character ()
  (delete-input-character))

(defun pressed-digit-character ()
  (cond
    ((or (is-key-pressed-p +key-zero+)
         (is-key-pressed-p +key-kp-0+))
     #\0)
    ((or (is-key-pressed-p +key-one+)
         (is-key-pressed-p +key-kp-1+))
     #\1)
    ((or (is-key-pressed-p +key-two+)
         (is-key-pressed-p +key-kp-2+))
     #\2)
    ((or (is-key-pressed-p +key-three+)
         (is-key-pressed-p +key-kp-3+))
     #\3)
    ((or (is-key-pressed-p +key-four+)
         (is-key-pressed-p +key-kp-4+))
     #\4)
    ((or (is-key-pressed-p +key-five+)
         (is-key-pressed-p +key-kp-5+))
     #\5)
    ((or (is-key-pressed-p +key-six+)
         (is-key-pressed-p +key-kp-6+))
     #\6)
    ((or (is-key-pressed-p +key-seven+)
         (is-key-pressed-p +key-kp-7+))
     #\7)
    ((or (is-key-pressed-p +key-eight+)
         (is-key-pressed-p +key-kp-8+))
     #\8)
    ((or (is-key-pressed-p +key-nine+)
         (is-key-pressed-p +key-kp-9+))
     #\9)))

(defun pressed-number-key-character (node)
  (or (pressed-digit-character)
      (when (and (or (is-key-pressed-p +key-minus+)
                     (is-key-pressed-p +key-kp-subtract+))
                 (number-input-character-p node #\-))
        #\-)))

(defun drain-number-character-input (node)
  (loop with typed-p = nil
        for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (number-input-character-p node char))
          do (setf typed-p t)
             (append-number-input char)
        finally (return typed-p)))

(defun drain-number-input (node)
  (unless (drain-number-character-input node)
    (let ((char (pressed-number-key-character node)))
      (when char
        (append-number-input char))))
  (when (is-key-pressed-p +key-backspace+)
    (delete-number-input-character)))

(defun parse-number-input ()
  (let ((buffer (play-state-input-buffer *state*)))
    (when (plusp (length buffer))
      (handler-case
          (parse-integer buffer)
        (error () nil)))))

(defun number-input-valid-p (node value)
  (and value
       (or (null (node-min-value node))
           (>= value (node-min-value node)))
       (or (null (node-max-value node))
           (<= value (node-max-value node)))))

(defun submit-number-node (node)
  (let ((value (parse-number-input)))
    (if (number-input-valid-p node value)
        (progn
          (setf (dialog-value (node-response-key node)) value)
          (jump-to-node (node-target node)))
        (play-choice-switch))))

(defun string-input-max-length (node)
  (or (node-max-length node) 32))

(defun string-input-character-p (char)
  (and (or (graphic-char-p char)
           (char= char #\Space))
       (not (char= char #\Rubout))))

(defun append-string-input (node char)
  (append-input-character char (string-input-max-length node)))

(defun drain-string-input (node)
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (append-string-input node char))
  (when (is-key-pressed-p +key-backspace+)
    (delete-input-character)))

(defun string-submit-pressed-p ()
  (or (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-kp-enter+)))

(defun string-input-value ()
  (string-trim '(#\Space #\Tab #\Newline #\Return)
               (play-state-input-buffer *state*)))

(defun string-input-valid-p (node value)
  (or (node-allow-empty-p node)
      (plusp (length value))))

(defun submit-string-node (node)
  (let ((value (string-input-value)))
    (if (string-input-valid-p node value)
        (progn
          (setf (dialog-value (node-response-key node)) value)
          (jump-to-node (node-target node)))
        (play-choice-switch))))

(defun update-number-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (drain-number-input node)
     (when (confirm-pressed-p)
       (submit-number-node node)))))

(defun update-string-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (drain-string-input node)
     (when (string-submit-pressed-p)
       (submit-string-node node)))))
