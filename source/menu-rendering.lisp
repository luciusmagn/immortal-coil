(in-package #:immortal-coil)

(-> menu-alpha-scale () scalar)
(defun menu-alpha-scale ()
  (smoothstep (/ *menu-elapsed* *menu-fade-seconds*)))

(-> start-button-flash-scale () scalar)
(defun start-button-flash-scale ()
  (if (eq *menu-start-state* :starting)
      (+ 0.25 (* 0.75
                 (if (< (mod (* *menu-start-elapsed* 10.0) 1.0) 0.5)
                     1.0
                     0.35)))
      1.0))

(-> menu-option-alpha () alpha-channel)
(defun menu-option-alpha ()
  (if (selected-menu-action-available-p)
      245
      112))

(-> draw-menu-option () t)
(defun draw-menu-option ()
  (let* ((alpha-scale (menu-alpha-scale))
         (button-scale (* alpha-scale (start-button-flash-scale)))
         (hovered-p (mouse-on-menu-option-p))
         (base-alpha (if hovered-p 255 (menu-option-alpha)))
         (color (make-color 255 255 255 (round (* base-alpha button-scale)))))
    (draw-centered-text (selected-menu-label)
                        +menu-start-x+
                        +menu-start-y+
                        *menu-start-text-size*
                        color)))

(-> menu-status-text () (option string))
(defun menu-status-text ()
  (when (eq (selected-menu-action) :mods)
    *menu-status-message*))

(-> draw-menu-status () t)
(defun draw-menu-status ()
  (let ((text (menu-status-text)))
    (when text
      (draw-centered-text text
                          +menu-start-x+
                          (+ +menu-start-y+ 42)
                          13
                          (make-color 255
                                      255
                                      255
                                      (round (* 180 (menu-alpha-scale))))))))

(-> draw-menu-arrow-triangle (scalar scalar scalar scalar scalar scalar t) t)
(defun draw-menu-arrow-triangle (x1 y1 x2 y2 x3 y3 color)
  (draw-triangle-points x1 y1 x2 y2 x3 y3 color :filled-p t)
  (draw-triangle-points x1 y1 x3 y3 x2 y2 color :filled-p t))

(-> draw-menu-arrow-shape (menu-direction scalar scalar scalar scalar t) t)
(defun draw-menu-arrow-shape (direction x y width height color)
  (if (minusp direction)
      (draw-menu-arrow-triangle (- x (/ width 2)) y
                                (+ x (/ width 2)) (- y (/ height 2))
                                (+ x (/ width 2)) (+ y (/ height 2))
                                color)
      (draw-menu-arrow-triangle (+ x (/ width 2)) y
                                (- x (/ width 2)) (+ y (/ height 2))
                                (- x (/ width 2)) (- y (/ height 2))
                                color)))

(-> menu-arrow-scale (menu-direction boolean boolean) scalar)
(defun menu-arrow-scale (direction hovered-p pressed-p)
  (let ((pulse (* 0.035
                  (sin (+ (* *menu-elapsed* 2.7)
                          (if (minusp direction) 0.0 pi))))))
    (* (+ 1.0 pulse (if hovered-p 0.055 0.0))
       (if pressed-p 0.86 1.0))))

(-> draw-menu-arrow-bloom (menu-direction scalar scalar scalar scalar scalar boolean) t)
(defun draw-menu-arrow-bloom (direction x y width height alpha-scale pressed-p)
  (let ((strength (if pressed-p 1.25 1.0)))
    (dolist (layer '((2.20 34) (1.62 62)))
      (destructuring-bind (scale alpha) layer
        (draw-menu-arrow-shape
         direction
         x
         y
         (* width scale)
         (* height scale)
         (make-color 255
                     255
                     255
                     (round (* alpha alpha-scale strength))))))))

(-> draw-menu-arrow (menu-direction) t)
(defun draw-menu-arrow (direction)
  (let* ((alpha-scale (menu-alpha-scale))
         (hovered-p (mouse-on-menu-arrow-p direction))
         (pressed-p (menu-arrow-pressed-p direction))
         (scale (menu-arrow-scale direction hovered-p pressed-p))
         (color (make-color 255 255 255 (round (* 255 alpha-scale))))
         (x (+ (menu-arrow-center-x direction)
               (if pressed-p (* direction 2.0) 0.0)))
         (y +menu-start-y+)
         (w (* 18.0 scale))
         (h (* 26.0 scale)))
    (draw-menu-arrow-bloom direction x y w h alpha-scale pressed-p)
    (draw-menu-arrow-shape direction x y w h color)))

(-> draw-menu-arrows () t)
(defun draw-menu-arrows ()
  (draw-menu-arrow -1)
  (draw-menu-arrow 1))

(-> draw-menu () t)
(defun draw-menu ()
  (draw-title-logo (menu-alpha-scale))
  (draw-particles (menu-alpha-scale))
  (draw-menu-arrows)
  (draw-menu-option)
  (draw-menu-status))
