(in-package #:immortal-coil)

;;; Projection helpers (flight-project, flight-cockpit-position) live in
;;; flight/minigame.lisp so the collision test can share them.

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


;;; Starfield. The 3d space used to be a stack of identical bounding
;;; rectangles. now it is star lines streaking past, which read as depth
;;; and speed without boxing the gates in.

(defconstant +flight-star-count+ 72)

(-> flight-star-unit (flight-gate-index flight-gate-index) scalar)
(defun flight-star-unit (index salt)
  (let* ((h (logand (+ (* (1+ index) 374761393) (* salt 2246822519))
                    #xffffffff))
         (h (logand (* (logxor h (ash h -15)) 2246822519) #xffffffff))
         (h (logand (* (logxor h (ash h -13)) 3266489917) #xffffffff)))
    (/ (float (logxor h (ash h -16)) 1.0) 4294967296.0)))

(-> draw-flight-star (flight-gate-index scalar) t)
(defun draw-flight-star (index distance)
  (let* ((span +flight-visible-depth+)
         (star-x (- (* (flight-star-unit index 1) 3.2) 1.6))
         (star-y (- (* (flight-star-unit index 2) 2.2) 1.1))
         (phase (* (flight-star-unit index 3) span))
         (z (- span (mod (+ distance phase) span)))
         (z-tail (min span (+ z 0.55))))
    (when (> z 0.05)
      (multiple-value-bind (near-x near-y)
          (flight-project star-x star-y z)
        (multiple-value-bind (far-x far-y)
            (flight-project star-x star-y z-tail)
          (draw-thick-line-between near-x
                                   near-y
                                   far-x
                                   far-y
                                   (make-color 255 255 255
                                               (flight-depth-alpha z 0 150))
                                   1.0))))))

(-> draw-flight-starfield (flight-minigame) t)
(defun draw-flight-starfield (game)
  (let ((distance (flight-minigame-distance game)))
    (dotimes (index +flight-star-count+)
      (draw-flight-star index distance))))

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
  (max 1 (ceiling (flight-minigame-distance game))))

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
    (when (and (> z 0.06)
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

;;; The ship model is a true 3d hull: x is lateral, y is vertical, and z
;;; runs nose-forward into the screen. Steering rolls the hull into the
;;; turn, yaws the nose, and pitches it with vertical input.

(-> flight-ship-rotated-point (scalar scalar list)
    (values scalar scalar scalar))
(defun flight-ship-rotated-point (aim-x aim-y point)
  (destructuring-bind (local-x local-y local-z) point
    (let* ((roll (clamp-value (* aim-x 0.42) -0.42 0.42))
           (yaw (clamp-value (* aim-x 0.28) -0.28 0.28))
           (pitch (clamp-value (* aim-y 0.30) -0.30 0.30))
           (cos-roll (cos roll))
           (sin-roll (sin roll))
           (cos-yaw (cos yaw))
           (sin-yaw (sin yaw))
           (cos-pitch (cos pitch))
           (sin-pitch (sin pitch))
           (roll-x (- (* local-x cos-roll) (* local-y sin-roll)))
           (roll-y (+ (* local-x sin-roll) (* local-y cos-roll)))
           (yaw-x (+ (* roll-x cos-yaw) (* local-z sin-yaw)))
           (yaw-z (- (* local-z cos-yaw) (* roll-x sin-yaw)))
           (pitch-y (+ (* roll-y cos-pitch) (* yaw-z sin-pitch)))
           (pitch-z (- (* yaw-z cos-pitch) (* roll-y sin-pitch))))
      (values yaw-x pitch-y pitch-z))))

(-> flight-ship-point (scalar scalar scalar scalar list)
    (values scalar scalar))
(defun flight-ship-point (center-x center-y aim-x aim-y point)
  (multiple-value-bind (x y z)
      (flight-ship-rotated-point aim-x aim-y point)
    (let ((scale (/ 1.0 (+ 1.0 (* (clamp-value z -100.0 100.0) 0.004)))))
      (values (+ center-x (* x scale))
              (+ center-y
                 (* y scale)
                 (- (* z 0.32)))))))

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
  (let* ((nose           '(0.0 2.0 70.0))
         (left-shoulder  '(-13.0 -4.0 28.0))
         (right-shoulder '(13.0 -4.0 28.0))
         (canopy         '(0.0 -12.0 16.0))
         (left-wing      '(-50.0 7.0 -16.0))
         (right-wing     '(50.0 7.0 -16.0))
         (left-tail      '(-16.0 -2.0 -36.0))
         (right-tail     '(16.0 -2.0 -36.0))
         (tail           '(0.0 4.0 -44.0))
         (left-shade     (flight-ship-side-shade 154.0 aim-x 42.0))
         (right-shade    (flight-ship-side-shade 118.0 aim-x -42.0))
         (top-shade      (flight-ship-side-shade 218.0 aim-y 26.0))
         (left-color     (make-color left-shade left-shade left-shade 224))
         (right-color    (make-color right-shade right-shade right-shade 224))
         (center-color   (make-color top-shade top-shade top-shade 232))
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
                              nose left-shoulder canopy center-color)
    (draw-flight-ship-surface center-x center-y aim-x aim-y
                              nose canopy right-shoulder center-color)
    (dolist (edge `((,nose ,left-wing 2.0)
                    (,nose ,right-wing 2.0)
                    (,nose ,tail 1.4)
                    (,nose ,canopy 1.2)
                    (,left-shoulder ,canopy 1.0)
                    (,canopy ,right-shoulder 1.0)
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
    (draw-flight-starfield game)
    (draw-flight-gates game)
    (draw-flight-guidance game)
    (draw-flight-player game color)
    (draw-flight-view-border)
    (draw-flight-hud game color)))
