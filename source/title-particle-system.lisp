(in-package #:immortal-coil)

(defvar *title-particles* (make-array 0 :adjustable t :fill-pointer 0))
(defvar *title-particle-spawn-debt* 0.0)

(defstruct title-particle
  phase
  speed
  seed
  entry-angle
  entry-offset
  orbit-radius
  orbit-turns
  exit-angle
  branch-side
  branch-spread
  branch-curve
  alpha)

(defun random-title-exit-angle ()
  (let ((base (case (get-random-value 0 3)
                (0 (* pi 1.16))
                (1 (* pi 1.36))
                (2 (* pi 1.64))
                (t (* pi 1.84)))))
    (+ base (random-float -0.06 0.06))))

(defun random-title-entry-angle ()
  (+ (/ pi 2.0)
     (random-float -0.22 0.22)))

(defun current-title-particle-count ()
  (if (realp *title-particle-count*)
      (max 0 (round *title-particle-count*))
      (progn
        (runtime-warn "Invalid title particle count: ~s" *title-particle-count*)
        0)))

(defun reset-title-particle (particle)
  (let ((exit-angle (random-title-exit-angle)))
    (setf (title-particle-phase particle) 0.0
          (title-particle-speed particle) (random-float 0.020 0.030)
          (title-particle-seed particle) (random-float 0.0 (* 2 pi))
          (title-particle-entry-angle particle) (random-title-entry-angle)
          (title-particle-entry-offset particle) (random-float -56.0 56.0)
          (title-particle-orbit-radius particle) (+ +title-orbit-radius+
                                                    (random-float -16.0 16.0))
          (title-particle-orbit-turns particle) (get-random-value 1 3)
          (title-particle-exit-angle particle) exit-angle
          (title-particle-branch-side particle) (if (minusp (cos exit-angle))
                                                    -1.0
                                                    1.0)
          (title-particle-branch-spread particle) (random-float 90.0 360.0)
          (title-particle-branch-curve particle) (random-float -110.0 110.0)
          (title-particle-alpha particle) (get-random-value 110 230)))
  particle)

(defun reset-title-particles ()
  (setf *title-particles* (make-array 0 :adjustable t :fill-pointer 0)
        *title-particle-spawn-debt* 0.0))

(defun update-title-particle (particle dt)
  (incf (title-particle-phase particle)
        (* (title-particle-speed particle) dt)))

(defun title-particle-finished-p (particle)
  (> (title-particle-phase particle) 1.0))

(defun remove-finished-title-particles ()
  (let ((write-index 0)
        (count (length *title-particles*)))
    (loop for read-index below count
          for particle = (aref *title-particles* read-index)
          unless (title-particle-finished-p particle)
            do (setf (aref *title-particles* write-index) particle
                     write-index (1+ write-index)))
    (setf (fill-pointer *title-particles*) write-index)))

(defun title-spawn-scale ()
  (let ((cap (current-title-particle-count)))
    (if (zerop cap)
        0.0
        (expt (clamp01 (- 1.0 (/ (length *title-particles*) cap)))
              1.7))))

(defun spawn-title-particle ()
  (vector-push-extend
   (reset-title-particle (make-title-particle))
   *title-particles*))

(defun spawn-title-particles (dt)
  (let ((cap (current-title-particle-count)))
    (incf *title-particle-spawn-debt*
          (* *title-particle-spawn-rate*
             (title-spawn-scale)
             dt))
    (loop while (and (>= *title-particle-spawn-debt* 1.0)
                     (< (length *title-particles*) cap))
          do (decf *title-particle-spawn-debt* 1.0)
             (spawn-title-particle))))

(defun update-title-particles (dt)
  (spawn-title-particles dt)
  (loop for particle across *title-particles*
        do (update-title-particle particle dt))
  (remove-finished-title-particles))
