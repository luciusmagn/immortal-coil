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

(defun current-dialog-input-active-p ()
  (when (and (eq *mode* :game)
             (not *paused-p*)
             *state*)
    (let ((node (current-node)))
      (and (member (node-kind node) '(:number :string))
           (story-text-visible-p node)))))

(defun fullscreen-shortcut-available-p ()
  (not (current-dialog-input-active-p)))

(defun update-window-controls ()
  (when (and (fullscreen-shortcut-available-p)
             (is-key-pressed-p +key-f+))
    (toggle-game-fullscreen)))
