(in-package #:immortal-coil)

(defconstant +flight-center-x+ +virtual-center-x+)
(defconstant +flight-center-y+ 420.0)
(defconstant +flight-view-width+ 760.0)
(defconstant +flight-view-height+ 390.0)
(defconstant +flight-visible-depth+ 8.0)
(defconstant +flight-success-distance+ 28.0)

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
  (+ 1.08 (* 0.055 (flight-minigame-elapsed game))))

(defun flight-opening-half-size (gate-index)
  (max 0.22 (- 0.43 (* gate-index 0.006))))

(defun flight-gate-center (gate-index)
  (values (+ (* 0.36 (sin (+ 0.7 (* gate-index 0.82))))
             (* 0.14 (sin (* gate-index 1.71))))
          (+ (* 0.30 (cos (+ 0.4 (* gate-index 0.73))))
             (* 0.12 (sin (* gate-index 1.17))))))

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
          unless (flight-player-in-gate-p game gate)
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
       (t (error "Unknown minigame: ~a" (node-minigame node)))))))

(defun flight-project (x y z)
  (let* ((depth (+ z 0.75))
         (scale (/ 1.0 depth)))
    (values (+ +flight-center-x+
               (* x +flight-view-width+ 0.5 scale))
            (+ +flight-center-y+
               (* y +flight-view-height+ 0.5 scale)))))

(defun draw-flight-rectangle (left top right bottom z color)
  (multiple-value-bind (x1 y1)
      (flight-project left top z)
    (multiple-value-bind (x2 y2)
        (flight-project right top z)
      (multiple-value-bind (x3 y3)
          (flight-project right bottom z)
        (multiple-value-bind (x4 y4)
            (flight-project left bottom z)
          (draw-line-between x1 y1 x2 y2 color)
          (draw-line-between x2 y2 x3 y3 color)
          (draw-line-between x3 y3 x4 y4 color)
          (draw-line-between x4 y4 x1 y1 color))))))

(defun draw-flight-tunnel-rails (color)
  (dolist (corner '((-1.0 -1.0)
                    (1.0 -1.0)
                    (1.0 1.0)
                    (-1.0 1.0)))
    (multiple-value-bind (near-x near-y)
        (flight-project (first corner) (second corner) 0.65)
      (multiple-value-bind (far-x far-y)
          (flight-project (first corner) (second corner) +flight-visible-depth+)
        (draw-line-between near-x near-y far-x far-y color)))))

(defun draw-flight-tunnel-frames (color)
  (loop for z from 0.7 to +flight-visible-depth+ by 0.7
        do (draw-flight-rectangle -1.0 -1.0 1.0 1.0 z color))
  (draw-flight-tunnel-rails color))

(defun draw-flight-gate (game gate-index color)
  (let ((z (- gate-index (flight-minigame-distance game))))
    (when (and (> z 0.25)
               (< z +flight-visible-depth+))
      (multiple-value-bind (gate-x gate-y)
          (flight-gate-center gate-index)
        (let ((half-size (flight-opening-half-size gate-index)))
          (draw-flight-rectangle (- gate-x half-size)
                                 (- gate-y half-size)
                                 (+ gate-x half-size)
                                 (+ gate-y half-size)
                                 z
                                 color)
          (draw-flight-rectangle -1.0 -1.0 1.0 1.0 z color))))))

(defun draw-flight-gates (game color)
  (let ((first-gate (max 1 (floor (flight-minigame-distance game)))))
    (loop for gate from first-gate below (+ first-gate 9)
          do (draw-flight-gate game gate color))))

(defun draw-flight-player (game color)
  (let* ((x (+ +flight-center-x+
              (* (flight-minigame-player-x game)
                 +flight-view-width+
                 0.32)))
         (y (+ +flight-center-y+
              (* (flight-minigame-player-y game)
                 +flight-view-height+
                 0.32)))
         (size 18.0))
    (draw-triangle-points x (- y size)
                          (- x size) (+ y size)
                          (+ x size) (+ y size)
                          color)
    (draw-line-between (- x 28) y (+ x 28) y color)
    (draw-line-between x (- y 28) x (+ y 28) color)))

(defun draw-flight-hud (game color)
  (let ((distance-label (format nil "~2,'0d/~2,'0d"
                                (min (floor (flight-minigame-distance game))
                                     (round +flight-success-distance+))
                                (round +flight-success-distance+))))
    (draw-centered-text distance-label
                        +virtual-center-x+
                        (- +virtual-height+ 72)
                        18
                        color)))

(defun draw-flight-minigame (node color)
  (let ((game (ensure-flight-minigame node)))
    (draw-flight-tunnel-frames (make-color 255 255 255 110))
    (draw-flight-gates game color)
    (draw-flight-player game color)
    (draw-flight-hud game color)))

(defun draw-minigame-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node 96 color)
    (when (story-text-visible-p node)
      (draw-flight-minigame node (make-color 255 255 255 230)))))
