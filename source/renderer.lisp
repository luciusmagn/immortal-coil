(in-package #:immortal-coil)

(defun load-crt-shader ()
  (make-shader-asset
   :fspath (asdf:system-relative-pathname
            :immortal-coil
            "assets/shaders/crt.fs")
   :load-now t))

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
  (let* ((render-width (get-render-width))
         (render-height (get-render-height))
         (scale (min (/ (float render-width 1.0) +virtual-width+)
                     (/ (float render-height 1.0) +virtual-height+)))
         (target-width (* +virtual-width+ scale))
         (target-height (* +virtual-height+ scale)))
    (setf (dest (texture target))
          (make-instance 'rl-rectangle
                         :x (/ (- render-width target-width) 2)
                         :y (/ (- render-height target-height) 2)
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
  (clear-background :color +black+)
  (case *mode*
    (:menu (draw-menu))
    (:game (draw-gameplay))
    (t (draw-menu)))
  (draw-screen-fade))

(defun draw-target (target shader)
  (with-drawing (:bgcolor +black+)
    (if shader
        (progn
          (claylib/ll:begin-shader-mode (claylib::c-ptr shader))
          (draw-object (texture target))
          (claylib/ll:end-shader-mode))
        (draw-object (texture target)))))
