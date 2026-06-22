(in-package #:immortal-coil)

(defun setup-game ()
  (load-options)
  (setf *mode* :menu
        *game-fade-elapsed* 0.0
        *quit-requested-p* nil
        *save-current-game-p* nil
        *requested-window-mode* nil
        *fullscreen-size-ready-p* nil)
  (reset-editor-state)
  (reset-menu-state)
  (reset-pause-menu-state)
  (reset-options-menu-state)
  (reset-particles :title-menu))

(defun setup-window-resources ()
  (handler-case
      (progn
        (load-title-logo)
        (load-audio)
        (cond
          ((eq *mode* :menu) (play-title-music))
          ;; a window reopen (e.g. a fullscreen toggle) reloads all audio
          ;; mid-game; bring the story track back rather than going silent
          ((eq *mode* :game) (apply-restored-story-music))))
    (error (condition)
      (runtime-warn "Could not set up window resources: ~a" condition))))

(defun teardown-window-resources ()
  (handler-case
      (progn
        (clear-audio-resources)
        (clear-title-logo))
    (error (condition)
      (runtime-warn "Could not tear down window resources: ~a" condition))))

(defun normalize-window-state-before-close ()
  (when (and (eq *window-mode* :fullscreen)
             (is-window-fullscreen-p))
    (clear-window-state +flag-fullscreen-mode+)))

(defun update-world ()
  (handler-case
      (let ((dt (get-frame-time)))
        (case *mode*
          (:menu (update-menu dt))
          (:game
           (cond
             (*paused-p*
              (update-pause-menu))
             ((update-editor-controls dt)
              nil)
             ((maybe-open-pause-menu)
              nil)
             (t
              (incf *game-fade-elapsed* dt)
              (update-gameplay dt))))
          (t (update-menu dt))))
    (error (condition)
      (runtime-warn "Frame update failed: ~a" condition))))

(defun update-window-controls-maybe ()
  (handler-case
      (update-window-controls)
    (error (condition)
      (runtime-warn "Window control update failed: ~a" condition))))

(defun update-bgm-streams-maybe ()
  (handler-case
      (update-bgm-streams)
    (error (condition)
      (runtime-warn "BGM stream update failed: ~a" condition))))

(defun run-window-contents ()
  (when (eq *window-mode* :fullscreen)
    (sync-active-fullscreen-window-size))
  (let ((target (load-render-texture +virtual-width+ +virtual-height+))
        (shader-asset (load-crt-shader)))
    (configure-target-texture target)
    (setup-window-resources)
    (let ((next-mode
            (do-game-loop (:livesupport t
                           :end (or *requested-window-mode*
                                     *quit-requested-p*)
                           :result *requested-window-mode*)
              (update-bgm-streams-maybe)
              (update-window-controls-maybe)
              (update-world)
              (with-texture-mode (target :clear +black+)
                (draw-world))
              (configure-target-destination target)
              (draw-target target (when shader-asset
                                    (asset shader-asset)))
              (update-bgm-streams-maybe))))
      (normalize-window-state-before-close)
      ;; carry the playing story track across the close/reopen so a fullscreen
      ;; toggle does not leave the game silent
      (let ((selection (active-story-music-selection)))
        (when selection (setf *pending-restored-music* selection)))
      (teardown-window-resources)
      next-mode)))

(defun run-game-window (mode)
  (setf *window-mode* mode
        *requested-window-mode* nil)
  (let ((next-mode nil))
    (if (eq mode :fullscreen)
        (progn
          (prime-fullscreen-window-size)
          (with-window (:width (fullscreen-window-width)
                        :height (fullscreen-window-height)
                        :title "mag's Game"
                        :fps 60
                        :exit-key +key-null+)
            (apply-fullscreen-monitor)
            (setf next-mode (run-window-contents))))
        (with-window (:width +virtual-width+
                      :height +virtual-height+
                      :title "mag's Game"
                      :exit-key +key-null+
                      :fps 60)
          (setf next-mode (run-window-contents))))
    next-mode))

(defun main ()
  (setup-game)
  (loop for next-mode = (run-game-window *window-mode*)
        while next-mode
        do (setf *window-mode* next-mode)))
