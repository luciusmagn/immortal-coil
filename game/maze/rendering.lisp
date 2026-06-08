(in-package #:immortal-coil)

(defconstant +dream-maze-view-left+ 130)
(defconstant +dream-maze-view-top+ 154)
(defconstant +dream-maze-view-width+ 1020)
(defconstant +dream-maze-view-height+ 420)
(defconstant +dream-maze-ray-count+ 170)
(defconstant +dream-maze-fov+ 1.08)
(defconstant +dream-maze-dither-size+ 5)

(defparameter *dream-maze-bayer-4x4*
  #(0 8 2 10
    12 4 14 6
    3 11 1 9
    15 7 13 5))

(-> dream-maze-view-bottom () scalar)
(defun dream-maze-view-bottom ()
  (+ +dream-maze-view-top+ +dream-maze-view-height+))

(-> dream-maze-view-center-y () scalar)
(defun dream-maze-view-center-y ()
  (+ +dream-maze-view-top+ (/ +dream-maze-view-height+ 2.0)))

(-> dream-maze-column-width () scalar)
(defun dream-maze-column-width ()
  (/ +dream-maze-view-width+ +dream-maze-ray-count+))

(-> dream-maze-dither-threshold (integer integer) scalar)
(defun dream-maze-dither-threshold (x y)
  (/ (+ (aref *dream-maze-bayer-4x4*
              (+ (* (mod y 4) 4)
                 (mod x 4)))
        0.5)
     16.0))

(-> dream-maze-dither-lit-p (integer integer scalar) boolean)
(defun dream-maze-dither-lit-p (x y brightness)
  (< (dream-maze-dither-threshold x y)
     (clamp01 brightness)))

(-> draw-dream-maze-rect (scalar scalar scalar scalar alpha-channel) t)
(defun draw-dream-maze-rect (x y width height alpha)
  (claylib/ll:draw-rectangle (round x)
                             (round y)
                             (max 1 (round width))
                             (max 1 (round height))
                             (claylib::c-ptr
                              (make-color 255 255 255 alpha))))

(-> draw-dream-maze-black-rect (scalar scalar scalar scalar alpha-channel) t)
(defun draw-dream-maze-black-rect (x y width height alpha)
  (claylib/ll:draw-rectangle (round x)
                             (round y)
                             (max 1 (round width))
                             (max 1 (round height))
                             (claylib::c-ptr
                              (make-color 0 0 0 alpha))))

(-> draw-dream-maze-depth-field () t)
(defun draw-dream-maze-depth-field ()
  (let ((center (dream-maze-view-center-y))
        (block (* +dream-maze-dither-size+ 2)))
    (loop for y from center below (dream-maze-view-bottom) by block
          for row-index from 0
          for distance = (/ (- y center) (/ +dream-maze-view-height+ 2.0))
          for brightness = (* 0.28 (smoothstep distance))
          do (loop for x from +dream-maze-view-left+
                     below (+ +dream-maze-view-left+ +dream-maze-view-width+)
                     by (* block 2)
                   for column-index from 0
                   when (dream-maze-dither-lit-p column-index
                                                 row-index
                                                 brightness)
                     do (draw-dream-maze-rect x
                                              y
                                              +dream-maze-dither-size+
                                              +dream-maze-dither-size+
                                              150)))
    (loop for y downfrom center above +dream-maze-view-top+ by block
          for row-index from 0
          for distance = (/ (- center y) (/ +dream-maze-view-height+ 2.0))
          for brightness = (* 0.16 (smoothstep distance))
          do (loop for x from (+ +dream-maze-view-left+ block)
                     below (+ +dream-maze-view-left+ +dream-maze-view-width+)
                     by (* block 2)
                   for column-index from 0
                   when (dream-maze-dither-lit-p column-index
                                                 row-index
                                                 brightness)
                     do (draw-dream-maze-rect x
                                              y
                                              +dream-maze-dither-size+
                                              +dream-maze-dither-size+
                                              112)))))

(-> dream-maze-ray-angle (dream-maze-minigame nonnegative-integer) scalar)
(defun dream-maze-ray-angle (game column)
  (+ (dream-maze-minigame-angle game)
     (* (- (/ column (max 1.0 (1- +dream-maze-ray-count+)))
           0.5)
        +dream-maze-fov+)))

(-> dream-maze-corrected-distance (dream-maze-minigame scalar scalar) scalar)
(defun dream-maze-corrected-distance (game angle distance)
  (max 0.05
       (* distance
          (cos (- angle (dream-maze-minigame-angle game))))))

(-> dream-maze-wall-brightness (dream-maze-ray-hit scalar) scalar)
(defun dream-maze-wall-brightness (hit distance)
  (let* ((base (/ 1.0 (+ 0.38 (* distance 0.36))))
         (side-scale (if (dream-maze-ray-hit-vertical-p hit) 0.72 1.0))
         (exit-boost (if (dream-maze-exit-cell-p
                          (dream-maze-ray-hit-cell hit))
                         0.34
                         0.0)))
    (clamp01 (+ exit-boost (* base side-scale)))))

(-> dream-maze-wall-height (scalar) scalar)
(defun dream-maze-wall-height (distance)
  (min (* +dream-maze-view-height+ 1.8)
       (/ (* +dream-maze-view-height+ 0.82) distance)))

(-> draw-dream-maze-wall-column (integer scalar scalar scalar scalar boolean)
    t)
(defun draw-dream-maze-wall-column (column x top bottom brightness exit-p)
  (let ((column-width (ceiling (dream-maze-column-width))))
    (loop for y from top below bottom by +dream-maze-dither-size+
          for row-index from 0
          when (dream-maze-dither-lit-p column row-index brightness)
            do (draw-dream-maze-rect x
                                     y
                                     column-width
                                     +dream-maze-dither-size+
                                     (if exit-p 238 218)))
    (when exit-p
      (let ((center-x (+ x (/ column-width 2.0))))
        (draw-thick-line-between center-x
                                 top
                                 center-x
                                 bottom
                                 (make-color 255 255 255 190)
                                 1.0)))))

(-> dream-maze-visible-exit-p (dream-maze-minigame integer integer) boolean)
(defun dream-maze-visible-exit-p (game cell-x cell-y)
  (let* ((exit-x (+ cell-x 0.5))
         (exit-y (+ cell-y 0.5))
         (dx (- exit-x (dream-maze-minigame-x game)))
         (dy (- exit-y (dream-maze-minigame-y game)))
         (forward (+ (* dx (cos (dream-maze-minigame-angle game)))
                     (* dy (sin (dream-maze-minigame-angle game)))))
         (side (+ (* (- dx) (sin (dream-maze-minigame-angle game)))
                  (* dy (cos (dream-maze-minigame-angle game)))))
         (fov-side (* forward (tan (/ +dream-maze-fov+ 2.0)))))
    (and (> forward 0.12)
         (<= (abs side) fov-side)
         (dream-maze-exit-cell-p
          (dream-maze-ray-hit-cell
           (dream-maze-cast-ray game (atan dy dx)))))))

(-> dream-maze-exit-screen-position
    (dream-maze-minigame integer integer)
    (values scalar scalar scalar))
(defun dream-maze-exit-screen-position (game cell-x cell-y)
  (let* ((exit-x (+ cell-x 0.5))
         (exit-y (+ cell-y 0.5))
         (dx (- exit-x (dream-maze-minigame-x game)))
         (dy (- exit-y (dream-maze-minigame-y game)))
         (forward (+ (* dx (cos (dream-maze-minigame-angle game)))
                     (* dy (sin (dream-maze-minigame-angle game)))))
         (side (+ (* (- dx) (sin (dream-maze-minigame-angle game)))
                  (* dy (cos (dream-maze-minigame-angle game)))))
         (projection (/ side
                        (max 0.001
                             (* forward
                                (tan (/ +dream-maze-fov+ 2.0))))))
         (screen-x (+ +dream-maze-view-left+
                      (/ +dream-maze-view-width+ 2.0)
                      (* projection (/ +dream-maze-view-width+ 2.0)))))
    (values screen-x
            (dream-maze-view-center-y)
            (max 0.05 forward))))

(-> draw-dream-maze-exit-frame (scalar scalar scalar character) t)
(defun draw-dream-maze-exit-frame (screen-x center-y distance cell)
  (declare (ignore cell))
  (let* ((height (max 58.0
                      (min +dream-maze-view-height+
                           (* (dream-maze-wall-height distance) 0.9))))
         (width (max 58.0 (* height 0.42)))
         (left (- screen-x (/ width 2.0)))
         (right (+ screen-x (/ width 2.0)))
         (top (max +dream-maze-view-top+ (- center-y (/ height 2.0))))
         (bottom (min (dream-maze-view-bottom) (+ center-y (/ height 2.0))))
         (label-size (round (max 12.0 (min 22.0 (/ width 3.4)))))
         (label-y (+ top (* (- bottom top) 0.23))))
    (draw-dream-maze-black-rect (+ left 5)
                                (+ top 5)
                                (max 1 (- width 10))
                                (max 1 (- (- bottom top) 10))
                                232)
    (draw-thick-line-between left
                             top
                             right
                             top
                             (make-color 255 255 255 245)
                             3.0)
    (draw-thick-line-between left
                             bottom
                             right
                             bottom
                             (make-color 255 255 255 245)
                             3.0)
    (draw-thick-line-between left
                             top
                             left
                             bottom
                             (make-color 255 255 255 245)
                             3.0)
    (draw-thick-line-between right
                             top
                             right
                             bottom
                             (make-color 255 255 255 245)
                             3.0)
    (draw-centered-text "EXIT"
                        screen-x
                        label-y
                        label-size
                        (make-color 255 255 255 245))
    (draw-thick-line-between (- screen-x 12)
                             (+ label-y label-size 10)
                             (+ screen-x 12)
                             (+ label-y label-size 10)
                             (make-color 255 255 255 210)
                             2.0)))

(-> draw-dream-maze-visible-exits (dream-maze-minigame) t)
(defun draw-dream-maze-visible-exits (game)
  (dolist (exit (dream-maze-exit-cells))
    (destructuring-bind (cell-x cell-y cell) exit
      (when (dream-maze-visible-exit-p game cell-x cell-y)
        (multiple-value-bind (screen-x center-y distance)
            (dream-maze-exit-screen-position game cell-x cell-y)
          (draw-dream-maze-exit-frame screen-x center-y distance cell))))))

(-> draw-dream-maze-ray-column (dream-maze-minigame nonnegative-integer) t)
(defun draw-dream-maze-ray-column (game column)
  (let* ((angle (dream-maze-ray-angle game column))
         (hit (dream-maze-cast-ray game angle))
         (distance (dream-maze-corrected-distance
                    game
                    angle
                    (dream-maze-ray-hit-distance hit)))
         (height (dream-maze-wall-height distance))
         (center (dream-maze-view-center-y))
         (top (max +dream-maze-view-top+ (- center (/ height 2.0))))
         (bottom (min (dream-maze-view-bottom) (+ center (/ height 2.0))))
         (x (+ +dream-maze-view-left+
               (* column (dream-maze-column-width))))
         (exit-p (dream-maze-exit-cell-p (dream-maze-ray-hit-cell hit))))
    (draw-dream-maze-wall-column column
                                 x
                                 top
                                 bottom
                                 (dream-maze-wall-brightness hit distance)
                                 exit-p)))

(-> draw-dream-maze-view (dream-maze-minigame) t)
(defun draw-dream-maze-view (game)
  (draw-dream-maze-depth-field)
  (loop for column from 0 below +dream-maze-ray-count+
        do (draw-dream-maze-ray-column game column))
  (draw-dream-maze-visible-exits game)
  (draw-thick-line-between +dream-maze-view-left+
                           +dream-maze-view-top+
                           (+ +dream-maze-view-left+ +dream-maze-view-width+)
                           +dream-maze-view-top+
                           (make-color 255 255 255 80)
                           1.0)
  (draw-thick-line-between +dream-maze-view-left+
                           (dream-maze-view-bottom)
                           (+ +dream-maze-view-left+ +dream-maze-view-width+)
                           (dream-maze-view-bottom)
                           (make-color 255 255 255 80)
                           1.0))

(-> draw-dream-maze-reticle () t)
(defun draw-dream-maze-reticle ()
  (let ((x +virtual-center-x+)
        (y (dream-maze-view-center-y))
        (color (make-color 255 255 255 144)))
    (draw-thick-line-between (- x 10) y (- x 3) y color 1.0)
    (draw-thick-line-between (+ x 3) y (+ x 10) y color 1.0)
    (draw-thick-line-between x (- y 10) x (- y 3) color 1.0)
    (draw-thick-line-between x (+ y 3) x (+ y 10) color 1.0)))

(-> draw-dream-maze-minigame (node t) t)
(defun draw-dream-maze-minigame (node color)
  (declare (ignore color))
  (let ((game (ensure-dream-maze-minigame node)))
    (draw-dream-maze-view game)
    (draw-dream-maze-reticle)))
