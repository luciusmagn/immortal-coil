(in-package #:immortal-coil)

(defconstant +flight-center-x+ +virtual-center-x+)
(defconstant +flight-center-y+ 420.0)
(defconstant +flight-view-width+ 760.0)
(defconstant +flight-view-height+ 390.0)
(defconstant +flight-visible-depth+ 8.0)
(defconstant +flight-success-distance+ 28.0)
(defconstant +flight-safe-gate-count+ 3)
(defconstant +flight-cockpit-scale+ 0.32)

(defvar *flight-minigame* nil)

(defstruct flight-minigame
  node-id
  elapsed
  distance
  player-x
  player-y
  velocity-x
  velocity-y
  last-gate)

(defun clamp-value (value min max)
  (min max (max min value)))

(defun make-fresh-flight-minigame (node)
  (make-flight-minigame :node-id (node-id node)
                        :elapsed 0.0
                        :distance 0.0
                        :player-x 0.0
                        :player-y 0.0
                        :velocity-x 0.0
                        :velocity-y 0.0
                        :last-gate 0))

(defun ensure-flight-minigame (node)
  (unless (and *flight-minigame*
               (equal (flight-minigame-node-id *flight-minigame*)
                      (node-id node)))
    (setf *flight-minigame* (make-fresh-flight-minigame node)))
  *flight-minigame*)

(defun flight-axis (negative-key positive-key)
  (- (if (is-key-down-p positive-key) 1.0 0.0)
     (if (is-key-down-p negative-key) 1.0 0.0)))

(defun flight-input-x ()
  (+ (flight-axis +key-left+ +key-right+)
     (flight-axis +key-a+ +key-d+)))

(defun flight-input-y ()
  (+ (flight-axis +key-up+ +key-down+)
     (flight-axis +key-w+ +key-s+)))

(defun flight-speed (game)
  (+ 0.76 (* 0.038 (flight-minigame-elapsed game))))

(defun flight-opening-half-size (gate-index)
  (max 0.31 (- 0.55 (* gate-index 0.008))))

(defun flight-gate-drift-scale (gate-index)
  (smoothstep (/ (max 0 (- gate-index +flight-safe-gate-count+))
                 7.0)))

(defun flight-gate-center (gate-index)
  (let ((drift (flight-gate-drift-scale gate-index)))
    (values (* drift
               (+ (* 0.36 (sin (+ 0.7 (* gate-index 0.82))))
                  (* 0.14 (sin (* gate-index 1.71)))))
            (* drift
               (+ (* 0.30 (cos (+ 0.4 (* gate-index 0.73))))
                  (* 0.12 (sin (* gate-index 1.17))))))))

(defun flight-player-in-gate-p (game gate-index)
  (multiple-value-bind (gate-x gate-y)
      (flight-gate-center gate-index)
    (let ((half-size (flight-opening-half-size gate-index)))
      (and (<= (abs (- (flight-minigame-player-x game) gate-x))
               half-size)
           (<= (abs (- (flight-minigame-player-y game) gate-y))
               half-size)))))

(defun record-flight-crash ()
  (setf (dialog-value "ship-crashed") t))

(defun finish-flight-minigame (target)
  (setf *flight-minigame* nil)
  (jump-to-node target))

(defun fail-flight-minigame (node)
  (record-flight-crash)
  (finish-flight-minigame (node-failure-target node)))

(defun succeed-flight-minigame (node)
  (setf (dialog-value "ship-survived") t)
  (finish-flight-minigame (node-success-target node)))

(defun update-flight-physics (game dt)
  (let* ((input-x (clamp-value (flight-input-x) -1.0 1.0))
         (input-y (clamp-value (flight-input-y) -1.0 1.0))
         (damping (expt 0.08 dt)))
    (incf (flight-minigame-velocity-x game) (* input-x 2.6 dt))
    (incf (flight-minigame-velocity-y game) (* input-y 2.6 dt))
    (setf (flight-minigame-velocity-x game)
          (* (flight-minigame-velocity-x game) damping)
          (flight-minigame-velocity-y game)
          (* (flight-minigame-velocity-y game) damping))
    (incf (flight-minigame-player-x game)
          (* (flight-minigame-velocity-x game) dt))
    (incf (flight-minigame-player-y game)
          (* (flight-minigame-velocity-y game) dt))
    (setf (flight-minigame-player-x game)
          (clamp-value (flight-minigame-player-x game) -1.05 1.05)
          (flight-minigame-player-y game)
          (clamp-value (flight-minigame-player-y game) -1.05 1.05))))

(defun check-flight-gates (node game)
  (let ((current-gate (floor (flight-minigame-distance game))))
    (loop for gate from (1+ (flight-minigame-last-gate game)) to current-gate
          unless (or (<= gate +flight-safe-gate-count+)
                     (flight-player-in-gate-p game gate))
            do (fail-flight-minigame node)
               (return-from check-flight-gates nil)
          finally (setf (flight-minigame-last-gate game)
                        current-gate)))
  (when (>= (flight-minigame-distance game) +flight-success-distance+)
    (succeed-flight-minigame node)))

(defun update-flight-minigame-node (node dt)
  (let ((game (ensure-flight-minigame node)))
    (incf (flight-minigame-elapsed game) dt)
    (incf (flight-minigame-distance game)
          (* (flight-speed game) dt))
    (update-flight-physics game dt)
    (check-flight-gates node game)))

(defun update-minigame-node (node dt)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (case (node-minigame node)
       (:wire-flight (update-flight-minigame-node node dt))
       (t
        (runtime-warn "Unknown minigame: ~a" (node-minigame node))
        (jump-to-node (or (node-failure-target node)
                          (node-success-target node)
                          *runtime-fallback-node-id*)))))))

(defun flight-project (x y z)
  (let* ((depth (+ z 0.75))
         (scale (/ 1.0 depth)))
    (values (+ +flight-center-x+
               (* x +flight-view-width+ 0.5 scale))
            (+ +flight-center-y+
               (* y +flight-view-height+ 0.5 scale)))))

(defun flight-cockpit-position (x y)
  (values (+ +flight-center-x+
             (* x +flight-view-width+ +flight-cockpit-scale+))
          (+ +flight-center-y+
             (* y +flight-view-height+ +flight-cockpit-scale+))))

(defun flight-depth-alpha (z min-alpha max-alpha)
  (let ((progress (clamp01 (/ (- +flight-visible-depth+ z)
                              +flight-visible-depth+))))
    (round (+ min-alpha (* (- max-alpha min-alpha) progress)))))

(defun flight-target-gate-index (game)
  (max 1 (ceiling (+ (flight-minigame-distance game) 0.25))))

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

(defun draw-flight-gates (game)
  (let ((first-gate (max 1 (floor (flight-minigame-distance game))))
        (target-gate (flight-target-gate-index game)))
    (loop for gate from first-gate below (+ first-gate 9)
          unless (= gate target-gate)
            do (draw-flight-gate game gate nil))
    (draw-flight-gate game target-gate t)))

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

(defun draw-flight-minigame (node color)
  (let ((game (ensure-flight-minigame node)))
    (draw-flight-tunnel-frames)
    (draw-flight-gates game)
    (draw-flight-guidance game)
    (draw-flight-player game color)
    (draw-flight-hud game color)))

(defun draw-minigame-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node 96 color)
    (when (and (story-text-visible-p node)
               (eq (node-minigame node) :wire-flight))
      (draw-flight-minigame node (make-color 255 255 255 230)))))
