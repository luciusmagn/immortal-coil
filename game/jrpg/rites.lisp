(in-package #:immortal-coil)

;;; Two small rites of the King-in-Yellow path, as minigames:
;;;   :sign-trace  - copy the Yellow Sign stroke by stroke (watch, then trace).
;;;   :organ-tune  - play the organist's tune; it dies in its third line.
;;; Both are session minigames (state on the instance; input in -update, drawing
;;; in -draw); both are forgiving and resolve to the success target - the point
;;; is the doing, and (for the organ) the failing.


;;; ===========================================================================
;;; THE YELLOW SIGN - trace it. A fixed sequence of axis strokes; the sign
;;; first draws itself (watch), then the player reproduces it with the arrow
;;; keys, in order. Completing it marks you. Wrong keys only wobble the line.
;;; ===========================================================================

;; (direction . length); a jagged sigil when drawn as a connected polyline.
(defparameter *yellow-sign-strokes*
  '((:d . 3) (:r . 4) (:u . 2) (:l . 2) (:d . 3) (:r . 4) (:u . 4)))

(defparameter +sign-trace-unit+ 40)
(defparameter +sign-show-step+ 0.42)   ; seconds per stroke while showing
(defparameter +sign-show-pause+ 0.7)   ; pause between showing and tracing

(defclass sign-trace-session (minigame-session)
  ((phase       :initform :show :accessor sign-phase)   ; :show :input :done
   (shown       :initform 0     :accessor sign-shown)   ; strokes auto-drawn
   (placed      :initform 0     :accessor sign-placed)  ; strokes the player set
   (timer       :initform 0.0   :accessor sign-timer)
   (wobble      :initform 0.0   :accessor sign-wobble)
   (mistakes    :initform 0     :accessor sign-mistakes)
   (done-delay  :initform 0.0   :accessor sign-done-delay)))

(defun sign-dir-delta (dir)
  (ecase dir (:u '(0 -1)) (:d '(0 1)) (:l '(-1 0)) (:r '(1 0))))

(defun sign-trace-vertices ()
  "Grid vertices of the sign polyline, starting at (0,0)."
  (let ((x 0) (y 0) (pts (list '(0 0))))
    (dolist (stroke *yellow-sign-strokes*)
      (destructuring-bind (dx dy) (sign-dir-delta (car stroke))
        (incf x (* dx (cdr stroke)))
        (incf y (* dy (cdr stroke)))
        (push (list x y) pts)))
    (nreverse pts)))

(defun sign-trace-input-dir ()
  (cond ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+)) :u)
        ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+)) :d)
        ((or (is-key-pressed-p +key-left+) (is-key-pressed-p +key-a+)) :l)
        ((or (is-key-pressed-p +key-right+) (is-key-pressed-p +key-d+)) :r)))

(defun sign-trace-succeed (session node)
  (declare (ignore node))
  (setf (sign-phase session) :done
        (sign-done-delay session) 0.8)
  (jrpg-init-state)
  (jrpg-mark-yellow-sign)
  (jrpg-spend-composure 1)
  ;; tracing the Sign into Wilde's register is the Reader's mark and the
  ;; Repairer's signature both
  (jrpg-lean-class :reader 2)
  (jrpg-lean-class :repairer 1)
  (play-jrpg-sound "crown" :volume 0.34))

(defmethod minigame-session-update ((session sign-trace-session) node dt)
  (incf (sign-timer session) dt)
  (when (plusp (sign-wobble session))
    (setf (sign-wobble session) (max 0.0 (- (sign-wobble session) dt))))
  (ecase (sign-phase session)
    (:show
     ;; reveal one stroke per step; once the whole sign is shown, hold for a
     ;; beat, then hand it over to be traced
     (let ((more (< (sign-shown session) (length *yellow-sign-strokes*))))
       (when (>= (sign-timer session) (if more +sign-show-step+ +sign-show-pause+))
         (setf (sign-timer session) 0.0)
         (if more
             (progn (incf (sign-shown session))
                    (play-jrpg-sound "ledger" :volume 0.18))
             (setf (sign-phase session) :input)))))
    (:input
     (let ((dir (sign-trace-input-dir)))
       (when dir
         (let ((want (car (nth (sign-placed session) *yellow-sign-strokes*))))
           (if (eq dir want)
               (progn
                 (incf (sign-placed session))
                 (play-jrpg-sound "coin" :volume 0.22)
                 (when (>= (sign-placed session) (length *yellow-sign-strokes*))
                   (sign-trace-succeed session node)))
               (progn (setf (sign-wobble session) 0.3)
                      (incf (sign-mistakes session))
                      (play-jrpg-sound "hit" :volume 0.22)))))))
    (:done
     (setf (sign-done-delay session) (- (sign-done-delay session) dt))
     (when (<= (sign-done-delay session) 0.0)
       (finish-minigame-node node (node-success-target node))))))

(defun sign-trace-draw-polyline (vertices upto ox oy unit color-ptr thick)
  "Draw the first UPTO segments of the grid polyline at screen origin OX,OY."
  (loop for i from 0 below (min upto (1- (length vertices)))
        for a = (nth i vertices)
        for b = (nth (1+ i) vertices)
        for ax = (+ ox (* (first a) unit))  for ay = (+ oy (* (second a) unit))
        for bx = (+ ox (* (first b) unit))  for by = (+ oy (* (second b) unit))
        for lx = (min ax bx) for ly = (min ay by)
        do (claylib/ll:draw-rectangle
            (round (- lx (/ thick 2))) (round (- ly (/ thick 2)))
            (round (+ (abs (- bx ax)) thick)) (round (+ (abs (- by ay)) thick))
            color-ptr)))

(defmethod minigame-session-draw ((session sign-trace-session) node color)
  (declare (ignore color))
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 232)))
  (let* ((verts (sign-trace-vertices))
         (unit +sign-trace-unit+)
         (minx (reduce #'min verts :key #'first))
         (maxx (reduce #'max verts :key #'first))
         (miny (reduce #'min verts :key #'second))
         (maxy (reduce #'max verts :key #'second))
         (ox (- +virtual-center-x+ (* (/ (+ minx maxx) 2.0) unit)))
         (oy (- +virtual-center-y+ (* (/ (+ miny maxy) 2.0) unit)))
         (jitter (if (plusp (sign-wobble session))
                     (round (* 4 (sin (* (sign-timer session) 60.0)))) 0)))
    ;; ghost of the whole sign, faint
    (sign-trace-draw-polyline verts (length *yellow-sign-strokes*) (+ ox jitter) oy unit
                              (claylib::c-ptr (make-color 255 255 255 40)) 6)
    ;; what is drawn so far, in the Sign's yellow
    (let ((upto (if (eq (sign-phase session) :show) (sign-shown session)
                    (sign-placed session))))
      (sign-trace-draw-polyline verts upto (+ ox jitter) oy unit
                                (claylib::c-ptr (yellow-sign-color 235)) 6))
    ;; a node at the next vertex the player must move toward
    (when (eq (sign-phase session) :input)
      (let ((v (nth (min (sign-placed session) (1- (length verts))) verts)))
        (claylib/ll:draw-rectangle (round (- (+ ox (* (first v) unit)) 5))
                                   (round (- (+ oy (* (second v) unit)) 5))
                                   10 10
                                   (claylib::c-ptr (yellow-sign-color 200)))))
    (draw-centered-text
     (ecase (sign-phase session)
       (:show "the Yellow Sign. watch your hand draw it.")
       (:input "trace it: arrow keys, in order.")
       (:done "it is drawn. it is on you now."))
     +virtual-center-x+ (- oy 40) 20 (make-color 255 255 255 220))))

(register-minigame-session-kind :sign-trace 'sign-trace-session)

(dialog-minigame "jrpg/trace-sign"
                 ""
                 :game :sign-trace
                 :success "jrpg/castaigne"
                 :failure "jrpg/castaigne")


;;; ===========================================================================
;;; THE COURT OF THE DRAGON - the organist's tune. Notes fall to a strike line;
;;; SPACE plays the one crossing it. It is built to DIE in its third line: the
;;; staff cracks, the last notes scatter, and you are handed to the flight no
;;; matter how you played. The failing is canon.
;;; ===========================================================================

;; (strike-time . line); lines 1-2 are playable, line 3 breaks after two notes.
(defparameter *organ-notes*
  '((1.0 . 1) (1.7 . 1) (2.4 . 1) (3.1 . 1)
    (4.1 . 2) (4.8 . 2) (5.5 . 2) (6.2 . 2)
    (7.2 . 3) (7.9 . 3)))

(defparameter +organ-lead+ 1.4)        ; seconds a note is visible before its time
(defparameter +organ-window+ 0.18)     ; hit window around a note's time
(defparameter +organ-break-time+ 8.6)  ; when the third line has died
(defparameter +organ-end-time+ 10.0)

(defclass organ-tune-session (minigame-session)
  ((elapsed :initform 0.0 :accessor organ-elapsed)
   (hits    :initform nil :accessor organ-hits)   ; indices already struck
   (flash   :initform 0.0 :accessor organ-flash)
   (good    :initform 0   :accessor organ-good)
   (done    :initform nil :accessor organ-done)))

(defun organ-strike-y () (+ +virtual-center-y+ 110))
(defun organ-top-y () (- +virtual-center-y+ 80))

(defmethod minigame-session-update ((session organ-tune-session) node dt)
  (incf (organ-elapsed session) dt)
  (when (plusp (organ-flash session))
    (setf (organ-flash session) (max 0.0 (- (organ-flash session) dt))))
  (when (confirm-pressed-p)
    ;; strike the nearest un-hit, still-playable note within the window
    (let ((e (organ-elapsed session)) (best nil) (best-d 1e9))
      (loop for n in *organ-notes* for i from 0
            when (and (not (member i (organ-hits session)))
                      (<= (cdr n) 2)          ; line 3 cannot be played
                      (< (abs (- e (car n))) +organ-window+))
              do (let ((d (abs (- e (car n)))))
                   (when (< d best-d) (setf best-d d best i))))
      (if best
          (progn (push best (organ-hits session))
                 (incf (organ-good session))
                 (setf (organ-flash session) 0.16)
                 (play-jrpg-sound "chime" :volume 0.3))
          (play-jrpg-sound "hit" :volume 0.15))))
  (when (and (not (organ-done session))
             (>= (organ-elapsed session) +organ-end-time+))
    (setf (organ-done session) t)
    (finish-minigame-node node (node-success-target node))))

(defmethod minigame-session-draw ((session organ-tune-session) node color)
  (declare (ignore color))
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 230)))
  (let* ((e (organ-elapsed session))
         (broken (>= e +organ-break-time+))
         (sy (organ-strike-y))
         (ty (organ-top-y))
         (cx +virtual-center-x+)
         (lane 70))
    ;; the strike line (cracks once the tune dies)
    (claylib/ll:draw-rectangle (round (- cx 260)) (round sy) 520 3
                               (claylib::c-ptr (make-color 255 255 255
                                                           (if broken 70 210))))
    ;; falling notes
    (loop for n in *organ-notes* for i from 0
          for tt = (car n) for line = (cdr n)
          for appear = (- tt +organ-lead+)
          when (and (>= e appear) (not (member i (organ-hits session))))
            do (let* ((prog (/ (- e appear) +organ-lead+))
                      (x (+ cx (* (- line 2) lane)
                            ;; line 3 scatters sideways once it breaks
                            (if (and broken (= line 3))
                                (* 90 (sin (* e 6.0))) 0)))
                      (y (+ ty (* prog (- sy ty))))
                      (a (if (and broken (= line 3)) 90 220)))
                 (when (< y (+ sy 40))
                   (claylib/ll:draw-rectangle (round (- x 7)) (round (- y 7)) 14 14
                                              (claylib::c-ptr (make-color 255 255 255 a))))))
    ;; hit flash on the strike line
    (when (plusp (organ-flash session))
      (claylib/ll:draw-rectangle (round (- cx 260)) (round (- sy 4)) 520 11
                                 (claylib::c-ptr (make-color 255 255 255
                                                             (round (* 200 (/ (organ-flash session) 0.16)))))))
    (draw-centered-text
     (cond (broken "the tune dies in its third line.")
           ((< e 3.6) "play the organist's tune. SPACE on the line.")
           ((< e 6.6) "the second line. SPACE on the line.")
           (t "the third line --"))
     cx (- ty 36) 19 (make-color 255 255 255 220))
    (draw-centered-text (format nil "played ~d" (organ-good session))
                        cx (+ sy 40) 16 (make-color 255 255 255 170))))

(register-minigame-session-kind :organ-tune 'organ-tune-session)

(dialog-minigame "jrpg/organ-game"
                 ""
                 :game :organ-tune
                 :success "jrpg/flight"
                 :failure "jrpg/flight")
