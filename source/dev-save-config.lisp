(in-package #:immortal-coil)

(defparameter *dev-save-overrides-enabled-p* t)

(-> disabled-dev-save-env-value-p (string) boolean)
(defun disabled-dev-save-env-value-p (value)
  (not (null (member (string-downcase value)
                     '("1" "true" "yes" "on")
                     :test #'string=))))

(-> dev-save-overrides-enabled-p () boolean)
(defun dev-save-overrides-enabled-p ()
  (and *dev-save-overrides-enabled-p*
       (not (disabled-dev-save-env-value-p
             (or (uiop:getenv "IMMORTAL_COIL_DISABLE_DEV_SAVE")
                 "")))))
