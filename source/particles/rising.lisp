(in-package #:immortal-coil)

(defstruct rising-particle
  x
  y
  vx
  vy
  wobble-phase
  wobble-speed
  wobble-strength
  age
  ttl
  alpha)

(defun reset-rising-particle (particle &key initial-p)
  (let ((ttl (random-float 80.0 120.0)))
    (setf (rising-particle-x particle) (random-float 20.0 (- +virtual-width+ 20.0))
          (rising-particle-y particle) (if initial-p
                                           (random-float -20.0 (+ +virtual-height+ 100.0))
                                           (random-float (+ +virtual-height+ 10.0)
                                                         (+ +virtual-height+ 140.0)))
          (rising-particle-vx particle) (random-float -3.0 3.0)
          (rising-particle-vy particle) (random-float -20.0 -12.0)
          (rising-particle-wobble-phase particle) (random-float 0.0 (* 2 pi))
          (rising-particle-wobble-speed particle) (random-float 0.6 1.5)
          (rising-particle-wobble-strength particle) (random-float 8.0 20.0)
          (rising-particle-age particle) (if initial-p
                                             (random-float 0.0 ttl)
                                             0.0)
          (rising-particle-ttl particle) ttl
          (rising-particle-alpha particle) (get-random-value 100 220)))
  particle)

(defun update-rising-particle (particle dt)
  (incf (rising-particle-age particle) dt)
  (if (or (< (rising-particle-y particle) -120)
          (< (rising-particle-x particle) -30)
          (> (rising-particle-x particle) (+ +virtual-width+ 30)))
      (reset-rising-particle particle)
      (progn
        (incf (rising-particle-wobble-phase particle)
              (* (rising-particle-wobble-speed particle) dt))
        (incf (rising-particle-x particle)
              (* (+ (rising-particle-vx particle)
                    (* (rising-particle-wobble-strength particle)
                       (sin (rising-particle-wobble-phase particle))))
                 dt))
        (incf (rising-particle-y particle)
              (* (rising-particle-vy particle) dt)))))

(defun rising-particle-visible-alpha (particle)
  (round (* (rising-particle-alpha particle)
            (clamp01 (/ (rising-particle-age particle) 0.8)))))

(defun draw-rising-particle (particle alpha-scale)
  (let ((alpha (round (* (rising-particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (rising-particle-x particle))
                                 (round (rising-particle-y particle))
                                 +particle-size+
                                 +particle-size+
                                 (draw-color-ptr 255 255 255 alpha)))))


;;; System

(defclass rising-particle-system (particle-system) ())

(defmethod particle-system-count ((system rising-particle-system))
  (if (realp *particle-count*)
      (max 0 (round *particle-count*))
      (progn
        (runtime-warn "Invalid particle count: ~s" *particle-count*)
        0)))

(defmethod particle-system-make ((system rising-particle-system))
  (make-rising-particle))

(defmethod particle-system-reset-particle ((system rising-particle-system)
                                           particle
                                           &key initial-p)
  (reset-rising-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system rising-particle-system)
                                            particle
                                            dt)
  (update-rising-particle particle dt))

(defmethod particle-system-draw-particle ((system rising-particle-system)
                                          particle
                                          alpha-scale)
  (draw-rising-particle particle alpha-scale))
