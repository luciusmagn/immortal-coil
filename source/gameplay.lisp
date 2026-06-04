(in-package #:immortal-coil)

(defvar *state* nil)

(defstruct play-state
  current-id
  elapsed
  visible-count
  selected-index)

(defun reset-play-state (&optional (id *story-start-node*))
  (setf *state* (make-play-state :current-id id
                                 :elapsed 0.0
                                 :visible-count 0
                                 :selected-index 0)))

(defun current-node ()
  (find-node (play-state-current-id *state*)))

(defun story-text-visible-p (node)
  (>= (play-state-visible-count *state*)
      (length (node-text node))))

(defun jump-to-node (id)
  (setf (play-state-current-id *state*) id
        (play-state-elapsed *state*) 0.0
        (play-state-visible-count *state*) 0
        (play-state-selected-index *state*) 0))

(defun current-alpha ()
  (round (* 255 (cubic-in (/ (play-state-elapsed *state*) *fade-seconds*)))))

(defun visible-node-text (node)
  (subseq (node-text node)
          0
          (min (play-state-visible-count *state*)
               (length (node-text node)))))

(defun draw-cursor (x y width size color)
  (when (< (mod (floor (* 60 (get-time))) 70) 35)
    (claylib/ll:draw-rectangle (round (+ x width 6))
                               (round y)
                               (round (/ size 2))
                               size
                               (claylib::c-ptr color))))

(defun choice-switch-pressed-p ()
  (or (is-key-pressed-p +key-left+)
      (is-key-pressed-p +key-right+)))

(defun advance-typewriter (node)
  (let* ((old-count (play-state-visible-count *state*))
         (new-count (min (length (node-text node))
                         (floor (* (play-state-elapsed *state*)
                                   *characters-per-second*)))))
    (when (> new-count old-count)
      (setf (play-state-visible-count *state*) new-count)
      (play-type-click (node-text node) old-count new-count))))

(defun skip-typewriter (node)
  (setf (play-state-visible-count *state*) (length (node-text node))))

(defun update-text-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (is-key-pressed-p +key-space+)
       (skip-typewriter node)))
    ((and (node-next node)
          (is-key-pressed-p +key-space+))
     (jump-to-node (node-next node)))))

(defun update-choice-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (is-key-pressed-p +key-space+)
       (skip-typewriter node)))
    (t
     (let ((choice-count (length (node-choices node))))
       (when (and (> choice-count 1)
                  (choice-switch-pressed-p))
         (setf (play-state-selected-index *state*)
               (mod (1+ (play-state-selected-index *state*))
                    choice-count))
         (play-choice-switch))
       (when (is-key-pressed-p +key-space+)
         (jump-to-node
          (choice-target (aref (node-choices node)
                               (play-state-selected-index *state*)))))))))

(defun update-gameplay (dt)
  (update-particles dt)
  (incf (play-state-elapsed *state*) dt)
  (let ((node (current-node)))
    (advance-typewriter node)
    (case (node-kind node)
      (:choice (update-choice-node node))
      (t (update-text-node node)))))

(defun draw-opening-text-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (multiple-value-bind (x y width)
        (draw-centered-text text 400 280 size color)
      (draw-cursor x y width size color))))

(defun draw-choice-option (choice x y selected-p color)
  (let ((size 20))
    (draw-text-at (choice-label choice) x y size color)
    (when selected-p
      (claylib/ll:draw-rectangle (round x)
                                 (+ y size 3)
                                 (measure-text (choice-label choice) size)
                                 4
                                 (claylib::c-ptr color)))))

(defun draw-choice-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (multiple-value-bind (x y width)
        (draw-centered-text text 400 200 size color)
      (draw-cursor x y width size color))
    (loop for choice across (node-choices node)
          for i from 0
          for x in '(200 600)
          do (draw-choice-option choice
                                 x
                                 450
                                 (= i (play-state-selected-index *state*))
                                 color))))

(defun draw-gameplay ()
  (draw-particles)
  (case (node-kind (current-node))
    (:choice (draw-choice-node (current-node)))
    (t (draw-opening-text-node (current-node)))))
