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
