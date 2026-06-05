(in-package #:immortal-coil)

(defun capture-fullscreen-size ()
  (let ((monitor (get-current-monitor)))
    (setf *fullscreen-width* (get-monitor-width monitor)
          *fullscreen-height* (get-monitor-height monitor))))

(defun request-fullscreen ()
  (capture-fullscreen-size)
  (setf *requested-window-mode* :fullscreen))

(defun request-windowed ()
  (setf *requested-window-mode* :windowed))

(defun toggle-game-fullscreen ()
  (unless *requested-window-mode*
    (case *window-mode*
      (:fullscreen (request-windowed))
      (t (request-fullscreen)))))

(defun update-window-controls ()
  (when (is-key-pressed-p +key-f+)
    (toggle-game-fullscreen)))
