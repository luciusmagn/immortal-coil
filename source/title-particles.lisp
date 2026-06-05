(in-package #:immortal-coil)

(defvar *title-particles* (make-array 0 :adjustable t :fill-pointer 0))
(defvar *title-particle-spawn-debt* 0.0)

(defstruct title-particle
  phase
  speed
  seed
  entry-angle
  entry-offset
  orbit-radius
  orbit-turns
  exit-angle
  branch-side
  branch-spread
  branch-curve
  alpha)

(defun random-title-exit-angle ()
  (let ((base (case (get-random-value 0 3)
                (0 (* pi 1.16))
                (1 (* pi 1.36))
                (2 (* pi 1.64))
                (t (* pi 1.84)))))
    (+ base (random-float -0.06 0.06))))

(defun random-title-entry-angle ()
  (+ (/ pi 2.0)
     (random-float -0.22 0.22)))

(defun current-title-particle-count ()
  (max 0 (round *title-particle-count*)))

(defun reset-title-particle (particle)
  (let ((exit-angle (random-title-exit-angle)))
    (setf (title-particle-phase particle) 0.0
          (title-particle-speed particle) (random-float 0.020 0.030)
          (title-particle-seed particle) (random-float 0.0 (* 2 pi))
          (title-particle-entry-angle particle) (random-title-entry-angle)
          (title-particle-entry-offset particle) (random-float -56.0 56.0)
          (title-particle-orbit-radius particle) (+ +title-orbit-radius+
                                                    (random-float -16.0 16.0))
          (title-particle-orbit-turns particle) (get-random-value 1 3)
          (title-particle-exit-angle particle) exit-angle
          (title-particle-branch-side particle) (if (minusp (cos exit-angle))
                                                    -1.0
                                                    1.0)
          (title-particle-branch-spread particle) (random-float 90.0 360.0)
          (title-particle-branch-curve particle) (random-float -110.0 110.0)
          (title-particle-alpha particle) (get-random-value 110 230)))
  particle)

(defun reset-title-particles ()
  (setf *title-particles* (make-array 0 :adjustable t :fill-pointer 0)
        *title-particle-spawn-debt* 0.0))

(defun update-title-particle (particle dt)
  (incf (title-particle-phase particle)
        (* (title-particle-speed particle) dt)))

(defun title-particle-finished-p (particle)
  (> (title-particle-phase particle) 1.0))

(defun remove-finished-title-particles ()
  (let ((write-index 0)
        (count (length *title-particles*)))
    (loop for read-index below count
          for particle = (aref *title-particles* read-index)
          unless (title-particle-finished-p particle)
            do (setf (aref *title-particles* write-index) particle
                     write-index (1+ write-index)))
    (setf (fill-pointer *title-particles*) write-index)))

(defun title-spawn-scale ()
  (let ((cap (current-title-particle-count)))
    (if (zerop cap)
        0.0
        (expt (clamp01 (- 1.0 (/ (length *title-particles*) cap)))
              1.7))))

(defun spawn-title-particle ()
  (vector-push-extend
   (reset-title-particle (make-title-particle))
   *title-particles*))

(defun spawn-title-particles (dt)
  (let ((cap (current-title-particle-count)))
    (incf *title-particle-spawn-debt*
          (* *title-particle-spawn-rate*
             (title-spawn-scale)
             dt))
    (loop while (and (>= *title-particle-spawn-debt* 1.0)
                     (< (length *title-particles*) cap))
          do (decf *title-particle-spawn-debt* 1.0)
             (spawn-title-particle))))

(defun update-title-particles (dt)
  (spawn-title-particles dt)
  (loop for particle across *title-particles*
        do (update-title-particle particle dt))
  (remove-finished-title-particles))

(defun title-particle-trunk-position (particle phase)
  (let* ((u (/ phase 0.30))
         (eased (smoothstep u))
         (start-y (+ +virtual-height+ 60.0))
         (entry-angle (title-particle-entry-angle particle))
         (radius (title-particle-orbit-radius particle))
         (start-x (+ +menu-start-x+
                     (title-particle-entry-offset particle)))
         (end-x (+ +menu-start-x+ (* (cos entry-angle) radius)))
         (end-y (+ +menu-start-y+ (* (sin entry-angle) radius)))
         (wobble (+ (* 20.0
                       (sin (+ (title-particle-seed particle)
                               (* u 10.0)))
                       (sin (* pi u)))
                    (* (title-particle-branch-side particle)
                       13.0
                       (sin (* pi u))))))
    (values (+ start-x
               (* (- end-x start-x) eased)
               wobble)
            (+ start-y (* (- end-y start-y) eased)))))

(defun title-particle-orbit-delta (particle)
  (+ (- (title-particle-exit-angle particle)
        (title-particle-entry-angle particle))
     (* 2.0 pi (title-particle-orbit-turns particle))))

(defun title-particle-orbit-position (particle phase)
  (let* ((u (/ (- phase 0.30) 0.56))
         (endpoint-fade (sin (* pi u)))
         (angle (+ (title-particle-entry-angle particle)
                   (* (title-particle-orbit-delta particle)
                      (smoothstep u))
                   (* 0.26
                      endpoint-fade
                      (sin (+ (title-particle-seed particle)
                              (* 11.0 pi u))))
                   (* 0.11
                      endpoint-fade
                      (sin (+ (* 1.4 (title-particle-seed particle))
                              (* 21.0 pi u))))))
         (radius (+ (title-particle-orbit-radius particle)
                    (* 24.0
                       endpoint-fade
                       (sin (+ (title-particle-seed particle)
                               (* 9.0 pi u))))
                    (* 13.0
                       endpoint-fade
                       (sin (+ (* 1.7 (title-particle-seed particle))
                               (* 17.0 pi u)))))))
    (values (+ +menu-start-x+
               (* (cos angle) radius))
            (+ +menu-start-y+
               (* (sin angle) radius)))))

(defun title-particle-exit-position (particle)
  (let ((angle (title-particle-exit-angle particle))
        (radius (title-particle-orbit-radius particle)))
    (values (+ +menu-start-x+ (* (cos angle) radius))
            (+ +menu-start-y+ (* (sin angle) radius)))))

(defun title-particle-branch-position (particle phase)
  (multiple-value-bind (start-x start-y)
      (title-particle-exit-position particle)
    (let* ((u (/ (- phase 0.86) 0.14))
           (eased (smoothstep u))
           (side (title-particle-branch-side particle))
           (spread (title-particle-branch-spread particle))
           (curve (title-particle-branch-curve particle))
           (x (+ start-x
                 (* side spread (expt eased 1.18))
                 (* curve eased (- 1.0 eased))
                 (* 12.0
                    (sin (+ (title-particle-seed particle)
                            (* u 11.0))))))
           (y (- start-y (* 470.0 eased))))
      (values x y))))

(defun title-particle-position (particle)
  (let ((phase (title-particle-phase particle)))
    (cond
      ((< phase 0.30)
       (title-particle-trunk-position particle phase))
      ((< phase 0.86)
       (title-particle-orbit-position particle phase))
      (t
       (title-particle-branch-position particle phase)))))

(defun title-particle-visible-alpha (particle)
  (if (minusp (title-particle-phase particle))
      0
      (round (* (title-particle-alpha particle)
                (clamp01 (/ (title-particle-phase particle) 0.06))))))

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
