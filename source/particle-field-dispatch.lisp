(in-package #:immortal-coil)

(defparameter *particle-field-modes* '(:rising :stars :title-menu))

(-> reset-particle-modes () t)
(defun reset-particle-modes ()
  (reset-rising-particles)
  (reset-star-particles)
  (reset-title-particles))

(-> ensure-particle-count () t)
(defun ensure-particle-count ()
  (ensure-rising-particle-count)
  (ensure-star-particle-count))

(-> update-particle-mode (particle-field-mode seconds) t)
(defun update-particle-mode (mode dt)
  (case mode
    (:rising (update-rising-particles dt))
    (:stars (update-star-particles dt))
    (:title-menu (update-title-particles dt))
    (t (runtime-warn "Cannot update unknown particle mode: ~a" mode))))

(-> draw-particle-mode (particle-field-mode scalar) t)
(defun draw-particle-mode (mode alpha-scale)
  (case mode
    (:rising (draw-rising-particles alpha-scale))
    (:stars (draw-star-particles alpha-scale))
    (:title-menu (draw-title-particles alpha-scale))
    (t (runtime-warn "Cannot draw unknown particle mode: ~a" mode))))
