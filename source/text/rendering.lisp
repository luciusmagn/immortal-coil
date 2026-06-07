(in-package #:immortal-coil)

(-> node-speaker-visible-p (node) boolean)
(defun node-speaker-visible-p (node)
  (and (node-speaker node)
       (plusp (length (node-speaker node)))))

(-> draw-node-speaker (node t) t)
(defun draw-node-speaker (node color)
  (when (node-speaker-visible-p node)
    (draw-centered-text (node-speaker node)
                        +virtual-center-x+
                        (- +virtual-center-y+ 82)
                        18
                        color)))

(-> node-text-center-y (node) scalar)
(defun node-text-center-y (node)
  (if (node-speaker-visible-p node)
      (- +virtual-center-y+ 12)
      (- +virtual-center-y+ 20)))

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
    (draw-node-speaker node color)
    (multiple-value-bind (x y width)
        (draw-centered-text text
                            +virtual-center-x+
                            (node-text-center-y node)
                            size
                            color)
      (draw-cursor x y width size color))))
