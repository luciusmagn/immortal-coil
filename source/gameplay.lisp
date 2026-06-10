(in-package #:immortal-coil)

(defun update-gameplay (dt)
  (update-particles dt)
  (incf (play-state-elapsed *state*) dt)
  (node-update (current-node) dt))

(defun draw-gameplay ()
  (draw-particles)
  (node-draw (current-node)))
