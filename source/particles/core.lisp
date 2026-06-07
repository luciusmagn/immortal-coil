(in-package #:immortal-coil)

(-> reset-particles (&optional t) particle-field-mode)
(defun reset-particles (&optional (mode :rising))
  (reset-particle-modes)
  (reset-particle-field-mode mode))

(-> update-particles (seconds) t)
(defun update-particles (dt)
  (ensure-particle-count)
  (update-particle-field-transition dt)
  (loop for mode in *particle-field-modes*
        when (plusp (particle-mode-alpha mode))
          do (update-particle-mode mode dt)))

(-> draw-particles (&optional scalar) t)
(defun draw-particles (&optional (alpha-scale 1.0))
  (loop for mode in *particle-field-modes*
        for mode-alpha = (* alpha-scale (particle-mode-alpha mode))
        when (plusp mode-alpha)
          do (draw-particle-mode mode mode-alpha)))
