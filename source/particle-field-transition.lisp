(in-package #:immortal-coil)

(-> particle-field-transition-active-p () boolean)
(defun particle-field-transition-active-p ()
  (and (not (eq *particle-field-from-mode*
                *particle-field-to-mode*))
       (plusp *particle-field-transition-seconds*)
       (< *particle-field-transition-elapsed*
          *particle-field-transition-seconds*)))

(-> particle-field-transition-progress () scalar)
(defun particle-field-transition-progress ()
  (if (particle-field-transition-active-p)
      (smoothstep (/ *particle-field-transition-elapsed*
                     *particle-field-transition-seconds*))
      1.0))

(-> visible-particle-field-mode () particle-field-mode)
(defun visible-particle-field-mode ()
  (if (particle-field-transition-active-p)
      (if (< (particle-field-transition-progress) 0.5)
          *particle-field-from-mode*
          *particle-field-to-mode*)
      *particle-field-mode*))

(-> clear-particle-field-transition (particle-field-mode) particle-field-mode)
(defun clear-particle-field-transition (mode)
  (setf *particle-field-mode* mode
        *particle-field-from-mode* mode
        *particle-field-to-mode* mode
        *particle-field-transition-elapsed* 0.0
        *particle-field-transition-seconds* 0.0)
  mode)

(-> start-particle-field-transition (particle-field-mode seconds)
    particle-field-mode)
(defun start-particle-field-transition (target-mode fade-seconds)
  (let ((from-mode (visible-particle-field-mode)))
    (setf *particle-field-mode* target-mode
          *particle-field-from-mode* from-mode
          *particle-field-to-mode* target-mode
          *particle-field-transition-elapsed* 0.0
          *particle-field-transition-seconds* fade-seconds))
  target-mode)

(-> set-particle-field-mode (t
                             &key
                             (:fade-seconds seconds)
                             (:immediate t))
    particle-field-mode)
(defun set-particle-field-mode (mode
                                &key
                                  (fade-seconds *particle-field-fade-seconds*)
                                  immediate)
  (let ((target-mode (normalize-particle-field-mode mode)))
    (cond
      ((or immediate (<= fade-seconds 0.0))
       (clear-particle-field-transition target-mode))
      ((and (particle-field-transition-active-p)
            (eq *particle-field-to-mode* target-mode))
       nil)
      ((eq (visible-particle-field-mode) target-mode)
       (clear-particle-field-transition target-mode))
      (t
       (start-particle-field-transition target-mode fade-seconds))))
  *particle-field-mode*)

(-> reset-particle-field-mode (&optional t) particle-field-mode)
(defun reset-particle-field-mode (&optional (mode :rising))
  (set-particle-field-mode mode :immediate t))

(-> update-particle-field-transition (seconds) t)
(defun update-particle-field-transition (dt)
  (when (particle-field-transition-active-p)
    (incf *particle-field-transition-elapsed* dt)
    (when (>= *particle-field-transition-elapsed*
              *particle-field-transition-seconds*)
      (clear-particle-field-transition *particle-field-to-mode*))))
