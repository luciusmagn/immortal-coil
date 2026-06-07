(in-package #:immortal-coil)

(defvar *particle-field-mode* :rising)
(defvar *particle-field-from-mode* :rising)
(defvar *particle-field-to-mode* :rising)
(defvar *particle-field-transition-elapsed* 0.0)
(defvar *particle-field-transition-seconds* 0.0)

(defparameter *particle-field-modes* '(:rising :stars :title-menu))

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

(-> reset-particle-field-mode (&optional t) particle-field-mode)
(defun reset-particle-field-mode (&optional (mode :rising))
  (set-particle-field-mode mode :immediate t))

(-> reset-particles (&optional t) particle-field-mode)
(defun reset-particles (&optional (mode :rising))
  (reset-rising-particles)
  (reset-star-particles)
  (reset-title-particles)
  (reset-particle-field-mode mode))

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

(-> update-particle-field-transition (seconds) t)
(defun update-particle-field-transition (dt)
  (when (particle-field-transition-active-p)
    (incf *particle-field-transition-elapsed* dt)
    (when (>= *particle-field-transition-elapsed*
              *particle-field-transition-seconds*)
      (setf *particle-field-from-mode* *particle-field-to-mode*
            *particle-field-mode* *particle-field-to-mode*
            *particle-field-transition-elapsed* 0.0
            *particle-field-transition-seconds* 0.0))))

(-> particle-mode-alpha (particle-field-mode) scalar)
(defun particle-mode-alpha (mode)
  (if (particle-field-transition-active-p)
      (let ((progress (particle-field-transition-progress)))
        (cond
          ((eq mode *particle-field-from-mode*) (- 1.0 progress))
          ((eq mode *particle-field-to-mode*) progress)
          (t 0.0)))
      (if (eq mode *particle-field-mode*) 1.0 0.0)))

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

(-> particle-field-state-data () plist)
(defun particle-field-state-data ()
  (list :mode *particle-field-mode*
        :from-mode *particle-field-from-mode*
        :to-mode *particle-field-to-mode*
        :transition-elapsed *particle-field-transition-elapsed*
        :transition-seconds *particle-field-transition-seconds*))

(-> restore-particle-field-state (t) t)
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
