(in-package #:immortal-coil)

(-> particle-mode-alpha (particle-field-mode) scalar)
(defun particle-mode-alpha (mode)
  (if (particle-field-transition-active-p)
      (let ((progress (particle-field-transition-progress)))
        (cond
          ((eq mode *particle-field-from-mode*) (- 1.0 progress))
          ((eq mode *particle-field-to-mode*) progress)
          (t 0.0)))
      (if (eq mode *particle-field-mode*) 1.0 0.0)))
