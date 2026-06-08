(in-package #:immortal-coil)

(defparameter *copyright-label-text* "(c) 2026")
(defparameter *company-label-text* "lambda symbolics ou")
(defconstant +company-label-size+ 24)
(defconstant +company-label-left-padding+ 28.0)
(defconstant +company-label-right-padding+ 42.0)
(defconstant +company-label-bottom-padding+ 25.0)

(-> company-label-y () scalar)
(defun company-label-y ()
  (- +virtual-height+
     +company-label-bottom-padding+
     +company-label-size+))

(-> copyright-label-position () (values scalar scalar))
(defun copyright-label-position ()
  (let ((x +company-label-left-padding+)
        (y (company-label-y)))
    (values x y)))

(-> company-label-position () (values scalar scalar))
(defun company-label-position ()
  (let ((x (- +virtual-width+
              +company-label-right-padding+
              (text-width *company-label-text* +company-label-size+)))
        (y (company-label-y)))
    (values x y)))

(-> draw-corner-label-glow (string scalar scalar) t)
(defun draw-corner-label-glow (text x y)
  (dolist (layer '((2.0 18) (1.0 34)))
    (destructuring-bind (offset alpha) layer
      (draw-text-at text
                    (+ x offset)
                    y
                    +company-label-size+
                    (make-color 255 255 255 alpha))
      (draw-text-at text
                    (- x offset)
                    y
                    +company-label-size+
                    (make-color 255 255 255 alpha))
      (draw-text-at text
                    x
                    (+ y offset)
                    +company-label-size+
                    (make-color 255 255 255 alpha))
      (draw-text-at text
                    x
                    (- y offset)
                    +company-label-size+
                    (make-color 255 255 255 alpha)))))

(-> draw-corner-label (string scalar scalar) t)
(defun draw-corner-label (text x y)
  (draw-corner-label-glow text x y)
  (draw-text-at text
                x
                y
                +company-label-size+
                (make-color 255 255 255 178)))

(-> draw-company-label () t)
(defun draw-company-label ()
  (multiple-value-bind (x y)
      (copyright-label-position)
    (draw-corner-label *copyright-label-text* x y))
  (multiple-value-bind (x y)
      (company-label-position)
    (draw-corner-label *company-label-text* x y)))
