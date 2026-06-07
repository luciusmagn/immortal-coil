(in-package #:immortal-coil)

(defvar *particle-field-mode* :rising)
(defvar *particle-field-from-mode* :rising)
(defvar *particle-field-to-mode* :rising)
(defvar *particle-field-transition-elapsed* 0.0)
(defvar *particle-field-transition-seconds* 0.0)

(defun valid-particle-field-mode-p (mode)
  (member mode '(:rising :stars)))

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

(defun particle-field-transition-active-p ()
  (and (not (eq *particle-field-from-mode*
                *particle-field-to-mode*))
       (plusp *particle-field-transition-seconds*)
       (< *particle-field-transition-elapsed*
          *particle-field-transition-seconds*)))

(defun particle-field-transition-progress ()
  (if (particle-field-transition-active-p)
      (smoothstep (/ *particle-field-transition-elapsed*
                     *particle-field-transition-seconds*))
      1.0))

(defun visible-particle-field-mode ()
  (if (particle-field-transition-active-p)
      (if (< (particle-field-transition-progress) 0.5)
          *particle-field-from-mode*
          *particle-field-to-mode*)
      *particle-field-mode*))

(defun set-particle-field-mode (mode
                                &key
                                  (fade-seconds *particle-field-fade-seconds*)
                                  immediate)
  (let ((target-mode (normalize-particle-field-mode mode)))
    (cond
      ((or immediate (<= fade-seconds 0.0))
       (setf *particle-field-mode* target-mode
             *particle-field-from-mode* target-mode
             *particle-field-to-mode* target-mode
             *particle-field-transition-elapsed* 0.0
             *particle-field-transition-seconds* 0.0))
      ((and (particle-field-transition-active-p)
            (eq *particle-field-to-mode* target-mode))
       nil)
      ((eq (visible-particle-field-mode) target-mode)
       (setf *particle-field-mode* target-mode
             *particle-field-from-mode* target-mode
             *particle-field-to-mode* target-mode
             *particle-field-transition-elapsed* 0.0
             *particle-field-transition-seconds* 0.0))
      (t
       (let ((from-mode (visible-particle-field-mode)))
         (setf *particle-field-mode* target-mode
               *particle-field-from-mode* from-mode
               *particle-field-to-mode* target-mode
               *particle-field-transition-elapsed* 0.0
               *particle-field-transition-seconds* fade-seconds)))))
  *particle-field-mode*)

(defun reset-particle-field-mode (&optional (mode :rising))
  (set-particle-field-mode mode :immediate t))

(defun reset-particles ()
  (reset-rising-particles)
  (reset-star-particles)
  (reset-particle-field-mode :rising))

(defun ensure-particle-count ()
  (ensure-rising-particle-count)
  (ensure-star-particle-count))

(defun update-particle-field-transition (dt)
  (when (particle-field-transition-active-p)
    (incf *particle-field-transition-elapsed* dt)
    (when (>= *particle-field-transition-elapsed*
              *particle-field-transition-seconds*)
      (setf *particle-field-from-mode* *particle-field-to-mode*
            *particle-field-mode* *particle-field-to-mode*
            *particle-field-transition-elapsed* 0.0
            *particle-field-transition-seconds* 0.0))))

(defun particle-mode-alpha (mode)
  (if (particle-field-transition-active-p)
      (let ((progress (particle-field-transition-progress)))
        (cond
          ((eq mode *particle-field-from-mode*) (- 1.0 progress))
          ((eq mode *particle-field-to-mode*) progress)
          (t 0.0)))
      (if (eq mode *particle-field-mode*) 1.0 0.0)))

(defun update-particles (dt)
  (ensure-particle-count)
  (update-particle-field-transition dt)
  (when (plusp (particle-mode-alpha :rising))
    (update-rising-particles dt))
  (when (plusp (particle-mode-alpha :stars))
    (update-star-particles dt)))

(defun draw-particles ()
  (let ((rising-alpha (particle-mode-alpha :rising))
        (star-alpha (particle-mode-alpha :stars)))
    (when (plusp rising-alpha)
      (draw-rising-particles rising-alpha))
    (when (plusp star-alpha)
      (draw-star-particles star-alpha))))

(defun particle-field-state-data ()
  (list :mode *particle-field-mode*
        :from-mode *particle-field-from-mode*
        :to-mode *particle-field-to-mode*
        :transition-elapsed *particle-field-transition-elapsed*
        :transition-seconds *particle-field-transition-seconds*))

(defun restore-particle-field-state (data)
  (ensure-particle-count)
  (if (and (listp data)
           (valid-particle-field-mode-p (getf data :mode)))
      (let ((mode (getf data :mode)))
        (setf *particle-field-mode* mode
              *particle-field-from-mode*
              (if (valid-particle-field-mode-p (getf data :from-mode))
                  (getf data :from-mode)
                  mode)
              *particle-field-to-mode*
              (if (valid-particle-field-mode-p (getf data :to-mode))
                  (getf data :to-mode)
                  mode)
              *particle-field-transition-elapsed*
              (if (realp (getf data :transition-elapsed))
                  (max 0.0 (getf data :transition-elapsed))
                  0.0)
              *particle-field-transition-seconds*
              (if (realp (getf data :transition-seconds))
                  (max 0.0 (getf data :transition-seconds))
                  0.0)))
      (reset-particle-field-mode :rising)))
