(in-package #:immortal-coil)

(-> story-text-visible-p (node) boolean)
(defun story-text-visible-p (node)
  (>= (play-state-visible-count *state*)
      (length (node-display-text node))))

(-> typewriter-elapsed () seconds)
(defun typewriter-elapsed ()
  (max 0.0 (- (play-state-elapsed *state*)
              (play-state-type-delay *state*))))

(-> current-alpha () alpha-channel)
(defun current-alpha ()
  (round (* 255 (clamp01 (cubic-in (/ (typewriter-elapsed)
                                      *fade-seconds*))))))

(-> visible-node-text (node) string)
(defun visible-node-text (node)
  (let ((text (node-display-text node)))
    (subseq text
            0
            (min (play-state-visible-count *state*)
                 (length text)))))

(-> confirm-pressed-p () boolean)
(defun confirm-pressed-p ()
  (or (is-key-pressed-p +key-space+)
      (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-kp-enter+)))

(-> advance-typewriter (node) t)
(defun advance-typewriter (node)
  (let* ((old-count (play-state-visible-count *state*))
         (text      (node-display-text node))
         (new-count (min (length text)
                         (floor (* (typewriter-elapsed)
                                   *characters-per-second*)))))
    (when (> new-count old-count)
      (setf (play-state-visible-count *state*) new-count)
      (play-type-click text old-count new-count))))

(-> skip-typewriter (node) nonnegative-integer)
(defun skip-typewriter (node)
  (setf (play-state-visible-count *state*)
        (length (node-display-text node))))

(-> update-text-node (node) t)
(defun update-text-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    ((and (node-next node)
          (confirm-pressed-p))
     (jump-to-node (node-next node)))))
