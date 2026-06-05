(in-package #:immortal-coil)

(defvar *particles* #())

(defstruct particle
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

(defun reset-particle (particle &key initial-p)
  (let ((ttl (random-float 80.0 120.0)))
    (setf (particle-x particle) (random-float 20.0 (- +virtual-width+ 20.0))
          (particle-y particle) (if initial-p
                                    (random-float -20.0 (+ +virtual-height+ 100.0))
                                    (random-float (+ +virtual-height+ 10.0)
                                                  (+ +virtual-height+ 140.0)))
          (particle-vx particle) (random-float -3.0 3.0)
          (particle-vy particle) (random-float -20.0 -12.0)
          (particle-wobble-phase particle) (random-float 0.0 (* 2 pi))
          (particle-wobble-speed particle) (random-float 0.6 1.5)
          (particle-wobble-strength particle) (random-float 8.0 20.0)
          (particle-age particle) (if initial-p
                                      (random-float 0.0 ttl)
                                      0.0)
          (particle-ttl particle) ttl
          (particle-alpha particle) (get-random-value 100 220)))
  particle)

(defun current-particle-count ()
  (max 0 (round *particle-count*)))

(defun resize-particles (count)
  (let ((old-particles *particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-particle (make-particle) :initial-p t))))
    (setf *particles* new-particles)))

(defun reset-particles ()
  (let ((count (current-particle-count)))
    (setf *particles* (make-array count))
    (loop for i below count
          do (setf (aref *particles* i)
                   (reset-particle (make-particle) :initial-p t)))))

(defun ensure-particle-count ()
  (let ((count (current-particle-count)))
    (unless (= (length *particles*) count)
      (resize-particles count))))

(defun update-particle (particle dt)
  (incf (particle-age particle) dt)
  (if (or (< (particle-y particle) -120)
          (< (particle-x particle) -30)
          (> (particle-x particle) (+ +virtual-width+ 30)))
      (reset-particle particle)
      (progn
        (incf (particle-wobble-phase particle)
              (* (particle-wobble-speed particle) dt))
        (incf (particle-x particle)
              (* (+ (particle-vx particle)
                    (* (particle-wobble-strength particle)
                       (sin (particle-wobble-phase particle))))
                 dt))
        (incf (particle-y particle) (* (particle-vy particle) dt)))))

(defun update-particles (dt)
  (ensure-particle-count)
  (loop for particle across *particles*
        do (update-particle particle dt)))

(defun particle-visible-alpha (particle)
  (round (* (particle-alpha particle)
            (clamp01 (/ (particle-age particle) 0.8)))))

(defun draw-particle (particle)
  (let ((alpha (particle-visible-alpha particle)))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (particle-x particle))
                                 (round (particle-y particle))
                                 +particle-size+
                                 +particle-size+
                                 (claylib::c-ptr
                                  (make-color 255 255 255 alpha))))))

(defun draw-particles ()
  (loop for particle across *particles*
        do (draw-particle particle)))
