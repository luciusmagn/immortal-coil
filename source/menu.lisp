(in-package #:immortal-coil)

(-> update-menu (seconds) t)
(defun update-menu (dt)
  (incf *menu-elapsed* dt)
  (update-title-music (menu-title-music-volume-scale))
  (update-particles dt)
  (case *menu-start-state*
    (:idle
     (move-menu-selection (menu-selection-direction))
     (when (menu-option-pressed-p)
       (execute-selected-menu-option)))
    (:starting
     (incf *menu-start-elapsed* dt)
     (when (>= *menu-start-elapsed* (start-transition-total-seconds))
       (complete-start-action)))))
