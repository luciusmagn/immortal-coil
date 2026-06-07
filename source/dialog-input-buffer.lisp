(in-package #:immortal-coil)

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
