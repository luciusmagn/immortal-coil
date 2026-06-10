;;; forest hide minigame
;;;
;;; The lantern sweeps past while the player hides under the pines.
;;; Breath pressure rises on its own; letting a breath out eases it but
;;; makes noise. Gasping, or being noisy while the light is close, is
;;; heard. Both outcomes continue the story; being heard only marks it.

(defconstant +forest-hide-duration+ 9.0)
(defconstant +forest-hide-breath-rise+ 0.085)
(defconstant +forest-hide-exhale+ 0.30)
(defconstant +forest-hide-exhale-noise+ 0.34)
(defconstant +forest-hide-noise-decay+ 0.55)

(defvar *forest-hide* nil)

(defstruct forest-hide
  (node-id *runtime-fallback-node-id* :type dialog-id)
  (elapsed 0.0 :type seconds)
  (breath  0.25 :type scalar)
  (noise   0.0 :type scalar))

(defun make-fresh-forest-hide (node)
  (make-forest-hide :node-id (node-id node)
                    :elapsed 0.0
                    :breath 0.25
                    :noise 0.0))

(defun ensure-forest-hide (node)
  (unless (and *forest-hide*
               (equal (forest-hide-node-id *forest-hide*)
                      (node-id node)))
    (setf *forest-hide* (make-fresh-forest-hide node)))
  *forest-hide*)

(defun forest-hide-exhale-pressed-p ()
  (or (is-key-pressed-p +key-space+)
      (is-key-pressed-p +key-up+)
      (is-key-pressed-p +key-w+)))

(defun forest-hide-light-x (game)
  (let ((progress (clamp01 (/ (forest-hide-elapsed game)
                              +forest-hide-duration+))))
    (+ 120.0 (* progress (- +virtual-width+ 240.0)))))

(defun forest-hide-danger (game)
  (let ((distance (abs (- (forest-hide-light-x game) +virtual-center-x+))))
    (clamp01 (- 1.0 (/ distance 320.0)))))

(defun finish-forest-hide (target)
  (setf *forest-hide* nil)
  (jump-to-dialog-target target))

(defun fail-forest-hide (node)
  (setf (dialog-value "forest-seen") t)
  (finish-forest-hide (node-failure-target node)))

(defun update-forest-hide-node (node dt)
  (let ((game (ensure-forest-hide node)))
    (incf (forest-hide-elapsed game) dt)
    (incf (forest-hide-breath game) (* +forest-hide-breath-rise+ dt))
    (setf (forest-hide-noise game)
          (max 0.0 (- (forest-hide-noise game)
                      (* +forest-hide-noise-decay+ dt))))
    (when (forest-hide-exhale-pressed-p)
      (setf (forest-hide-breath game)
            (max 0.0 (- (forest-hide-breath game) +forest-hide-exhale+)))
      (incf (forest-hide-noise game) +forest-hide-exhale-noise+))
    (cond
      ((>= (forest-hide-breath game) 1.0)
       (fail-forest-hide node))
      ((and (> (forest-hide-noise game) 0.55)
            (> (forest-hide-danger game) 0.35))
       (fail-forest-hide node))
      ((>= (forest-hide-elapsed game) +forest-hide-duration+)
       (finish-forest-hide (node-success-target node))))))

(defun draw-forest-hide-light (game)
  (let ((x (forest-hide-light-x game)))
    (loop for (half-width alpha) in '((90.0 26) (46.0 48) (16.0 92))
          do (claylib/ll:draw-rectangle (round (- x half-width))
                                        120
                                        (round (* half-width 2.0))
                                        330
                                        (claylib::c-ptr
                                         (make-color 255 255 255 alpha))))))

(defun draw-forest-hide-breath (game)
  (let* ((width 320.0)
         (left (- +virtual-center-x+ (/ width 2.0)))
         (y (- +virtual-height+ 96.0))
         (breath (clamp01 (forest-hide-breath game)))
         (noise (clamp01 (forest-hide-noise game))))
    (draw-thick-line-between left y (+ left width) y
                             (make-color 255 255 255 80)
                             1.0)
    (draw-thick-line-between left y (+ left (* width breath)) y
                             (make-color 255 255 255
                                         (round (+ 130 (* 110 breath))))
                             4.0)
    (when (plusp noise)
      (draw-thick-line-between left (- y 12.0)
                               (+ left (* width noise)) (- y 12.0)
                               (make-color 255 255 255 70)
                               2.0))))

(defun draw-forest-hide-node (node color)
  (declare (ignore color))
  (let ((game (ensure-forest-hide node)))
    (draw-forest-hide-light game)
    (draw-forest-hide-breath game)
    (draw-centered-text "space, w, or up arrow lets a breath out"
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))

(dialog-minigame-kind :forest-hide
                      :update #'update-forest-hide-node
                      :draw #'draw-forest-hide-node)
