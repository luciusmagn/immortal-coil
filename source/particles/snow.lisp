(in-package #:immortal-coil)

;;; Drifting snow: slow flakes falling with a side-to-side sway. For the
;;; cold pastoral chapters (winter, the hill house, the forest).

(defstruct snow-particle
  x
  y
  vx
  fall
  sway-phase
  sway-speed
  sway-strength
  size
  alpha)

(defun reset-snow-particle (particle &key initial-p)
  (setf (snow-particle-x particle) (random-float -20.0 (+ +virtual-width+ 20.0))
        (snow-particle-y particle) (if initial-p
                                       (random-float -20.0 (+ +virtual-height+ 20.0))
                                       (random-float -60.0 -10.0))
        (snow-particle-vx particle) (random-float -6.0 6.0)
        (snow-particle-fall particle) (random-float 18.0 46.0)
        (snow-particle-sway-phase particle) (random-float 0.0 (* 2 pi))
        (snow-particle-sway-speed particle) (random-float 0.5 1.4)
        (snow-particle-sway-strength particle) (random-float 6.0 16.0)
        (snow-particle-size particle) (get-random-value 1 2)
        (snow-particle-alpha particle) (get-random-value 110 220))
  particle)

(defun update-snow-particle (particle dt)
  (if (> (snow-particle-y particle) (+ +virtual-height+ 20))
      (reset-snow-particle particle)
      (progn
        (incf (snow-particle-sway-phase particle)
              (* (snow-particle-sway-speed particle) dt))
        (incf (snow-particle-x particle)
              (* (+ (snow-particle-vx particle)
                    (* (snow-particle-sway-strength particle)
                       (sin (snow-particle-sway-phase particle))))
                 dt))
        (incf (snow-particle-y particle)
              (* (snow-particle-fall particle) dt)))))

(defun draw-snow-particle (particle alpha-scale)
  (let ((alpha (round (* (snow-particle-alpha particle) alpha-scale))))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (snow-particle-x particle))
                                 (round (snow-particle-y particle))
                                 (snow-particle-size particle)
                                 (snow-particle-size particle)
                                 (draw-color-ptr 255 255 255 alpha)))))


;;; System

(defclass snow-particle-system (particle-system) ())

(defmethod particle-system-count ((system snow-particle-system)) 90)

(defmethod particle-system-make ((system snow-particle-system))
  (make-snow-particle))

(defmethod particle-system-reset-particle ((system snow-particle-system)
                                           particle
                                           &key initial-p)
  (reset-snow-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system snow-particle-system)
                                            particle
                                            dt)
  (update-snow-particle particle dt))

(defmethod particle-system-draw-particle ((system snow-particle-system)
                                          particle
                                          alpha-scale)
  (draw-snow-particle particle alpha-scale))
