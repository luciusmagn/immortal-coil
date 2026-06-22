(in-package #:immortal-coil)

;;; Registry

(defvar *particle-field-definitions* (make-hash-table :test #'eq))
(defvar *particle-field-modes* nil)
(defvar *particle-field-mode* :rising)
(defvar *particle-field-from-mode* :rising)
(defvar *particle-field-to-mode* :rising)
(defvar *particle-field-transition-elapsed* 0.0)
(defvar *particle-field-transition-seconds* 0.0)

(-> particle-field-mode-keyword (t) particle-field-mode)
(defun particle-field-mode-keyword (mode)
  (or (normalize-keyword-designator mode)
      (progn
        (runtime-warn "Expected a particle field mode, got: ~s" mode)
        :rising)))

(-> particle-field-handler-function (t string runtime-function) runtime-function)
(defun particle-field-handler-function (handler description fallback-function)
  (handler-case
      (or (resolve-function-designator handler)
          (progn
            (runtime-warn "Particle field ~a is not a function designator: ~s"
                          description
                          handler)
            fallback-function))
    (error (condition)
      (runtime-warn "Particle field ~a failed to resolve: ~s (~a)"
                    description
                    handler
                    condition)
      fallback-function)))

(-> make-function-particle-field-definition
    (particle-field-mode runtime-function runtime-function runtime-function runtime-function boolean)
    particle-field-definition)
(defun make-function-particle-field-definition (mode reset-function
                                                ensure-function update-function
                                                draw-function builtin-p)
  (make-instance 'function-particle-field-definition
                 :id mode
                 :reset-function reset-function
                 :ensure-function ensure-function
                 :update-function update-function
                 :draw-function draw-function
                 :builtin-p builtin-p))

(-> register-particle-field-definition (t &optional t t t t t)
    particle-field-definition)
(defun register-particle-field-definition (definition-or-mode
                                           &optional
                                             reset-function
                                             ensure-function
                                             update-function
                                             draw-function
                                             builtin-p)
  (let* ((definition
           (if (typep definition-or-mode 'particle-field-definition)
               definition-or-mode
               (make-function-particle-field-definition
                definition-or-mode
                reset-function
                ensure-function
                update-function
                draw-function
                builtin-p)))
         (mode (particle-field-definition-id definition)))
    (setf (gethash mode *particle-field-definitions*) definition)
    (unless (member mode *particle-field-modes* :test #'eq)
      (setf *particle-field-modes*
            (append *particle-field-modes* (list mode))))
    definition))

(-> registered-particle-field-modes () list)
(defun registered-particle-field-modes ()
  (sort (copy-list *particle-field-modes*)
        #'string<
        :key #'symbol-name))

(-> dialog-particle-field-kind
    (t &key (:reset t) (:ensure t) (:update t) (:draw t) (:builtin-p boolean))
    particle-field-mode)
(defun dialog-particle-field-kind (mode &key reset ensure update draw builtin-p)
  (let ((field-mode (particle-field-mode-keyword mode)))
    (register-particle-field-definition
     (make-function-particle-field-definition
      field-mode
      (if reset
          (particle-field-handler-function reset
                                           "reset handler"
                                           #'particle-field-reset-fallback)
          #'particle-field-reset-fallback)
      (if ensure
          (particle-field-handler-function ensure
                                           "ensure handler"
                                           #'particle-field-ensure-fallback)
          #'particle-field-ensure-fallback)
      (if update
          (particle-field-handler-function update
                                           "update handler"
                                           #'particle-field-update-fallback)
          #'particle-field-update-fallback)
      (if draw
          (particle-field-handler-function draw
                                           "draw handler"
                                           #'particle-field-draw-fallback)
          #'particle-field-draw-fallback)
      builtin-p))
    field-mode))

(-> reset-script-particle-field-modes () t)
(defun reset-script-particle-field-modes ()
  (maphash (lambda (mode definition)
             (unless (particle-field-definition-builtin-p definition)
               (remhash mode *particle-field-definitions*)))
           *particle-field-definitions*)
  (setf *particle-field-modes*
        (remove-if-not (lambda (mode)
                         (let ((definition
                                 (gethash mode *particle-field-definitions*)))
                           (and definition
                                (particle-field-definition-builtin-p
                                 definition))))
                       *particle-field-modes*))
  (unless (gethash *particle-field-mode* *particle-field-definitions*)
    (clear-particle-field-transition :rising)))


;;; Mode state

(-> valid-particle-field-mode-p (t) boolean)
(defun valid-particle-field-mode-p (mode)
  (and (keywordp mode)
       (not (null (gethash mode *particle-field-definitions*)))))

(-> normalize-particle-field-mode (t) particle-field-mode)
(defun normalize-particle-field-mode (mode)
  (let ((normalized (particle-field-mode-keyword mode)))
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

(-> reset-particle-modes () t)
(defun reset-particle-modes ()
  (dolist (mode *particle-field-modes*)
    (let ((definition (gethash mode *particle-field-definitions*)))
      (when definition
        (handler-case
            (particle-field-reset definition)
          (error (condition)
            (runtime-warn "Could not reset particle mode ~a: ~a"
                          mode
                          condition)))))))

(-> ensure-particle-count () t)
(defun ensure-particle-count ()
  (dolist (mode *particle-field-modes*)
    (let ((definition (gethash mode *particle-field-definitions*)))
      (when definition
        (handler-case
            (particle-field-ensure definition)
          (error (condition)
            (runtime-warn "Could not ensure particle mode ~a: ~a"
                          mode
                          condition)))))))

(-> update-particle-mode (particle-field-mode seconds) t)
(defun update-particle-mode (mode dt)
  (let ((definition (gethash mode *particle-field-definitions*)))
    (if definition
        (handler-case
            (particle-field-update definition dt)
          (error (condition)
            (runtime-warn "Could not update particle mode ~a: ~a"
                          mode
                          condition)))
        (runtime-warn "Cannot update unknown particle mode: ~a" mode))))

(-> draw-particle-mode (particle-field-mode scalar) t)
(defun draw-particle-mode (mode alpha-scale)
  (let ((definition (gethash mode *particle-field-definitions*)))
    (if definition
        (handler-case
            (particle-field-draw definition alpha-scale)
          (error (condition)
            (runtime-warn "Could not draw particle mode ~a: ~a"
                          mode
                          condition)))
        (runtime-warn "Cannot draw unknown particle mode: ~a" mode))))

(-> register-builtin-particle-field-modes () t)
(defun register-builtin-particle-field-modes ()
  (register-particle-field-definition
   (make-instance 'rising-particle-system :id :rising :builtin-p t))
  (register-particle-field-definition
   (make-instance 'star-particle-system :id :stars :builtin-p t))
  (register-particle-field-definition
   (make-instance 'warp-particle-system :id :warp :builtin-p t))
  (register-particle-field-definition
   (make-instance 'snow-particle-system :id :snow :builtin-p t))
  (register-particle-field-definition
   (make-instance 'ash-particle-system :id :ash :builtin-p t))
  (register-particle-field-definition
   (make-instance 'mote-particle-system :id :motes :builtin-p t))
  (register-particle-field-definition
   (make-instance 'rogue-glyph-particle-system :id :rogue-glyphs :builtin-p t))
  (register-particle-field-definition
   (make-instance 'tatter-particle-system :id :tatters :builtin-p t))
  (dialog-particle-field-kind :title-menu
                              :reset #'reset-title-particles
                              :update #'update-title-particles
                              :draw #'draw-title-particles
                              :builtin-p t))

(register-builtin-particle-field-modes)


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
