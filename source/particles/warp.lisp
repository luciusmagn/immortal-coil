(in-package #:immortal-coil)

(defparameter *warp-particle-count* 220)

(defstruct warp-particle
  angle
  distance
  speed
  length
  alpha
  seed)

(defun warp-max-distance ()
  (+ 120.0
     (sqrt (+ (expt +virtual-center-x+ 2)
              (expt +virtual-center-y+ 2)))))

(defun reset-warp-particle (particle &key initial-p)
  (setf (warp-particle-angle particle) (random-float 0.0 (* 2 pi))
        (warp-particle-distance particle) (if initial-p
                                              (random-float 0.0
                                                            (warp-max-distance))
                                              (random-float 0.0 48.0))
        (warp-particle-speed particle) (random-float 360.0 760.0)
        (warp-particle-length particle) (random-float 18.0 84.0)
        (warp-particle-alpha particle) (get-random-value 92 242)
        (warp-particle-seed particle) (random-float 0.0 (* 2 pi)))
  particle)

(defun update-warp-particle (particle dt)
  (incf (warp-particle-distance particle)
        (* (warp-particle-speed particle) dt))
  (when (> (warp-particle-distance particle)
           (warp-max-distance))
    (reset-warp-particle particle :initial-p nil))
  particle)

(defun warp-particle-point (particle distance)
  (values (+ +virtual-center-x+
             (* (cos (warp-particle-angle particle)) distance))
          (+ +virtual-center-y+
             (* (sin (warp-particle-angle particle)) distance))))

(defun warp-particle-visible-alpha (particle)
  (let* ((distance (warp-particle-distance particle))
         (fade-in (clamp01 (/ distance 160.0)))
         (edge-fade (clamp01 (/ (- (warp-max-distance) distance) 180.0)))
         (pulse (+ 0.84
                   (* 0.16
                      (sin (+ (warp-particle-seed particle)
                              (* distance 0.018)))))))
    (round (* (warp-particle-alpha particle)
              fade-in
              edge-fade
              pulse))))

(defun warp-particle-visible-length (particle)
  (min 130.0
       (+ (warp-particle-length particle)
          (* (warp-particle-distance particle) 0.10))))

(defun draw-warp-line (x1 y1 x2 y2 alpha)
  (claylib/ll:draw-line (round x1)
                        (round y1)
                        (round x2)
                        (round y2)
                        (draw-color-ptr 255 255 255 alpha))
  (when (> alpha 205)
    (claylib/ll:draw-line (round (+ x1 1.0))
                          (round y1)
                          (round (+ x2 1.0))
                          (round y2)
                          (draw-color-ptr 255
                                          255
                                          255
                                          (round (* alpha 0.48))))))

(defun draw-warp-particle (particle alpha-scale)
  (let ((alpha (round (* (warp-particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (let* ((distance (warp-particle-distance particle))
             (length (warp-particle-visible-length particle))
             (inner (max 0.0 (- distance length))))
        (multiple-value-bind (x1 y1)
            (warp-particle-point particle inner)
          (multiple-value-bind (x2 y2)
              (warp-particle-point particle distance)
            (draw-warp-line x1 y1 x2 y2 alpha)))))))


;;; System

(defclass warp-particle-system (particle-system) ())

(defmethod particle-system-count ((system warp-particle-system))
  (if (realp *warp-particle-count*)
      (max 0 (round *warp-particle-count*))
      (progn
        (runtime-warn "Invalid warp particle count: ~s"
                      *warp-particle-count*)
        0)))

(defmethod particle-system-make ((system warp-particle-system))
  (make-warp-particle))

(defmethod particle-system-reset-particle ((system warp-particle-system)
                                           particle
                                           &key initial-p)
  (reset-warp-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system warp-particle-system)
                                            particle
                                            dt)
  (update-warp-particle particle dt))

(defmethod particle-system-draw-particle ((system warp-particle-system)
                                          particle
                                          alpha-scale)
  (draw-warp-particle particle alpha-scale))
