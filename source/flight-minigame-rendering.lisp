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

(-> flight-target-gate-index (flight-minigame) flight-gate-index)
(defun flight-target-gate-index (game)
  (max 1 (ceiling (+ (flight-minigame-distance game) 0.25))))

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

(-> draw-flight-tunnel-rails () t)
(defun draw-flight-tunnel-rails ()
  (dolist (corner '((-1.0 -1.0)
                    (1.0 -1.0)
                    (1.0 1.0)
                    (-1.0 1.0)))
    (multiple-value-bind (near-x near-y)
        (flight-project (first corner) (second corner) 0.65)
      (multiple-value-bind (far-x far-y)
          (flight-project (first corner) (second corner) +flight-visible-depth+)
        (draw-thick-line-between near-x
                                 near-y
                                 far-x
                                 far-y
                                 (make-color 255 255 255 46)
                                 1.0)))))

(-> draw-flight-tunnel-frames () t)
(defun draw-flight-tunnel-frames ()
  (loop for z from 0.7 to +flight-visible-depth+ by 0.7
        for alpha = (flight-depth-alpha z 18 70)
        do (draw-flight-rectangle -1.0
                                  -1.0
                                  1.0
                                  1.0
                                  z
                                  (make-color 255 255 255 alpha)))
  (draw-flight-tunnel-rails))

(-> draw-flight-gate (flight-minigame flight-gate-index boolean) t)
(defun draw-flight-gate (game gate-index active-p)
  (let ((z (- gate-index (flight-minigame-distance game))))
    (when (and (> z 0.25)
               (< z +flight-visible-depth+))
      (multiple-value-bind (gate-x gate-y)
          (flight-gate-center gate-index)
        (let* ((half-size (flight-opening-half-size gate-index))
               (outer-alpha (if active-p
                                90
                                (flight-depth-alpha z 24 78)))
               (opening-alpha (if active-p
                                  246
                                  (flight-depth-alpha z 74 150)))
               (outer-color (make-color 255 255 255 outer-alpha))
               (opening-color (make-color 255 255 255 opening-alpha)))
          (when active-p
            (draw-flight-rectangle (- gate-x half-size)
                                   (- gate-y half-size)
                                   (+ gate-x half-size)
                                   (+ gate-y half-size)
                                   z
                                   (make-color 255 255 255 54)
                                   7.0))
          (draw-flight-rectangle -1.0
                                 -1.0
                                 1.0
                                 1.0
                                 z
                                 outer-color
                                 (if active-p 2.0 1.0))
          (draw-flight-rectangle (- gate-x half-size)
                                 (- gate-y half-size)
                                 (+ gate-x half-size)
                                 (+ gate-y half-size)
                                 z
                                 opening-color
                                 (if active-p 3.0 1.4)))))))

(-> draw-flight-gates (flight-minigame) t)
(defun draw-flight-gates (game)
  (let ((first-gate (max 1 (floor (flight-minigame-distance game))))
        (target-gate (flight-target-gate-index game)))
    (loop for gate from first-gate below (+ first-gate 9)
          unless (= gate target-gate)
            do (draw-flight-gate game gate nil))
    (draw-flight-gate game target-gate t)))

(-> draw-flight-target-brackets (scalar scalar t) t)
(defun draw-flight-target-brackets (x y color)
  (let ((half-size 24.0)
        (mark-size 10.0)
        (thickness 2.0))
    (dolist (corner '((-1.0 -1.0)
                      (1.0 -1.0)
                      (1.0 1.0)
                      (-1.0 1.0)))
      (let* ((side-x (first corner))
             (side-y (second corner))
             (corner-x (+ x (* side-x half-size)))
             (corner-y (+ y (* side-y half-size))))
        (draw-thick-line-between corner-x
                                 corner-y
                                 (- corner-x (* side-x mark-size))
                                 corner-y
                                 color
                                 thickness)
        (draw-thick-line-between corner-x
                                 corner-y
                                 corner-x
                                 (- corner-y (* side-y mark-size))
                                 color
                                 thickness)))))

(-> draw-flight-guidance (flight-minigame) t)
(defun draw-flight-guidance (game)
  (let ((target-gate (flight-target-gate-index game)))
    (multiple-value-bind (target-x target-y)
        (flight-gate-center target-gate)
      (multiple-value-bind (guide-x guide-y)
          (flight-cockpit-position target-x target-y)
        (multiple-value-bind (player-x player-y)
            (flight-cockpit-position (flight-minigame-player-x game)
                                     (flight-minigame-player-y game))
          (draw-thick-line-between player-x
                                   player-y
                                   guide-x
                                   guide-y
                                   (make-color 255 255 255 88)
                                   1.0)
          (draw-flight-target-brackets guide-x
                                       guide-y
                                       (make-color 255 255 255 184))
          (claylib/ll:draw-rectangle (round (- guide-x 2))
                                     (round (- guide-y 2))
                                     4
                                     4
                                     (claylib::c-ptr
                                      (make-color 255 255 255 220))))))))

(-> draw-flight-player (flight-minigame t) t)
(defun draw-flight-player (game color)
  (multiple-value-bind (x y)
      (flight-cockpit-position (flight-minigame-player-x game)
                               (flight-minigame-player-y game))
    (let ((size 18.0))
      (draw-thick-line-between (- x 30) y (+ x 30) y color 2.0)
      (draw-thick-line-between x (- y 30) x (+ y 30) color 2.0)
      (draw-thick-line-between (- x 14) (- y 14) (+ x 14) (+ y 14) color 1.0)
      (draw-thick-line-between (- x 14) (+ y 14) (+ x 14) (- y 14) color 1.0)
      (draw-triangle-points x (- y size)
                            (- x size) (+ y size)
                            (+ x size) (+ y size)
                            color
                            :filled-p t))))

(-> draw-flight-hud (flight-minigame t) t)
(defun draw-flight-hud (game color)
  (let ((distance-label (format nil "~2,'0d/~2,'0d"
                                (min (floor (flight-minigame-distance game))
                                     (round +flight-success-distance+))
                                (round +flight-success-distance+))))
    (draw-centered-text distance-label
                        +virtual-center-x+
                        (- +virtual-height+ 72)
                        18
                        color)
    (draw-centered-text "WASD / ARROWS"
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))

(-> draw-flight-minigame (node t) t)
(defun draw-flight-minigame (node color)
  (let ((game (ensure-flight-minigame node)))
    (draw-flight-tunnel-frames)
    (draw-flight-gates game)
    (draw-flight-guidance game)
    (draw-flight-player game color)
    (draw-flight-hud game color)))
