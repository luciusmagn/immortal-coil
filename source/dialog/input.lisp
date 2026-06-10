(in-package #:immortal-coil)

;;; Shared input buffer

(-> append-input-character (character nonnegative-integer) boolean)
(defun append-input-character (char max-length)
  (and (< (length (play-state-input-buffer *state*)) max-length)
       (progn
         (setf (play-state-input-buffer *state*)
               (concatenate 'string
                            (play-state-input-buffer *state*)
                            (string char)))
         (play-input-click)
         t)))

(-> delete-input-character () boolean)
(defun delete-input-character ()
  (let ((buffer (play-state-input-buffer *state*)))
    (when (plusp (length buffer))
      (setf (play-state-input-buffer *state*)
            (subseq buffer 0 (1- (length buffer))))
      (play-choice-switch)
      t)))


;;; Number input

(-> negative-number-input-allowed-p (node) boolean)
(defun negative-number-input-allowed-p (node)
  (or (null (node-min-value node))
      (minusp (node-min-value node))))

(-> number-input-character-p (node character) boolean)
(defun number-input-character-p (node char)
  (let ((buffer (play-state-input-buffer *state*)))
    (not (null (or (digit-char-p char)
                   (and (char= char #\-)
                        (zerop (length buffer))
                        (negative-number-input-allowed-p node)))))))

(-> append-number-input (character) boolean)
(defun append-number-input (char)
  (append-input-character char 12))

(-> delete-number-input-character () boolean)
(defun delete-number-input-character ()
  (delete-input-character))

(-> pressed-digit-character () (option character))
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

(-> pressed-number-key-character (node) (option character))
(defun pressed-number-key-character (node)
  (or (pressed-digit-character)
      (when (and (or (is-key-pressed-p +key-minus+)
                     (is-key-pressed-p +key-kp-subtract+))
                 (number-input-character-p node #\-))
        #\-)))

(-> drain-number-character-input (node) boolean)
(defun drain-number-character-input (node)
  (loop with typed-p = nil
        for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (number-input-character-p node char))
          do (setf typed-p t)
             (append-number-input char)
        finally (return typed-p)))

(-> drain-number-input (node) t)
(defun drain-number-input (node)
  (unless (drain-number-character-input node)
    (let ((char (pressed-number-key-character node)))
      (when char
        (append-number-input char))))
  (when (is-key-pressed-p +key-backspace+)
    (delete-number-input-character)))

(-> parse-number-input () (option integer))
(defun parse-number-input ()
  (let ((buffer (play-state-input-buffer *state*)))
    (when (plusp (length buffer))
      (handler-case
          (parse-integer buffer)
        (error () nil)))))

(-> number-input-valid-p (node (option integer)) boolean)
(defun number-input-valid-p (node value)
  (and value
       (or (null (node-min-value node))
           (>= value (node-min-value node)))
       (or (null (node-max-value node))
           (<= value (node-max-value node)))))

(-> submit-number-node (node) t)
(defun submit-number-node (node)
  (let ((value (parse-number-input)))
    (if (number-input-valid-p node value)
        (progn
          (setf (dialog-value (node-response-key node)) value)
          (jump-to-dialog-target (node-target node)))
        (play-choice-switch))))

(-> update-number-node (node) t)
(defun update-number-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (drain-number-input node)
     (when (confirm-pressed-p)
       (submit-number-node node)))))


;;; String input

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
          (jump-to-dialog-target (node-target node)))
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


;;; Rendering

(defun draw-input-field (color &key (field-width 220))
  (let* ((size 20)
         (buffer (play-state-input-buffer *state*))
         (field-x (- +virtual-center-x+ (/ field-width 2)))
         (field-y (+ +virtual-center-y+ 88)))
    (multiple-value-bind (x y width)
        (draw-centered-text buffer
                            +virtual-center-x+
                            field-y
                            size
                            color)
      (claylib/ll:draw-rectangle (round field-x)
                                 (+ (round field-y) size 8)
                                 (round field-width)
                                 4
                                 (claylib::c-ptr color))
      (draw-cursor x y width size color))))

(defun draw-number-input-field (color)
  (draw-input-field color :field-width 220))

(defun draw-string-input-field (color)
  (draw-input-field color :field-width 460))

(defun draw-number-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node
                        (- +virtual-center-y+ 80)
                        color
                        :cursor-p nil)
    (when (story-text-visible-p node)
      (draw-number-input-field color))))

(defun draw-string-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node
                        (- +virtual-center-y+ 80)
                        color
                        :cursor-p nil)
    (when (story-text-visible-p node)
      (draw-string-input-field color))))


;;; Node behavior

(defmethod node-update ((node number-input-node) dt)
  (declare (ignore dt))
  (advance-typewriter node)
  (update-number-node node))

(defmethod node-update ((node string-input-node) dt)
  (declare (ignore dt))
  (advance-typewriter node)
  (update-string-node node))

(defmethod node-draw ((node number-input-node))
  (draw-number-node node))

(defmethod node-draw ((node string-input-node))
  (draw-string-node node))
