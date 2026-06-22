(in-package #:immortal-coil)

;;; The in-city grid — a distinct walk from the inter-place road. Where the
;;; overworld is one winding way to one place, a city is an orthogonal grid of
;;; streets between building blocks, with several LETTERED DOORS, each leading
;;; to its own target. It shares the overworld engine (movement, camera, the
;;; traveller figure, the breadcrumb trail); only generation, the door-finish,
;;; and the rendering differ.
;;;
;;; Used as the night-city HUB: the player chooses which district to enter and
;;; in which order. A door whose story is finished is omitted on the next visit
;;; (its :done flag is set in the store), so the square is never the same twice
;;; — and the crossing door is always open, so a player can leave for Carcosa
;;; early and simply MISS the stories they did not walk into. That is the point.

(defun jrpg-city-door-glyph (spec)
  (let ((g (first spec)))
    (if (stringp g) (char g 0) g)))

(defun jrpg-city-door-open-p (spec)
  "A door (glyph target &key done) is open unless its DONE flag is set."
  (let ((done (getf (cddr spec) :done)))
    (or (null done) (not (jrpg-value done)))))

(defun jrpg-city-parse-doors (specs)
  "Returns (values alist glyph-list) for the OPEN doors only."
  (let ((alist nil) (glyphs nil))
    (dolist (spec specs)
      (when (jrpg-city-door-open-p spec)
        (let ((g (jrpg-city-door-glyph spec)))
          (push (cons g (second spec)) alist)
          (push g glyphs))))
    (values (nreverse alist) (nreverse glyphs))))

(defun jrpg-gen-city (w h door-glyphs)
  "Returns (values rows start-x start-y). An organic city: buildings (#\\#) cut by
avenues at IRREGULAR spacing (so blocks vary in size, not a Bomberman grid) plus
the rim, a few random alleys to break big blocks, lamps (#\\+) on the streets, and
one door per glyph carved into a building face that touches a street."
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
    (flet ((street-p (x y)
             (and (<= 0 x) (< x w) (<= 0 y) (< y h)
                  (member (aref grid y x) '(#\. #\+) :test #'char=))))
      (dolist (g door-glyphs)
        (loop repeat 400
              do (let ((x (get-random-value 1 (- w 2)))
                       (y (get-random-value 1 (- h 2))))
                   (when (and (char= (aref grid y x) #\#)
                              (or (street-p (1- x) y) (street-p (1+ x) y)
                                  (street-p x (1- y)) (street-p x (1+ y))))
                     (setf (aref grid y x) g)
                     (return))))))
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
    (multiple-value-bind (alist glyphs) (jrpg-city-parse-doors specs)
      (multiple-value-bind (rows sx sy) (jrpg-gen-city w h glyphs)
        (make-jrpg-overworld
         :node-id (node-id node)
         :map (coerce rows 'vector)
         :mode :city
         :doors alist
         :finish-glyphs glyphs
         :tile-messages (minigame-config-value node :tile-messages)
         :legend (minigame-config-value node :legend
                                        "walk onto a lettered door.  + lamp")
         :store-prefix (minigame-config-value node :store-prefix "jrpg-city")
         :x sx :y sy
         :encounter-target (minigame-config-value node :encounter-target)
         :encounter-rate (jrpg-overworld-config-int node :encounter-rate 0)
         :message (minigame-config-value
                   node :start-message
                   "the night square. arrows or wasd move; find a lit door."))))))

(defun ensure-jrpg-city (node)
  (ensure-jrpg-overworld-session node #'make-fresh-jrpg-city))

;;; --- city rendering ---

(defun draw-jrpg-city-building (sx sy)
  (let ((s +jrpg-overworld-tile-size+))
    (jrpg-ow-fill (+ sx 1) (+ sy 1) (- s 1) (- s 1) 58)        ; wall
    (jrpg-ow-fill (+ sx 1) (+ sy 1) (- s 1) 3 105)             ; lit eave
    (jrpg-ow-fill (+ sx 6) (+ sy 9) 4 5 130)                   ; a dim window
    (jrpg-ow-fill (+ sx (- s 9)) (+ sy 9) 4 5 130)))

(defun draw-jrpg-city-lamp (cx cy)
  (jrpg-ow-fill (- cx 5) (- cy 5) 10 10 26)                    ; glow
  (jrpg-ow-fill (- cx 2) (- cy 2) 4 4 230))                    ; flame

(defun draw-jrpg-city-door (cell cx cy)
  "A lit doorway in a building face, with its letter — the way on."
  (let ((s +jrpg-overworld-tile-size+))
    (jrpg-ow-fill (- cx (/ s 2) -1) (- cy (/ s 2) -1) (- s 2) (- s 2) 58)
    (jrpg-ow-fill (- cx 5) (- cy 8) 10 16 150)                 ; the lit opening
    (draw-rectangle-outline (- cx 6) (- cy 9) 12 18
                            (make-color 255 255 255 235) :thickness 1)
    (draw-centered-text (string cell) cx (+ cy 1) 16
                        (make-color 0 0 0 255))))

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
                              ((char= cell #\#) (draw-jrpg-city-building sx sy))
                              ((char= cell #\+) (draw-jrpg-city-lamp cx cy))
                              ((char= cell #\.) nil)
                              (t (draw-jrpg-city-door cell cx cy)))))))))

(defun update-jrpg-city-minigame (node dt)
  (declare (ignore dt))
  (jrpg-overworld-step node (ensure-jrpg-city node)))

(defun draw-jrpg-city-minigame (node color)
  (declare (ignore color))
  (jrpg-overworld-render-frame (ensure-jrpg-city node) #'draw-jrpg-city-map))

(dialog-minigame-kind :jrpg-city
                      :update #'update-jrpg-city-minigame
                      :draw #'draw-jrpg-city-minigame)
