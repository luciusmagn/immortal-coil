(in-package #:immortal-coil)

(defvar *state* nil)
(defvar *save-current-game-function* nil)
(defvar *save-current-game-p* nil)

(defstruct play-state
  (current-id     *runtime-fallback-node-id* :type dialog-id)
  (elapsed        0.0 :type seconds)
  (type-delay     0.0 :type seconds)
  (visible-count  0 :type nonnegative-integer)
  (selected-index 0 :type nonnegative-integer)
  (input-buffer   "" :type string))

(-> reset-play-state (&optional t) t)
(defun reset-play-state (&optional (id *story-start-node*))
  (reset-dialog-store)
  (ensure-runtime-fallback-node)
  (setf *state* (make-play-state :current-id (resolve-node-id
                                              (or id
                                                  *runtime-fallback-node-id*))
                                 :elapsed 0.0
                                 :type-delay *game-start-type-delay-seconds*
                                 :visible-count 0
                                 :selected-index 0
                                 :input-buffer ""))
  (apply-node-enter-effects (current-node)))

(-> save-current-game-maybe () t)
(defun save-current-game-maybe ()
  (when (and *save-current-game-p*
             *save-current-game-function*)
    (handler-case
        (funcall *save-current-game-function*)
      (error (condition)
        (runtime-warn "Could not save game: ~a" condition)))))

(-> current-node () node)
(defun current-node ()
  (let ((node (find-node (play-state-current-id *state*))))
    (unless (equal (play-state-current-id *state*)
                   (node-id node))
      (setf (play-state-current-id *state*) (node-id node)))
    node))

(-> story-text-visible-p (node) boolean)
(defun story-text-visible-p (node)
  (>= (play-state-visible-count *state*)
      (length (node-display-text node))))

(-> jump-to-node (t) t)
(defun jump-to-node (id)
  (setf (play-state-current-id *state*) (resolve-node-id id)
        (play-state-elapsed *state*) 0.0
        (play-state-type-delay *state*) 0.0
        (play-state-visible-count *state*) 0
        (play-state-selected-index *state*) 0
        (play-state-input-buffer *state*) "")
  (apply-node-enter-effects (current-node))
  (save-current-game-maybe))

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

(-> draw-cursor (scalar scalar scalar nonnegative-integer t) t)
(defun draw-cursor (x y width size color)
  (when (< (mod (floor (* 60 (get-time))) 70) 35)
    (claylib/ll:draw-rectangle (round (+ x width 6))
                               (round y)
                               (round (/ size 2))
                               size
                               (claylib::c-ptr color))))

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

(-> draw-opening-text-node (node) t)
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
