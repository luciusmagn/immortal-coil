(in-package #:immortal-coil)

(defvar *rising-particles* #())

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

(defun current-rising-particle-count ()
  (if (realp *particle-count*)
      (max 0 (round *particle-count*))
      (progn
        (runtime-warn "Invalid particle count: ~s" *particle-count*)
        0)))

(defun resize-rising-particles (count)
  (let ((old-particles *rising-particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-rising-particle (make-rising-particle)
                                              :initial-p t))))
    (setf *rising-particles* new-particles)))

(defun reset-rising-particles ()
  (let ((count (current-rising-particle-count)))
    (setf *rising-particles* (make-array count))
    (loop for i below count
          do (setf (aref *rising-particles* i)
                   (reset-rising-particle (make-rising-particle)
                                          :initial-p t)))))

(defun ensure-rising-particle-count ()
  (let ((count (current-rising-particle-count)))
    (unless (= (length *rising-particles*) count)
      (resize-rising-particles count))))

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

(defun update-rising-particles (dt)
  (loop for particle across *rising-particles*
        do (update-rising-particle particle dt)))

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

(defun draw-rising-particles (alpha-scale)
  (loop for particle across *rising-particles*
        do (draw-rising-particle particle alpha-scale)))
