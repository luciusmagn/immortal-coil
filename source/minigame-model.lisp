(in-package #:immortal-coil)

(-> minigame-update-fallback (node seconds) t)
(defun minigame-update-fallback (node dt)
  (declare (ignore node dt))
  nil)

(-> minigame-draw-fallback (node t) t)
(defun minigame-draw-fallback (node color)
  (declare (ignore node color))
  nil)

(defstruct minigame-definition
  (id              :unknown :type minigame-id)
  (update-function #'minigame-update-fallback :type runtime-function)
  (draw-function   #'minigame-draw-fallback :type runtime-function)
  (source          :unknown :type dialog-source))
