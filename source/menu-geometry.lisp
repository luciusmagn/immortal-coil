(in-package #:immortal-coil)

(-> menu-option-text-width () nonnegative-integer)
(defun menu-option-text-width ()
  (measure-text (selected-menu-label) *menu-start-text-size*))

(-> menu-option-bounds () (values scalar scalar scalar scalar))
(defun menu-option-bounds ()
  (let ((width (menu-option-text-width))
        (height *menu-start-text-size*))
    (values (- +menu-start-x+ (/ width 2) 18)
            (- +menu-start-y+ (/ height 2) 14)
            (+ width 36)
            (+ height 28))))

(-> point-in-rect-p (scalar scalar scalar scalar scalar scalar) boolean)
(defun point-in-rect-p (x y left top width height)
  (and (>= x left)
       (<= x (+ left width))
       (>= y top)
       (<= y (+ top height))))

(-> mouse-on-menu-option-p () boolean)
(defun mouse-on-menu-option-p ()
  (multiple-value-bind (left top width height)
      (menu-option-bounds)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(-> menu-arrow-center-x (menu-direction) scalar)
(defun menu-arrow-center-x (direction)
  (+ +menu-start-x+
     (* direction (+ +title-orbit-radius+ 86.0))))

(-> menu-arrow-bounds (menu-direction) (values scalar scalar scalar scalar))
(defun menu-arrow-bounds (direction)
  (let ((x (menu-arrow-center-x direction))
        (size 54.0))
    (values (- x (/ size 2))
            (- +menu-start-y+ (/ size 2))
            size
            size)))

(-> mouse-on-menu-arrow-p (menu-direction) boolean)
(defun mouse-on-menu-arrow-p (direction)
  (multiple-value-bind (left top width height)
      (menu-arrow-bounds direction)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(-> menu-arrow-pressed-p (menu-direction) boolean)
(defun menu-arrow-pressed-p (direction)
  (or (and (mouse-on-menu-arrow-p direction)
           (is-mouse-button-down-p +mouse-button-left+))
      (if (minusp direction)
          (is-key-down-p +key-left+)
          (is-key-down-p +key-right+))))
