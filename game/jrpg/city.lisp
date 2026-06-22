(in-package #:immortal-coil)

;;; The in-city grid - a distinct walk from the inter-place road. A city is
;;; blocks of connected houses with streets between; you enter a NAMED DOORWAY
;;; to reach a district, and leave by the GATE on the city's edge. It shares the
;;; overworld engine (movement, camera, the traveller, the trail); only
;;; generation, the door-finish, and the rendering differ.
;;;
;;; The night-city HUB: pick which district to enter and in which order. A door
;;; whose story is finished is dropped on the next visit (its :done flag is
;;; set), so the city is never the same twice - and the gate is always open, so
;;; a player can leave for Carcosa early and MISS the stories they skipped.
;;;
;;; A door spec is (glyph target &key name done exit). NAME is the sign over the
;;; doorway; DONE is the store flag that retires it; EXIT t marks the gate, set
;;; on the city's rim instead of a building face.

(defun jrpg-city-door-glyph (spec)
  (let ((g (first spec)))
    (if (stringp g) (char g 0) g)))

(defun jrpg-city-door-open-p (spec)
  (let ((done (getf (cddr spec) :done)))
    (or (null done) (not (jrpg-value done)))))

(defun jrpg-city-door-name (spec)
  (or (getf (cddr spec) :name) (string (jrpg-city-door-glyph spec))))

(defun jrpg-city-door-exit-p (spec)
  (and (getf (cddr spec) :exit) t))

(defun jrpg-city-parse-doors (specs)
  "Returns (values targets names glyphs exit-glyphs) for the OPEN doors:
TARGETS glyph->target, NAMES glyph->name, GLYPHS all open, EXIT-GLYPHS the
rim gates."
  (let ((targets nil) (names nil) (glyphs nil) (exits nil))
    (dolist (spec specs)
      (when (jrpg-city-door-open-p spec)
        (let ((g (jrpg-city-door-glyph spec)))
          (push (cons g (second spec)) targets)
          (push (cons g (jrpg-city-door-name spec)) names)
          (push g glyphs)
          (when (jrpg-city-door-exit-p spec) (push g exits)))))
    (values (nreverse targets) (nreverse names) (nreverse glyphs) (nreverse exits))))

(defun jrpg-gen-city (w h interior-glyphs exit-glyphs)
  "Returns (values rows start-x start-y). Buildings (#\\#) cut by avenues at
irregular spacing plus the rim, alleys to break big blocks, lamps (#\\+) on the
streets, INTERIOR doors carved into building faces, and EXIT gates set on the
top rim (the way out of the city)."
  (let ((grid (make-array (list h w) :initial-element #\#)))
    ;; rim street
    (dotimes (i w) (setf (aref grid 0 i) #\. (aref grid (1- h) i) #\.))
    (dotimes (i h) (setf (aref grid i 0) #\. (aref grid i (1- w)) #\.))
    ;; horizontal avenues at irregular rows (blocks 2-4 tall)
    (let ((y (+ 1 (get-random-value 1 2))))
      (loop while (< y (1- h))
            do (dotimes (xx w) (setf (aref grid y xx) #\.))
               (incf y (get-random-value 3 5))))
    ;; vertical avenues at irregular columns (blocks 2-5 wide)
    (let ((x (+ 1 (get-random-value 1 2))))
      (loop while (< x (1- w))
            do (dotimes (yy h) (setf (aref grid yy x) #\.))
               (incf x (get-random-value 3 6))))
    ;; a few short alleys to break the larger blocks
    (dotimes (i (max 2 (floor (* w h) 70)))
      (let ((ax (get-random-value 1 (- w 2)))
            (ay (get-random-value 1 (- h 2)))
            (len (get-random-value 2 4))
            (horiz (zerop (get-random-value 0 1))))
        (dotimes (k len)
          (let ((px (min (- w 2) (+ ax (if horiz k 0))))
                (py (min (- h 2) (+ ay (if horiz 0 k)))))
            (setf (aref grid py px) #\.)))))
    ;; lamps on some street cells
    (dotimes (i (max 3 (floor (* w h) 42)))
      (let ((lx (get-random-value 1 (- w 2)))
            (ly (get-random-value 1 (- h 2))))
        (when (char= (aref grid ly lx) #\.)
          (setf (aref grid ly lx) #\+))))
    ;; exit gates spread along the top rim - the way out
    (let ((k (length exit-glyphs)))
      (loop for g in exit-glyphs
            for i from 1
            for ex = (max 1 (min (- w 2) (floor (* i w) (1+ k))))
            do (setf (aref grid 0 ex) g)))
    ;; interior doors carved into a building face that touches a street
    (flet ((street-p (x y)
             (and (<= 0 x) (< x w) (<= 0 y) (< y h)
                  (member (aref grid y x) '(#\. #\+) :test #'char=))))
      (dolist (g interior-glyphs)
        (loop repeat 400
              do (let ((x (get-random-value 1 (- w 2)))
                       (y (get-random-value 1 (- h 2))))
                   (when (and (char= (aref grid y x) #\#)
                              (or (street-p (1- x) y) (street-p (1+ x) y)
                                  (street-p x (1- y)) (street-p x (1+ y))))
                     (setf (aref grid y x) g)
                     (return))))))
    ;; start: a street cell low and left
    (let ((sx 1) (sy (- h 2)))
      (block found
        (loop for y from (- h 2) downto 1
              do (loop for x from 1 below (1- w)
                       do (when (char= (aref grid y x) #\.)
                            (setf sx x sy y)
                            (return-from found)))))
      (values (jrpg-gen-rows grid) sx sy))))

(defun make-fresh-jrpg-city (node)
  (jrpg-init-state)
  (let* ((w (jrpg-overworld-config-int node :gen-width 26))
         (h (jrpg-overworld-config-int node :gen-height 13))
         (specs (let ((v (minigame-config-value node :doors)))
                  (if (listp v) v nil))))
    (multiple-value-bind (targets names glyphs exits) (jrpg-city-parse-doors specs)
      (let ((interior (remove-if (lambda (g) (member g exits)) glyphs)))
        (multiple-value-bind (rows sx sy) (jrpg-gen-city w h interior exits)
          (make-jrpg-overworld
           :node-id (node-id node)
           :map (coerce rows 'vector)
           :mode :city
           :doors targets
           :door-names names
           :finish-glyphs glyphs
           :tile-messages (minigame-config-value node :tile-messages)
           :legend (minigame-config-value
                    node :legend
                    "enter a doorway; the gate on the rim is the way on.")
           :store-prefix (minigame-config-value node :store-prefix "jrpg-city")
           :x sx :y sy
           :encounter-target (minigame-config-value node :encounter-target)
           :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
           :message (minigame-config-value
                     node :start-message
                     "the night city. arrows or wasd move; the doorways are signed.")))))))

(defun ensure-jrpg-city (node)
  (ensure-jrpg-overworld-session node #'make-fresh-jrpg-city))

;;; --- city rendering: connected houses, named doorways, a rim gate ---

(defun jrpg-city-building-p (game x y)
  (char= (jrpg-overworld-cell game x y) #\#))

(defun draw-jrpg-city-house-cell (game sx sy mx my)
  "Part of a house: a dark wall, with a lit roof eave and walls drawn only on
sides that face the street - so a whole block reads as one building, and the
inner cells just fill. A window where the wall fronts the street."
  (let* ((s +jrpg-overworld-tile-size+)
         (up (jrpg-city-building-p game mx (1- my)))
         (dn (jrpg-city-building-p game mx (1+ my)))
         (lf (jrpg-city-building-p game (1- mx) my))
         (rt (jrpg-city-building-p game (1+ mx) my)))
    (jrpg-ow-fill sx sy s s 58)                          ; wall fill
    (unless up (jrpg-ow-fill sx sy s 4 168))             ; lit roof eave
    (unless dn (jrpg-ow-fill sx (+ sy s -2) s 2 120)     ; base sill
               (jrpg-ow-fill (+ sx (/ s 2) -3) (+ sy 8) 6 6 150)) ; a window
    (unless lf (jrpg-ow-fill sx sy 2 s 112))             ; left wall
    (unless rt (jrpg-ow-fill (+ sx s -2) sy 2 s 112))))  ; right wall

(defun draw-jrpg-city-lamp (cx cy)
  (jrpg-ow-fill (- cx 5) (- cy 5) 10 10 26)              ; glow
  (jrpg-ow-fill (- cx 2) (- cy 2) 4 4 230))             ; flame

(defun jrpg-door-label-width (name)
  (+ (text-width name 12) 14))

(defun jrpg-draw-door-label (name cx top)
  "A floating name plate: white text in a SOLID black box with a white border,
so the sign reads cleanly over lit roofs."
  (when (and name (plusp (length name)))
    (let* ((w (jrpg-door-label-width name))
           (lx (- cx (/ w 2))))
      (claylib/ll:draw-rectangle (round lx) (round top) (round w) 17
                                 (claylib::c-ptr (make-color 0 0 0 255)))
      (draw-rectangle-outline lx top w 17 (make-color 255 255 255 200) :thickness 1)
      (draw-centered-text name cx (+ top 8) 12 (make-color 255 255 255 240)))))

(defun draw-jrpg-city-door (game sx sy mx my name)
  "A doorway in a building face, or - on the city rim - a wide gate, with a
floating name plate. The plate sits above the door, but drops below it when the
player stands anywhere under its full width, so it never hides the traveller."
  (let* ((s +jrpg-overworld-tile-size+)
         (cx (+ sx (/ s 2)))
         (edge (or (= mx 0) (= my 0)
                   (= mx (1- (jrpg-overworld-width game)))
                   (= my (1- (jrpg-overworld-height game)))))
         ;; how many columns the plate spans on either side of the door, so the
         ;; dodge covers the whole label and not just the door's own tile
         (half-cols (if (and name (plusp (length name)))
                        (ceiling (/ (jrpg-door-label-width name) 2.0) s)
                        0))
         (player-over (and (= (jrpg-overworld-y game) (1- my))
                           (<= (abs (- (jrpg-overworld-x game) mx)) half-cols))))
    (jrpg-ow-fill sx sy s s 58)                          ; the wall it sits in
    (jrpg-ow-fill sx sy s 4 168)                         ; lintel / roof
    (if edge
        (progn                                           ; a city gate (the way out)
          (jrpg-ow-fill (- cx 9) (+ sy 4) 18 (- s 4) 210)
          (jrpg-ow-fill (- cx 7) (+ sy 7) 14 (- s 7) 60))
        (progn                                           ; an interior doorway
          (jrpg-ow-fill (- cx 5) (+ sy 6) 10 (- s 6) 190)
          (jrpg-ow-fill (- cx 3) (+ sy 9) 6 (- s 10) 55)))
    (jrpg-draw-door-label name cx (if player-over (+ sy s 3) (- sy 17)))))

(defun draw-jrpg-city-map (game)
  (multiple-value-bind (cam-x cam-y) (jrpg-overworld-camera game)
    (jrpg-overworld-draw-trail game cam-x cam-y)
    (loop with s = +jrpg-overworld-tile-size+
          for row below +jrpg-overworld-view-rows+
          do (loop for col below +jrpg-overworld-view-cols+
                   for mx = (+ cam-x col)
                   for my = (+ cam-y row)
                   when (and (< mx (jrpg-overworld-width game))
                             (< my (jrpg-overworld-height game)))
                     do (multiple-value-bind (sx sy)
                            (jrpg-overworld-cell-screen col row)
                          (let ((cell (jrpg-overworld-cell game mx my))
                                (cx (+ sx (/ s 2)))
                                (cy (+ sy (/ s 2))))
                            (cond
                              ((char= cell #\#) (draw-jrpg-city-house-cell game sx sy mx my))
                              ((char= cell #\+) (draw-jrpg-city-lamp cx cy))
                              ((char= cell #\.) nil)
                              (t (draw-jrpg-city-door
                                  game sx sy mx my
                                  (cdr (assoc cell (jrpg-overworld-door-names game)
                                              :test #'char=)))))))))))

(defun update-jrpg-city-minigame (node dt)
  (declare (ignore dt))
  (jrpg-overworld-step node (ensure-jrpg-city node)))

(defun draw-jrpg-city-minigame (node color)
  (declare (ignore color))
  (jrpg-overworld-render-frame (ensure-jrpg-city node) #'draw-jrpg-city-map))

(dialog-minigame-kind :jrpg-city
                      :update #'update-jrpg-city-minigame
                      :draw #'draw-jrpg-city-minigame)
