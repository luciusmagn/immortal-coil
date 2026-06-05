(in-package #:immortal-coil)

(defun choice-layout (node)
  (or (node-layout node) :horizontal))

(defun horizontal-selection-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)))

(defun vertical-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(defun selection-direction (node)
  (case (choice-layout node)
    (:horizontal (horizontal-selection-direction))
    (t (vertical-selection-direction))))

(defun move-selection (node direction)
  (let ((choice-count (length (active-node-choices node))))
    (when (>= (play-state-selected-index *state*) choice-count)
      (setf (play-state-selected-index *state*)
            (max 0 (1- choice-count))))
    (when (and direction (> choice-count 1))
      (setf (play-state-selected-index *state*)
            (mod (+ (play-state-selected-index *state*) direction)
                 choice-count))
      (play-choice-switch))))

(defun update-choice-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (move-selection node (selection-direction node))
     (when (and (plusp (length (active-node-choices node)))
                (confirm-pressed-p))
       (jump-to-node
        (choice-target (aref (active-node-choices node)
                             (play-state-selected-index *state*))))))))

(defun matching-branch-target (node)
  (loop for branch across (node-branches node)
        when (dialog-condition-true-p (branch-condition branch))
          return (branch-target branch)))

(defun update-branch-node (node)
  (let ((target (matching-branch-target node)))
    (unless target
      (error "Branch node has no matching case: ~a" (node-id node)))
    (jump-to-node target)))

(defun negative-number-input-allowed-p (node)
  (or (null (node-min-value node))
      (minusp (node-min-value node))))

(defun number-input-character-p (node char)
  (let ((buffer (play-state-input-buffer *state*)))
    (or (digit-char-p char)
        (and (char= char #\-)
             (zerop (length buffer))
             (negative-number-input-allowed-p node)))))

(defun append-number-input (char)
  (when (< (length (play-state-input-buffer *state*)) 12)
    (setf (play-state-input-buffer *state*)
          (concatenate 'string
                       (play-state-input-buffer *state*)
                       (string char)))
    (play-input-click)))

(defun delete-number-input-character ()
  (let ((buffer (play-state-input-buffer *state*)))
    (when (plusp (length buffer))
      (setf (play-state-input-buffer *state*)
            (subseq buffer 0 (1- (length buffer))))
      (play-choice-switch))))

(defun drain-number-input (node)
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (number-input-character-p node char))
          do (append-number-input char))
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
    (when (number-input-valid-p node value)
      (setf (dialog-value (node-response-key node)) value)
      (jump-to-node (node-target node)))))

(defun update-number-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (drain-number-input node)
     (when (confirm-pressed-p)
       (submit-number-node node)))))
