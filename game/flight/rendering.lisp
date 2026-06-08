(in-package #:immortal-coil)

;;; Projection

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

(-> flight-view-left () scalar)
(defun flight-view-left ()
  (- +flight-center-x+ (/ +flight-view-width+ 2.0)))

(-> flight-view-top () scalar)
(defun flight-view-top ()
  (- +flight-center-y+ (/ +flight-view-height+ 2.0)))

(-> flight-view-right () scalar)
(defun flight-view-right ()
  (+ +flight-center-x+ (/ +flight-view-width+ 2.0)))

(-> flight-view-bottom () scalar)
(defun flight-view-bottom ()
  (+ +flight-center-y+ (/ +flight-view-height+ 2.0)))

(-> flight-depth-alpha (scalar alpha-channel alpha-channel) alpha-channel)
(defun flight-depth-alpha (z min-alpha max-alpha)
  (let ((progress (clamp01 (/ (- +flight-visible-depth+ z)
                              +flight-visible-depth+))))
    (round (+ min-alpha (* (- max-alpha min-alpha) progress)))))

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


;;; Tunnel

(-> draw-flight-tunnel-rail (list) t)
(defun draw-flight-tunnel-rail (corner)
  (multiple-value-bind (near-x near-y)
      (flight-project (first corner) (second corner) 0.65)
    (multiple-value-bind (far-x far-y)
        (flight-project (first corner) (second corner) +flight-visible-depth+)
      (draw-thick-line-between near-x
                               near-y
                               far-x
                               far-y
                               (make-color 255 255 255 46)
                               1.0))))

(-> draw-flight-tunnel-rails () t)
(defun draw-flight-tunnel-rails ()
  (dolist (corner '((-1.0 -1.0)
                    (1.0 -1.0)
                    (1.0 1.0)
                    (-1.0 1.0)))
    (draw-flight-tunnel-rail corner)))

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

(-> draw-flight-view-border () t)
(defun draw-flight-view-border ()
  (let ((color (make-color 255 255 255 82)))
    (draw-thick-line-between (flight-view-left)
                             (flight-view-top)
                             (flight-view-right)
                             (flight-view-top)
                             color
                             1.0)
    (draw-thick-line-between (flight-view-left)
                             (flight-view-bottom)
                             (flight-view-right)
                             (flight-view-bottom)
                             color
                             1.0)
    (draw-thick-line-between (flight-view-left)
                             (flight-view-top)
                             (flight-view-left)
                             (flight-view-bottom)
                             color
                             1.0)
    (draw-thick-line-between (flight-view-right)
                             (flight-view-top)
                             (flight-view-right)
                             (flight-view-bottom)
                             color
                             1.0)))


;;; Gates

(-> flight-target-gate-index (flight-minigame) flight-gate-index)
(defun flight-target-gate-index (game)
  (max 1 (ceiling (+ (flight-minigame-distance game) 0.25))))

(-> draw-flight-gate-highlight (scalar scalar scalar scalar) t)
(defun draw-flight-gate-highlight (gate-x gate-y half-size z)
  (draw-flight-rectangle (- gate-x half-size)
                         (- gate-y half-size)
                         (+ gate-x half-size)
                         (+ gate-y half-size)
                         z
                         (make-color 255 255 255 54)
                         7.0))

(-> draw-flight-gate-frame (scalar scalar scalar scalar t t boolean) t)
(defun draw-flight-gate-frame (gate-x gate-y half-size z outer-color
                               opening-color active-p)
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
                         (if active-p 3.0 1.4)))

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
            (draw-flight-gate-highlight gate-x gate-y half-size z))
          (draw-flight-gate-frame gate-x
                                  gate-y
                                  half-size
                                  z
                                  outer-color
                                  opening-color
                                  active-p))))))

(-> draw-flight-gates (flight-minigame) t)
(defun draw-flight-gates (game)
  (let ((first-gate (max 1 (floor (flight-minigame-distance game))))
        (target-gate (flight-target-gate-index game)))
    (loop for gate from first-gate below (+ first-gate 9)
          unless (= gate target-gate)
            do (draw-flight-gate game gate nil))
    (draw-flight-gate game target-gate t)))


;;; Player and HUD

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

(-> flight-ship-rotated-point (scalar scalar list)
    (values scalar scalar scalar))
(defun flight-ship-rotated-point (aim-x aim-y point)
  (destructuring-bind (local-x local-y depth) point
    (let* ((yaw (clamp-value (* aim-x 0.46) -0.46 0.46))
           (pitch (clamp-value (* aim-y 0.36) -0.36 0.36))
           (cos-yaw (cos yaw))
           (sin-yaw (sin yaw))
           (cos-pitch (cos pitch))
           (sin-pitch (sin pitch))
           (x local-x)
           (y (- local-y 32.0))
           (z (- depth 22.0))
           (yaw-x (+ (* x cos-yaw) (* z sin-yaw)))
           (yaw-z (- (* z cos-yaw) (* x sin-yaw)))
           (pitch-y (+ (* y cos-pitch) (* yaw-z sin-pitch)))
           (pitch-z (- (* yaw-z cos-pitch) (* y sin-pitch))))
      (values yaw-x
              (+ pitch-y 32.0)
              (+ pitch-z 22.0)))))

(-> flight-ship-point (scalar scalar scalar scalar list)
    (values scalar scalar))
(defun flight-ship-point (center-x center-y aim-x aim-y point)
  (multiple-value-bind (x y depth)
      (flight-ship-rotated-point aim-x aim-y point)
    (let ((scale (+ 1.0 (* (clamp-value depth -26.0 72.0) 0.004))))
      (values (+ center-x (* x scale))
              (+ center-y
                 (* y scale)
                 (- (* depth 0.13)))))))

(-> draw-flight-ship-surface (scalar scalar scalar scalar list list list t) t)
(defun draw-flight-ship-surface (center-x center-y aim-x aim-y
                                 point-a point-b point-c color)
  (multiple-value-bind (x1 y1)
      (flight-ship-point center-x center-y aim-x aim-y point-a)
    (multiple-value-bind (x2 y2)
        (flight-ship-point center-x center-y aim-x aim-y point-b)
      (multiple-value-bind (x3 y3)
          (flight-ship-point center-x center-y aim-x aim-y point-c)
        (draw-triangle-points x1
                              y1
                              x2
                              y2
                              x3
                              y3
                              color
                              :filled-p t)))))

(-> draw-flight-ship-edge (scalar scalar scalar scalar list list t scalar)
    t)
(defun draw-flight-ship-edge (center-x center-y aim-x aim-y
                              point-a point-b color thickness)
  (multiple-value-bind (x1 y1)
      (flight-ship-point center-x
                         center-y
                         aim-x
                         aim-y
                         point-a)
    (multiple-value-bind (x2 y2)
        (flight-ship-point center-x
                           center-y
                           aim-x
                           aim-y
                           point-b)
      (draw-thick-line-between x1 y1 x2 y2 color thickness))))

(-> flight-ship-side-shade (scalar scalar scalar) alpha-channel)
(defun flight-ship-side-shade (base steering bias)
  (round (clamp-value (+ base (* steering bias)) 42.0 235.0)))

(-> draw-flight-ship-body (scalar scalar scalar scalar t) t)
(defun draw-flight-ship-body (center-x center-y aim-x aim-y outline-color)
  (let* ((nose           '(0.0 -8.0 66.0))
         (left-shoulder  '(-16.0 14.0 42.0))
         (right-shoulder '(16.0 14.0 42.0))
         (spine          '(0.0 28.0 22.0))
         (left-wing      '(-54.0 34.0 15.0))
         (right-wing     '(54.0 34.0 15.0))
         (left-tail      '(-20.0 54.0 0.0))
         (right-tail     '(20.0 54.0 0.0))
         (tail           '(0.0 66.0 0.0))
         (left-shade     (flight-ship-side-shade 154.0 aim-x 42.0))
         (right-shade    (flight-ship-side-shade 118.0 aim-x -42.0))
         (left-color     (make-color left-shade left-shade left-shade 224))
         (right-color    (make-color right-shade right-shade right-shade 224))
         (center-color   (make-color 224 224 224 232))
         (rear-color     (make-color 76 76 76 206))
         (soft-outline   (make-color 255 255 255 142)))
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              left-wing left-tail tail rear-color)
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              right-wing tail right-tail rear-color)
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              nose left-wing tail left-color)
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              nose tail right-wing right-color)
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              nose left-shoulder spine center-color)
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              nose spine right-shoulder center-color)
    (dolist (edge `((,nose ,left-wing 2.0)
                    (,nose ,right-wing 2.0)
                    (,nose ,tail 1.4)
                    (,nose ,spine 1.2)
                    (,left-shoulder ,spine 1.0)
                    (,spine ,right-shoulder 1.0)
                    (,left-shoulder ,left-wing 1.0)
                    (,right-shoulder ,right-wing 1.0)
                    (,left-wing ,left-tail 1.2)
                    (,left-tail ,tail 1.2)
                    (,tail ,right-tail 1.2)
                    (,right-tail ,right-wing 1.2)
                    (,left-shoulder ,nose 1.0)
                    (,right-shoulder ,nose 1.0)))
      (destructuring-bind (point-a point-b thickness) edge
        (draw-flight-ship-edge center-x
                               center-y
                               aim-x
                               aim-y
                               point-a
                               point-b
                               (if (< thickness 1.2)
                                   soft-outline
                                   outline-color)
                               thickness)))))

(-> draw-flight-player (flight-minigame t) t)
(defun draw-flight-player (game color)
  (multiple-value-bind (x y)
      (flight-cockpit-position (flight-minigame-player-x game)
                               (flight-minigame-player-y game))
    (draw-flight-ship-body x
                           y
                           (flight-minigame-ship-aim-x game)
                           (flight-minigame-ship-aim-y game)
                           color)))

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
    (draw-centered-text "WASD / ARROWS STEER"
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))


;;; Entry point

(-> draw-flight-minigame (node t) t)
(defun draw-flight-minigame (node color)
  (let ((game (ensure-flight-minigame node)))
    (draw-flight-tunnel-frames)
    (draw-flight-gates game)
    (draw-flight-guidance game)
    (draw-flight-player game color)
    (draw-flight-view-border)
    (draw-flight-hud game color)))
