(in-package #:immortal-coil)

(defconstant +dream-maze-width+ 15)
(defconstant +dream-maze-height+ 9)
(defconstant +dream-maze-player-radius+ 0.18)
(defconstant +dream-maze-move-speed+ 2.0)
(defconstant +dream-maze-turn-speed+ 2.2)
(defconstant +dream-maze-max-depth+ 16.0)
(defconstant +dream-maze-max-steps+ 48)

(defparameter *dream-maze-map*
  #("###############"
    "#     #   # B #"
    "# ### # # # # #"
    "# #   # #   # #"
    "# # ### ##### #"
    "# #           #"
    "# ### ##### # #"
    "#A        # C #"
    "###############"))

(defvar *dream-maze-minigame* nil)

(defstruct dream-maze-minigame
  (node-id       *runtime-fallback-node-id* :type dialog-id)
  (x             1.5 :type scalar)
  (y             1.5 :type scalar)
  (angle         0.0 :type scalar)
  (elapsed       0.0 :type seconds)
  (step-distance 0.0 :type scalar))

(defstruct dream-maze-ray-hit
  (distance   +dream-maze-max-depth+ :type scalar)
  (cell       #\# :type character)
  (vertical-p nil :type boolean))

(-> dream-maze-clamp-value (scalar scalar scalar) scalar)
(defun dream-maze-clamp-value (value min max)
  (min max (max min value)))

(-> make-fresh-dream-maze-minigame (node) dream-maze-minigame)
(defun make-fresh-dream-maze-minigame (node)
  (make-dream-maze-minigame :node-id (node-id node)
                            :x 1.5
                            :y 1.5
                            :angle 0.0
                            :elapsed 0.0
                            :step-distance 0.0))

(-> ensure-dream-maze-minigame (node) dream-maze-minigame)
(defun ensure-dream-maze-minigame (node)
  (unless (and *dream-maze-minigame*
               (equal (dream-maze-minigame-node-id *dream-maze-minigame*)
                      (node-id node)))
    (setf *dream-maze-minigame*
          (make-fresh-dream-maze-minigame node)))
  *dream-maze-minigame*)

(-> dream-maze-cell (integer integer) character)
(defun dream-maze-cell (cell-x cell-y)
  (if (and (<= 0 cell-x)
           (< cell-x +dream-maze-width+)
           (<= 0 cell-y)
           (< cell-y +dream-maze-height+))
      (char (aref *dream-maze-map* cell-y) cell-x)
      #\#))

(-> dream-maze-exit-cell-p (character) boolean)
(defun dream-maze-exit-cell-p (cell)
  (not (null (member cell '(#\A #\B #\C) :test #'char=))))

(-> dream-maze-exit-cells () list)
(defun dream-maze-exit-cells ()
  (loop for y from 0 below +dream-maze-height+
        append
        (loop for x from 0 below +dream-maze-width+
              for cell = (dream-maze-cell x y)
              when (dream-maze-exit-cell-p cell)
                collect (list x y cell))))

(-> dream-maze-solid-cell-p (character) boolean)
(defun dream-maze-solid-cell-p (cell)
  (or (char= cell #\#)
      (dream-maze-exit-cell-p cell)))

(-> dream-maze-passable-cell-p (character) boolean)
(defun dream-maze-passable-cell-p (cell)
  (not (char= cell #\#)))

(-> dream-maze-position-passable-p (scalar scalar) boolean)
(defun dream-maze-position-passable-p (x y)
  (loop for offset-x in (list (- +dream-maze-player-radius+)
                             +dream-maze-player-radius+)
        always
        (loop for offset-y in (list (- +dream-maze-player-radius+)
                                    +dream-maze-player-radius+)
              always
              (dream-maze-passable-cell-p
               (dream-maze-cell (floor (+ x offset-x))
                                (floor (+ y offset-y)))))))

(-> dream-maze-axis (t t) scalar)
(defun dream-maze-axis (negative-key positive-key)
  (- (if (is-key-down-p positive-key) 1.0 0.0)
     (if (is-key-down-p negative-key) 1.0 0.0)))

(-> dream-maze-forward-input () scalar)
(defun dream-maze-forward-input ()
  (+ (dream-maze-axis +key-down+ +key-up+)
     (dream-maze-axis +key-s+ +key-w+)))

(-> dream-maze-turn-input () scalar)
(defun dream-maze-turn-input ()
  (+ (dream-maze-axis +key-left+ +key-right+)
     (dream-maze-axis +key-a+ +key-d+)))

(-> move-dream-maze-player (dream-maze-minigame scalar scalar) scalar)
(defun move-dream-maze-player (game dx dy)
  (let ((old-x (dream-maze-minigame-x game))
        (old-y (dream-maze-minigame-y game)))
    (let ((next-x (+ old-x dx))
          (next-y (+ old-y dy)))
      (when (dream-maze-position-passable-p next-x
                                            (dream-maze-minigame-y game))
        (setf (dream-maze-minigame-x game) next-x))
      (when (dream-maze-position-passable-p (dream-maze-minigame-x game)
                                            next-y)
        (setf (dream-maze-minigame-y game) next-y)))
    (sqrt (+ (expt (- (dream-maze-minigame-x game) old-x) 2)
             (expt (- (dream-maze-minigame-y game) old-y) 2)))))

(-> update-dream-maze-motion (dream-maze-minigame seconds) scalar)
(defun update-dream-maze-motion (game dt)
  (let ((turn (dream-maze-clamp-value (dream-maze-turn-input) -1.0 1.0))
        (move (dream-maze-clamp-value (dream-maze-forward-input) -1.0 1.0)))
    (incf (dream-maze-minigame-angle game)
          (* turn +dream-maze-turn-speed+ dt))
    (if (zerop move)
        0.0
        (let ((dx (* (cos (dream-maze-minigame-angle game))
                     move
                     +dream-maze-move-speed+
                     dt))
              (dy (* (sin (dream-maze-minigame-angle game))
                     move
                     +dream-maze-move-speed+
                     dt)))
          (move-dream-maze-player game dx dy)))))

(-> maybe-call-dream-maze-audio (symbol &rest t) t)
(defun maybe-call-dream-maze-audio (function-name &rest arguments)
  (when (fboundp function-name)
    (handler-case
        (apply (symbol-function function-name) arguments)
      (error (condition)
        (runtime-warn "Dream maze audio function failed: ~a (~a)"
                      function-name
                      condition)))))

(-> stop-dream-maze-audio () t)
(defun stop-dream-maze-audio ()
  (maybe-call-dream-maze-audio 'stop-dream-maze-static))

(-> update-dream-maze-audio (dream-maze-minigame scalar) t)
(defun update-dream-maze-audio (game moved-distance)
  (maybe-call-dream-maze-audio 'update-dream-maze-static game)
  (maybe-call-dream-maze-audio 'update-dream-maze-footsteps
                               game
                               moved-distance))

(-> dream-maze-exit-name (character) string)
(defun dream-maze-exit-name (cell)
  (case cell
    (#\A "left")
    (#\B "upper")
    (#\C "right")
    (t "unknown")))

(-> dream-maze-current-cell (dream-maze-minigame) character)
(defun dream-maze-current-cell (game)
  (dream-maze-cell (floor (dream-maze-minigame-x game))
                   (floor (dream-maze-minigame-y game))))

(-> finish-dream-maze-minigame (node dream-maze-minigame character) t)
(defun finish-dream-maze-minigame (node game exit-cell)
  (declare (ignore game))
  (stop-dream-maze-audio)
  (setf (dialog-value "dream-maze-exit")
        (dream-maze-exit-name exit-cell)
        *dream-maze-minigame*
        nil)
  (jump-to-dialog-target (node-success-target node)))

(-> check-dream-maze-exit (node dream-maze-minigame) t)
(defun check-dream-maze-exit (node game)
  (let ((cell (dream-maze-current-cell game)))
    (when (dream-maze-exit-cell-p cell)
      (finish-dream-maze-minigame node game cell))))

(-> dream-maze-inverse-component (scalar) scalar)
(defun dream-maze-inverse-component (value)
  (if (< (abs value) 0.0001)
      100000.0
      (abs (/ 1.0 value))))

(-> dream-maze-initial-side-distance (scalar integer integer scalar) scalar)
(defun dream-maze-initial-side-distance (position cell step delta)
  (if (minusp step)
      (* (- position cell) delta)
      (* (- (1+ cell) position) delta)))

(-> dream-maze-cast-ray (dream-maze-minigame scalar) dream-maze-ray-hit)
(defun dream-maze-cast-ray (game angle)
  (let* ((ray-x (cos angle))
         (ray-y (sin angle))
         (map-x (floor (dream-maze-minigame-x game)))
         (map-y (floor (dream-maze-minigame-y game)))
         (step-x (if (minusp ray-x) -1 1))
         (step-y (if (minusp ray-y) -1 1))
         (delta-x (dream-maze-inverse-component ray-x))
         (delta-y (dream-maze-inverse-component ray-y))
         (side-x (dream-maze-initial-side-distance
                  (dream-maze-minigame-x game)
                  map-x
                  step-x
                  delta-x))
         (side-y (dream-maze-initial-side-distance
                  (dream-maze-minigame-y game)
                  map-y
                  step-y
                  delta-y)))
    (loop for step from 0 below +dream-maze-max-steps+
          for vertical-p = (< side-x side-y)
          for distance = (if vertical-p side-x side-y)
          do (if vertical-p
                 (progn
                   (incf map-x step-x)
                   (incf side-x delta-x))
                 (progn
                   (incf map-y step-y)
                   (incf side-y delta-y)))
             (let ((cell (dream-maze-cell map-x map-y)))
               (when (dream-maze-solid-cell-p cell)
                 (return
                   (make-dream-maze-ray-hit
                    :distance (max 0.05 distance)
                    :cell cell
                    :vertical-p vertical-p))))
          finally
             (return
               (make-dream-maze-ray-hit
                :distance +dream-maze-max-depth+
                :cell #\#
                :vertical-p nil)))))

(-> update-dream-maze-minigame-node (node seconds) t)
(defun update-dream-maze-minigame-node (node dt)
  (let ((game (ensure-dream-maze-minigame node)))
    (incf (dream-maze-minigame-elapsed game) dt)
    (update-dream-maze-audio game
                             (update-dream-maze-motion game dt))
    (check-dream-maze-exit node game)))
