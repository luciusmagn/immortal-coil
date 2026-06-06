(in-package #:immortal-coil)

(defun setup-game ()
  (setf *mode* :menu
        *menu-elapsed* 0.0
        *menu-selected-index* 0
        *menu-start-action* nil
        *menu-start-state* :idle
        *menu-start-elapsed* 0.0
        *game-fade-elapsed* 0.0
        *quit-requested-p* nil
        *save-current-game-p* nil
        *window-mode* :windowed
        *requested-window-mode* nil)
  (reset-title-particles))

(defun setup-window-resources ()
  (load-title-logo)
  (load-audio)
  (when (eq *mode* :menu)
    (play-title-music)))

(defun teardown-window-resources ()
  (clear-audio-resources)
  (clear-title-logo))

(defun normalize-window-state-before-close ()
  (when (and (eq *window-mode* :fullscreen)
             (is-window-fullscreen-p))
    (clear-window-state +flag-fullscreen-mode+)))

(defun update-world ()
  (let ((dt (get-frame-time)))
    (case *mode*
      (:menu (update-menu dt))
      (:game
       (incf *game-fade-elapsed* dt)
       (update-gameplay dt))
      (t (update-menu dt)))))

(defun fullscreen-window-width ()
  (max +virtual-width+ *fullscreen-width*))

(defun fullscreen-window-height ()
  (max +virtual-height+ *fullscreen-height*))

(defun run-window-contents ()
  (let ((target (load-render-texture +virtual-width+ +virtual-height+))
        (shader-asset (load-crt-shader)))
    (configure-target-texture target)
    (setup-window-resources)
    (let ((next-mode
            (do-game-loop (:livesupport t
                           :end (or *requested-window-mode*
                                     *quit-requested-p*)
                           :result *requested-window-mode*)
              (update-window-controls)
              (update-world)
              (with-texture-mode (target :clear +black+)
                (draw-world))
              (configure-target-destination target)
              (draw-target target (asset shader-asset)))))
      (normalize-window-state-before-close)
      (teardown-window-resources)
      next-mode)))

(defun run-game-window (mode)
  (setf *window-mode* mode
        *requested-window-mode* nil)
  (let ((next-mode nil))
    (if (eq mode :fullscreen)
        (with-window (:width (fullscreen-window-width)
                      :height (fullscreen-window-height)
                      :title "mag's Game"
                      :fps 60
                      :flags (list +flag-fullscreen-mode+))
          (setf next-mode (run-window-contents)))
        (with-window (:width +virtual-width+
                      :height +virtual-height+
                      :title "mag's Game"
                      :fps 60)
          (setf next-mode (run-window-contents))))
    next-mode))

(defun main ()
  (setup-game)
  (loop for next-mode = (run-game-window *window-mode*)
        while next-mode
        do (setf *window-mode* next-mode)))
