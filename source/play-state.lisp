(in-package #:immortal-coil)

(defvar *state* nil)

(defstruct play-state
  current-id
  elapsed
  type-delay
  visible-count
  selected-index
  input-buffer)

(defun reset-play-state (&optional (id *story-start-node*))
  (reset-dialog-store)
  (setf *state* (make-play-state :current-id id
                                 :elapsed 0.0
                                 :type-delay *game-start-type-delay-seconds*
                                 :visible-count 0
                                 :selected-index 0
                                 :input-buffer "")))

(defun current-node ()
  (find-node (play-state-current-id *state*)))

(defun story-text-visible-p (node)
  (>= (play-state-visible-count *state*)
      (length (node-display-text node))))

(defun jump-to-node (id)
  (setf (play-state-current-id *state*) id
        (play-state-elapsed *state*) 0.0
        (play-state-type-delay *state*) 0.0
        (play-state-visible-count *state*) 0
        (play-state-selected-index *state*) 0
        (play-state-input-buffer *state*) ""))

(defun typewriter-elapsed ()
  (max 0.0 (- (play-state-elapsed *state*)
              (play-state-type-delay *state*))))

(defun current-alpha ()
  (round (* 255 (cubic-in (/ (typewriter-elapsed) *fade-seconds*)))))

(defun visible-node-text (node)
  (let ((text (node-display-text node)))
    (subseq text
            0
            (min (play-state-visible-count *state*)
                 (length text)))))

(defun draw-cursor (x y width size color)
  (when (< (mod (floor (* 60 (get-time))) 70) 35)
    (claylib/ll:draw-rectangle (round (+ x width 6))
                               (round y)
                               (round (/ size 2))
                               size
                               (claylib::c-ptr color))))

(defun confirm-pressed-p ()
  (or (is-key-pressed-p +key-space+)
      (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-kp-enter+)))

(defun advance-typewriter (node)
  (let* ((old-count (play-state-visible-count *state*))
         (text      (node-display-text node))
         (new-count (min (length text)
                         (floor (* (typewriter-elapsed)
                                   *characters-per-second*)))))
    (when (> new-count old-count)
      (setf (play-state-visible-count *state*) new-count)
      (play-type-click text old-count new-count))))

(defun skip-typewriter (node)
  (setf (play-state-visible-count *state*)
        (length (node-display-text node))))

(defun update-text-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    ((and (node-next node)
          (confirm-pressed-p))
     (jump-to-node (node-next node)))))

(defun draw-opening-text-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (multiple-value-bind (x y width)
        (draw-centered-text text
                            +virtual-center-x+
                            (- +virtual-center-y+ 20)
                            size
                            color)
      (draw-cursor x y width size color))))
