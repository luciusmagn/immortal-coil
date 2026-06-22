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

(defun jrpg-gen-overworld (w h finish-glyph waypoints)
  "Returns (values rows start-x start-y)."
  (let* ((grid (make-array (list h w) :initial-element #\.))
         (seen (make-hash-table :test 'equal))
         (sx 1) (sy (floor h 2))
         (fx (- w 2)) (fy (floor h 2))
         (road nil)
         (x sx) (y sy))
    (flet ((keep (px py) (setf (gethash (cons px py) seen) t)))
      (keep x y)
      (push (list x y) road)
      (loop repeat (* w h)
            while (or (/= x fx) (/= y fy))
            do (let ((choices nil))
                 (cond ((< x fx) (push (cons 1 0) choices)
                                 (push (cons 1 0) choices)
                                 (push (cons 1 0) choices))
                       ((> x fx) (push (cons -1 0) choices)))
                 (cond ((< y fy) (push (cons 0 1) choices))
                       ((> y fy) (push (cons 0 -1) choices)))
                 (push (if (zerop (get-random-value 0 1))
                           (cons 0 1) (cons 0 -1))
                       choices)
                 (let ((step (nth (get-random-value 0 (1- (length choices)))
                                  choices)))
                   (setf x (max 1 (min (- w 2) (+ x (car step))))
                         y (max 1 (min (- h 2) (+ y (cdr step)))))
                   (keep x y)
                   (push (list x y) road))))
      ;; straighten the rest of the road to the finish, guaranteeing a path
      (loop while (/= x fx) do (incf x (if (< x fx) 1 -1))
                               (keep x y) (push (list x y) road))
      (loop while (/= y fy) do (incf y (if (< y fy) 1 -1))
                               (keep x y) (push (list x y) road))
      (setf road (nreverse road))
      ;; obstacle clusters, never on the road
      (dotimes (i (floor (* w h) 12))
        (let ((cx (get-random-value 1 (- w 2)))
              (cy (get-random-value 1 (- h 2)))
              (glyph (if (zerop (get-random-value 0 3)) #\~ #\^)))
          (dotimes (j (get-random-value 1 4))
            (let ((ox (max 1 (min (- w 2) (+ cx (get-random-value -1 1)))))
                  (oy (max 1 (min (- h 2) (+ cy (get-random-value -1 1))))))
              (unless (gethash (cons ox oy) seen)
                (setf (aref grid oy ox) glyph))))))
      ;; landmarks strung along the road
      (let ((n (length road))
            (k (length waypoints)))
        (loop for wp in waypoints
              for i from 1
              for idx = (min (1- n) (max 1 (floor (* i n) (1+ k))))
              do (destructuring-bind (wx wy) (nth idx road)
                   (setf (aref grid wy wx) wp)
                   (keep wx wy))))
      (setf (aref grid fy fx) finish-glyph
            (aref grid sy sx) #\.)
      ;; pickups on open cells near the road
      (let ((placed 0))
        (dolist (cell road)
          (when (< placed 5)
            (destructuring-bind (rx ry) cell
              (let ((ox (max 1 (min (- w 2) (+ rx (get-random-value -2 2)))))
                    (oy (max 1 (min (- h 2) (+ ry (get-random-value -1 1))))))
                (when (and (char= (aref grid oy ox) #\.)
                           (not (gethash (cons ox oy) seen))
                           (zerop (get-random-value 0 6)))
                  (setf (aref grid oy ox)
                        (if (zerop (get-random-value 0 1)) #\$ #\o))
                  (incf placed)))))))
      (values (jrpg-gen-rows grid) sx sy))))

(defvar *jrpg-overworld* nil)

(defstruct jrpg-overworld
  (node-id          *runtime-fallback-node-id*)
  (map              *jrpg-overworld-map*)
  (finish-glyphs    '(#\!))
  (tile-messages    nil)
  (legend           "V village  = bridge  + sign  T tower  $ gold  o tonic")
  (store-prefix     "jrpg-overworld")
  (x                1)
  (y                4)
  ;; random encounters: each step past the cooldown rolls 1-in-rate to drop
  ;; the walker into a battle. the battle returns to this same node and the
  ;; walk resumes where it left off (the session is not cleared on encounter).
  (encounter-target nil)
  (encounter-rate   0)
  (encounter-cool   3)
  (message          "arrows or wasd move."))

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
                      "= bridge  + sign  T tower  $ gold  o tonic  ^~ block")
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
                    "V village  = bridge  + sign  T tower  $ gold  o tonic")
           :store-prefix (minigame-config-value node :store-prefix
                                                "jrpg-overworld")
           :x start-x
           :y start-y
           :encounter-target (minigame-config-value node :encounter-target)
           :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
           :message (minigame-config-value
                     node :start-message
                     "arrows or wasd move."))))))

(defun ensure-jrpg-overworld (node)
  (unless (and *jrpg-overworld*
               (equal (jrpg-overworld-node-id *jrpg-overworld*)
                      (node-id node)))
    (setf *jrpg-overworld* (make-fresh-jrpg-overworld node)))
  *jrpg-overworld*)

(defun jrpg-overworld-cell (game x y)
  (if (and (<= 0 x)
           (< x (jrpg-overworld-width game))
           (<= 0 y)
           (< y (jrpg-overworld-height game)))
      (char (aref (jrpg-overworld-map game) y) x)
      #\^))

(defun jrpg-overworld-passable-p (cell)
  (not (member cell '(#\^ #\~) :test #'char=)))

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
    (#\$ "coins glint in the roadside grass.")
    (#\o "a small corked bottle waits on a flat stone.")
    (#\~ "the river runs cold and quick.")
    (t "the road is bright and empty.")))

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
           (let ((gold (get-random-value 3 6)))
             (jrpg-adjust-number "jrpg-gold" gold)
             (jrpg-overworld-mark-collected game x y)
             (play-jrpg-sound "coin" :volume 0.40)
             (setf (jrpg-overworld-message game)
                   (format nil "loose coins in the grass. ~d gold." gold)))))
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

(defun jrpg-overworld-finish (node)
  (setf *jrpg-overworld* nil)
  (jump-to-dialog-target (node-success-target node)))

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
            (setf (jrpg-overworld-encounter-cool game) 3)
            (jump-to-dialog-target target))))))

(defun jrpg-overworld-move (node game dx dy)
  (let* ((next-x (+ (jrpg-overworld-x game) dx))
         (next-y (+ (jrpg-overworld-y game) dy))
         (cell (jrpg-overworld-cell game next-x next-y)))
    (if (jrpg-overworld-passable-p cell)
        (progn
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
             (jrpg-overworld-finish node))
            (t
             (jrpg-overworld-maybe-encounter node game))))
        (setf (jrpg-overworld-message game)
              (if (char= cell #\~)
                  "the water is too deep to wade."
                  "you cannot get through that way.")))))

(defun update-jrpg-overworld-minigame (node dt)
  (declare (ignore dt))
  (let ((game (ensure-jrpg-overworld node)))
    (let ((direction (jrpg-overworld-input-direction)))
      (when direction
        (destructuring-bind (dx dy) direction
          (jrpg-overworld-move node game dx dy))))))

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

(defun draw-jrpg-overworld-cell (cell screen-x screen-y)
  "Distinct, readable tiles: open ground is a faint dot, blocks are solid
fills, water a low band, and landmarks/pickups bold glyphs — so the route
and its marks are not a field of identical specks."
  (let* ((s  +jrpg-overworld-tile-size+)
         (cx (+ screen-x (/ s 2)))
         (cy (+ screen-y (/ s 2))))
    (flet ((fill-rect (x y w h alpha)
             (claylib/ll:draw-rectangle (round x) (round y)
                                        (max 1 (round w)) (max 1 (round h))
                                        (claylib::c-ptr
                                         (make-color 255 255 255 alpha)))))
      (case cell
        (#\.                              ; open ground
         (fill-rect (- cx 1) (- cy 1) 2 2 38))
        (#\^                              ; obstacle: a solid block
         (fill-rect (+ screen-x 3) (+ screen-y 3) (- s 6) (- s 6) 150))
        (#\~                              ; water: a low filled band
         (fill-rect (+ screen-x 2) cy (- s 4) (- (/ s 2) 2) 80))
        (t                               ; landmark / pickup / finish
         (draw-centered-text (jrpg-overworld-tile-label cell)
                             cx cy 20
                             (make-color 255 255 255 235)))))))

(defun jrpg-draw-overworld-figure (cx cy)
  "A small standing figure — the traveller. Drawn from rectangles so it
reads as a person, not the dungeon @."
  (flet ((fill-rect (x y w h)
           (claylib/ll:draw-rectangle (round x) (round y)
                                      (max 1 (round w)) (max 1 (round h))
                                      (claylib::c-ptr (make-color 255 255 255 255)))))
    (fill-rect (- cx 3) (- cy 9) 6 5)     ; head
    (fill-rect (- cx 4) (- cy 3) 8 8)     ; body
    (fill-rect (- cx 4) (+ cy 5) 3 4)     ; left leg
    (fill-rect (+ cx 1) (+ cy 5) 3 4)))   ; right leg

(defun draw-jrpg-overworld-map (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (loop for row below +jrpg-overworld-view-rows+
          do (loop for col below +jrpg-overworld-view-cols+
                   for mx = (+ cam-x col)
                   for my = (+ cam-y row)
                   when (and (< mx (jrpg-overworld-width game))
                             (< my (jrpg-overworld-height game)))
                     do (draw-jrpg-overworld-cell
                         (jrpg-overworld-effective-cell game mx my)
                         (+ +jrpg-overworld-left+ (* col +jrpg-overworld-tile-size+))
                         (+ +jrpg-overworld-top+ (* row +jrpg-overworld-tile-size+)))))
    (jrpg-draw-overworld-figure
     (+ +jrpg-overworld-left+
        (* (- (jrpg-overworld-x game) cam-x) +jrpg-overworld-tile-size+)
        (/ +jrpg-overworld-tile-size+ 2))
     (+ +jrpg-overworld-top+
        (* (- (jrpg-overworld-y game) cam-y) +jrpg-overworld-tile-size+)
        (/ +jrpg-overworld-tile-size+ 2)))))

(defun draw-jrpg-overworld-minigame (node color)
  (declare (ignore color))
  (let ((game (ensure-jrpg-overworld node)))
    (draw-jrpg-box 220 132 840 432 208)
    (draw-jrpg-overworld-map game)
    (draw-jrpg-box 250 392 480 92)
    (draw-jrpg-line (jrpg-overworld-message game) 270 414 17)
    (draw-jrpg-line (jrpg-overworld-legend game)
                    270
                    444
                    15
                    194)
    (draw-jrpg-box 760 392 260 92)
    (draw-jrpg-line (format nil "hp ~d/~d"
                            (jrpg-number "jrpg-hero-hp")
                            (jrpg-number "jrpg-hero-max-hp" 18))
                    782
                    414
                    17)
    (draw-jrpg-line (format nil "gold ~d" (jrpg-number "jrpg-gold"))
                    782
                    444
                    17)))

(dialog-minigame-kind :jrpg-overworld
                      :update #'update-jrpg-overworld-minigame
                      :draw #'draw-jrpg-overworld-minigame)
