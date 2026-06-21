;;; rogue delve minigame
;;;
;;; Reusable turn-based crawl. Progress lives in the dialog store under
;;; a config prefix so autosaves can resume a long delve.
;;;
;;; Map glyphs: # wall, . floor, @ spawn, * chalk mark, m hunter,
;;; b/g/o monsters (bat/goblin/orc), ^ trap, : ration, ! potion, ? map scroll,
;;; >/< stairs internally render as %, , is the bottom.

(defconstant +delve-cell+ 28)
(defconstant +delve-glyph-size+ 24)
(defconstant +delve-sight+ 4)
(defconstant +delve-map-center-y+ 378.0)
(defconstant +delve-hud-height+ 116.0)
(defconstant +delve-hud-gap+ 16.0)
(defconstant +delve-display-stairs-glyph+ #\%)
(defconstant +delve-ration-glyph+ #\:)
(defconstant +delve-goal-glyph+ #\,)

(defparameter *delve-classes*
  '((:id :fighter
     :label "FIGHTER"
     :hp 10
     :sight 4
     :attack 7
     :stealth 1
     :rations 1
     :scrolls 0
     :digs 0
     :description "mail and a short sword. opens doors with his shoulder.")
    (:id :rogue
     :label "ROGUE"
     :hp 6
     :sight 5
     :attack 4
     :stealth 5
     :rations 2
     :scrolls 1
     :digs 0
     :description "soft boots, lockpicks, a nose for floors that bite.")
    (:id :ranger
     :label "RANGER"
     :hp 7
     :sight 6
     :attack 5
     :stealth 3
     :rations 2
     :scrolls 0
     :digs 0
     :description "long sight and a quiet bow. reads the dark a room out.")
    (:id :seer
     :label "SEER"
     :hp 4
     :sight 7
     :attack 3
     :stealth 2
     :rations 1
     :scrolls 2
     :digs 0
     :description "a bad knife, long eyes, and a map sense.")
    (:id :tunneler
     :label "TUNNELER"
     :hp 8
     :sight 4
     :attack 4
     :stealth 2
     :rations 1
     :scrolls 0
     :digs 3
     :description "a pick and a grudge against walls. digs when cornered.")))

(defparameter *delve-inventory-options*
  #(:ration :scroll :dig :return))

;;; Procedural floors
;;;
;;; Each delve builds its own rooms-and-corridors dungeon once and stores
;;; the result under the save prefix, so a resumed crawl keeps the same
;;; map. Two different delves (different prefixes) and two playthroughs of
;;; one delve get different layouts.

(defun delve-rect-clear-p (grid x0 y0 rw rh)
  (let ((h (array-dimension grid 0))
        (w (array-dimension grid 1)))
    (loop for y from (1- y0) to (+ y0 rh) always
          (loop for x from (1- x0) to (+ x0 rw) always
                (or (< x 0) (< y 0) (>= x w) (>= y h)
                    (char= (aref grid y x) #\#))))))

(defun delve-carve-rect (grid x0 y0 rw rh)
  (loop for y from y0 below (+ y0 rh) do
        (loop for x from x0 below (+ x0 rw) do
              (setf (aref grid y x) #\.))))

(defun delve-carve-h (grid xa xb y)
  (loop for x from (min xa xb) to (max xa xb) do (setf (aref grid y x) #\.)))

(defun delve-carve-v (grid ya yb x)
  (loop for y from (min ya yb) to (max ya yb) do (setf (aref grid y x) #\.)))

(defun delve-generate-grid (w h)
  "Return (values grid room-centers); rooms are chained by corridors, so
the whole floor is connected."
  (let ((grid (make-array (list h w) :initial-element #\#))
        (centers nil))
    (dotimes (try 24)
      (let* ((rw (+ 3 (get-random-value 0 5)))
             (rh (+ 2 (get-random-value 0 3)))
             (x0 (+ 1 (get-random-value 0 (max 1 (- w rw 2)))))
             (y0 (+ 1 (get-random-value 0 (max 1 (- h rh 2))))))
        (when (delve-rect-clear-p grid x0 y0 rw rh)
          (delve-carve-rect grid x0 y0 rw rh)
          (let ((cx (+ x0 (floor rw 2)))
                (cy (+ y0 (floor rh 2))))
            (when centers
              (destructuring-bind (px py) (first centers)
                (if (zerop (get-random-value 0 1))
                    (progn (delve-carve-h grid px cx py)
                           (delve-carve-v grid py cy cx))
                    (progn (delve-carve-v grid py cy px)
                           (delve-carve-h grid px cx cy)))))
            (push (list cx cy) centers)))))
    (values grid (nreverse centers))))

(defun delve-open-cells (grid)
  (loop for y below (array-dimension grid 0)
        nconc (loop for x below (array-dimension grid 1)
                    when (char= (aref grid y x) #\.)
                      collect (list x y))))

(defun delve-grid-rows (grid)
  (loop for y below (array-dimension grid 0)
        collect (coerce (loop for x below (array-dimension grid 1)
                              collect (aref grid y x))
                        'string)))

(defun delve-floor-grid-and-rooms (w h)
  "A connected floor grid with at least three rooms, or, after enough
failed tries, one open interior room with synthesized centers."
  (loop for try below 60
        do (multiple-value-bind (grid centers) (delve-generate-grid w h)
             (when (>= (length centers) 3)
               (return-from delve-floor-grid-and-rooms (values grid centers))))
        finally
           (let ((grid (make-array (list h w) :initial-element #\#)))
             (delve-carve-rect grid 1 1 (- w 2) (- h 2))
             (return (values grid
                             (list (list 2 2)
                                   (list (floor w 2) (floor h 2))
                                   (list (- w 3) (- h 3))))))))

(defun delve-build-floor (w h first-p last-p hunters monsters items traps)
  "Build one floor and return its rows as a list of strings."
  (multiple-value-bind (grid centers) (delve-floor-grid-and-rooms w h)
    (destructuring-bind (fx fy) (first centers)
      (destructuring-bind (lx ly) (car (last centers))
        (if first-p
            (progn
              (setf (aref grid fy fx) #\@)
              (destructuring-bind (sx sy) (second centers)
                (setf (aref grid sy sx) #\<)))
            (setf (aref grid fy fx) #\<))
        (setf (aref grid ly lx) (if last-p #\, #\>))))
    (let ((cells (dream-maze-shuffle (delve-open-cells grid))))
      (flet ((scatter (glyph n)
               (dotimes (i n)
                 (when cells
                   (destructuring-bind (cx cy) (pop cells)
                     (setf (aref grid cy cx) glyph))))))
        (scatter #\m hunters)
        (dotimes (i monsters)
          (scatter (nth (get-random-value 0 2) '(#\g #\b #\o)) 1))
        (scatter #\* (max 1 (floor items 2)))
        (scatter #\: (max 1 (floor (1+ items) 3)))
        (scatter #\! 1)
        (scatter #\? 1)
        (scatter #\^ traps)))
    (delve-grid-rows grid)))

(defun delve-config-count (session key default)
  (let ((value (session-config-value session key default)))
    (if (and (integerp value) (>= value 0)) value default)))

(defun delve-generate-dungeon (session)
  "A fresh dungeon for this delve as a list of floors (each a row list)."
  (let ((floors (max 2 (delve-config-count session :gen-floors 4)))
        (w (max 13 (delve-config-count session :gen-width 23)))
        (h (max 9 (delve-config-count session :gen-height 15)))
        (hunters (delve-config-count session :gen-hunters 1))
        (monsters (delve-config-count session :gen-monsters 4))
        (items (delve-config-count session :gen-items 4))
        (traps (delve-config-count session :gen-traps 2)))
    (loop for fi below floors
          collect (delve-build-floor w h
                                     (zerop fi)
                                     (= fi (1- floors))
                                     hunters monsters items traps))))

;;; Crawl state

(defclass rogue-delve-session (minigame-session)
  ((floors
    :initform #()
    :accessor delve-floors)))

(defun delve-prefix (session)
  (session-config-value session :save-prefix "delve"))

(defun delve-key (session name)
  (format nil "~a-~a" (delve-prefix session) name))

(defun delve-state (session name &optional default)
  (session-store-value session (delve-key session name) default))

(defun (setf delve-state) (value session name)
  (setf (session-store-value session (delve-key session name)) value))

(defun delve-parse-floor (rows)
  (coerce (mapcar (lambda (row) (coerce row 'vector)) rows) 'vector))

(defun delve-find-glyph (floor glyph)
  (loop for y below (length floor)
        do (loop for x below (length (aref floor y))
                 when (eql (aref (aref floor y) x) glyph)
                   do (return-from delve-find-glyph (values x y))))
  (values 1 1))

(defun delve-floor-index (session)
  (let ((count (length (delve-floors session))))
    (min (delve-state session "floor" 0)
         (max 0 (1- count)))))

(defun delve-floor-grid (session)
  (aref (delve-floors session) (delve-floor-index session)))

(defun delve-glyph-at (session x y)
  (let ((grid (delve-floor-grid session)))
    (if (and (>= y 0) (< y (length grid))
             (>= x 0) (< x (length (aref grid y))))
        (aref (aref grid y) x)
        #\#)))

(defun delve-position-token (floor x y)
  (list floor x y))

(defun delve-picked-p (session floor x y)
  (member (delve-position-token floor x y)
          (delve-state session "picked")
          :test #'equal))

(defun delve-killed-p (session floor x y)
  (member (delve-position-token floor x y)
          (delve-state session "killed")
          :test #'equal))

(defun delve-mark-picked (session floor x y)
  (pushnew (delve-position-token floor x y)
           (delve-state session "picked")
           :test #'equal))

(defun delve-mark-killed (session floor x y)
  (pushnew (delve-position-token floor x y)
           (delve-state session "killed")
           :test #'equal))

(defun delve-class (session)
  (let ((class-id (delve-state session "class")))
    (or (and class-id
             (find class-id
                   *delve-classes*
                   :key (lambda (entry) (getf entry :id))))
        (first *delve-classes*))))

(defun delve-class-id (class)
  (getf class :id))

(defun delve-class-label (class)
  (getf class :label "ADVENTURER"))

(defun delve-class-value (session key &optional default)
  (getf (delve-class session) key default))

(defun delve-player-sight (session)
  (+ (delve-class-value session :sight +delve-sight+)
     (if (delve-state session "mapped") 1 0)))

(defun delve-player-attack (session)
  (+ (delve-class-value session :attack 4)
     (if (dialog-value "rogue-sword") 1 0)))

(defun delve-max-hp (session)
  (delve-class-value session :hp 5))

(defun delve-current-hp (session)
  (or (delve-state session "hp")
      (delve-max-hp session)))

(defun delve-sound (session key &optional (volume 0.42))
  (let ((path (session-config-value session key)))
    (when path
      (play-story-sound path :volume volume))))

(defun delve-set-message (session control &rest args)
  (setf (delve-state session "message")
        (if args
            (apply #'format nil control args)
            control)))

(defun delve-monster-name (glyph)
  (case (char-downcase glyph)
    (#\b "bat")
    (#\g "goblin")
    (#\o "orc")
    (t nil)))

(defun delve-monster-attack-text (glyph)
  (case (char-downcase glyph)
    (#\b "the bat tears at your face.")
    (#\g "the goblin jabs under your guard.")
    (#\o "the orc drives you back a step.")
    (t "the monster hits you.")))

(defun delve-monster-damage (glyph)
  (case (char-downcase glyph)
    (#\o 2)
    (t 1)))

(defun delve-goal-p (glyph)
  (member glyph '(#\, #\$) :test #'eql))


;;; Session setup

(declaim (ftype (function (t t) t) delve-ensure-monsters))

(defun delve-place-hunter (session floor-index)
  (delve-ensure-monsters session floor-index)
  (setf (delve-state session "hunter-alert") 0)
  (let ((grid (aref (delve-floors session) floor-index)))
    (multiple-value-bind (x y) (delve-find-glyph grid #\m)
      (if (eql (aref (aref grid y) x) #\m)
          (setf (delve-state session "hunter-x") x
                (delve-state session "hunter-y") y
                (delve-state session "hunter") t)
          (setf (delve-state session "hunter") nil)))))

(defun delve-initialize-position (session)
  (multiple-value-bind (x y)
      (delve-find-glyph (aref (delve-floors session) 0) #\@)
    (setf (delve-state session "floor") 0
          (delve-state session "x") x
          (delve-state session "y") y)
    (delve-place-hunter session 0)))

(defun delve-resolve-floor-rows (session)
  "Floors as row lists: stored map if resuming, else an authored :maps,
else a freshly generated dungeon. Persisted so a resume keeps its map."
  (let ((stored (delve-state session "floor-data")))
    (if (and (listp stored) stored)
        stored
        (let* ((maps (session-config-value session :maps))
               (rows (if (and (listp maps) maps)
                         maps
                         (delve-generate-dungeon session))))
          (setf (delve-state session "floor-data") rows)
          rows))))

(defun delve-load-floors (session)
  (setf (delve-floors session)
        (coerce (mapcar #'delve-parse-floor
                        (delve-resolve-floor-rows session))
                'vector)))

;;; Carrying stats between consecutive delves
;;;
;;; A delve remembers its ending stats on success under a global key. A
;;; delve placed right after another (config :inherit t) seeds itself from
;;; them and skips the class menu, so a two-stage descent keeps its run.

(defun delve-store-carry (session)
  (setf (dialog-value "delve-carry")
        (list :class (delve-state session "class")
              :hp (delve-current-hp session)
              :rations (delve-state session "rations" 0)
              :scrolls (delve-state session "scrolls" 0)
              :digs (delve-state session "digs" 0)
              :xp (delve-state session "xp" 0)
              :marks (delve-state session "marks" 0))))

(defun delve-apply-carry (session carry)
  (when (getf carry :class)
    (setf (delve-state session "class") (getf carry :class)))
  (setf (delve-state session "phase") :crawl
        (delve-state session "rations") (or (getf carry :rations) 0)
        (delve-state session "scrolls") (or (getf carry :scrolls) 0)
        (delve-state session "digs") (or (getf carry :digs) 0)
        (delve-state session "xp") (or (getf carry :xp) 0)
        (delve-state session "marks") (or (getf carry :marks) 0)
        (delve-state session "inventory-index") 0
        (delve-state session "hp")
        (max 1 (min (or (getf carry :hp) (delve-max-hp session))
                    (delve-max-hp session))))
  (delve-set-message session
                     "you go down again, carrying what the last dark left you."))

(defmethod initialize-instance :after ((session rogue-delve-session) &key)
  (unless (delve-state session "started")
    (with-batched-store-saves ()
      (setf (delve-state session "started") t
            (delve-state session "phase") :class
            (delve-state session "class-index") 0
            (delve-state session "marks") 0
            (delve-state session "xp") 0
            (delve-state session "turns") 0
            (delve-state session "picked") nil
            (delve-state session "killed") nil
            (delve-state session "monsters") nil
            (delve-state session "monsters-init") nil
            (delve-state session "hunter-alert") 0
            (delve-state session "mapped") nil
            (delve-state session "floor-data") nil
            (delve-state session "message") "choose a class.")
      (delve-load-floors session)
      (delve-initialize-position session)
      (when (and (session-config-value session :inherit)
                 (dialog-value "delve-carry"))
        (delve-apply-carry session (dialog-value "delve-carry")))))
  (delve-load-floors session)
  (unless (delve-state session "phase")
    (setf (delve-state session "phase")
          (if (delve-state session "class") :crawl :class))))

(defun delve-start-class (session class)
  (with-batched-store-saves ()
    (setf (delve-state session "class") (delve-class-id class)
          (delve-state session "phase") :crawl
          (delve-state session "hp") (getf class :hp)
          (delve-state session "rations") (getf class :rations)
          (delve-state session "scrolls") (getf class :scrolls 0)
          (delve-state session "digs") (getf class :digs 0)
          (delve-state session "inventory-index") 0)
    (delve-set-message session
                       "~a enters the dungeon."
                       (string-downcase (delve-class-label class))))
  (delve-sound session :class-sound 0.54))


;;; Turn rules

(defun delve-walkable-p (session x y)
  (not (eql (delve-glyph-at session x y) #\#)))

(defun delve-monster-p (glyph)
  (not (null (delve-monster-name glyph))))

(defun delve-item-p (glyph)
  (member glyph '(#\* #\: #\! #\?) :test #'eql))

(defun delve-hunter-caught-p (session)
  (and (delve-state session "hunter")
       (= (delve-state session "hunter-x") (delve-state session "x"))
       (= (delve-state session "hunter-y") (delve-state session "y"))))

(defun delve-finish (session node outcome-key fallback)
  (when (eq outcome-key :goal-target)
    (delve-store-carry session))
  (setf (delve-state session "started") nil)
  (finish-minigame-node node
                        (or (session-config-value session outcome-key)
                            fallback)))

(defun delve-hurt (session node amount)
  (let ((hp (max 0 (- (delve-current-hp session) amount))))
    (setf (delve-state session "hp") hp)
    (delve-sound session :hit-sound 0.46)
    (if (zerop hp)
        (progn
          (delve-finish session node :caught-target (node-failure-target node))
          nil)
        t)))

(defun delve-switch-floor (session new-floor arrival-glyph)
  (let* ((bounded-floor (min (max 0 new-floor)
                             (1- (length (delve-floors session)))))
         (grid (aref (delve-floors session) bounded-floor)))
    (multiple-value-bind (x y) (delve-find-glyph grid arrival-glyph)
      (setf (delve-state session "floor") bounded-floor
            (delve-state session "x") x
            (delve-state session "y") y
            (delve-state session "mapped") nil)
      (delve-place-hunter session bounded-floor)
      (delve-sound session :stairs-sound 0.48))))

;;; Roaming monsters
;;;
;;; The monster glyphs in the generated grid seed a live, per-floor list
;;; of (x y glyph). They wake when the player comes within a stealth-
;;; dependent radius, step toward them, and bite from an adjacent cell.
;;; The list lives in the store, so a resumed crawl finds them where they
;;; wandered. The static grid glyphs themselves render as plain floor.

(defun delve-scan-monsters (grid)
  "Each monster is (x y glyph roused). They start unroused: a monster that
has not yet noticed the player can be taken from behind."
  (loop for y below (length grid)
        nconc (loop for x below (length (aref grid y))
                    for glyph = (aref (aref grid y) x)
                    when (delve-monster-p glyph)
                      collect (list x y glyph nil))))

(defun delve-floor-monsters (session floor)
  (cdr (assoc floor (delve-state session "monsters") :test #'eql)))

(defun (setf delve-floor-monsters) (value session floor)
  (setf (delve-state session "monsters")
        (cons (cons floor value)
              (remove floor (delve-state session "monsters")
                      :key #'car :test #'eql)))
  value)

(defun delve-ensure-monsters (session floor)
  (unless (member floor (delve-state session "monsters-init") :test #'eql)
    (setf (delve-floor-monsters session floor)
          (delve-scan-monsters (aref (delve-floors session) floor)))
    (setf (delve-state session "monsters-init")
          (cons floor (delve-state session "monsters-init")))))

(defun delve-monster-at (session floor x y)
  (find-if (lambda (mon) (and (= (first mon) x) (= (second mon) y)))
           (delve-floor-monsters session floor)))

(defun delve-remove-monster (session floor mon)
  (setf (delve-floor-monsters session floor)
        (remove mon (delve-floor-monsters session floor) :test #'eq)))

(defun delve-monster-wake-radius (session)
  ;; How near you can get before a monster may notice you. A loud class is
  ;; spotted from across the room; a stealthy one can nearly step on them.
  (max 2 (- 6 (delve-class-value session :stealth 1))))

(defun delve-random-step (mx my)
  "A random orthogonal neighbour of MX,MY, or the cell itself (a fifth of
the time, so an idle monster sometimes just holds where it is)."
  (case (get-random-value 0 4)
    (0 (cons (1+ mx) my))
    (1 (cons (1- mx) my))
    (2 (cons mx (1+ my)))
    (3 (cons mx (1- my)))
    (t (cons mx my))))

(defun delve-move-monsters (session node)
  "A roused monster in range pursues and bites. An unroused one may fail a
stealth roll and not notice you (and can then be backstabbed). Whatever it
is doing, an idle monster drifts a step now and then, so the floor is never
a room of frozen statues. Returns NIL if a bite finishes the player."
  (let* ((floor (delve-floor-index session))
         (px (delve-state session "x"))
         (py (delve-state session "y"))
         (wake (delve-monster-wake-radius session))
         (stealth (delve-class-value session :stealth 1))
         (occupied (make-hash-table :test #'equal))
         (result nil)
         (alive t))
    (dolist (mon (delve-floor-monsters session floor))
      (setf (gethash (cons (first mon) (second mon)) occupied) t))
    (dolist (mon (delve-floor-monsters session floor))
      (let* ((mx (first mon))
             (my (second mon))
             (glyph (third mon))
             (roused (fourth mon))
             (nx mx)
             (ny my)
             (dist (max (abs (- px mx)) (abs (- py my)))))
        (flet ((step-to (cands)
                 (dolist (cand cands)
                   (let ((cx (car cand))
                         (cy (cdr cand)))
                     (when (and (or (/= cx mx) (/= cy my))
                                (delve-walkable-p session cx cy)
                                (not (and (= cx px) (= cy py)))
                                (not (gethash (cons cx cy) occupied)))
                       (setf nx cx ny cy)
                       (return))))))
          (cond
            ((not alive))
            ;; in notice range, and either already roused or it spots you now
            ((and (<= dist wake)
                  (or roused (> (get-random-value 1 6) stealth)))
             (setf roused t)
             (if (<= dist 1)
                 (progn
                   (delve-set-message session (delve-monster-attack-text glyph))
                   (delve-sound session :hit-sound 0.40)
                   (unless (delve-hurt session node (delve-monster-damage glyph))
                     (setf alive nil)))
                 (let* ((dx (cond ((< mx px) 1) ((> mx px) -1) (t 0)))
                        (dy (cond ((< my py) 1) ((> my py) -1) (t 0)))
                        (prefer-x (>= (abs (- px mx)) (abs (- py my)))))
                   (step-to (if prefer-x
                                (list (cons (+ mx dx) my) (cons mx (+ my dy)))
                                (list (cons mx (+ my dy)) (cons (+ mx dx) my)))))))
            ;; idle (out of range, or dormant in range): drift about half the
            ;; time so the dungeon feels lived-in rather than paused
            ((zerop (get-random-value 0 1))
             (step-to (list (delve-random-step mx my))))))
        (remhash (cons mx my) occupied)
        (setf (gethash (cons nx ny) occupied) t)
        (push (list nx ny glyph roused) result)))
    (setf (delve-floor-monsters session floor) (nreverse result))
    alive))


;;; Hunter
;;;
;;; The hunter senses the player within a stealth-dependent radius and
;;; then keeps the scent for several turns even after the player slips
;;; back out of range, closing a step at a time. A stealthy class can
;;; pass much nearer before it stirs.

(defun delve-hunter-detect-radius (session)
  (max 3 (- 8 (delve-class-value session :stealth 1))))

(defun delve-hunter-pursue (session hx hy px py)
  (let* ((dx (cond ((< hx px) 1) ((> hx px) -1) (t 0)))
         (dy (cond ((< hy py) 1) ((> hy py) -1) (t 0)))
         (prefer-x (>= (abs (- px hx)) (abs (- py hy)))))
    (flet ((try-x ()
             (and (/= dx 0)
                  (delve-walkable-p session (+ hx dx) hy)
                  (setf (delve-state session "hunter-x") (+ hx dx))))
           (try-y ()
             (and (/= dy 0)
                  (delve-walkable-p session hx (+ hy dy))
                  (setf (delve-state session "hunter-y") (+ hy dy)))))
      (if prefer-x (or (try-x) (try-y)) (or (try-y) (try-x))))))

(defun delve-hunter-step (session)
  (when (delve-state session "hunter")
    (let* ((hx (delve-state session "hunter-x"))
           (hy (delve-state session "hunter-y"))
           (px (delve-state session "x"))
           (py (delve-state session "y"))
           (distance (max (abs (- px hx)) (abs (- py hy)))))
      (when (<= distance (delve-hunter-detect-radius session))
        (setf (delve-state session "hunter-alert") 9))
      (when (plusp (delve-state session "hunter-alert" 0))
        (setf (delve-state session "hunter-alert")
              (1- (delve-state session "hunter-alert" 0)))
        (delve-hunter-pursue session hx hy px py)
        ;; Closing burst. At walking pace it could never run anyone down, so
        ;; once it has the scent it takes a second step when already near, and
        ;; now and then even at range, gaining ground over a long chase. Break
        ;; its line for long enough (alert decays over 9 turns) and you slip it.
        (let* ((nhx (delve-state session "hunter-x"))
               (nhy (delve-state session "hunter-y"))
               (ndist (max (abs (- px nhx)) (abs (- py nhy)))))
          (when (and (plusp ndist)
                     (or (<= ndist 3)
                         (zerop (get-random-value 0 2))))
            (delve-hunter-pursue session nhx nhy px py)))))))

(defun delve-hunter-rob (session)
  "The hunter reaches the player. It is not fatal and never ends the
crawl: it takes the gathered chalk and a ration, and falls back to its
round while the player tears free into the dark. A stealthy class is
sensed late enough to avoid it; a loud one pays the toll."
  (setf (delve-state session "marks") 0)
  (when (plusp (delve-state session "rations" 0))
    (decf (delve-state session "rations")))
  (delve-place-hunter session (delve-floor-index session))
  (delve-set-message session
                     "the hunter has you a breath. it takes your chalk and a ration; you tear loose into the dark.")
  (delve-sound session :hit-sound 0.5))

(defun delve-advance-turn (session node)
  (incf (delve-state session "turns"))
  (when (and (zerop (mod (delve-state session "turns") 26))
             (zerop (delve-state session "rations" 0)))
    (delve-set-message session "hunger takes one hit.")
    (unless (delve-hurt session node 1)
      (return-from delve-advance-turn nil)))
  (unless (delve-move-monsters session node)
    (return-from delve-advance-turn nil))
  (delve-hunter-step session)
  (when (delve-hunter-caught-p session)
    (delve-hunter-rob session))
  t)

(defun delve-resolve-monster (session node x y mon floor-index)
  (let* ((glyph (third mon))
         (roused (fourth mon))
         (name (or (delve-monster-name glyph) "monster"))
         ;; a monster that has not noticed you is taken from behind: a
         ;; backstab always lands, rewarding a quiet approach
         (hit-p (or (not roused)
                    (<= (get-random-value 1 10) (delve-player-attack session)))))
    (if hit-p
        (progn
          (delve-remove-monster session floor-index mon)
          (incf (delve-state session "xp"))
          (setf (delve-state session "x") x
                (delve-state session "y") y)
          (if roused
              (delve-set-message session "you kill the ~a." name)
              (delve-set-message session "you take the ~a from behind, before it wakes." name))
          (delve-sound session :kill-sound 0.48)
          (delve-advance-turn session node))
        (progn
          (delve-set-message session (delve-monster-attack-text glyph))
          (delve-sound session :hit-sound 0.46)
          (when (delve-hurt session node (delve-monster-damage glyph))
            (delve-advance-turn session node))))))

(defun delve-trigger-trap (session node floor-index x y)
  (delve-mark-picked session floor-index x y)
  (let ((stealth (delve-class-value session :stealth 1)))
    (if (<= (get-random-value 1 6) stealth)
        (progn
          (delve-set-message session "you spot the trap before it bites.")
          (delve-sound session :pickup-sound 0.38))
        (progn
          (delve-set-message session "the trap takes one clean hit.")
          (delve-hurt session node 1)))))

(defun delve-collect-item (session floor-index x y glyph)
  (unless (delve-picked-p session floor-index x y)
    (delve-mark-picked session floor-index x y)
    (case glyph
      (#\*
       (incf (delve-state session "marks"))
       (delve-set-message session "you pocket a chalk mark."))
      (#\:
       (incf (delve-state session "rations"))
       (delve-set-message session "you pack a food ration."))
      (#\!
       (setf (delve-state session "hp")
             (min (delve-max-hp session)
                  (+ (delve-current-hp session) 2)))
       (delve-set-message session "the potion closes a wound."))
      (#\?
       (incf (delve-state session "scrolls"))
       (delve-set-message session "you find a map scroll.")))
    (delve-sound session :pickup-sound 0.38)))

(defun delve-enter-cell (session node x y)
  (let* ((glyph (delve-glyph-at session x y))
         (floor-index (delve-floor-index session)))
    (cond
      ((not (delve-walkable-p session x y))
       (delve-sound session :bump-sound 0.28)
       t)
      ((delve-monster-at session floor-index x y)
       (delve-resolve-monster session node x y
                              (delve-monster-at session floor-index x y)
                              floor-index))
      ((and (eql glyph #\^)
            (not (delve-picked-p session floor-index x y)))
       (setf (delve-state session "x") x
             (delve-state session "y") y)
       (when (delve-trigger-trap session node floor-index x y)
         (delve-advance-turn session node)))
      (t
       (setf (delve-state session "x") x
             (delve-state session "y") y)
       (when (delve-item-p glyph)
         (delve-collect-item session floor-index x y glyph))
       (cond
         ((delve-goal-p glyph)
          (delve-set-message session "you find the bottom.")
          (delve-finish session node :goal-target
                        (node-success-target node))
          nil)
         ((eql glyph #\>)
          (delve-set-message session "you take the stairs down.")
          (if (< (1+ floor-index) (length (delve-floors session)))
              (delve-switch-floor session (1+ floor-index) #\<)
              (delve-finish session node :goal-target
                            (node-success-target node)))
          nil)
         ((eql glyph #\<)
          (if (zerop floor-index)
              (progn
                (delve-set-message session "you take the stairs out.")
                (delve-finish session node :leave-target
                              (node-failure-target node))
                nil)
              (progn
                (delve-set-message session "you take the stairs up.")
                (delve-switch-floor session (1- floor-index) #\>)
                nil)))
         (t
          (delve-sound session :step-sound 0.30)
          (delve-advance-turn session node)))))))

(defun delve-take-step (session node dx dy)
  (let ((x (+ (delve-state session "x") dx))
        (y (+ (delve-state session "y") dy)))
    (with-batched-store-saves ()
      (delve-enter-cell session node x y))))

(defun delve-step-input ()
  (cond
    ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
     (values 0 -1))
    ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
     (values 0 1))
    ((or (is-key-pressed-p +key-left+) (is-key-pressed-p +key-a+))
     (values -1 0))
    ((or (is-key-pressed-p +key-right+) (is-key-pressed-p +key-d+))
     (values 1 0))
    (t (values nil nil))))


;;; Menus

(defun delve-menu-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+)
         (is-key-pressed-p +key-s+)
         (is-key-pressed-p +key-d+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+)
         (is-key-pressed-p +key-w+)
         (is-key-pressed-p +key-a+))
     -1)))

(defun delve-class-count ()
  (length *delve-classes*))

(defun delve-selected-class (session)
  (nth (mod (delve-state session "class-index" 0)
            (delve-class-count))
       *delve-classes*))

(defun update-delve-class-menu (session)
  (let ((direction (delve-menu-direction)))
    (when direction
      (setf (delve-state session "class-index")
            (mod (+ (delve-state session "class-index" 0) direction)
                 (delve-class-count)))
      (delve-sound session :menu-sound 0.28)))
  (when (confirm-pressed-p)
    (delve-start-class session (delve-selected-class session))))

(defun delve-inventory-action-visible-p (session action)
  (case action
    (:ration (plusp (delve-state session "rations" 0)))
    (:scroll (plusp (delve-state session "scrolls" 0)))
    (:dig (plusp (delve-state session "digs" 0)))
    (t t)))

(defun delve-inventory-actions (session)
  (remove-if-not (lambda (action)
                   (delve-inventory-action-visible-p session action))
                 (coerce *delve-inventory-options* 'list)))

(defun delve-selected-inventory-action (session)
  (let ((actions (delve-inventory-actions session)))
    (nth (mod (delve-state session "inventory-index" 0)
              (length actions))
         actions)))

(defun delve-close-inventory (session)
  (setf (delve-state session "phase") :crawl
        (delve-state session "inventory-index") 0)
  (delve-sound session :menu-sound 0.24))

(defun delve-persist-floor (session)
  "Write the current (mutated) floor grid back into the stored map so a
resume keeps any walls the tunneler broke."
  (let* ((idx (delve-floor-index session))
         (grid (aref (delve-floors session) idx))
         (rows (loop for row across grid collect (coerce row 'string)))
         (data (copy-list (delve-state session "floor-data"))))
    (when (and data (< idx (length data)))
      (setf (nth idx data) rows
            (delve-state session "floor-data") data))))

(defun delve-dig-around (session)
  "Break interior walls orthogonally next to the player. Returns the count."
  (let* ((grid (delve-floor-grid session))
         (px (delve-state session "x"))
         (py (delve-state session "y"))
         (h (length grid))
         (w (length (aref grid 0)))
         (broken 0))
    (dolist (step '((1 . 0) (-1 . 0) (0 . 1) (0 . -1)))
      (let ((nx (+ px (car step)))
            (ny (+ py (cdr step))))
        (when (and (> nx 0) (< nx (1- w))
                   (> ny 0) (< ny (1- h))
                   (char= (aref (aref grid ny) nx) #\#))
          (setf (aref (aref grid ny) nx) #\.)
          (incf broken))))
    (when (plusp broken)
      (delve-persist-floor session))
    broken))

(defun delve-use-inventory-action (session action)
  (case action
    (:ration
     (when (plusp (delve-state session "rations" 0))
       (decf (delve-state session "rations"))
       (setf (delve-state session "hp")
             (min (delve-max-hp session)
                  (+ (delve-current-hp session) 2)))
       (delve-set-message session "you eat a ration.")
       (delve-sound session :pickup-sound 0.42)
       (delve-close-inventory session)))
    (:scroll
     (when (plusp (delve-state session "scrolls" 0))
       (decf (delve-state session "scrolls"))
       (setf (delve-state session "mapped") t)
       (delve-set-message session "the map fills in this floor.")
       (delve-sound session :pickup-sound 0.42)
       (delve-close-inventory session)))
    (:dig
     (if (plusp (delve-state session "digs" 0))
         (let ((broken (delve-dig-around session)))
           (if (plusp broken)
               (progn
                 (decf (delve-state session "digs"))
                 (delve-set-message session "your pick opens the wall.")
                 (delve-sound session :hit-sound 0.5))
               (delve-set-message session "no wall close enough to break."))
           (delve-close-inventory session))
         (progn
           (delve-set-message session "your digs are spent.")
           (delve-close-inventory session))))
    (t
     (delve-set-message session "pack closed.")
     (delve-close-inventory session))))

(defun update-delve-inventory-menu (session)
  (let ((actions (delve-inventory-actions session))
        (direction (delve-menu-direction)))
    (when direction
      (setf (delve-state session "inventory-index")
            (mod (+ (delve-state session "inventory-index" 0)
                    direction)
                 (length actions)))
      (delve-sound session :menu-sound 0.24))
    (cond
      ((or (is-key-pressed-p +key-i+)
           (is-key-pressed-p +key-tab+)
           (is-key-pressed-p +key-escape+))
       (delve-close-inventory session))
      ((confirm-pressed-p)
       (delve-use-inventory-action
        session
        (delve-selected-inventory-action session))))))

(defun update-delve-crawl (session node)
  (cond
    ((or (is-key-pressed-p +key-i+)
         (is-key-pressed-p +key-tab+))
     (setf (delve-state session "phase") :inventory)
     (delve-sound session :menu-sound 0.24))
    (t
     (multiple-value-bind (dx dy) (delve-step-input)
       (when dx
         (delve-take-step session node dx dy))))))

(defmethod minigame-session-update ((session rogue-delve-session) node dt)
  (declare (ignore dt))
  (case (delve-state session "phase" :class)
    (:class
     (update-delve-class-menu session))
    (:inventory
     (update-delve-inventory-menu session))
    (t
     (update-delve-crawl session node))))

(register-minigame-session-kind :rogue-delve 'rogue-delve-session)
