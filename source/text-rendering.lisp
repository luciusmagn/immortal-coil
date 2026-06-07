(in-package #:immortal-coil)

(-> draw-cursor (scalar scalar scalar nonnegative-integer t) t)
(defun draw-cursor (x y width size color)
  (when (< (mod (floor (* 60 (get-time))) 70) 35)
    (claylib/ll:draw-rectangle (round (+ x width 6))
                               (round y)
                               (round (/ size 2))
                               size
                               (claylib::c-ptr color))))

(-> draw-opening-text-node (node) t)
(defun draw-opening-text-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (multiple-value-bind (x y width)
        (draw-centered-text text
                            +virtual-center-x+
                            (- +virtual-center-y+ 20)
                            size
                            color)
      (draw-cursor x y width size color))))
