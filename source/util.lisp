(in-package #:immortal-coil)

(defun clamp01 (value)
  (min 1.0 (max 0.0 value)))

(defun cubic-in (value)
  (let ((x (clamp01 value)))
    (* x x x)))

(defun smoothstep (value)
  (let ((x (clamp01 value)))
    (* x x (- 3.0 (* 2.0 x)))))

(defun random-float (min max)
  (+ min
     (* (- max min)
        (/ (get-random-value 0 10000) 10000.0))))

(defun draw-text-at (text x y size color)
  (claylib/ll:draw-text text
                        (round x)
                        (round y)
                        size
                        (claylib::c-ptr color)))

(defun draw-centered-text (text center-x center-y size color)
  (let* ((width (measure-text text size))
         (x (- center-x (/ width 2)))
         (y (- center-y (/ size 2))))
    (draw-text-at text x y size color)
    (values x y width)))
