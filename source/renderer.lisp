(in-package #:immortal-coil)

(defun load-crt-shader ()
  (handler-case
      (make-shader-asset
       :fspath (project-pathname "assets/shaders/crt.frag")
       :load-now t)
    (error (condition)
      (runtime-warn "Could not load CRT shader: ~a" condition)
      nil)))

;;; CRT shader uniforms: uInvert (light theme) and uOff (power animation). Both
;;; default to 0 in the shader, so if the FFI plumbing fails the picture just
;;; renders normally.

(defvar *crt-uniform-locs* nil
  "(invert-loc . off-loc) for the loaded CRT shader, or nil if unavailable.")

(defun cache-crt-uniform-locations (shader)
  (setf *crt-uniform-locs*
        (handler-case
            (when shader
              (cons (claylib/ll:get-shader-location (claylib::c-ptr shader)
                                                    "uInvert")
                    (claylib/ll:get-shader-location (claylib::c-ptr shader)
                                                    "uOff")))
          (error (condition)
            (runtime-warn "CRT shader uniforms unavailable: ~a" condition)
            nil))))

(defun set-shader-float (shader location value)
  (when (and location (>= location 0))
    (cffi:with-foreign-object (pointer :float)
      (setf (cffi:mem-aref pointer :float) (coerce value 'single-float))
      (claylib/ll:set-shader-value (claylib::c-ptr shader)
                                   location
                                   pointer
                                   +shader-uniform-float+))))

(defun apply-crt-uniforms (shader)
  (when (and shader *crt-uniform-locs*)
    (handler-case
        (progn
          (set-shader-float shader (car *crt-uniform-locs*)
                            (if *light-theme-p* 1.0 0.0))
          (set-shader-float shader (cdr *crt-uniform-locs*)
                            (clamp01 *crt-off-amount*)))
      (error (condition)
        (runtime-warn "CRT uniform update failed: ~a" condition)
        (setf *crt-uniform-locs* nil)))))

(defun update-crt-power (dt)
  "Advance the power animation. Runs every frame, in any mode."
  (case *crt-power-state*
    (:warming
     (setf *crt-off-amount* (max 0.0 (- *crt-off-amount* (/ dt *crt-warm-seconds*))))
     (when (<= *crt-off-amount* 0.0)
       (setf *crt-off-amount* 0.0
             *crt-power-state* :on
             *crt-power-booted-p* t)))
    (:cooling
     (setf *crt-off-amount* (min 1.0 (+ *crt-off-amount* (/ dt *crt-cool-seconds*))))
     (when (>= *crt-off-amount* 1.0)
       (setf *crt-off-amount* 1.0
             *crt-power-state* :off)))
    (t nil)))

(defun crt-cooling-down-p ()
  (member *crt-power-state* '(:cooling :off)))

(defun begin-crt-cooldown ()
  "Start the power-off collapse (called once when a quit is requested)."
  (when (eq *crt-power-state* :on)
    (setf *crt-power-state* :cooling)
    (play-crt-power-off)))

(defun render-texture-width ()
  (max 1 (round (* +virtual-width+ *render-scale*))))

(defun render-texture-height ()
  (max 1 (round (* +virtual-height+ *render-scale*))))

(defun configure-target-texture (target)
  (setf (filter (texture target)) +texture-filter-point+
        (source (texture target))
        (make-instance 'rl-rectangle
                       :x 0
                       :y 0
                       :width (width (texture target))
                       :height (- (height (texture target))))
        (origin (texture target)) (make-vector2 0 0)
        (rot (texture target)) 0.0
        (tint (texture target)) +white+))

(defun configure-target-destination (target)
  (let* ((screen-width (get-screen-width))
         (screen-height (get-screen-height))
         (scale (min (/ (float screen-width 1.0) +virtual-width+)
                     (/ (float screen-height 1.0) +virtual-height+)))
         (target-width (* +virtual-width+ scale))
         (target-height (* +virtual-height+ scale)))
    (setf (dest (texture target))
          (make-instance 'rl-rectangle
                         :x (/ (- screen-width target-width) 2)
                         :y (/ (- screen-height target-height) 2)
                         :width target-width
                         :height target-height))))

(defun menu-fade-out-alpha ()
  (if (eq *menu-start-state* :starting)
      (let ((progress (/ (- *menu-start-elapsed* *start-confirm-seconds*)
                         *start-fade-out-seconds*)))
        (round (* 255 (smoothstep progress))))
      0))

(defun game-fade-in-alpha ()
  (if (eq *mode* :game)
      (round (* 255 (- 1.0 (smoothstep (/ *game-fade-elapsed*
                                          *game-fade-in-seconds*)))))
      0))

(defun screen-fade-alpha ()
  (max (menu-fade-out-alpha)
       (game-fade-in-alpha)))

(defun draw-screen-fade ()
  (let ((alpha (screen-fade-alpha)))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle 0
                                 0
                                 +virtual-width+
                                 +virtual-height+
                                 (claylib::c-ptr
                                  (make-color 0 0 0 alpha))))))

(defun draw-world ()
  (handler-case
      (progn
        (clear-background :color +black+)
        (case *mode*
          (:menu (draw-menu))
          (:game (draw-gameplay))
          (t (draw-menu)))
        (when (and (eq *mode* :game)
                   (editor-active-p))
          (draw-editor-overlay))
        ;; corner HUD only in-game (not the title/menu), and never over the
        ;; editor chrome
        (when (and (eq *mode* :game) (not (editor-active-p)))
          (draw-hud))
        (when (eq *mode* :menu)
          (draw-company-label))
        (draw-screen-fade)
        (when (and (eq *mode* :game)
                   *paused-p*)
          (draw-pause-menu)))
    (error (condition)
      (runtime-warn "Frame draw failed: ~a" condition)
      (clear-background :color +black+))))

(defun draw-target (target shader)
  (with-drawing (:bgcolor +black+)
    (if shader
        (progn
          (apply-crt-uniforms shader)
          (claylib/ll:begin-shader-mode (claylib::c-ptr shader))
          (draw-object (texture target))
          (claylib/ll:end-shader-mode))
        (draw-object (texture target)))))
