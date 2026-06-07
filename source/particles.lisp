(in-package #:immortal-coil)

(defvar *particles* #())
(defvar *star-particles* #())
(defvar *particle-field-mode* :rising)
(defvar *particle-field-from-mode* :rising)
(defvar *particle-field-to-mode* :rising)
(defvar *particle-field-transition-elapsed* 0.0)
(defvar *particle-field-transition-seconds* 0.0)

(defstruct particle
  x
  y
  vx
  vy
  wobble-phase
  wobble-speed
  wobble-strength
  age
  ttl
  alpha)

(defstruct star-particle
  x
  y
  drift-x
  drift-y
  age
  seed
  twinkle-speed
  alpha)

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

(defun reset-particle (particle &key initial-p)
  (let ((ttl (random-float 80.0 120.0)))
    (setf (particle-x particle) (random-float 20.0 (- +virtual-width+ 20.0))
          (particle-y particle) (if initial-p
                                    (random-float -20.0 (+ +virtual-height+ 100.0))
                                    (random-float (+ +virtual-height+ 10.0)
                                                  (+ +virtual-height+ 140.0)))
          (particle-vx particle) (random-float -3.0 3.0)
          (particle-vy particle) (random-float -20.0 -12.0)
          (particle-wobble-phase particle) (random-float 0.0 (* 2 pi))
          (particle-wobble-speed particle) (random-float 0.6 1.5)
          (particle-wobble-strength particle) (random-float 8.0 20.0)
          (particle-age particle) (if initial-p
                                      (random-float 0.0 ttl)
                                      0.0)
          (particle-ttl particle) ttl
          (particle-alpha particle) (get-random-value 100 220)))
  particle)

(defun reset-star-particle (particle &key initial-p)
  (setf (star-particle-x particle) (random-float 8.0 (- +virtual-width+ 8.0))
        (star-particle-y particle) (random-float 8.0 (- +virtual-height+ 8.0))
        (star-particle-drift-x particle) (random-float -2.2 2.2)
        (star-particle-drift-y particle) (random-float -0.7 0.7)
        (star-particle-age particle) (if initial-p
                                         (random-float 0.0 40.0)
                                         0.0)
        (star-particle-seed particle) (random-float 0.0 (* 2 pi))
        (star-particle-twinkle-speed particle) (random-float 0.55 1.85)
        (star-particle-alpha particle) (get-random-value 90 240))
  particle)

(defun current-particle-count ()
  (if (realp *particle-count*)
      (max 0 (round *particle-count*))
      (progn
        (runtime-warn "Invalid particle count: ~s" *particle-count*)
        0)))

(defun current-star-particle-count ()
  (if (realp *star-particle-count*)
      (max 0 (round *star-particle-count*))
      (progn
        (runtime-warn "Invalid star particle count: ~s" *star-particle-count*)
        0)))

(defun resize-particles (count)
  (let ((old-particles *particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-particle (make-particle) :initial-p t))))
    (setf *particles* new-particles)))

(defun resize-star-particles (count)
  (let ((old-particles *star-particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-star-particle (make-star-particle)
                                            :initial-p t))))
    (setf *star-particles* new-particles)))

(defun reset-particles ()
  (let ((count (current-particle-count))
        (star-count (current-star-particle-count)))
    (setf *particles* (make-array count))
    (loop for i below count
          do (setf (aref *particles* i)
                   (reset-particle (make-particle) :initial-p t)))
    (setf *star-particles* (make-array star-count))
    (loop for i below star-count
          do (setf (aref *star-particles* i)
                   (reset-star-particle (make-star-particle)
                                        :initial-p t)))
    (reset-particle-field-mode :rising)))

(defun ensure-particle-count ()
  (let ((count (current-particle-count)))
    (unless (= (length *particles*) count)
      (resize-particles count)))
  (let ((count (current-star-particle-count)))
    (unless (= (length *star-particles*) count)
      (resize-star-particles count))))

(defun update-particle (particle dt)
  (incf (particle-age particle) dt)
  (if (or (< (particle-y particle) -120)
          (< (particle-x particle) -30)
          (> (particle-x particle) (+ +virtual-width+ 30)))
      (reset-particle particle)
      (progn
        (incf (particle-wobble-phase particle)
              (* (particle-wobble-speed particle) dt))
        (incf (particle-x particle)
              (* (+ (particle-vx particle)
                    (* (particle-wobble-strength particle)
                       (sin (particle-wobble-phase particle))))
                 dt))
        (incf (particle-y particle) (* (particle-vy particle) dt)))))

(defun wrap-star-particle (particle)
  (when (< (star-particle-x particle) -4.0)
    (setf (star-particle-x particle) (+ +virtual-width+ 4.0)))
  (when (> (star-particle-x particle) (+ +virtual-width+ 4.0))
    (setf (star-particle-x particle) -4.0))
  (when (< (star-particle-y particle) -4.0)
    (setf (star-particle-y particle) (+ +virtual-height+ 4.0)))
  (when (> (star-particle-y particle) (+ +virtual-height+ 4.0))
    (setf (star-particle-y particle) -4.0)))

(defun update-star-particle (particle dt)
  (incf (star-particle-age particle) dt)
  (incf (star-particle-x particle)
        (* (star-particle-drift-x particle) dt))
  (incf (star-particle-y particle)
        (* (star-particle-drift-y particle) dt))
  (wrap-star-particle particle))

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
    (loop for particle across *particles*
          do (update-particle particle dt)))
  (when (plusp (particle-mode-alpha :stars))
    (loop for particle across *star-particles*
          do (update-star-particle particle dt))))

(defun particle-visible-alpha (particle)
  (round (* (particle-alpha particle)
            (clamp01 (/ (particle-age particle) 0.8)))))

(defun star-particle-visible-alpha (particle)
  (let* ((wave (* 0.5
                  (+ 1.0
                     (sin (+ (star-particle-seed particle)
                             (* (star-particle-age particle)
                                (star-particle-twinkle-speed particle)))))))
         (glint (* 0.5
                   (+ 1.0
                      (sin (+ (* 1.7 (star-particle-seed particle))
                              (* (star-particle-age particle)
                                 (star-particle-twinkle-speed particle)
                                 4.6))))))
         (brightness (+ 0.18
                        (* 0.62 (expt wave 2.8))
                        (* 0.20 (expt glint 16.0)))))
    (round (* (star-particle-alpha particle)
              (clamp01 brightness)))))

(defun star-particle-core-size (alpha)
  (if (> alpha 210)
      2
      +star-particle-size+))

(defun draw-star-particle-core (x y size color)
  (claylib/ll:draw-rectangle (- x (floor size 2))
                             (- y (floor size 2))
                             size
                             size
                             (claylib::c-ptr color)))

(defun draw-particle (particle alpha-scale)
  (let ((alpha (round (* (particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (particle-x particle))
                                 (round (particle-y particle))
                                 +particle-size+
                                 +particle-size+
                                 (claylib::c-ptr
                                  (make-color 255 255 255 alpha))))))

(defun draw-star-particle (particle alpha-scale)
  (let ((alpha (round (* (star-particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (let* ((x (round (star-particle-x particle)))
             (y (round (star-particle-y particle)))
             (size (star-particle-core-size alpha))
             (color (make-color 255 255 255 alpha)))
        (draw-star-particle-core x y size color)
        (when (> alpha 165)
          (let ((glint-color (make-color 255 255 255
                                         (round (* alpha 0.42)))))
            (claylib/ll:draw-rectangle (- x 1)
                                       y
                                       3
                                       1
                                       (claylib::c-ptr glint-color))
            (claylib/ll:draw-rectangle x
                                       (- y 1)
                                       1
                                       3
                                       (claylib::c-ptr glint-color))))))))

(defun draw-particles ()
  (let ((rising-alpha (particle-mode-alpha :rising))
        (star-alpha (particle-mode-alpha :stars)))
    (when (plusp rising-alpha)
      (loop for particle across *particles*
            do (draw-particle particle rising-alpha)))
    (when (plusp star-alpha)
      (loop for particle across *star-particles*
            do (draw-star-particle particle star-alpha)))))

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
