(in-package #:immortal-coil)

(defvar *title-particles* #())

(defstruct title-particle
  phase
  speed
  seed
  orbit-radius
  branch-side
  branch-spread
  branch-curve
  alpha)

(defun current-title-particle-count ()
  (max 0 (round *title-particle-count*)))

(defun reset-title-particle (particle &key initial-p)
  (setf (title-particle-phase particle) (if initial-p
                                            (random-float 0.0 1.0)
                                            0.0)
        (title-particle-speed particle) (random-float 0.035 0.055)
        (title-particle-seed particle) (random-float 0.0 (* 2 pi))
        (title-particle-orbit-radius particle) (+ +title-orbit-radius+
                                                  (random-float -13.0 13.0))
        (title-particle-branch-side particle) (if (zerop (get-random-value 0 1))
                                                  -1.0
                                                  1.0)
        (title-particle-branch-spread particle) (random-float 70.0 330.0)
        (title-particle-branch-curve particle) (random-float -70.0 70.0)
        (title-particle-alpha particle) (get-random-value 110 230))
  particle)

(defun resize-title-particles (count)
  (let ((old-particles *title-particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-title-particle (make-title-particle) :initial-p t))))
    (setf *title-particles* new-particles)))

(defun reset-title-particles (&key initial-p)
  (let ((count (current-title-particle-count)))
    (setf *title-particles* (make-array count))
    (loop for i below count
          do (setf (aref *title-particles* i)
                   (reset-title-particle (make-title-particle)
                                         :initial-p initial-p)))))

(defun ensure-title-particle-count ()
  (let ((count (current-title-particle-count)))
    (unless (= (length *title-particles*) count)
      (resize-title-particles count))))

(defun update-title-particle (particle dt)
  (incf (title-particle-phase particle)
        (* (title-particle-speed particle) dt))
  (when (> (title-particle-phase particle) 1.0)
    (reset-title-particle particle)))

(defun update-title-particles (dt)
  (ensure-title-particle-count)
  (loop for particle across *title-particles*
        do (update-title-particle particle dt)))

(defun title-particle-trunk-position (particle phase)
  (let* ((u (/ phase 0.34))
         (eased (smoothstep u))
         (start-y 660.0)
         (end-y (+ +menu-start-y+ (title-particle-orbit-radius particle)))
         (trunk-offset (* 18.0 (sin (title-particle-seed particle))))
         (wobble (+ (* 10.0
                       (sin (+ (title-particle-seed particle)
                               (* u 10.0)))
                       (sin (* pi u)))
                    (* (title-particle-branch-side particle)
                       5.0
                       (sin (* pi u))))))
    (values (+ +menu-start-x+
               (* trunk-offset (- 1.0 eased))
               wobble)
            (+ start-y (* (- end-y start-y) eased)))))

(defun title-particle-orbit-position (particle phase)
  (let* ((u (/ (- phase 0.34) 0.36))
         (endpoint-fade (sin (* pi u)))
         (angle (+ (/ pi 2.0)
                   (* 3.0 pi (smoothstep u))
                   (* 0.055
                      endpoint-fade
                      (sin (+ (title-particle-seed particle)
                              (* 6.0 pi u))))))
         (radius (+ (title-particle-orbit-radius particle)
                    (* 4.0
                       endpoint-fade
                       (sin (+ (title-particle-seed particle)
                               (* 4.0 pi u)))))))
    (values (+ +menu-start-x+
               (* (cos angle) radius))
            (+ +menu-start-y+
               (* (sin angle) radius)))))

(defun title-particle-branch-position (particle phase)
  (let* ((u (/ (- phase 0.70) 0.30))
         (eased (smoothstep u))
         (start-y (- +menu-start-y+ (title-particle-orbit-radius particle)))
         (side (title-particle-branch-side particle))
         (spread (title-particle-branch-spread particle))
         (curve (title-particle-branch-curve particle))
         (x (+ +menu-start-x+
               (* side spread (expt eased 1.25))
               (* curve eased (- 1.0 eased))
               (* 7.0 (sin (+ (title-particle-seed particle)
                              (* u 9.0))))))
         (y (- start-y (* 500.0 eased))))
    (values x y)))

(defun title-particle-position (particle)
  (let ((phase (title-particle-phase particle)))
    (cond
      ((< phase 0.34)
       (title-particle-trunk-position particle phase))
      ((< phase 0.70)
       (title-particle-orbit-position particle phase))
      (t
       (title-particle-branch-position particle phase)))))

(defun title-particle-visible-alpha (particle)
  (round (* (title-particle-alpha particle)
            (clamp01 (/ (title-particle-phase particle) 0.06)))))

(defun draw-title-particle (particle alpha-scale)
  (let ((alpha (round (* (title-particle-visible-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (multiple-value-bind (x y)
          (title-particle-position particle)
        (claylib/ll:draw-rectangle (round x)
                                   (round y)
                                   +particle-size+
                                   +particle-size+
                                   (claylib::c-ptr
                                    (make-color 255 255 255 alpha)))))))

(defun draw-title-particles (&optional (alpha-scale 1.0))
  (loop for particle across *title-particles*
        do (draw-title-particle particle alpha-scale)))
