(in-package #:immortal-coil)

(-> open-pause-menu () t)
(defun open-pause-menu ()
  (setf *paused-p* t)
  (selection-reset *pause-selection*)
  (play-choice-switch))

(-> close-pause-menu () t)
(defun close-pause-menu ()
  (reset-pause-menu-state)
  (play-choice-switch))

(-> return-to-title-menu () t)
(defun return-to-title-menu ()
  (save-current-game)
  (setf *paused-p* nil
        *save-current-game-p* nil
        *mode* :menu)
  (reset-menu-state)
  (reset-particles :title-menu)
  (play-title-music))

(-> quit-from-pause-menu () t)
(defun quit-from-pause-menu ()
  (play-start-confirm)
  (save-current-game)
  (setf *quit-requested-p* t))

(-> execute-selected-pause-option () t)
(defun execute-selected-pause-option ()
  (case (selected-pause-action)
    (:resume
     (close-pause-menu))
    (:menu
     (play-start-confirm)
     (return-to-title-menu))
    (:quit
     (quit-from-pause-menu))
    (t
     (close-pause-menu))))
