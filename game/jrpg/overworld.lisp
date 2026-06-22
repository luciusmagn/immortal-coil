(in-package #:immortal-coil)

(defconstant +jrpg-overworld-tile-size+ 24)
(defconstant +jrpg-overworld-left+ 250)
(defconstant +jrpg-overworld-top+ 160)
(defconstant +jrpg-overworld-view-cols+ 30)
(defconstant +jrpg-overworld-view-rows+ 9)

(defparameter *jrpg-overworld-map*
  #("................"
    "...^^^^.....o..."
    "..^....^.....T.."
    "..^....^........"
    ".V...B....!!...."
    ".....R........$."
    "......~~~......."))

;;; Procedural overworld. A big map with a guaranteed winding road from
;;; the west edge to the finish, the occurrence's landmarks strung along
;;; that road, obstacle clusters and pickups scattered off it. Generated
;;; fresh each time the walk is entered, so the route is never the same.

(defun jrpg-gen-rows (grid)
  (loop for y below (array-dimension grid 0)
        collect (coerce (loop for x below (array-dimension grid 1)
                              collect (aref grid y x))
                        'string)))

(defun jrpg-gen-blob (grid w h cx cy steps glyph avoid)
  "Drunkard's-walk a coherent blob of GLYPH from (CX,CY), never overwriting an
AVOID glyph. Connected and organic, not per-cell noise."
  (let ((x cx) (y cy))
    (dotimes (i steps)
      (unless (member (aref grid y x) avoid :test #'char=)
        (setf (aref grid y x) glyph))
      (ecase (get-random-value 0 3)
        (0 (incf x)) (1 (decf x)) (2 (incf y)) (3 (decf y)))
      (setf x (max 1 (min (- w 2) x))
            y (max 1 (min (- h 2) y))))))

(defun jrpg-gen-ridge (grid w h len avoid)
  "A mountain ridge: a mostly-horizontal wandering line of #\\^, thickened to
three cells, so ranges read as ranges and not scatter."
  (let ((x (get-random-value 1 (- w 2)))
        (y (get-random-value 1 (- h 2)))
        (dir (if (zerop (get-random-value 0 1)) 1 -1)))
    (dotimes (i len)
      (dolist (dd '(-1 0 1))
        (let ((yy (+ y dd)))
          (when (and (< 0 yy (1- h))
                     (not (member (aref grid yy x) avoid :test #'char=)))
            (setf (aref grid yy x) #\^))))
      (if (zerop (get-random-value 0 2))
          (incf y (if (zerop (get-random-value 0 1)) 1 -1))
          (incf x dir))
      (setf x (max 1 (min (- w 2) x))
            y (max 1 (min (- h 2) y))))))

(defun jrpg-gen-overworld (w h finish-glyph waypoints)
  "Returns (values rows start-x start-y). A coherent FF-style overworld: grass
plains, a winding ROAD from the west edge to the finish (always passable),
mountain ridges and forest patches and a lake set OFF the road, the occurrence's
landmarks strung along it. Generated fresh each entry."
  (let* ((grid (make-array (list h w) :initial-element #\.))
         (sx 1) (sy (floor h 2))
         (fx (- w 2)) (fy (floor h 2))
         (road nil) (x sx) (y sy))
    ;; 1. carve a winding road (the guaranteed path), marked #\,
    (setf (aref grid y x) #\,)
    (push (list x y) road)
    (loop repeat (* w h)
          while (or (/= x fx) (/= y fy))
          do (let ((choices nil))
               (cond ((< x fx) (dotimes (k 3) (push (cons 1 0) choices)))
                     ((> x fx) (push (cons -1 0) choices)))
               (cond ((< y fy) (push (cons 0 1) choices))
                     ((> y fy) (push (cons 0 -1) choices)))
               (push (if (zerop (get-random-value 0 1)) (cons 0 1) (cons 0 -1)) choices)
               (let ((step (nth (get-random-value 0 (1- (length choices))) choices)))
                 (setf x (max 1 (min (- w 2) (+ x (car step))))
                       y (max 1 (min (- h 2) (+ y (cdr step)))))
                 (setf (aref grid y x) #\,)
                 (push (list x y) road))))
    (loop while (/= x fx) do (incf x (if (< x fx) 1 -1))
                             (setf (aref grid y x) #\,) (push (list x y) road))
    (loop while (/= y fy) do (incf y (if (< y fy) 1 -1))
                             (setf (aref grid y x) #\,) (push (list x y) road))
    (setf road (nreverse road))
    ;; 2. ranges, forests, a lake - coherent regions, all sparing the road
    (dotimes (i (max 2 (floor w 14)))
      (jrpg-gen-ridge grid w h (floor w 2) '(#\,)))
    (dotimes (i (max 3 (floor (* w h) 90)))
      (jrpg-gen-blob grid w h (get-random-value 2 (- w 3)) (get-random-value 2 (- h 3))
                     (get-random-value 6 16) #\f '(#\, #\^ #\~)))
    (dotimes (i (max 1 (floor w 22)))
      (jrpg-gen-blob grid w h (get-random-value 2 (- w 3)) (get-random-value 2 (- h 3))
                     (get-random-value 10 24) #\~ '(#\, #\^)))
    ;; 3. landmarks (towns) strung along the road
    (let ((n (length road)) (k (length waypoints)))
      (loop for wp in waypoints
            for i from 1
            for idx = (min (1- n) (max 1 (floor (* i n) (1+ k))))
            do (destructuring-bind (wx wy) (nth idx road)
                 (setf (aref grid wy wx) wp))))
    ;; 4. finish, and the start on the road
    (setf (aref grid fy fx) finish-glyph
          (aref grid sy sx) #\,)
    ;; 5. a few pickups on open grass beside the road
    (let ((placed 0))
      (dolist (cell road)
        (when (< placed 5)
          (destructuring-bind (rx ry) cell
            (let ((ox (max 1 (min (- w 2) (+ rx (get-random-value -2 2)))))
                  (oy (max 1 (min (- h 2) (+ ry (get-random-value -1 1))))))
              (when (and (char= (aref grid oy ox) #\.)
                         (zerop (get-random-value 0 6)))
                (setf (aref grid oy ox)
                      (if (zerop (get-random-value 0 1)) #\$ #\o))
                (incf placed)))))))
    (values (jrpg-gen-rows grid) sx sy)))

(defvar *jrpg-overworld* nil)

(defstruct jrpg-overworld
  (node-id          *runtime-fallback-node-id*)
  (map              *jrpg-overworld-map*)
  (finish-glyphs    '(#\!))
  (tile-messages    nil)
  (legend           "V village  = bridge  + sign  T tower  $ Hours  o tonic")
  (store-prefix     "jrpg-overworld")
  (x                1)
  (y                4)
  ;; random encounters: each step past the cooldown rolls 1-in-rate to drop
  ;; the walker into a battle. the battle returns to this same node and the
  ;; walk resumes where it left off (the session is not cleared on encounter).
  (encounter-target nil)
  (encounter-rate   0)
  (encounter-cool   6)
  (message          "arrows or wasd move.")
  ;; :city is an orthogonal street grid whose lettered doors each lead to their
  ;; own target (the DOORS alist); :road is the winding inter-place road.
  (mode             :road)
  (doors            nil)
  (door-names       nil)
  ;; facing (for the figure) and a short breadcrumb trail of recent cells
  (facing           1)
  (visited          nil)
  ;; the read-only stat card, toggled with C (pauses movement while up)
  (show-card        nil))

(defun jrpg-overworld-width (game)
  (length (aref (jrpg-overworld-map game) 0)))

(defun jrpg-overworld-height (game)
  (length (jrpg-overworld-map game)))

(defun jrpg-overworld-normalize-map (map)
  (cond
    ((null map)
     *jrpg-overworld-map*)
    ((vectorp map)
     map)
    ((listp map)
     (coerce map 'vector))
    (t
     (runtime-warn "JRPG overworld map config is not a list or vector: ~s"
                   map)
     *jrpg-overworld-map*)))

(defun jrpg-overworld-normalize-finish-glyphs (glyphs)
  (cond
    ((null glyphs)
     '(#\!))
    ((characterp glyphs)
     (list glyphs))
    ((stringp glyphs)
     (loop for glyph across glyphs collect glyph))
    ((listp glyphs)
     glyphs)
    (t
     (runtime-warn "JRPG overworld finish glyph config is invalid: ~s"
                   glyphs)
     '(#\!))))

(defun jrpg-overworld-start-coordinates (node)
  (let ((start (minigame-config-value node :start '(1 4))))
    (if (and (listp start)
             (integerp (first start))
             (integerp (second start)))
        (values (first start) (second start))
        (progn
          (runtime-warn "JRPG overworld start config is invalid: ~s"
                        start)
          (values 1 4)))))

(defun jrpg-overworld-config-int (node key default)
  (let ((value (minigame-config-value node key default)))
    (if (integerp value) value default)))

(defun make-fresh-jrpg-overworld (node)
  (jrpg-init-state)
  (let ((gen-width (minigame-config-value node :gen-width)))
    (if (and (integerp gen-width) (> gen-width 12))
        (let* ((gen-height (jrpg-overworld-config-int node :gen-height 18))
               (finish (let ((value (minigame-config-value node
                                                           :finish-glyph #\!)))
                         (if (characterp value) value #\!)))
               (waypoints (let ((value (minigame-config-value node :waypoints
                                                              '(#\R))))
                            (if (listp value) value '(#\R)))))
          (multiple-value-bind (rows start-x start-y)
              (jrpg-gen-overworld gen-width gen-height finish waypoints)
            (make-jrpg-overworld
             :node-id (node-id node)
             :map (coerce rows 'vector)
             :finish-glyphs (list finish)
             :tile-messages (minigame-config-value node :tile-messages)
             :legend (minigame-config-value
                      node :legend
                      "= bridge  + sign  T tower  $ Hours  o tonic  ^~ block")
             :store-prefix (minigame-config-value node :store-prefix
                                                  "jrpg-overworld")
             :x start-x
             :y start-y
             :encounter-target (minigame-config-value node :encounter-target)
             :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
             :message (minigame-config-value
                       node :start-message
                       "the way opens out. arrows or wasd move."))))
        (multiple-value-bind (start-x start-y)
            (jrpg-overworld-start-coordinates node)
          (make-jrpg-overworld
           :node-id (node-id node)
           :map (jrpg-overworld-normalize-map
                 (minigame-config-value node :map))
           :finish-glyphs (jrpg-overworld-normalize-finish-glyphs
                           (minigame-config-value node :finish-glyphs))
           :tile-messages (minigame-config-value node :tile-messages)
           :legend (minigame-config-value
                    node :legend
                    "V village  = bridge  + sign  T tower  $ Hours  o tonic")
           :store-prefix (minigame-config-value node :store-prefix
                                                "jrpg-overworld")
           :x start-x
           :y start-y
           :encounter-target (minigame-config-value node :encounter-target)
           :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
           :message (minigame-config-value
                     node :start-message
                     "arrows or wasd move."))))))

(defun ensure-jrpg-overworld-session (node builder)
  "Build the walk with BUILDER on first entry to a node and keep it until the
node changes, so a returning walk resumes (encounters do not reset it)."
  (unless (and *jrpg-overworld*
               (equal (jrpg-overworld-node-id *jrpg-overworld*)
                      (node-id node)))
    (setf *jrpg-overworld* (funcall builder node)))
  *jrpg-overworld*)

(defun ensure-jrpg-overworld (node)
  (ensure-jrpg-overworld-session node #'make-fresh-jrpg-overworld))

(defun jrpg-overworld-cell (game x y)
  (if (and (<= 0 x)
           (< x (jrpg-overworld-width game))
           (<= 0 y)
           (< y (jrpg-overworld-height game)))
      (char (aref (jrpg-overworld-map game) y) x)
      #\^))

(defun jrpg-overworld-passable-p (cell)
  (not (member cell '(#\^ #\~ #\#) :test #'char=)))

(defun jrpg-overworld-input-direction ()
  (cond
    ((or (is-key-pressed-p +key-left+)
         (is-key-pressed-p +key-a+))
     '(-1 0))
    ((or (is-key-pressed-p +key-right+)
         (is-key-pressed-p +key-d+))
     '(1 0))
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-w+))
     '(0 -1))
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-s+))
     '(0 1))))

(defun jrpg-overworld-default-tile-message (cell)
  (case cell
    (#\V "the village gate is already behind you.")
    (#\B "the bridge guard raises the gate chain.")
    (#\R "the road sign says NORTH TOWER.")
    (#\T "the tower is still too far to touch.")
    (#\S "the roadside shrine is white stone and old pine.")
    (#\! "the grass shakes.")
    (#\$ "loose Hours dropped in the grass.")
    (#\o "a small corked bottle waits on a flat stone.")
    (#\~ "the water lies still and the colour of slate.")
    (#\, "the road runs on, pale through the grass.")
    (#\f "trees crowd close to the road.")
    (t "open grass, and your own long shadow.")))

(defun jrpg-overworld-tile-message (game cell)
  (or (rest (assoc cell
                   (jrpg-overworld-tile-messages game)
                   :test #'char=))
      (jrpg-overworld-default-tile-message cell)))

(defun jrpg-overworld-store-key (game suffix)
  (format nil "~a-~a" (jrpg-overworld-store-prefix game) suffix))

(defun jrpg-overworld-collected (game)
  (jrpg-value (jrpg-overworld-store-key game "collected") nil))

(defun jrpg-overworld-collected-p (game x y)
  (member (list x y) (jrpg-overworld-collected game) :test #'equal))

(defun jrpg-overworld-mark-collected (game x y)
  (setf (jrpg-value (jrpg-overworld-store-key game "collected"))
        (cons (list x y) (jrpg-overworld-collected game))))

(defun jrpg-overworld-effective-cell (game x y)
  "A picked-up gold or potion tile reads as plain road afterward."
  (let ((cell (jrpg-overworld-cell game x y)))
    (if (and (member cell '(#\$ #\o) :test #'char=)
             (jrpg-overworld-collected-p game x y))
        #\.
        cell)))

(defun jrpg-overworld-tile-effects (game x y cell)
  "Sounds and pickups for the tile just entered; pickups override the
message and are taken only once."
  (case cell
    (#\$ (unless (jrpg-overworld-collected-p game x y)
           (let ((found (get-random-value 3 6)))
             (jrpg-adjust-number "jrpg-hours" found)
             (jrpg-overworld-mark-collected game x y)
             (play-jrpg-sound "coin" :volume 0.40)
             (setf (jrpg-overworld-message game)
                   (format nil "loose Hours in the grass. +~d." found)))))
    (#\o (unless (jrpg-overworld-collected-p game x y)
           (jrpg-adjust-number "jrpg-potions" 1)
           (jrpg-overworld-mark-collected game x y)
           (play-jrpg-sound "tonic" :volume 0.40)
           (setf (jrpg-overworld-message game)
                 "a corked tonic, left for travelers. you take it.")))
    (#\B (play-jrpg-sound "gate-chain" :volume 0.42))
    (#\R (play-jrpg-sound "ledger" :volume 0.30))
    (#\T (play-jrpg-sound "bell" :volume 0.30))
    (#\S (play-jrpg-sound "bell" :volume 0.24))))

(defun jrpg-record-overworld-cell (game cell)
  (declare (ignore game))
  (case cell
    (#\B (setf (jrpg-value "jrpg-crossed-bridge") t
               (jrpg-value "jrpg-route") "bridge road"))
    (#\R (setf (jrpg-value "jrpg-read-road-sign") t
               (jrpg-value "jrpg-route") "north road"))
    (#\T (setf (jrpg-value "jrpg-saw-tower") t))
    (#\S (setf (jrpg-value "jrpg-road-shrine-seen") t))
    (#\! (setf (jrpg-value "jrpg-last-terrain") "grass"))))

(defun jrpg-overworld-finish-cell-p (game cell)
  (not (null (member cell
                     (jrpg-overworld-finish-glyphs game)
                     :test #'char=))))

(defun jrpg-overworld-finish (node game cell)
  "Leave the walk. In a city, the lettered door CELL goes to its own target;
on a road the single finish glyph goes to the node's success target."
  (let ((target (or (and (eq (jrpg-overworld-mode game) :city)
                         (cdr (assoc cell (jrpg-overworld-doors game)
                                     :test #'char=)))
                    (node-success-target node))))
    (setf *jrpg-overworld* nil)
    (jump-to-dialog-target target)))

(defun jrpg-overworld-maybe-encounter (node game)
  "After a step, roll for a random encounter. On a hit, drop into the
configured battle WITHOUT clearing the session, so the walk resumes at this
spot when the battle returns to this node. A short cooldown keeps the first
steps and the steps just after a fight safe."
  (declare (ignore node))
  (let ((target (jrpg-overworld-encounter-target game))
        (rate   (jrpg-overworld-encounter-rate game)))
    (when (and target (plusp rate))
      (if (plusp (jrpg-overworld-encounter-cool game))
          (decf (jrpg-overworld-encounter-cool game))
          (when (zerop (get-random-value 0 (1- rate)))
            (setf (jrpg-overworld-encounter-cool game) 6)
            (jump-to-dialog-target target))))))

(defun jrpg-overworld-remember-visited (game x y)
  "Keep a short breadcrumb trail of recently-stepped cells, newest first."
  (let ((cell (list x y)))
    (unless (equal cell (first (jrpg-overworld-visited game)))
      (push cell (jrpg-overworld-visited game))
      (when (> (length (jrpg-overworld-visited game)) 48)
        (setf (jrpg-overworld-visited game)
              (subseq (jrpg-overworld-visited game) 0 48))))))

(defun jrpg-overworld-move (node game dx dy)
  (let* ((next-x (+ (jrpg-overworld-x game) dx))
         (next-y (+ (jrpg-overworld-y game) dy))
         (cell (jrpg-overworld-cell game next-x next-y)))
    (unless (zerop dx)
      (setf (jrpg-overworld-facing game) (if (plusp dx) 1 -1)))
    (if (jrpg-overworld-passable-p cell)
        (progn
          (jrpg-overworld-remember-visited game
                                           (jrpg-overworld-x game)
                                           (jrpg-overworld-y game))
          (setf (jrpg-overworld-x game) next-x
                (jrpg-overworld-y game) next-y
                (jrpg-overworld-message game)
                (jrpg-overworld-tile-message
                 game
                 (jrpg-overworld-effective-cell game next-x next-y)))
          (jrpg-record-overworld-cell game cell)
          (jrpg-overworld-tile-effects game next-x next-y cell)
          (cond
            ((jrpg-overworld-finish-cell-p game cell)
             (jrpg-overworld-finish node game cell))
            (t
             (jrpg-overworld-maybe-encounter node game))))
        (setf (jrpg-overworld-message game)
              (if (char= cell #\~)
                  "the water is too deep to wade."
                  "you cannot get through that way.")))))

(defun jrpg-overworld-step (node game)
  "One frame of walking input; shared by the road and the city. C opens the
full character screen and returns here, like the menu key in a JRPG."
  (cond
    ((is-key-pressed-p +key-c+)
     (setf (jrpg-value "jrpg-char-return") (jrpg-overworld-node-id game))
     (jump-to-dialog-target "jrpg/character"))
    (t
     (let ((direction (jrpg-overworld-input-direction)))
       (when direction
         (destructuring-bind (dx dy) direction
           (jrpg-overworld-move node game dx dy)))))))

(defun update-jrpg-overworld-minigame (node dt)
  (declare (ignore dt))
  (jrpg-overworld-step node (ensure-jrpg-overworld node)))

(defun jrpg-overworld-camera (game)
  "Top-left viewport tile, scrolled to keep the player centered and
clamped to the map edges."
  (let ((w (jrpg-overworld-width game))
        (h (jrpg-overworld-height game)))
    (values (max 0 (min (- (jrpg-overworld-x game)
                           (floor +jrpg-overworld-view-cols+ 2))
                        (max 0 (- w +jrpg-overworld-view-cols+))))
            (max 0 (min (- (jrpg-overworld-y game)
                           (floor +jrpg-overworld-view-rows+ 2))
                        (max 0 (- h +jrpg-overworld-view-rows+)))))))

(defun jrpg-overworld-tile-label (cell)
  (case cell
    (#\^ "^")
    (#\V "V")
    (#\B "=")
    (#\R "+")
    (#\T "T")
    (#\S "S")
    (#\! "\"")
    (#\$ "$")
    (#\o "o")
    (#\~ "~")
    (t ".")))

(defun jrpg-ow-fill (x y w h alpha)
  (claylib/ll:draw-rectangle (round x) (round y)
                             (max 1 (round w)) (max 1 (round h))
                             (claylib::c-ptr (make-color 255 255 255 alpha))))

(defun jrpg-overworld-cell-screen (col row)
  "Screen x,y of the top-left of a viewport tile."
  (values (+ +jrpg-overworld-left+ (* col +jrpg-overworld-tile-size+))
          (+ +jrpg-overworld-top+ (* row +jrpg-overworld-tile-size+))))

(defun jrpg-overworld-draw-grid ()
  "Faint guide lines, so the walk reads as a grid and not floating specks."
  (let ((w (* +jrpg-overworld-view-cols+ +jrpg-overworld-tile-size+))
        (h (* +jrpg-overworld-view-rows+ +jrpg-overworld-tile-size+)))
    (loop for c from 0 to +jrpg-overworld-view-cols+
          for x = (+ +jrpg-overworld-left+ (* c +jrpg-overworld-tile-size+))
          do (jrpg-ow-fill x +jrpg-overworld-top+ 1 h 14))
    (loop for r from 0 to +jrpg-overworld-view-rows+
          for y = (+ +jrpg-overworld-top+ (* r +jrpg-overworld-tile-size+))
          do (jrpg-ow-fill +jrpg-overworld-left+ y w 1 14))))

(defun jrpg-overworld-draw-trail (game cam-x cam-y)
  "Faint marks where the traveller has lately stepped."
  (let ((s +jrpg-overworld-tile-size+))
    (dolist (cell (jrpg-overworld-visited game))
      (destructuring-bind (mx my) cell
        (let ((col (- mx cam-x)) (row (- my cam-y)))
          (when (and (<= 0 col) (< col +jrpg-overworld-view-cols+)
                     (<= 0 row) (< row +jrpg-overworld-view-rows+))
            (multiple-value-bind (sx sy) (jrpg-overworld-cell-screen col row)
              (jrpg-ow-fill (+ sx (/ s 2) -1) (+ sy (/ s 2) -1) 3 3 30))))))))

(defun draw-jrpg-overworld-cell (cell screen-x screen-y)
  "Coherent terrain, no grid: plains clean dark, the road a faint worn track,
mountains peaks, forest little trees, water a glinting pool; landmarks bold."
  (let* ((s  +jrpg-overworld-tile-size+)
         (cx (+ screen-x (/ s 2)))
         (cy (+ screen-y (/ s 2))))
    (case cell
      (#\.)                              ; plains: clean
      (#\,                               ; road: a faint worn track
       (jrpg-ow-fill (+ screen-x 4) (+ screen-y 4) (- s 8) (- s 8) 24))
      (#\^                               ; mountain: a peak (narrow up, wide down)
       (loop for r from 0 below 5
             for ww = (max 2 (round (* (- s 6) (/ (+ r 1) 5.0))))
             for rh = (max 1 (round (/ (- s 8) 5.0)))
             do (jrpg-ow-fill (- cx (/ ww 2)) (+ screen-y 4 (* r rh)) ww rh
                              (+ 95 (* r 14)))))
      (#\f                               ; forest: a little tree
       (loop for r from 0 below 3
             for ww = (+ 4 (* r 4))
             do (jrpg-ow-fill (- cx (/ ww 2)) (+ screen-y 4 (* r 4)) ww 4 135))
       (jrpg-ow-fill (- cx 1) (+ cy 4) 2 4 120))   ; trunk
      (#\~                               ; water: a glinting pool
       (jrpg-ow-fill (+ screen-x 2) (+ screen-y 2) (- s 4) (- s 4) 52)
       (jrpg-ow-fill (+ screen-x 4) (- cy 2) (- s 9) 2 110)
       (jrpg-ow-fill (+ screen-x 6) (+ cy 3) (- s 12) 2 90))
      (t                                 ; landmark / pickup / finish
       (draw-centered-text (jrpg-overworld-tile-label cell)
                           cx cy 20 (make-color 255 255 255 235))))))

(defun jrpg-draw-overworld-figure (cx cy &optional (facing 1))
  "The traveller, drawn from rectangles, with a short arm in the heading so
the way they face reads at a glance."
  (flet ((fill-rect (x y w h)
           (claylib/ll:draw-rectangle (round x) (round y)
                                      (max 1 (round w)) (max 1 (round h))
                                      (claylib::c-ptr (make-color 255 255 255 255)))))
    (fill-rect (- cx 3) (- cy 9) 6 5)     ; head
    (fill-rect (- cx 4) (- cy 3) 8 8)     ; body
    (fill-rect (- cx 4) (+ cy 5) 3 4)     ; left leg
    (fill-rect (+ cx 1) (+ cy 5) 3 4)     ; right leg
    (if (plusp facing)
        (fill-rect (+ cx 4) (- cy 2) 3 4)     ; arm, facing right
        (fill-rect (- cx 7) (- cy 2) 3 4))))  ; arm, facing left

(defun draw-jrpg-overworld-map (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (jrpg-overworld-draw-trail game cam-x cam-y)
    (loop for row below +jrpg-overworld-view-rows+
          do (loop for col below +jrpg-overworld-view-cols+
                   for mx = (+ cam-x col)
                   for my = (+ cam-y row)
                   when (and (< mx (jrpg-overworld-width game))
                             (< my (jrpg-overworld-height game)))
                     do (multiple-value-bind (sx sy)
                            (jrpg-overworld-cell-screen col row)
                          (draw-jrpg-overworld-cell
                           (jrpg-overworld-effective-cell game mx my)
                           sx sy))))))

(defun jrpg-overworld-draw-player (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (let ((s +jrpg-overworld-tile-size+))
      (jrpg-draw-overworld-figure
       (+ +jrpg-overworld-left+ (* (- (jrpg-overworld-x game) cam-x) s) (/ s 2))
       (+ +jrpg-overworld-top+ (* (- (jrpg-overworld-y game) cam-y) s) (/ s 2))
       (jrpg-overworld-facing game)))))

(defun jrpg-overworld-render-frame (game map-fn)
  "Shared chrome: the arena box, the chosen map, the player, and the HUD."
  (draw-jrpg-box 220 132 840 432 208)
  (funcall map-fn game)
  (jrpg-overworld-draw-player game)
  (draw-jrpg-box 250 392 480 92)
  (draw-jrpg-line (jrpg-overworld-message game) 270 410 17)
  ;; the legend can run long; wrap it to up to two lines inside the box
  (loop for line in (let ((ls (wrap-text-lines (jrpg-overworld-legend game) 15 444)))
                      (if (> (length ls) 2) (subseq ls 0 2) ls))
        for i from 0
        do (draw-jrpg-line line 270 (+ 438 (* i 18)) 15 194))
  (draw-jrpg-box 760 392 260 92)
  (draw-jrpg-line (format nil "hp ~d/~d"
                          (jrpg-number "jrpg-hero-hp")
                          (jrpg-number "jrpg-hero-max-hp" 18))
                  782 414 17)
  (draw-jrpg-line (format nil "~d Hours    C: menu" (jrpg-hours))
                  782 444 15))

(defun draw-jrpg-overworld-minigame (node color)
  (declare (ignore color))
  (jrpg-overworld-render-frame (ensure-jrpg-overworld node)
                               #'draw-jrpg-overworld-map))

(dialog-minigame-kind :jrpg-overworld
                      :update #'update-jrpg-overworld-minigame
                      :draw #'draw-jrpg-overworld-minigame)
