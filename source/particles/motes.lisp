(in-package #:immortal-coil)

;;; Dust motes: faint flecks hanging in still air, drifting slowly and
;;; pulsing in and out as they catch the light. They wrap at the edges
;;; rather than falling, so the air just hangs. For the sterile, held
;;; places (the facility, containment, the under-court of the kept).

(defstruct mote-particle
  x
  y
  vx
  vy
  pulse-phase
  pulse-speed
  base-alpha
  size)

(defun reset-mote-particle (particle &key initial-p)
  (declare (ignore initial-p))
  (setf (mote-particle-x particle) (random-float 0.0 +virtual-width+)
        (mote-particle-y particle) (random-float 0.0 +virtual-height+)
        (mote-particle-vx particle) (random-float -7.0 7.0)
        (mote-particle-vy particle) (random-float -5.0 5.0)
        (mote-particle-pulse-phase particle) (random-float 0.0 (* 2 pi))
        (mote-particle-pulse-speed particle) (random-float 0.3 1.0)
        (mote-particle-base-alpha particle) (get-random-value 40 120)
        (mote-particle-size particle) (get-random-value 1 2))
  particle)

(defun mote-wrap (value limit)
  (cond ((< value -8.0) (+ limit 8.0))
        ((> value (+ limit 8.0)) -8.0)
        (t value)))

(defun update-mote-particle (particle dt)
  (incf (mote-particle-pulse-phase particle)
        (* (mote-particle-pulse-speed particle) dt))
  (setf (mote-particle-x particle)
        (mote-wrap (+ (mote-particle-x particle)
                      (* (mote-particle-vx particle) dt))
                   +virtual-width+)
        (mote-particle-y particle)
        (mote-wrap (+ (mote-particle-y particle)
                      (* (mote-particle-vy particle) dt))
                   +virtual-height+)))

(defun draw-mote-particle (particle alpha-scale)
  (let ((alpha (round (* (mote-particle-base-alpha particle)
                         (+ 0.35 (* 0.65 (abs (sin (mote-particle-pulse-phase particle)))))
                         alpha-scale))))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (mote-particle-x particle))
                                 (round (mote-particle-y particle))
                                 (mote-particle-size particle)
                                 (mote-particle-size particle)
                                 (draw-color-ptr 222 226 235 alpha)))))


;;; System

(defclass mote-particle-system (particle-system) ())

(defmethod particle-system-count ((system mote-particle-system)) 60)

(defmethod particle-system-make ((system mote-particle-system))
  (make-mote-particle))

(defmethod particle-system-reset-particle ((system mote-particle-system)
                                           particle
                                           &key initial-p)
  (reset-mote-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system mote-particle-system)
                                            particle
                                            dt)
  (update-mote-particle particle dt))

(defmethod particle-system-draw-particle ((system mote-particle-system)
                                          particle
                                          alpha-scale)
  (draw-mote-particle particle alpha-scale))
