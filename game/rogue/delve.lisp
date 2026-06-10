;;; rogue delve minigame
;;;
;;; A reusable turn-based crawl over config-supplied maps, drawn with
;;; tiny black-and-white pixel sprites and a short torch radius. All
;;; progress lives in the dialog store under a config prefix, so the
;;; autosave keeps mid-delve position across restarts and a node can
;;; resume a long expedition where it left off.
;;;
;;; Map glyphs: # wall, . floor, @ spawn, * mark, m hunter,
;;; > stairs down, < stairs up (leaving on floor one), $ the goal.
;;;
;;; Config: :maps (list of floors, each a list of row strings),
;;; :save-prefix, :leave-target, :caught-target.

(defconstant +delve-cell+ 46)
(defconstant +delve-pixel+ 8)
(defconstant +delve-sight+ 4)

(defparameter *delve-sprites*
  '((#\@ . ("..#.."
            ".###."
            "#.#.#"
            ".###."
            ".#.#."))
    (#\m . (".#.#."
            "#####"
            "##.##"
            "#####"
            "#...#"))
    (#\# . ("#####"
            "##.##"
            "#####"
            "#.###"
            "#####"))
    (#\* . ("..#.."
            ".###."
            "##.##"
            ".###."
            "..#.."))
    (#\> . ("#####"
            ".###."
            ".###."
            "..#.."
            "..#.."))
    (#\< . ("..#.."
            "..#.."
            ".###."
            ".###."
            "#####"))
    (#\$ . ("#####"
            "#...#"
            "#.#.#"
            "#...#"
            "#####"))
    (#\. . ("....."
            "....."
            "..#.."
            "....."
            "....."))))

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

(defun delve-floor-grid (session)
  (aref (delve-floors session)
        (min (delve-state session "floor" 0)
             (1- (length (delve-floors session))))))

(defun delve-glyph-at (session x y)
  (let ((grid (delve-floor-grid session)))
    (if (and (>= y 0) (< y (length grid))
             (>= x 0) (< x (length (aref grid y))))
        (aref (aref grid y) x)
        #\#)))

(defun delve-picked-p (session floor x y)
  (member (list floor x y) (delve-state session "picked")
          :test #'equal))

(defun delve-walkable-p (session x y)
  (not (eql (delve-glyph-at session x y) #\#)))

(defun delve-place-hunter (session floor-index)
  (let ((grid (aref (delve-floors session) floor-index)))
    (multiple-value-bind (x y) (delve-find-glyph grid #\m)
      (if (eql (delve-glyph-at session x y) #\m)
          (setf (delve-state session "hunter-x") x
                (delve-state session "hunter-y") y
                (delve-state session "hunter") t)
          (setf (delve-state session "hunter") nil)))))

(defmethod initialize-instance :after ((session rogue-delve-session) &key)
  (let ((maps (session-config-value session :maps)))
    (setf (delve-floors session)
          (coerce (mapcar #'delve-parse-floor maps) 'vector))
    (unless (delve-state session "started")
      (multiple-value-bind (x y)
          (delve-find-glyph (aref (delve-floors session) 0) #\@)
        (with-batched-store-saves ()
          (setf (delve-state session "started") t
                (delve-state session "floor") 0
                (delve-state session "x") x
                (delve-state session "y") y
                (delve-state session "marks") 0
                (delve-state session "picked") nil)
          (delve-place-hunter session 0))))))

(defun delve-switch-floor (session new-floor arrival-glyph)
  (let ((grid (aref (delve-floors session) new-floor)))
    (multiple-value-bind (x y) (delve-find-glyph grid arrival-glyph)
      (setf (delve-state session "floor") new-floor
            (delve-state session "x") x
            (delve-state session "y") y)
      (delve-place-hunter session new-floor))))

(defun delve-hunter-step (session)
  (when (delve-state session "hunter")
    (let* ((hx (delve-state session "hunter-x"))
           (hy (delve-state session "hunter-y"))
           (px (delve-state session "x"))
           (py (delve-state session "y"))
           (distance (max (abs (- px hx)) (abs (- py hy)))))
      (when (<= distance 6)
        (let* ((step-x (+ hx (cond ((< hx px) 1) ((> hx px) -1) (t 0))))
               (step-y (+ hy (cond ((< hy py) 1) ((> hy py) -1) (t 0)))))
          (cond
            ((and (/= step-x hx)
                  (delve-walkable-p session step-x hy))
             (setf (delve-state session "hunter-x") step-x))
            ((and (/= step-y hy)
                  (delve-walkable-p session hx step-y))
             (setf (delve-state session "hunter-y") step-y))))))))

(defun delve-hunter-caught-p (session)
  (and (delve-state session "hunter")
       (= (delve-state session "hunter-x") (delve-state session "x"))
       (= (delve-state session "hunter-y") (delve-state session "y"))))

(defun delve-finish (session node outcome-key fallback)
  (setf (delve-state session "started") nil)
  (finish-minigame-node node
                        (or (session-config-value session outcome-key)
                            fallback)))

(defun delve-take-step (session node dx dy)
  "One full turn: the player steps, pickups and stairs resolve, the
hunter answers. Returns nil when the turn ended the delve."
  (let* ((x (+ (delve-state session "x") dx))
         (y (+ (delve-state session "y") dy)))
    (unless (delve-walkable-p session x y)
      (return-from delve-take-step t))
    (with-batched-store-saves ()
      (setf (delve-state session "x") x
            (delve-state session "y") y)
      (let ((glyph (delve-glyph-at session x y))
            (floor-index (delve-state session "floor" 0)))
        (when (and (eql glyph #\*)
                   (not (delve-picked-p session floor-index x y)))
          (push (list floor-index x y) (delve-state session "picked"))
          (incf (delve-state session "marks")))
        (cond
          ((eql glyph #\$)
           (delve-finish session node :goal-target
                         (node-success-target node))
           (return-from delve-take-step nil))
          ((eql glyph #\>)
           (delve-switch-floor session (1+ floor-index) #\<))
          ((eql glyph #\<)
           (if (zerop floor-index)
               (progn
                 (delve-finish session node :leave-target
                               (node-failure-target node))
                 (return-from delve-take-step nil))
               (delve-switch-floor session (1- floor-index) #\>)))
          (t
           (delve-hunter-step session)
           (when (delve-hunter-caught-p session)
             (delve-finish session node :caught-target
                           (node-failure-target node))
             (return-from delve-take-step nil)))))
      t)))

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

(defmethod minigame-session-update ((session rogue-delve-session) node dt)
  (declare (ignore dt))
  (multiple-value-bind (dx dy) (delve-step-input)
    (when dx
      (delve-take-step session node dx dy))))

(defun delve-draw-sprite (glyph left top alpha)
  (let ((bitmap (rest (assoc glyph *delve-sprites*))))
    (when bitmap
      (loop for row in bitmap
            for py from 0
            do (loop for cell across row
                     for px from 0
                     when (eql cell #\#)
                       do (claylib/ll:draw-rectangle
                           (round (+ left 3 (* px +delve-pixel+)))
                           (round (+ top 3 (* py +delve-pixel+)))
                           +delve-pixel+
                           +delve-pixel+
                           (claylib::c-ptr
                            (make-color 255 255 255 alpha))))))))

(defun delve-cell-glyph (session floor-index x y)
  (let ((glyph (delve-glyph-at session x y)))
    (cond
      ((and (eql glyph #\*)
            (delve-picked-p session floor-index x y))
       #\.)
      ((or (eql glyph #\@) (eql glyph #\m))
       #\.)
      (t glyph))))

(defmethod minigame-session-draw ((session rogue-delve-session) node color)
  (declare (ignore node))
  (let* ((grid (delve-floor-grid session))
         (floor-index (delve-state session "floor" 0))
         (px (delve-state session "x" 1))
         (py (delve-state session "y" 1))
         (rows (length grid))
         (cols (length (aref grid 0)))
         (left (- +virtual-center-x+ (/ (* cols +delve-cell+) 2.0)))
         (top (- 384 (/ (* rows +delve-cell+) 2.0))))
    (loop for y below rows
          do (loop for x below (length (aref grid y))
                   for distance = (max (abs (- x px)) (abs (- y py)))
                   when (<= distance +delve-sight+)
                     do (let ((alpha (round (* 235 (- 1.0 (* 0.18 distance)))))
                              (cell-left (+ left (* x +delve-cell+)))
                              (cell-top (+ top (* y +delve-cell+))))
                          (delve-draw-sprite
                           (delve-cell-glyph session floor-index x y)
                           cell-left cell-top (max 40 alpha))
                          (when (and (delve-state session "hunter")
                                     (= x (delve-state session "hunter-x"))
                                     (= y (delve-state session "hunter-y")))
                            (delve-draw-sprite #\m cell-left cell-top
                                               (max 40 alpha)))
                          (when (and (= x px) (= y py))
                            (delve-draw-sprite #\@ cell-left cell-top 255)))))
    (draw-centered-text (format nil "floor ~d   marks ~d"
                                (1+ floor-index)
                                (delve-state session "marks" 0))
                        +virtual-center-x+
                        96
                        16
                        (make-color 255 255 255 170))
    (draw-centered-text "wasd or arrows step"
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))

(register-minigame-session-kind :rogue-delve 'rogue-delve-session)
