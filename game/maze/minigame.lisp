(in-package #:immortal-coil)

(defconstant +dream-maze-base-width+ 9)
(defconstant +dream-maze-base-height+ 5)
(defconstant +dream-maze-player-radius+ 0.18)
(defconstant +dream-maze-move-speed+ 2.0)
(defconstant +dream-maze-turn-speed+ 2.2)
(defconstant +dream-maze-max-depth+ 26.0)
(defconstant +dream-maze-max-steps+ 80)
(defconstant +dream-maze-exit-glyph+ #\$)
(defconstant +dream-maze-braid-chance+ 4)  ; in 10: how often a dead end opens

;;; Doors carry an abstract sign and a target node, both from the dialog
;;; config (:doors), so a mod can add as many doors as it likes and draw
;;; whatever sign it wants. The maze grows with the door count and a
;;; config :size multiplier. *dream-maze-exits* records where each door
;;; landed; the grid marks those cells with +dream-maze-exit-glyph+.
(defstruct dream-maze-exit
  (x      1 :type fixnum)
  (y      1 :type fixnum)
  (sign   "?" :type string)
  (target nil))

(defvar *dream-maze-exits* nil)

;;; Fallback grid (with two marked doors) until the first generation runs.
(defvar *dream-maze-map*
  #("#######"
    "#  $  #"
    "# ### #"
    "#  $  #"
    "#######"))

(defun dream-maze-grid-height ()
  (length *dream-maze-map*))

(defun dream-maze-grid-width ()
  (if (plusp (length *dream-maze-map*))
      (length (aref *dream-maze-map* 0))
      0))

(-> dream-maze-shuffle (list) list)
(defun dream-maze-shuffle (items)
  (let ((vec (coerce items 'vector)))
    (loop for i from (1- (length vec)) downto 1
          for j = (get-random-value 0 i)
          do (rotatef (aref vec i) (aref vec j)))
    (coerce vec 'list)))

(defun dream-maze-make-odd (n)
  (let ((v (max 5 (round n))))
    (if (oddp v) v (1+ v))))

(defun dream-maze-dimensions (door-count size-mult)
  "Maze size grows with the door count and the config size multiplier."
  (let ((m (max 0.5 (if (realp size-mult) size-mult 1.0)))
        (n (max 1 door-count)))
    (values (dream-maze-make-odd (* (+ +dream-maze-base-width+ (* 2 n)) m))
            (dream-maze-make-odd (* (+ +dream-maze-base-height+ (* 2 n)) m)))))

(defun dream-maze-cell-passages (grid x y w h)
  "How many of the four neighbour cells X,Y already connects to."
  (loop for step in '((2 . 0) (-2 . 0) (0 . 2) (0 . -2))
        count (let ((nx (+ x (car step)))
                    (ny (+ y (cdr step)))
                    (wx (+ x (truncate (car step) 2)))
                    (wy (+ y (truncate (cdr step) 2))))
                (and (< 0 nx (1- w)) (< 0 ny (1- h))
                     (char/= (aref grid wy wx) #\#)))))

(defun dream-maze-cell-distances (grid w h)
  "BFS cell distances from the (1,1) spawn over open passages."
  (let ((dist (make-hash-table :test #'equal))
        (queue (list (cons 1 1))))
    (setf (gethash (cons 1 1) dist) 0)
    (loop while queue
          for cell = (pop queue)
          for cx = (car cell)
          for cy = (cdr cell)
          do (dolist (step '((2 . 0) (-2 . 0) (0 . 2) (0 . -2)))
               (let ((nx (+ cx (car step)))
                     (ny (+ cy (cdr step)))
                     (wx (+ cx (truncate (car step) 2)))
                     (wy (+ cy (truncate (cdr step) 2))))
                 (when (and (< 0 nx (1- w)) (< 0 ny (1- h))
                            (char/= (aref grid wy wx) #\#)
                            (not (gethash (cons nx ny) dist)))
                   (setf (gethash (cons nx ny) dist)
                         (1+ (gethash cell dist)))
                   (setf queue (nconc queue (list (cons nx ny))))))))
    dist))

(defun dream-maze-pick-door-cells (dist door-count)
  "Pick DOOR-COUNT distinct cells, spread out and far from the spawn:
the farthest first, then each one maximising distance to those chosen."
  (let ((cells (loop for k being the hash-keys of dist
                     unless (equal k (cons 1 1)) collect k))
        (chosen nil))
    (when cells
      (push (reduce (lambda (a b)
                      (if (>= (gethash a dist 0) (gethash b dist 0)) a b))
                    cells)
            chosen)
      (loop while (and (< (length chosen) door-count)
                       (> (length cells) (length chosen)))
            do (let ((best nil) (best-score -1))
                 (dolist (c cells)
                   (unless (member c chosen :test #'equal)
                     (let ((score (loop for p in chosen
                                        minimize (+ (abs (- (car c) (car p)))
                                                    (abs (- (cdr c) (cdr p)))))))
                       (when (> score best-score)
                         (setf best-score score best c)))))
                 (if best (push best chosen) (return)))))
    (nreverse chosen)))

;;; Carve a randomized depth-first maze, braid it (open some dead ends so
;;; it loops and is easy to cross), then drop one door per DOORS entry at a
;;; well-spread reachable cell. Returns (values grid-vector exits-list).
(defun generate-dream-maze-map (doors size-mult)
  (multiple-value-bind (w h) (dream-maze-dimensions (length doors) size-mult)
    (let ((grid (make-array (list h w) :initial-element #\#)))
      (labels ((cell-p (x y)
                 (and (oddp x) (oddp y) (< 0 x (1- w)) (< 0 y (1- h))))
               (carve (x y)
                 (setf (aref grid y x) #\Space)
                 (dolist (step (dream-maze-shuffle
                                '((2 . 0) (-2 . 0) (0 . 2) (0 . -2))))
                   (let ((nx (+ x (car step)))
                         (ny (+ y (cdr step))))
                     (when (and (cell-p nx ny)
                                (char= (aref grid ny nx) #\#))
                       (setf (aref grid (+ y (truncate (cdr step) 2))
                                  (+ x (truncate (car step) 2)))
                             #\Space)
                       (carve nx ny))))))
        (carve 1 1)
        ;; Braid: open about +dream-maze-braid-chance+/10 of the dead ends
        ;; so the maze loops and is crossable instead of one winding thread.
        (loop for y from 1 below (1- h) by 2 do
          (loop for x from 1 below (1- w) by 2 do
            (when (and (= 1 (dream-maze-cell-passages grid x y w h))
                       (< (get-random-value 0 9) +dream-maze-braid-chance+))
              (dolist (step (dream-maze-shuffle
                             '((2 . 0) (-2 . 0) (0 . 2) (0 . -2))))
                (let ((nx (+ x (car step)))
                      (ny (+ y (cdr step)))
                      (wx (+ x (truncate (car step) 2)))
                      (wy (+ y (truncate (cdr step) 2))))
                  (when (and (cell-p nx ny) (char= (aref grid wy wx) #\#))
                    (setf (aref grid wy wx) #\Space)
                    (return))))))))
      (let* ((dist (dream-maze-cell-distances grid w h))
             (cells (dream-maze-pick-door-cells dist (length doors)))
             (exits nil))
        (loop for door in doors
              for cell in cells
              do (setf (aref grid (cdr cell) (car cell)) +dream-maze-exit-glyph+)
                 (push (make-dream-maze-exit :x (car cell)
                                             :y (cdr cell)
                                             :sign (first door)
                                             :target (second door))
                       exits))
        (values (coerce (loop for y below h
                              collect (coerce (loop for x below w
                                                    collect (aref grid y x))
                                              'string))
                        'vector)
                (nreverse exits))))))

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

(defun dream-maze-spawn-angle ()
  "Face an open neighbour of the (1,1) spawn so the player never opens the
maze staring straight into a wall."
  (flet ((open-p (cell-x cell-y)
           (char/= (char (aref *dream-maze-map* cell-y) cell-x) #\#)))
    (cond ((open-p 2 1) 0.0)                 ; east
          ((open-p 1 2) (float (/ pi 2) 1.0)) ; south
          (t 0.0))))

(defun dream-maze-config-doors (node)
  "The doors from the node's :doors config as (sign target) lists. Each
entry may be (sign target) or a bare target; falls back to one door at the
success target so an unconfigured maze still works."
  (let ((doors (minigame-config-value node :doors)))
    (or (and (consp doors)
             (loop for door in doors
                   for sign = (if (consp door) (first door) "?")
                   for target = (if (consp door) (second door) door)
                   collect (list (if (stringp sign) sign (princ-to-string sign))
                                 target)))
        (list (list "?" (node-success-target node))))))

(-> make-fresh-dream-maze-minigame (node) dream-maze-minigame)
(defun make-fresh-dream-maze-minigame (node)
  (multiple-value-bind (grid exits)
      (generate-dream-maze-map (dream-maze-config-doors node)
                               (minigame-config-value node :size 1.0))
    (setf *dream-maze-map* grid
          *dream-maze-exits* exits))
  (make-dream-maze-minigame :node-id (node-id node)
                            :x 1.5
                            :y 1.5
                            :angle (dream-maze-spawn-angle)
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
  (let ((h (dream-maze-grid-height)))
    (if (and (<= 0 cell-y) (< cell-y h))
        (let* ((row (aref *dream-maze-map* cell-y))
               (w (length row)))
          (if (and (<= 0 cell-x) (< cell-x w))
              (char row cell-x)
              #\#))
        #\#)))

(-> dream-maze-exit-cell-p (character) boolean)
(defun dream-maze-exit-cell-p (cell)
  (char= cell +dream-maze-exit-glyph+))

(defun dream-maze-exit-at (cell-x cell-y)
  (find-if (lambda (exit)
             (and (= (dream-maze-exit-x exit) cell-x)
                  (= (dream-maze-exit-y exit) cell-y)))
           *dream-maze-exits*))

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

(-> finish-dream-maze-minigame (node dream-maze-minigame dream-maze-exit) t)
(defun finish-dream-maze-minigame (node game exit)
  (declare (ignore game))
  (stop-dream-maze-audio)
  (setf (dialog-value "dream-maze-exit") (dream-maze-exit-sign exit)
        *dream-maze-minigame* nil)
  (finish-minigame-node node
                        (or (dream-maze-exit-target exit)
                            (node-success-target node))))

(-> check-dream-maze-exit (node dream-maze-minigame) t)
(defun check-dream-maze-exit (node game)
  (let ((exit (dream-maze-exit-at (floor (dream-maze-minigame-x game))
                                  (floor (dream-maze-minigame-y game)))))
    (when exit
      (finish-dream-maze-minigame node game exit))))

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
