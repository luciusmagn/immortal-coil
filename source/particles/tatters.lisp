(in-package #:immortal-coil)

;;; Yellow tatters: slow shreds of the King's mantle drifting down and swaying
;;; like rag caught in a draught - sallow yellow, the one colour in the game.
;;; For Carcosa, the court, and the King: the air itself coming apart in tatters.

(defstruct tatter-particle
  x y vy sway-phase sway-speed sway-amp len width base-alpha pulse)

(defun reset-tatter-particle (particle &key initial-p)
  (setf (tatter-particle-x particle) (random-float 0.0 +virtual-width+)
        (tatter-particle-y particle) (if initial-p
                                         (random-float 0.0 +virtual-height+)
                                         (random-float -40.0 -8.0))
        (tatter-particle-vy particle) (random-float 8.0 24.0)
        (tatter-particle-sway-phase particle) (random-float 0.0 (* 2 pi))
        (tatter-particle-sway-speed particle) (random-float 0.6 1.6)
        (tatter-particle-sway-amp particle) (random-float 4.0 14.0)
        (tatter-particle-len particle) (get-random-value 5 13)
        (tatter-particle-width particle) (get-random-value 1 2)
        (tatter-particle-base-alpha particle) (get-random-value 45 130)
        (tatter-particle-pulse particle) (random-float 0.0 (* 2 pi)))
  particle)

(defun update-tatter-particle (particle dt)
  (incf (tatter-particle-sway-phase particle)
        (* (tatter-particle-sway-speed particle) dt))
  (incf (tatter-particle-pulse particle) (* 1.5 dt))
  (incf (tatter-particle-y particle) (* (tatter-particle-vy particle) dt))
  (when (> (tatter-particle-y particle) (+ +virtual-height+ 16.0))
    (reset-tatter-particle particle)))

(defun draw-tatter-particle (particle alpha-scale)
  (let* ((sway (* (tatter-particle-sway-amp particle)
                  (sin (tatter-particle-sway-phase particle))))
         (x (+ (tatter-particle-x particle) sway))
         (y (tatter-particle-y particle))
         (len (tatter-particle-len particle))
         (w (tatter-particle-width particle))
         (alpha (round (* (tatter-particle-base-alpha particle)
                          (+ 0.55 (* 0.45 (abs (sin (tatter-particle-pulse particle)))))
                          alpha-scale))))
    (when (plusp alpha)
      ;; a sallow-yellow shred: a vertical streak with a torn kink below it
      (claylib/ll:draw-rectangle (round x) (round y) w len
                                 (draw-color-ptr 214 198 86 alpha))
      (claylib/ll:draw-rectangle (round (+ x 1)) (round (+ y len)) w
                                 (max 1 (floor len 2))
                                 (draw-color-ptr 214 198 86 (round (* alpha 0.7)))))))


;;; System

(defclass tatter-particle-system (particle-system) ())

(defmethod particle-system-count ((system tatter-particle-system)) 70)

(defmethod particle-system-make ((system tatter-particle-system))
  (make-tatter-particle))

(defmethod particle-system-reset-particle ((system tatter-particle-system)
                                           particle
                                           &key initial-p)
  (reset-tatter-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system tatter-particle-system)
                                            particle
                                            dt)
  (update-tatter-particle particle dt))

(defmethod particle-system-draw-particle ((system tatter-particle-system)
                                          particle
                                          alpha-scale)
  (draw-tatter-particle particle alpha-scale))
