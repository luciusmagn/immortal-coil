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

(-> visible-node-text-lines (node nonnegative-integer scalar) (list-of string))
(defun visible-node-text-lines (node size max-width)
  (visible-text-lines (wrap-text-lines (node-display-text node)
                                       size
                                       max-width)
                      (play-state-visible-count *state*)))

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
     (jump-to-dialog-target (node-next node)))))


;;; Rendering

(-> node-speaker-visible-p (node) boolean)
(defun node-speaker-visible-p (node)
  (and (node-speaker node)
       (plusp (length (node-speaker node)))))

(-> draw-speaker-label (string scalar scalar nonnegative-integer t) t)
(defun draw-speaker-label (text center-x center-y size color)
  (let* ((padding-x 18)
         (padding-y 8)
         (text-width (text-width text size))
         (panel-width (+ text-width (* 2 padding-x)))
         (panel-height (+ size (* 2 padding-y)))
         (left (- center-x (/ panel-width 2.0)))
         (top (- center-y (/ panel-height 2.0))))
    (claylib/ll:draw-rectangle (round left)
                               (round top)
                               (round panel-width)
                               (round panel-height)
                               (claylib::c-ptr
                                (make-color 0 0 0 255)))
    (draw-rectangle-outline left
                            top
                            panel-width
                            panel-height
                            color
                            :thickness 2)
    (draw-centered-text text center-x center-y size color)
    t))

(-> draw-node-speaker (node t) t)
(defun draw-node-speaker (node color)
  (when (node-speaker-visible-p node)
    (draw-speaker-label (node-speaker node)
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
         (lines (visible-node-text-lines node size *dialog-text-max-width*)))
    (draw-node-speaker node color)
    (multiple-value-bind (x y width)
        (draw-centered-text-lines lines
                                  +virtual-center-x+
                                  (node-text-center-y node)
                                  size
                                  color)
      (draw-cursor x y width size color))))


;;; Node behavior
;;;
;;; The base methods cover text and say nodes and act as the fallback
;;; for any future node class without its own behavior.

(defmethod node-update ((node node) dt)
  (declare (ignore dt))
  (advance-typewriter node)
  (update-text-node node))

(defmethod node-draw ((node node))
  (draw-opening-text-node node))

(defmethod node-draw ((node scene-node))
  (let* ((alpha (current-alpha))
         (color (make-color 255 255 255 alpha))
         (rule-color (make-color 255 255 255 (round (* alpha 0.5))))
         (x 132.0)
         (rule-y (- +virtual-height+ 196.0)))
    (draw-thick-line-between x rule-y (+ x 236.0) rule-y rule-color 1.0)
    (draw-text-at (visible-node-text node)
                  (round x)
                  (round (+ rule-y 16.0))
                  17
                  color)))
