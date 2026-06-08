(in-package #:immortal-coil)

;;; Mode state

(defvar *particle-field-mode* :rising)
(defvar *particle-field-from-mode* :rising)
(defvar *particle-field-to-mode* :rising)
(defvar *particle-field-transition-elapsed* 0.0)
(defvar *particle-field-transition-seconds* 0.0)

(-> valid-particle-field-mode-p (t) boolean)
(defun valid-particle-field-mode-p (mode)
  (typep mode 'particle-field-mode))

(-> normalize-particle-field-mode (t) particle-field-mode)
(defun normalize-particle-field-mode (mode)
  (let ((normalized (typecase mode
                      (keyword mode)
                      (symbol (intern (symbol-name mode) "KEYWORD"))
                      (string (intern (string-upcase mode) "KEYWORD")))))
    (cond
      ((valid-particle-field-mode-p normalized)
       normalized)
      (t
       (runtime-warn "Unknown particle field mode: ~a" mode)
       *particle-field-mode*))))


;;; Transitions

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


;;; Alpha

(-> particle-mode-alpha (particle-field-mode) scalar)
(defun particle-mode-alpha (mode)
  (if (particle-field-transition-active-p)
      (let ((progress (particle-field-transition-progress)))
        (cond
          ((eq mode *particle-field-from-mode*) (- 1.0 progress))
          ((eq mode *particle-field-to-mode*) progress)
          (t 0.0)))
      (if (eq mode *particle-field-mode*) 1.0 0.0)))


;;; Save data

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


;;; Mode dispatch

(defparameter *particle-field-modes* '(:rising :stars :title-menu))

(-> reset-particle-modes () t)
(defun reset-particle-modes ()
  (reset-rising-particles)
  (reset-star-particles)
  (reset-title-particles))

(-> ensure-particle-count () t)
(defun ensure-particle-count ()
  (ensure-rising-particle-count)
  (ensure-star-particle-count))

(-> update-particle-mode (particle-field-mode seconds) t)
(defun update-particle-mode (mode dt)
  (case mode
    (:rising (update-rising-particles dt))
    (:stars (update-star-particles dt))
    (:title-menu (update-title-particles dt))
    (t (runtime-warn "Cannot update unknown particle mode: ~a" mode))))

(-> draw-particle-mode (particle-field-mode scalar) t)
(defun draw-particle-mode (mode alpha-scale)
  (case mode
    (:rising (draw-rising-particles alpha-scale))
    (:stars (draw-star-particles alpha-scale))
    (:title-menu (draw-title-particles alpha-scale))
    (t (runtime-warn "Cannot draw unknown particle mode: ~a" mode))))


;;; Public field loop

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
