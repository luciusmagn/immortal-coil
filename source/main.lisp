(in-package #:immortal-coil)

(defun setup-game ()
  (setf *mode* :menu
        *menu-elapsed* 0.0)
  (reset-title-particles)
  (load-audio))

(defun update-world ()
  (let ((dt (get-frame-time)))
    (case *mode*
      (:menu (update-menu dt))
      (:game (update-gameplay dt))
      (t (update-menu dt)))))

(defun main ()
  (with-window (:width +virtual-width+
                :height +virtual-height+
                :title "mag's Game"
                :fps 60)
    (let ((target (load-render-texture +virtual-width+ +virtual-height+))
          (shader-asset (load-crt-shader)))
      (configure-target-texture target)
      (setup-game)
      (do-game-loop (:livesupport t)
        (update-window-controls)
        (update-world)
        (with-texture-mode (target :clear +black+)
          (draw-world))
        (configure-target-destination target)
        (draw-target target (asset shader-asset))))))
