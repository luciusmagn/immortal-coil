(in-package #:immortal-coil)

(-> particle-field-state-data () particle-field-save-data)
(defun particle-field-state-data ()
  (list :mode *particle-field-mode*
        :from-mode *particle-field-from-mode*
        :to-mode *particle-field-to-mode*
        :transition-elapsed *particle-field-transition-elapsed*
        :transition-seconds *particle-field-transition-seconds*))

(-> particle-field-state-number (plist keyword) scalar)
(defun particle-field-state-number (data key)
  (let ((value (getf data key)))
    (if (realp value)
        (max 0.0 value)
        0.0)))

(-> particle-field-state-mode (plist keyword particle-field-mode)
    particle-field-mode)
(defun particle-field-state-mode (data key default)
  (let ((mode (getf data key)))
    (if (valid-particle-field-mode-p mode)
        mode
        default)))

(-> ensure-particle-count-maybe () t)
(defun ensure-particle-count-maybe ()
  (when (fboundp 'ensure-particle-count)
    (funcall (symbol-function 'ensure-particle-count))))

(-> restore-particle-field-state (t) t)
(defun restore-particle-field-state (data)
  (ensure-particle-count-maybe)
  (if (and (plistp data)
           (valid-particle-field-mode-p (getf data :mode)))
      (let ((mode (getf data :mode)))
        (setf *particle-field-mode* mode
              *particle-field-from-mode*
              (particle-field-state-mode data :from-mode mode)
              *particle-field-to-mode*
              (particle-field-state-mode data :to-mode mode)
              *particle-field-transition-elapsed*
              (particle-field-state-number data :transition-elapsed)
              *particle-field-transition-seconds*
              (particle-field-state-number data :transition-seconds)))
      (reset-particle-field-mode :rising)))
