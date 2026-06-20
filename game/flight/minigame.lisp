(in-package #:immortal-coil)

(defconstant +flight-center-x+ +virtual-center-x+)
(defconstant +flight-center-y+ 420.0)
(defconstant +flight-view-width+ 760.0)
(defconstant +flight-view-height+ 390.0)
(defconstant +flight-visible-depth+ 8.0)
(defconstant +flight-success-distance+ 28.0)
(defconstant +flight-safe-gate-count+ 3)
(defconstant +flight-cockpit-scale+ 0.32)
(defconstant +flight-commit-z+ 0.2)

(defvar *flight-minigame* nil)

;;; Projection. The ship reticle and the gates share these, so the gate
;;; collision below can be done in screen space: what you see lined up is
;;; what you fly through.
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

(defstruct flight-minigame
  (node-id    *runtime-fallback-node-id* :type dialog-id)
  (elapsed    0.0 :type seconds)
  (distance   0.0 :type scalar)
  (player-x   0.0 :type scalar)
  (player-y   0.0 :type scalar)
  (velocity-x 0.0 :type scalar)
  (velocity-y 0.0 :type scalar)
  (ship-aim-x 0.0 :type scalar)
  (ship-aim-y 0.0 :type scalar)
  (last-gate  0 :type flight-gate-index))

(-> clamp-value (scalar scalar scalar) scalar)
(defun clamp-value (value min max)
  (min max (max min value)))

(-> make-fresh-flight-minigame (node) flight-minigame)
(defun make-fresh-flight-minigame (node)
  (make-flight-minigame :node-id (node-id node)
                        :elapsed 0.0
                        :distance 0.0
                        :player-x 0.0
                        :player-y 0.0
                        :velocity-x 0.0
                        :velocity-y 0.0
                        :ship-aim-x 0.0
                        :ship-aim-y 0.0
                        :last-gate 0))

(-> ensure-flight-minigame (node) flight-minigame)
(defun ensure-flight-minigame (node)
  (unless (and *flight-minigame*
               (equal (flight-minigame-node-id *flight-minigame*)
                      (node-id node)))
    (setf *flight-minigame* (make-fresh-flight-minigame node)))
  *flight-minigame*)

(-> flight-axis (t t) scalar)
(defun flight-axis (negative-key positive-key)
  (- (if (is-key-down-p positive-key) 1.0 0.0)
     (if (is-key-down-p negative-key) 1.0 0.0)))

(-> flight-input-x () scalar)
(defun flight-input-x ()
  (+ (flight-axis +key-left+ +key-right+)
     (flight-axis +key-a+ +key-d+)))

(-> flight-input-y () scalar)
(defun flight-input-y ()
  (+ (flight-axis +key-up+ +key-down+)
     (flight-axis +key-w+ +key-s+)))

(-> flight-speed (flight-minigame) scalar)
(defun flight-speed (game)
  (+ 0.76 (* 0.038 (flight-minigame-elapsed game))))

(-> flight-opening-half-size (flight-gate-index) scalar)
(defun flight-opening-half-size (gate-index)
  (max 0.31 (- 0.55 (* gate-index 0.008))))

(-> flight-gate-drift-scale (flight-gate-index) scalar)
(defun flight-gate-drift-scale (gate-index)
  (smoothstep (/ (max 0 (- gate-index +flight-safe-gate-count+))
                 7.0)))

(-> flight-gate-center (flight-gate-index) (values scalar scalar))
(defun flight-gate-center (gate-index)
  (let ((drift (flight-gate-drift-scale gate-index)))
    (values (* drift
               (+ (* 0.36 (sin (+ 0.7 (* gate-index 0.82))))
                  (* 0.14 (sin (* gate-index 1.71)))))
            (* drift
               (+ (* 0.30 (cos (+ 0.4 (* gate-index 0.73))))
                  (* 0.12 (sin (* gate-index 1.17))))))))

(-> flight-player-in-gate-p (flight-minigame flight-gate-index) boolean)
(defun flight-player-in-gate-p (game gate-index)
  ;; Screen-space test at the commit plane: the ship clears the gate when
  ;; its drawn reticle sits inside the gate opening as it is drawn at the
  ;; moment of crossing. the ship is a point; its hull may overhang.
  (multiple-value-bind (gate-x gate-y)
      (flight-gate-center gate-index)
    (let ((half-size (flight-opening-half-size gate-index)))
      (multiple-value-bind (ship-x ship-y)
          (flight-cockpit-position (flight-minigame-player-x game)
                                   (flight-minigame-player-y game))
        (multiple-value-bind (left top)
            (flight-project (- gate-x half-size)
                            (- gate-y half-size)
                            +flight-commit-z+)
          (multiple-value-bind (right bottom)
              (flight-project (+ gate-x half-size)
                              (+ gate-y half-size)
                              +flight-commit-z+)
            (and (<= left ship-x right)
                 (<= top ship-y bottom))))))))

(-> record-flight-crash () t)
(defun record-flight-crash ()
  (setf (dialog-value "ship-crashed") t))

(-> finish-flight-minigame ((option dialog-target)) t)
(defun finish-flight-minigame (target)
  (setf *flight-minigame* nil)
  (jump-to-dialog-target target))

(-> fail-flight-minigame (node) t)
(defun fail-flight-minigame (node)
  (record-flight-crash)
  (finish-flight-minigame (node-failure-target node)))

(-> succeed-flight-minigame (node) t)
(defun succeed-flight-minigame (node)
  (setf (dialog-value "ship-survived") t)
  (finish-flight-minigame (node-success-target node)))

(-> update-flight-physics (flight-minigame seconds) t)
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

(-> flight-ship-target-aim (flight-minigame) (values scalar scalar))
(defun flight-ship-target-aim (game)
  (let* ((input-x (clamp-value (flight-input-x) -1.0 1.0))
         (input-y (clamp-value (flight-input-y) -1.0 1.0))
         (velocity-x (clamp-value (* (flight-minigame-velocity-x game) 0.34)
                                  -0.55
                                  0.55))
         (velocity-y (clamp-value (* (flight-minigame-velocity-y game) 0.34)
                                  -0.55
                                  0.55)))
    (values (clamp-value (+ (* input-x 0.68) velocity-x)
                         -1.0
                         1.0)
            (clamp-value (+ (* input-y 0.68) velocity-y)
                         -1.0
                         1.0))))

(-> flight-aim-smoothing-factor (seconds) scalar)
(defun flight-aim-smoothing-factor (dt)
  (clamp01 (- 1.0 (exp (* -5.6 dt)))))

(-> smooth-flight-aim (scalar scalar seconds) scalar)
(defun smooth-flight-aim (current target dt)
  (+ current
     (* (- target current)
        (flight-aim-smoothing-factor dt))))

(-> update-flight-ship-aim (flight-minigame seconds) t)
(defun update-flight-ship-aim (game dt)
  (multiple-value-bind (target-x target-y)
      (flight-ship-target-aim game)
    (setf (flight-minigame-ship-aim-x game)
          (smooth-flight-aim (flight-minigame-ship-aim-x game)
                             target-x
                             dt)
          (flight-minigame-ship-aim-y game)
          (smooth-flight-aim (flight-minigame-ship-aim-y game)
                             target-y
                             dt))))

(-> check-flight-gates (node flight-minigame) t)
(defun check-flight-gates (node game)
  (let ((current-gate (floor (+ (flight-minigame-distance game)
                                +flight-commit-z+))))
    (loop for gate from (1+ (flight-minigame-last-gate game)) to current-gate
          unless (or (<= gate +flight-safe-gate-count+)
                     (flight-player-in-gate-p game gate))
            do (fail-flight-minigame node)
               (return-from check-flight-gates nil)
          finally (setf (flight-minigame-last-gate game)
                        current-gate)))
  (when (>= (flight-minigame-distance game) +flight-success-distance+)
    (succeed-flight-minigame node)))

(-> update-flight-minigame-node (node seconds) t)
(defun update-flight-minigame-node (node dt)
  (let ((game (ensure-flight-minigame node)))
    (incf (flight-minigame-elapsed game) dt)
    (incf (flight-minigame-distance game)
          (* (flight-speed game) dt))
    (update-flight-physics game dt)
    (update-flight-ship-aim game dt)
    (check-flight-gates node game)))
