(in-package #:immortal-coil)

(defun title-particle-visible-alpha (particle)
  (if (minusp (title-particle-phase particle))
      0
      (round (* (title-particle-alpha particle)
                (clamp01 (/ (title-particle-phase particle) 0.06))))))

(defun draw-title-particle (particle alpha-scale)
  (let ((alpha (round (* (title-particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (multiple-value-bind (x y)
          (title-particle-position particle)
        (claylib/ll:draw-rectangle (round x)
                                   (round y)
                                   +particle-size+
                                   +particle-size+
                                   (claylib::c-ptr
                                    (title-logo-particle-color x y alpha)))))))

(defun draw-title-particles (&optional (alpha-scale 1.0))
  (loop for particle across *title-particles*
        do (draw-title-particle particle alpha-scale)))
