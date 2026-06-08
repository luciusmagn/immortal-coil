(in-package #:immortal-coil)

(defvar *star-particles* #())

(defstruct star-particle
  x
  y
  drift-x
  drift-y
  age
  seed
  twinkle-speed
  alpha)

(defun reset-star-particle (particle &key initial-p)
  (setf (star-particle-x particle) (random-float 8.0 (- +virtual-width+ 8.0))
        (star-particle-y particle) (random-float 8.0 (- +virtual-height+ 8.0))
        (star-particle-drift-x particle) (random-float -2.2 2.2)
        (star-particle-drift-y particle) (random-float -0.7 0.7)
        (star-particle-age particle) (if initial-p
                                         (random-float 0.0 40.0)
                                         0.0)
        (star-particle-seed particle) (random-float 0.0 (* 2 pi))
        (star-particle-twinkle-speed particle) (random-float 0.55 1.85)
        (star-particle-alpha particle) (get-random-value 90 240))
  particle)

(defun current-star-particle-count ()
  (if (realp *star-particle-count*)
      (max 0 (round *star-particle-count*))
      (progn
        (runtime-warn "Invalid star particle count: ~s" *star-particle-count*)
        0)))

(defun resize-star-particles (count)
  (let ((old-particles *star-particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-star-particle (make-star-particle)
                                            :initial-p t))))
    (setf *star-particles* new-particles)))

(defun reset-star-particles ()
  (let ((count (current-star-particle-count)))
    (setf *star-particles* (make-array count))
    (loop for i below count
          do (setf (aref *star-particles* i)
                   (reset-star-particle (make-star-particle)
                                        :initial-p t)))))

(defun ensure-star-particle-count ()
  (let ((count (current-star-particle-count)))
    (unless (= (length *star-particles*) count)
      (resize-star-particles count))))

(defun wrap-star-particle (particle)
  (when (< (star-particle-x particle) -4.0)
    (setf (star-particle-x particle) (+ +virtual-width+ 4.0)))
  (when (> (star-particle-x particle) (+ +virtual-width+ 4.0))
    (setf (star-particle-x particle) -4.0))
  (when (< (star-particle-y particle) -4.0)
    (setf (star-particle-y particle) (+ +virtual-height+ 4.0)))
  (when (> (star-particle-y particle) (+ +virtual-height+ 4.0))
    (setf (star-particle-y particle) -4.0)))

(defun update-star-particle (particle dt)
  (incf (star-particle-age particle) dt)
  (incf (star-particle-x particle)
        (* (star-particle-drift-x particle) dt))
  (incf (star-particle-y particle)
        (* (star-particle-drift-y particle) dt))
  (wrap-star-particle particle))

(defun update-star-particles (dt)
  (loop for particle across *star-particles*
        do (update-star-particle particle dt)))

(defun star-particle-visible-alpha (particle)
  (let* ((wave (* 0.5
                  (+ 1.0
                     (sin (+ (star-particle-seed particle)
                             (* (star-particle-age particle)
                                (star-particle-twinkle-speed particle)))))))
         (glint (* 0.5
                   (+ 1.0
                      (sin (+ (* 1.7 (star-particle-seed particle))
                              (* (star-particle-age particle)
                                 (star-particle-twinkle-speed particle)
                                 4.6))))))
         (brightness (+ 0.18
                        (* 0.62 (expt wave 2.8))
                        (* 0.20 (expt glint 16.0)))))
    (round (* (star-particle-alpha particle)
              (clamp01 brightness)))))

(defun star-particle-core-size (alpha)
  (if (> alpha 210)
      2
      +star-particle-size+))

(defun draw-star-particle-core (x y size color-ptr)
  (claylib/ll:draw-rectangle (- x (floor size 2))
                             (- y (floor size 2))
                             size
                             size
                             color-ptr))

(defun draw-star-particle (particle alpha-scale)
  (let ((alpha (round (* (star-particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (let* ((x (round (star-particle-x particle)))
             (y (round (star-particle-y particle)))
             (size (star-particle-core-size alpha)))
        (draw-star-particle-core x
                                 y
                                 size
                                 (draw-color-ptr 255 255 255 alpha))
        (when (> alpha 165)
          (let ((glint-alpha (round (* alpha 0.42))))
            (claylib/ll:draw-rectangle
             (- x 1)
             y
             3
             1
             (draw-color-ptr 255 255 255 glint-alpha))
            (claylib/ll:draw-rectangle
             x
             (- y 1)
             1
             3
             (draw-color-ptr 255 255 255 glint-alpha))))))))

(defun draw-star-particles (alpha-scale)
  (loop for particle across *star-particles*
        do (draw-star-particle particle alpha-scale)))
