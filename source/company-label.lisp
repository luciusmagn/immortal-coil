(in-package #:immortal-coil)

(defparameter *company-label-text* "(c) 2026 lambda symbolics ou")
(defconstant +company-label-size+ 24)
(defconstant +company-label-left-padding+ 28.0)
(defconstant +company-label-bottom-padding+ 25.0)

(-> company-label-position () (values scalar scalar))
(defun company-label-position ()
  (let ((x +company-label-left-padding+)
        (y (- +virtual-height+
              +company-label-bottom-padding+
              +company-label-size+)))
    (values x y)))

(-> draw-company-label-glow (scalar scalar) t)
(defun draw-company-label-glow (x y)
  (dolist (layer '((2.0 18) (1.0 34)))
    (destructuring-bind (offset alpha) layer
      (draw-text-at *company-label-text*
                    (+ x offset)
                    y
                    +company-label-size+
                    (make-color 255 255 255 alpha))
      (draw-text-at *company-label-text*
                    (- x offset)
                    y
                    +company-label-size+
                    (make-color 255 255 255 alpha))
      (draw-text-at *company-label-text*
                    x
                    (+ y offset)
                    +company-label-size+
                    (make-color 255 255 255 alpha))
      (draw-text-at *company-label-text*
                    x
                    (- y offset)
                    +company-label-size+
                    (make-color 255 255 255 alpha)))))

(-> draw-company-label () t)
(defun draw-company-label ()
  (multiple-value-bind (x y)
      (company-label-position)
    (draw-company-label-glow x y)
    (draw-text-at *company-label-text*
                  x
                  y
                  +company-label-size+
                  (make-color 255 255 255 178))))
