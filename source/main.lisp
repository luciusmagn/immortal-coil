(in-package #:immortal-coil)

(defun setup-game ()
  (load-options)
  (setf *mode* :menu
        *disclaimer-pending-p* t
        *game-fade-elapsed* 0.0
        *quit-requested-p* nil
        *save-current-game-p* nil
        *requested-window-mode* nil
        *fullscreen-size-ready-p* nil
        ;; power the tube on again for each fresh run; without this a second
        ;; (main) in the same REPL keeps the post-quit :off state and the
        ;; shader stays collapsed to black
        *crt-power-state* :warming
        *crt-off-amount* 1.0
        *crt-power-booted-p* nil)
  (reset-editor-state)
  (reset-menu-state)
  (reset-pause-menu-state)
  (reset-options-menu-state)
  (reset-particles :title-menu))

(defun setup-window-resources ()
  (handler-case
      (progn
        (load-audio)
        ;; the tube powers on with the first window only (warming state); a
        ;; later window reopen is already :on and stays silent here
        (when (eq *crt-power-state* :warming)
          (play-crt-power-on))
        (cond
          ((eq *mode* :menu) (play-title-music))
          ;; a window reopen (e.g. a fullscreen toggle) reloads all audio
          ;; mid-game; bring the story track back rather than going silent
          ((eq *mode* :game) (apply-restored-story-music))))
    (error (condition)
      (runtime-warn "Could not set up window resources: ~a" condition))))

(-> clear-hot-reload-resource-caches () t)
(defun clear-hot-reload-resource-caches ()
  "Drop cached external resources whose wrappers do not survive reloads safely."
  (handler-case
      (progn
        (clear-sb-atlas)
        (clear-hexany-labeler-sheets)
        ;; Defined by bundled scripts; guard so the engine still loads before
        ;; those scripts have been evaluated.
        (when (fboundp 'clear-jrpg-tile-atlas)
          (funcall 'clear-jrpg-tile-atlas))
        (when (fboundp 'clear-jrpg-sprite-textures)
          (funcall 'clear-jrpg-sprite-textures))
        t)
    (error (condition)
      (runtime-warn "Could not clear reload resource caches: ~a" condition)
      nil)))

(defun teardown-window-resources ()
  (handler-case
      (progn
        (clear-audio-resources)
        (clear-hot-reload-resource-caches))
    (error (condition)
      (runtime-warn "Could not tear down window resources: ~a" condition))))

(-> dev-reload (&key (:system-p boolean) (:graph-p boolean)) t)
(defun dev-reload (&key (system-p t) (graph-p t))
  "Reload engine code and dynamic dialogue scripts in one REPL call."
  (when system-p
    (asdf:load-system :immortal-coil))
  (clear-hot-reload-resource-caches)
  (when graph-p
    (load-dialog-graph))
  t)

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
  (let ((target (load-render-texture (render-texture-width) (render-texture-height)))
        (shader-asset (load-crt-shader))
        ;; supersample: draw the 1280x720 layout into the larger texture through
        ;; a matching zoom, so vector graphics are rasterized at full resolution
        (render-camera (make-camera-2d 0.0 0.0 0.0 0.0
                                       :zoom (float *render-scale* 1.0))))
    (configure-target-texture target)
    (cache-crt-uniform-locations (when shader-asset (asset shader-asset)))
    (setup-window-resources)
    (let ((next-mode
            (do-game-loop (:livesupport t
                           :end (or *requested-window-mode*
                                    (and *quit-requested-p*
                                         (eq *crt-power-state* :off)))
                           :result *requested-window-mode*)
              (update-bgm-streams-maybe)
              (update-window-controls-maybe)
              ;; a requested quit first powers the tube down; the world freezes
              ;; under the collapse and the loop ends only once it is dark
              (when *quit-requested-p*
                (begin-crt-cooldown))
              (unless (crt-cooling-down-p)
                (update-world))
              (update-crt-power (get-frame-time))
              (with-texture-mode (target :clear +black+)
                (claylib/ll:begin-mode-2d (claylib::c-ptr render-camera))
                (draw-world)
                (claylib/ll:end-mode-2d))
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
