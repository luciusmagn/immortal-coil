(in-package #:immortal-coil)

;;; Falling ash: slow cinders drifting down, each flickering as it cools.
;;; A warm, dim grey, for the grim chapters (the war, the sealed district,
;;; the tribunal, the bell-fall funeral).

(defstruct ash-particle
  x
  y
  vx
  fall
  sway-phase
  sway-speed
  sway-strength
  flicker-phase
  flicker-speed
  alpha)

(defun reset-ash-particle (particle &key initial-p)
  (setf (ash-particle-x particle) (random-float -20.0 (+ +virtual-width+ 20.0))
        (ash-particle-y particle) (if initial-p
                                      (random-float -20.0 (+ +virtual-height+ 20.0))
                                      (random-float -60.0 -10.0))
        (ash-particle-vx particle) (random-float -4.0 4.0)
        (ash-particle-fall particle) (random-float 8.0 24.0)
        (ash-particle-sway-phase particle) (random-float 0.0 (* 2 pi))
        (ash-particle-sway-speed particle) (random-float 0.3 0.9)
        (ash-particle-sway-strength particle) (random-float 4.0 12.0)
        (ash-particle-flicker-phase particle) (random-float 0.0 (* 2 pi))
        (ash-particle-flicker-speed particle) (random-float 1.5 4.0)
        (ash-particle-alpha particle) (get-random-value 70 150))
  particle)

(defun update-ash-particle (particle dt)
  (if (> (ash-particle-y particle) (+ +virtual-height+ 20))
      (reset-ash-particle particle)
      (progn
        (incf (ash-particle-sway-phase particle)
              (* (ash-particle-sway-speed particle) dt))
        (incf (ash-particle-flicker-phase particle)
              (* (ash-particle-flicker-speed particle) dt))
        (incf (ash-particle-x particle)
              (* (+ (ash-particle-vx particle)
                    (* (ash-particle-sway-strength particle)
                       (sin (ash-particle-sway-phase particle))))
                 dt))
        (incf (ash-particle-y particle)
              (* (ash-particle-fall particle) dt)))))

(defun draw-ash-particle (particle alpha-scale)
  (let ((alpha (round (* (ash-particle-alpha particle)
                         (+ 0.45 (* 0.55 (abs (sin (ash-particle-flicker-phase particle)))))
                         alpha-scale))))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (ash-particle-x particle))
                                 (round (ash-particle-y particle))
                                 +particle-size+
                                 +particle-size+
                                 (draw-color-ptr 214 200 184 alpha)))))


;;; System

(defclass ash-particle-system (particle-system) ())

(defmethod particle-system-count ((system ash-particle-system)) 80)

(defmethod particle-system-make ((system ash-particle-system))
  (make-ash-particle))

(defmethod particle-system-reset-particle ((system ash-particle-system)
                                           particle
                                           &key initial-p)
  (reset-ash-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system ash-particle-system)
                                            particle
                                            dt)
  (update-ash-particle particle dt))

(defmethod particle-system-draw-particle ((system ash-particle-system)
                                          particle
                                          alpha-scale)
  (draw-ash-particle particle alpha-scale))
