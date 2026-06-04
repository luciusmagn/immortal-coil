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

(defun draw-world ()
  (clear-background :color +black+)
  (case *mode*
    (:menu (draw-menu))
    (:game (draw-gameplay))
    (t (draw-menu))))

(defun draw-target (target shader)
  (with-drawing (:bgcolor +black+)
    (if shader
        (progn
          (claylib/ll:begin-shader-mode (claylib::c-ptr shader))
          (draw-object (texture target))
          (claylib/ll:end-shader-mode))
        (draw-object (texture target)))))
