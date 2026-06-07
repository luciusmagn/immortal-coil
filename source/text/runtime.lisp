(in-package #:immortal-coil)

;;; Typewriter state

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


;;; Rendering

(-> node-speaker-visible-p (node) boolean)
(defun node-speaker-visible-p (node)
  (and (node-speaker node)
       (plusp (length (node-speaker node)))))

(-> draw-node-speaker (node t) t)
(defun draw-node-speaker (node color)
  (when (node-speaker-visible-p node)
    (draw-centered-text (node-speaker node)
                        +virtual-center-x+
                        (- +virtual-center-y+ 82)
                        18
                        color)))

(-> node-text-center-y (node) scalar)
(defun node-text-center-y (node)
  (if (node-speaker-visible-p node)
      (- +virtual-center-y+ 12)
      (- +virtual-center-y+ 20)))

(-> draw-cursor (scalar scalar scalar nonnegative-integer t) t)
(defun draw-cursor (x y width size color)
  (when (< (mod (floor (* 60 (get-time))) 70) 35)
    (claylib/ll:draw-rectangle (round (+ x width 6))
                               (round y)
                               (round (/ size 2))
                               size
                               (claylib::c-ptr color))))

(-> draw-opening-text-node (node) t)
(defun draw-opening-text-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (draw-node-speaker node color)
    (multiple-value-bind (x y width)
        (draw-centered-text text
                            +virtual-center-x+
                            (node-text-center-y node)
                            size
                            color)
      (draw-cursor x y width size color))))
