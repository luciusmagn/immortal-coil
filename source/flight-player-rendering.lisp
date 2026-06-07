(in-package #:immortal-coil)

(-> draw-flight-target-corner (scalar scalar scalar scalar t) t)
(defun draw-flight-target-corner (x y side-x side-y color)
  (let ((half-size 24.0)
        (mark-size 10.0)
        (thickness 2.0))
    (let ((corner-x (+ x (* side-x half-size)))
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
                               thickness))))

(-> draw-flight-target-brackets (scalar scalar t) t)
(defun draw-flight-target-brackets (x y color)
  (dolist (corner '((-1.0 -1.0)
                    (1.0 -1.0)
                    (1.0 1.0)
                    (-1.0 1.0)))
    (draw-flight-target-corner x y (first corner) (second corner) color)))

(-> draw-flight-guidance-dot (scalar scalar) t)
(defun draw-flight-guidance-dot (x y)
  (claylib/ll:draw-rectangle (round (- x 2))
                             (round (- y 2))
                             4
                             4
                             (claylib::c-ptr
                              (make-color 255 255 255 220))))

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
          (draw-flight-guidance-dot guide-x guide-y))))))

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
