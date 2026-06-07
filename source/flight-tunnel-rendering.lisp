(in-package #:immortal-coil)

(-> draw-flight-tunnel-rail (list) t)
(defun draw-flight-tunnel-rail (corner)
  (multiple-value-bind (near-x near-y)
      (flight-project (first corner) (second corner) 0.65)
    (multiple-value-bind (far-x far-y)
        (flight-project (first corner) (second corner) +flight-visible-depth+)
      (draw-thick-line-between near-x
                               near-y
                               far-x
                               far-y
                               (make-color 255 255 255 46)
                               1.0))))

(-> draw-flight-tunnel-rails () t)
(defun draw-flight-tunnel-rails ()
  (dolist (corner '((-1.0 -1.0)
                    (1.0 -1.0)
                    (1.0 1.0)
                    (-1.0 1.0)))
    (draw-flight-tunnel-rail corner)))

(-> draw-flight-tunnel-frames () t)
(defun draw-flight-tunnel-frames ()
  (loop for z from 0.7 to +flight-visible-depth+ by 0.7
        for alpha = (flight-depth-alpha z 18 70)
        do (draw-flight-rectangle -1.0
                                  -1.0
                                  1.0
                                  1.0
                                  z
                                  (make-color 255 255 255 alpha)))
  (draw-flight-tunnel-rails))
