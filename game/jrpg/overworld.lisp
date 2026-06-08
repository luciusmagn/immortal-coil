(in-package #:immortal-coil)

(defconstant +jrpg-overworld-tile-size+ 30)
(defconstant +jrpg-overworld-left+ 250)
(defconstant +jrpg-overworld-top+ 160)

(defparameter *jrpg-overworld-map*
  #("................"
    "...^^^^........."
    "..^....^.....T.."
    "..^....^........"
    ".V...B....!!...."
    ".....R.........."
    "................"))

(defvar *jrpg-overworld* nil)

(defstruct jrpg-overworld
  (node-id *runtime-fallback-node-id*)
  (x       1)
  (y       4)
  (steps   0)
  (message "walk north and east. arrows or wasd move."))

(defun jrpg-overworld-width ()
  (length (aref *jrpg-overworld-map* 0)))

(defun jrpg-overworld-height ()
  (length *jrpg-overworld-map*))

(defun make-fresh-jrpg-overworld (node)
  (jrpg-init-state)
  (make-jrpg-overworld :node-id (node-id node)
                       :x 1
                       :y 4
                       :steps 0
                       :message "walk north and east. arrows or wasd move."))

(defun ensure-jrpg-overworld (node)
  (unless (and *jrpg-overworld*
               (equal (jrpg-overworld-node-id *jrpg-overworld*)
                      (node-id node)))
    (setf *jrpg-overworld* (make-fresh-jrpg-overworld node)))
  *jrpg-overworld*)

(defun jrpg-overworld-cell (x y)
  (if (and (<= 0 x)
           (< x (jrpg-overworld-width))
           (<= 0 y)
           (< y (jrpg-overworld-height)))
      (char (aref *jrpg-overworld-map* y) x)
      #\^))

(defun jrpg-overworld-passable-p (cell)
  (not (char= cell #\^)))

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

(defun jrpg-overworld-tile-message (cell)
  (case cell
    (#\V "the village gate is already behind you.")
    (#\B "the bridge guard salutes too early.")
    (#\R "the road sign says NORTH TOWER.")
    (#\T "the tower is still too far to touch.")
    (#\! "the grass shakes.")
    (t "the road is bright and empty.")))

(defun jrpg-record-overworld-cell (cell)
  (case cell
    (#\B (setf (jrpg-value "jrpg-crossed-bridge") t
               (jrpg-value "jrpg-route") "bridge road"))
    (#\R (setf (jrpg-value "jrpg-read-road-sign") t
               (jrpg-value "jrpg-route") "north road"))
    (#\T (setf (jrpg-value "jrpg-saw-tower") t))
    (#\! (setf (jrpg-value "jrpg-last-terrain") "grass"))))

(defun jrpg-overworld-finish (node)
  (setf *jrpg-overworld* nil)
  (jump-to-dialog-target (node-success-target node)))

(defun jrpg-overworld-move (node game dx dy)
  (let* ((next-x (+ (jrpg-overworld-x game) dx))
         (next-y (+ (jrpg-overworld-y game) dy))
         (cell (jrpg-overworld-cell next-x next-y)))
    (if (jrpg-overworld-passable-p cell)
        (progn
          (setf (jrpg-overworld-x game) next-x
                (jrpg-overworld-y game) next-y
                (jrpg-overworld-message game)
                (jrpg-overworld-tile-message cell))
          (incf (jrpg-overworld-steps game))
          (setf (jrpg-value "jrpg-overworld-steps")
                (jrpg-overworld-steps game))
          (jrpg-record-overworld-cell cell)
          (when (char= cell #\!)
            (jrpg-overworld-finish node)))
        (setf (jrpg-overworld-message game)
              "the mountains block the road."))))

(defun update-jrpg-overworld-minigame (node dt)
  (declare (ignore dt))
  (let ((game (ensure-jrpg-overworld node)))
    (let ((direction (jrpg-overworld-input-direction)))
      (when direction
        (destructuring-bind (dx dy) direction
          (jrpg-overworld-move node game dx dy))))))

(defun jrpg-overworld-screen-x (x)
  (+ +jrpg-overworld-left+
     (* x +jrpg-overworld-tile-size+)))

(defun jrpg-overworld-screen-y (y)
  (+ +jrpg-overworld-top+
     (* y +jrpg-overworld-tile-size+)))

(defun jrpg-overworld-tile-label (cell)
  (case cell
    (#\^ "^")
    (#\V "V")
    (#\B "=")
    (#\R "+")
    (#\T "T")
    (#\! "\"")
    (t ".")))

(defun draw-jrpg-overworld-tile (x y cell)
  (let ((screen-x (jrpg-overworld-screen-x x))
        (screen-y (jrpg-overworld-screen-y y))
        (alpha (if (char= cell #\.) 92 220)))
    (draw-rectangle-outline screen-x
                            screen-y
                            +jrpg-overworld-tile-size+
                            +jrpg-overworld-tile-size+
                            (make-color 255 255 255 52)
                            :thickness 1)
    (draw-centered-text (jrpg-overworld-tile-label cell)
                        (+ screen-x (/ +jrpg-overworld-tile-size+ 2))
                        (+ screen-y (/ +jrpg-overworld-tile-size+ 2))
                        18
                        (make-color 255 255 255 alpha))))

(defun draw-jrpg-overworld-map (game)
  (loop for y from 0 below (jrpg-overworld-height)
        do (loop for x from 0 below (jrpg-overworld-width)
                 do (draw-jrpg-overworld-tile x
                                               y
                                               (jrpg-overworld-cell x y))))
  (draw-centered-text "@"
                      (+ (jrpg-overworld-screen-x (jrpg-overworld-x game))
                         (/ +jrpg-overworld-tile-size+ 2))
                      (+ (jrpg-overworld-screen-y (jrpg-overworld-y game))
                         (/ +jrpg-overworld-tile-size+ 2))
                      22
                      (make-color 255 255 255 255)))

(defun draw-jrpg-overworld-minigame (node color)
  (declare (ignore color))
  (let ((game (ensure-jrpg-overworld node)))
    (draw-jrpg-box 220 132 840 432 208)
    (draw-jrpg-overworld-map game)
    (draw-jrpg-box 250 392 480 92)
    (draw-jrpg-line (jrpg-overworld-message game) 270 414 17)
    (draw-jrpg-line "V village  = bridge  + sign  T tower  \" grass"
                    270
                    444
                    15
                    194)
    (draw-jrpg-box 760 392 260 92)
    (draw-jrpg-line (format nil "steps ~d" (jrpg-overworld-steps game))
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
