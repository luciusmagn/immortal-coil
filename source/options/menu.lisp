(in-package #:immortal-coil)

;;; Geometry

(defconstant +options-title-y+ 164.0)
(defconstant +options-row-start-y+ 246.0)
(defconstant +options-row-spacing+ 50.0)
(defconstant +options-label-x+ 430.0)
(defconstant +options-value-right-x+ 880.0)
(defconstant +options-row-left+ 360.0)
(defconstant +options-row-width+ 560.0)
(defconstant +options-row-height+ 36.0)
(defconstant +options-panel-width+ 640)
(defconstant +options-panel-height+ 484)
(defconstant +options-panel-top+ 132)

(-> options-row-y (integer) scalar)
(defun options-row-y (index)
  (+ +options-row-start-y+
     (* index +options-row-spacing+)))

(-> options-point-in-rect-p (scalar scalar scalar scalar scalar scalar)
    boolean)
(defun options-point-in-rect-p (x y left top width height)
  (and (>= x left)
       (<= x (+ left width))
       (>= y top)
       (<= y (+ top height))))

(-> mouse-on-options-row-p (integer) boolean)
(defun mouse-on-options-row-p (index)
  (options-point-in-rect-p (virtual-mouse-x)
                           (virtual-mouse-y)
                           +options-row-left+
                           (- (options-row-y index) 8)
                           +options-row-width+
                           +options-row-height+))

(-> hovered-options-row-index () (option integer))
(defun hovered-options-row-index ()
  (loop for index below (selection-count *options-selection*)
        when (mouse-on-options-row-p index)
          return index))

(-> options-row-hovered-p (integer) boolean)
(defun options-row-hovered-p (index)
  (and *options-mouse-hover-active-p*
       (mouse-on-options-row-p index)))

(-> options-panel-left () scalar)
(defun options-panel-left ()
  (- +virtual-center-x+ (/ +options-panel-width+ 2.0)))


;;; Rendering

(-> draw-options-marker (scalar scalar t) t)
(defun draw-options-marker (x y color)
  (draw-triangle-points x
                        y
                        (- x 12.0)
                        (- y 8.0)
                        (- x 12.0)
                        (+ y 8.0)
                        color
                        :filled-p t))

(-> draw-options-value-arrows (scalar scalar t) t)
(defun draw-options-value-arrows (x y color)
  (draw-triangle-points (- x 84.0) y
                        (- x 72.0) (- y 8.0)
                        (- x 72.0) (+ y 8.0)
                        color
                        :filled-p t)
  (draw-triangle-points (+ x 18.0) y
                        (+ x 6.0) (+ y 8.0)
                        (+ x 6.0) (- y 8.0)
                        color
                        :filled-p t))

(-> draw-options-row (integer) t)
(defun draw-options-row (index)
  (let* ((option (selection-item *options-selection* index))
         (action (command-option-action option))
         (selected-p (= index (selection-current-index *options-selection*)))
         (hovered-p (options-row-hovered-p index))
         (alpha (cond
                  ((or selected-p hovered-p) 255)
                  (t 172)))
         (color (make-color 255 255 255 alpha))
         (y (options-row-y index))
         (label (options-display-label option))
         (value (options-value-label action))
         (value-width (text-width value 20)))
    (when selected-p
      (draw-options-marker (- +options-label-x+ 34.0)
                           (+ y 10.0)
                           color))
    (draw-text-at label +options-label-x+ y 20 color)
    (when (plusp (length value))
      (draw-text-at value
                    (- +options-value-right-x+ value-width)
                    y
                    20
                    color)
      (when (and selected-p
                 (option-adjustable-p action))
        (draw-options-value-arrows (- +options-value-right-x+ value-width)
                                   (+ y 10.0)
                                   color)))))

(-> draw-options-panel () t)
(defun draw-options-panel ()
  (let ((left (options-panel-left))
        (top +options-panel-top+))
    (claylib/ll:draw-rectangle (round left)
                               (round top)
                               +options-panel-width+
                               +options-panel-height+
                               (claylib::c-ptr
                                (make-color 0 0 0 255)))
    (draw-rectangle-outline left
                            top
                            +options-panel-width+
                            +options-panel-height+
                            (make-color 255 255 255 255)
                            :thickness 2)))

(-> draw-options-menu () t)
(defun draw-options-menu ()
  (let ((color (make-color 255 255 255 240)))
    (draw-options-panel)
    (draw-centered-text "OPTIONS"
                        +virtual-center-x+
                        +options-title-y+
                        28
                        color)
    (loop for index below (selection-count *options-selection*)
          do (draw-options-row index))))


;;; Updating

(-> options-selection-direction () (option navigation-direction))
(defun options-selection-direction ()
  (cond
    ((is-key-pressed-p +key-down+) 1)
    ((is-key-pressed-p +key-up+) -1)))

(-> options-adjust-direction () (option navigation-direction))
(defun options-adjust-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)))

(-> move-options-selection ((option navigation-direction)) t)
(defun move-options-selection (direction)
  (when (selection-move *options-selection* direction)
    (deactivate-options-mouse-hover)
    (play-choice-switch)))

(-> update-options-mouse () t)
(defun update-options-mouse ()
  (let ((moved-p (options-mouse-moved-p))
        (index (hovered-options-row-index)))
    (cond
      ((and index
            (is-mouse-button-pressed-p +mouse-button-left+))
       (setf *options-mouse-hover-active-p* t
             (selection-selected-index *options-selection*) index)
       (activate-selected-option))
      ((and moved-p index)
       (setf *options-mouse-hover-active-p* t
             (selection-selected-index *options-selection*) index))
      (moved-p
       (deactivate-options-mouse-hover)))))

(-> update-options-menu () t)
(defun update-options-menu ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (close-options-menu))
    (t
     (update-options-mouse)
     (move-options-selection (options-selection-direction))
     (let ((direction (options-adjust-direction)))
       (when (and direction
                  (option-adjustable-p (selected-options-action)))
         (adjust-option-value (selected-options-action) direction)))
     (when (confirm-pressed-p)
       (activate-selected-option)))))
