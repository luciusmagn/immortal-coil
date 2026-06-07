(in-package #:immortal-coil)

(-> flight-project (scalar scalar scalar) (values scalar scalar))
(defun flight-project (x y z)
  (let* ((depth (+ z 0.75))
         (scale (/ 1.0 depth)))
    (values (+ +flight-center-x+
               (* x +flight-view-width+ 0.5 scale))
            (+ +flight-center-y+
               (* y +flight-view-height+ 0.5 scale)))))

(-> flight-cockpit-position (scalar scalar) (values scalar scalar))
(defun flight-cockpit-position (x y)
  (values (+ +flight-center-x+
             (* x +flight-view-width+ +flight-cockpit-scale+))
          (+ +flight-center-y+
             (* y +flight-view-height+ +flight-cockpit-scale+))))

(-> flight-depth-alpha (scalar alpha-channel alpha-channel) alpha-channel)
(defun flight-depth-alpha (z min-alpha max-alpha)
  (let ((progress (clamp01 (/ (- +flight-visible-depth+ z)
                              +flight-visible-depth+))))
    (round (+ min-alpha (* (- max-alpha min-alpha) progress)))))

(-> draw-flight-rectangle (scalar
                           scalar
                           scalar
                           scalar
                           scalar
                           t
                           &optional scalar)
    t)
(defun draw-flight-rectangle (left top right bottom z color
                              &optional (thickness 1.0))
  (multiple-value-bind (x1 y1)
      (flight-project left top z)
    (multiple-value-bind (x2 y2)
        (flight-project right top z)
      (multiple-value-bind (x3 y3)
          (flight-project right bottom z)
        (multiple-value-bind (x4 y4)
            (flight-project left bottom z)
          (draw-thick-line-between x1 y1 x2 y2 color thickness)
          (draw-thick-line-between x2 y2 x3 y3 color thickness)
          (draw-thick-line-between x3 y3 x4 y4 color thickness)
          (draw-thick-line-between x4 y4 x1 y1 color thickness))))))
