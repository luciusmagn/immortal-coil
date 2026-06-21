;;; rogue delve rendering

(defparameter *delve-legend-entries*
  '((#\% "stairs")
    (#\* "chalk")
    (#\: "food")
    (#\! "potion")
    (#\? "scroll")
    (#\, "bottom")
    (#\b "bat")
    (#\g "goblin")
    (#\o "orc")
    (#\M "hunter")
    (#\^ "trap")
    (#\= "ring")
    (#\) "weapon")
    (#\] "armor")
    (#\/ "staff")))

(defparameter *delve-legend-hidden-glyphs* '(#\@ #\#))

(defconstant +delve-hud-min-width+ 520.0)
(defconstant +delve-hud-padding-x+ 18.0)
(defconstant +delve-hud-edge-margin+ 24.0)
(defconstant +delve-hud-status-size+ 16)
(defconstant +delve-hud-controls-size+ 15)

(defun delve-cell-glyph (session floor-index x y)
  (let ((glyph (delve-glyph-at session x y)))
    (cond
      ((and (delve-item-p glyph)
            (delve-picked-p session floor-index x y))
       #\.)
      ((and (eql glyph #\^)
            (delve-picked-p session floor-index x y))
       #\.)
      ((and (delve-monster-p glyph)
            (delve-killed-p session floor-index x y))
       #\.)
      ((or (eql glyph #\>) (eql glyph #\<))
       +delve-display-stairs-glyph+)
      ((eql glyph #\$)
       +delve-goal-glyph+)
      ((delve-monster-p glyph)
       #\.)
      ((or (eql glyph #\@) (eql glyph #\m))
       #\.)
      (t glyph))))

(defun delve-visible-cell-p (session x y)
  (let ((distance (max (abs (- x (delve-state session "x" 1)))
                       (abs (- y (delve-state session "y" 1))))))
    (or (<= distance (delve-player-sight session))
        (and (delve-state session "mapped")
             (member (delve-glyph-at session x y)
                     '(#\# #\< #\> #\, #\$)
                     :test #'eql)))))

(defun delve-cell-alpha (session x y)
  (let ((distance (max (abs (- x (delve-state session "x" 1)))
                       (abs (- y (delve-state session "y" 1))))))
    (if (<= distance (delve-player-sight session))
        (max 55 (round (* 240 (- 1.0 (* 0.10 distance)))))
        70)))

(defun draw-delve-glyph (glyph center-x center-y alpha)
  (draw-centered-text (string glyph)
                      center-x
                      center-y
                      +delve-glyph-size+
                      (make-color 255 255 255 alpha)))

(defun delve-hud-left (map-left map-width hud-width)
  (let ((center (+ map-left (/ map-width 2.0))))
    (min (- +virtual-width+ hud-width +delve-hud-edge-margin+)
         (max +delve-hud-edge-margin+
              (- center (/ hud-width 2.0))))))

(defun delve-hud-width (map-width lines)
  (max map-width
       +delve-hud-min-width+
       (+ (* 2 +delve-hud-padding-x+)
          (loop for line in lines
                maximize (text-width line +delve-hud-status-size+)))))

(defun draw-delve-hud (session left top width height)
  (let* ((hud-top (min (+ top height +delve-hud-gap+)
                       (- +virtual-height+ +delve-hud-height+ 28.0)))
         (class (delve-class session))
         (status-a (format nil "~a  hp ~d/~d  depth ~d"
                           (delve-class-label class)
                           (delve-current-hp session)
                           (delve-max-hp session)
                           (1+ (delve-floor-index session))))
         (status-b (format nil "food ~d  scroll ~d  mark ~d  xp ~d~@[  dig ~d~]"
                           (delve-state session "rations" 0)
                           (delve-state session "scrolls" 0)
                           (delve-state session "marks" 0)
                           (delve-state session "xp" 0)
                           (let ((digs (delve-state session "digs" 0)))
                             (when (plusp digs) digs))))
         (message (delve-state session "message" "move carefully."))
         (controls "wasd/arrows move   i pack   move onto % stairs")
         (hud-width (delve-hud-width width
                                     (list message
                                           status-a
                                           status-b
                                           controls)))
         (hud-left (delve-hud-left left width hud-width))
         (text-left (+ hud-left +delve-hud-padding-x+))
         (color (make-color 255 255 255 190)))
    (claylib/ll:draw-rectangle (round hud-left)
                               (round hud-top)
                               (round hud-width)
                               (round +delve-hud-height+)
                               (claylib::c-ptr
                                (make-color 0 0 0 235)))
    (draw-rectangle-outline hud-left
                            hud-top
                            hud-width
                            +delve-hud-height+
                            (make-color 255 255 255 155)
                            :thickness 1)
    (draw-text-at message
                  text-left
                  (+ hud-top 13)
                  +delve-hud-status-size+
                  (make-color 255 255 255 220))
    (draw-text-at status-a text-left (+ hud-top 40) +delve-hud-status-size+ color)
    (draw-text-at status-b text-left (+ hud-top 64) +delve-hud-status-size+ color)
    (draw-text-at controls
                  text-left
                  (+ hud-top 91)
                  +delve-hud-controls-size+
                  color)))

(defun draw-delve-legend-entry (entry x y color)
  (destructuring-bind (glyph label) entry
    (draw-text-at (string glyph) x y 17 color)
    (draw-text-at label (+ x 28) y 15 color)))

(defun delve-legend-glyph-p (glyph)
  (and (not (member glyph *delve-legend-hidden-glyphs* :test #'eql))
       (assoc glyph *delve-legend-entries* :test #'eql)))

(defun delve-visible-legend-glyphs (session)
  (let* ((grid (delve-floor-grid session))
         (floor-index (delve-floor-index session))
         (glyphs nil))
    (flet ((record-glyph (glyph)
             (when (delve-legend-glyph-p glyph)
               (pushnew glyph glyphs :test #'eql))))
      (loop for y below (length grid)
            do (loop for x below (length (aref grid y))
                     when (delve-visible-cell-p session x y)
                       do (record-glyph
                           (delve-cell-glyph session floor-index x y))
                          (when (and (delve-state session "hunter")
                                     (= x (delve-state session "hunter-x"))
                                     (= y (delve-state session "hunter-y")))
                            (record-glyph #\M))))
      ;; live monsters draw from their own list (the grid cell shows floor),
      ;; so record the visible ones too or the legend never names them
      (dolist (mon (delve-floor-monsters session floor-index))
        (when (delve-visible-cell-p session (first mon) (second mon))
          (record-glyph (third mon)))))
    glyphs))

(defun delve-visible-legend-entries (session)
  (let ((glyphs (delve-visible-legend-glyphs session)))
    (remove-if-not (lambda (entry)
                     (member (first entry) glyphs :test #'eql))
                   *delve-legend-entries*)))

(defun draw-delve-legend (session left top width)
  (let ((entries (delve-visible-legend-entries session)))
    (when entries
      (let* ((panel-left (+ left width 32.0))
             (panel-top top)
             (panel-width 166.0)
             (row-height 19.0)
             (panel-height (+ 38.0 (* row-height (length entries))))
             (color (make-color 255 255 255 172)))
        (claylib/ll:draw-rectangle (round panel-left)
                                   (round panel-top)
                                   (round panel-width)
                                   (round panel-height)
                                   (claylib::c-ptr
                                    (make-color 0 0 0 218)))
        (draw-rectangle-outline panel-left
                                panel-top
                                panel-width
                                panel-height
                                (make-color 255 255 255 118)
                                :thickness 1)
        (draw-text-at "LEGEND"
                      (+ panel-left 16)
                      (+ panel-top 10)
                      14
                      (make-color 255 255 255 155))
        (loop for entry in entries
              for row from 0
              for y = (+ panel-top 34 (* row row-height))
              while (< (+ y 17) (+ panel-top panel-height))
              do (draw-delve-legend-entry entry
                                          (+ panel-left 16)
                                          y
                                          color))))))

(defun draw-delve-map (session)
  (let* ((grid (delve-floor-grid session))
         (floor-index (delve-floor-index session))
         (px (delve-state session "x" 1))
         (py (delve-state session "y" 1))
         (rows (length grid))
         (cols (length (aref grid 0)))
         (left (- +virtual-center-x+ (/ (* cols +delve-cell+) 2.0)))
         (top (- +delve-map-center-y+ (/ (* rows +delve-cell+) 2.0))))
    (loop for y below rows
          do (loop for x below (length (aref grid y))
                   when (delve-visible-cell-p session x y)
                     do (let* ((cell-left (+ left (* x +delve-cell+)))
                               (cell-top (+ top (* y +delve-cell+)))
                               (center-x (+ cell-left (/ +delve-cell+ 2.0)))
                               (center-y (+ cell-top (/ +delve-cell+ 2.0)))
                               (alpha (delve-cell-alpha session x y)))
                          (draw-delve-glyph
                           (delve-cell-glyph session floor-index x y)
                           center-x center-y alpha)
                          (when (and (delve-state session "hunter")
                                     (= x (delve-state session "hunter-x"))
                                     (= y (delve-state session "hunter-y")))
                            (draw-delve-glyph #\M center-x center-y alpha))
                          (when (and (= x px) (= y py))
                            (draw-delve-glyph #\@ center-x center-y 255)))))
    (loop for mon in (delve-floor-monsters session floor-index)
          for mx = (first mon)
          for my = (second mon)
          when (delve-visible-cell-p session mx my)
            do (draw-delve-glyph (third mon)
                                 (+ left (* mx +delve-cell+) (/ +delve-cell+ 2.0))
                                 (+ top (* my +delve-cell+) (/ +delve-cell+ 2.0))
                                 (delve-cell-alpha session mx my)))
    (draw-delve-hud session
                    left
                    top
                    (* cols +delve-cell+)
                    (* rows +delve-cell+))
    (draw-delve-legend session
                       left
                       top
                       (* cols +delve-cell+))))

(defun draw-delve-class-option (session class index y color)
  (let* ((selected-p (= index (delve-state session "class-index" 0)))
         (marker (if selected-p "@" " "))
         (line (format nil "~a ~a  hp ~d  sight ~d  atk ~d"
                       marker
                       (delve-class-label class)
                       (getf class :hp)
                       (getf class :sight)
                       (getf class :attack)))
         (desc (getf class :description "")))
    (draw-centered-text line +virtual-center-x+ y 22 color)
    (draw-centered-text desc
                        +virtual-center-x+
                        (+ y 28)
                        14
                        (make-color 255 255 255 (if selected-p 185 115)))))

(defun draw-delve-class-menu (session)
  (let* ((color (make-color 255 255 255 235))
         (count (length *delve-classes*))
         (step 64)
         (start-y 250)
         (hint-y (+ start-y (* count step) 14)))
    (draw-centered-text "CHOOSE A CLASS"
                        +virtual-center-x+
                        202
                        26
                        color)
    (loop for class in *delve-classes*
          for index from 0
          do (draw-delve-class-option session
                                      class
                                      index
                                      (+ start-y (* index step))
                                      color))
    (draw-centered-text "wasd/arrows select   enter confirm"
                        +virtual-center-x+
                        hint-y
                        15
                        (make-color 255 255 255 170))))

(defun delve-inventory-label (action)
  (case action
    (:ration "food ration")
    (:scroll "map scroll")
    (:dig "pick")
    (t "close pack")))

(defun delve-inventory-glyph (action)
  (case action
    (:ration +delve-ration-glyph+)
    (:scroll #\?)
    (:dig #\#)
    (t #\space)))

(defun delve-inventory-count (session action)
  (case action
    (:ration (delve-state session "rations" 0))
    (:scroll (delve-state session "scrolls" 0))
    (:dig (delve-state session "digs" 0))
    (t nil)))

(defun delve-inventory-description (action)
  (case action
    (:ration "eat: restore 2 hp")
    (:scroll "read: reveal this floor")
    (:dig "break the walls around you")
    (t "return to the map")))

(defun delve-inventory-line (session action index)
  (let ((count (delve-inventory-count session action))
        (letter (code-char (+ (char-code #\a) index))))
    (if count
        (format nil "~c) ~c  ~a x~d"
                letter
                (delve-inventory-glyph action)
                (delve-inventory-label action)
                count)
        (format nil "~c)    ~a"
                letter
                (delve-inventory-label action)))))

(defun draw-delve-inventory-menu (session)
  (let* ((actions (delve-inventory-actions session))
         (left (- +virtual-center-x+ 280))
         (top 184)
         (width 560)
         (height 340)
         (color (make-color 255 255 255 235)))
    (claylib/ll:draw-rectangle (round left)
                               (round top)
                               (round width)
                               (round height)
                               (claylib::c-ptr
                                (make-color 0 0 0 248)))
    (draw-rectangle-outline left top width height color :thickness 2)
    (draw-centered-text "PACK"
                        +virtual-center-x+
                        (+ top 42)
                        25
                        color)
    (loop for action in actions
          for index from 0
          for selected-p = (= index (delve-state session "inventory-index" 0))
          for y = (+ top 98 (* index 64))
          do (progn
               (draw-text-at
                (format nil "~a ~a"
                        (if selected-p ">" " ")
                        (delve-inventory-line session action index))
                (+ left 44)
                y
                20
                color)
               (draw-text-at (delve-inventory-description action)
                             (+ left 78)
                             (+ y 27)
                             14
                             (make-color 255 255 255
                                         (if selected-p 175 120)))))
    (draw-centered-text "enter use   esc/i close"
                        +virtual-center-x+
                        (- (+ top height) 34)
                        14
                        (make-color 255 255 255 165))))

(defmethod minigame-session-draw ((session rogue-delve-session) node color)
  (declare (ignore node color))
  (case (delve-state session "phase" :class)
    (:class
     (draw-delve-class-menu session))
    (:inventory
     (draw-delve-map session)
     (draw-delve-inventory-menu session))
    (t
     (draw-delve-map session))))
