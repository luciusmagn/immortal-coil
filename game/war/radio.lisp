;;; war radio minigame
;;;
;;; Late in the war path the player tunes the room radio looking for a
;;; clear band. Tuning toward the quiet spot lowers the static; holding
;;; it there settles the dial. There is no all-clear to find, only the
;;; numbers again; the bleakness lives in the story nodes, not in losing.

(defconstant +war-radio-duration+ 28.0)
(defconstant +war-radio-hold-seconds+ 2.4)
(defconstant +war-radio-band-width+ 0.045)
(defconstant +war-radio-dial-speed+ 0.22)

(defclass war-radio-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor war-radio-elapsed)
   (dial
    :initform 0.5
    :accessor war-radio-dial)
   (target
    :initform 0.5
    :accessor war-radio-target)
   (held
    :initform 0.0
    :accessor war-radio-held)))

(defmethod initialize-instance :after ((session war-radio-session) &key)
  (setf (war-radio-target session)
        (/ (get-random-value 16 84) 100.0)))

(defun war-radio-input ()
  (- (if (or (is-key-down-p +key-right+) (is-key-down-p +key-d+)) 1.0 0.0)
     (if (or (is-key-down-p +key-left+) (is-key-down-p +key-a+)) 1.0 0.0)))

(defun war-radio-noise (session)
  (clamp01 (/ (abs (- (war-radio-dial session) (war-radio-target session)))
              0.5)))

(defmethod minigame-session-update ((session war-radio-session) node dt)
  (incf (war-radio-elapsed session) dt)
  (setf (war-radio-dial session)
        (clamp01 (+ (war-radio-dial session)
                    (* (war-radio-input) +war-radio-dial-speed+ dt))))
  (if (<= (abs (- (war-radio-dial session) (war-radio-target session)))
          +war-radio-band-width+)
      (incf (war-radio-held session) dt)
      (setf (war-radio-held session)
            (max 0.0 (- (war-radio-held session) (* 2.0 dt)))))
  (cond
    ((>= (war-radio-held session) +war-radio-hold-seconds+)
     (setf (session-store-value session "war-found-band") t)
     (finish-minigame-node node (node-success-target node)))
    ((>= (war-radio-elapsed session) +war-radio-duration+)
     (setf (session-store-value session "war-found-band") nil)
     (finish-minigame-node node (node-failure-target node)))))

(defun draw-war-radio-static (session left right y)
  (let* ((noise (war-radio-noise session))
         (elapsed (war-radio-elapsed session))
         (bars 46)
         (step (/ (- right left) bars)))
    (loop for i below bars
          for x = (+ left (* i step))
          for wave = (abs (sin (+ (* i 7.31) (* elapsed 13.0))))
          for height = (+ 2.0 (* wave (+ 4.0 (* 72.0 noise))))
          do (claylib/ll:draw-rectangle (round x)
                                        (round (- y height))
                                        2
                                        (round height)
                                        (claylib::c-ptr
                                         (make-color 255 255 255 96))))))

(defun draw-war-radio-dial (session left right y color)
  (let ((dial-x (+ left (* (war-radio-dial session) (- right left))))
        (hold (clamp01 (/ (war-radio-held session)
                          +war-radio-hold-seconds+))))
    (draw-thick-line-between left y right y
                             (make-color 255 255 255 90)
                             1.0)
    (draw-thick-line-between dial-x (- y 14.0) dial-x (+ y 14.0) color 2.0)
    (when (plusp hold)
      (draw-thick-line-between (- dial-x 18.0)
                               (+ y 26.0)
                               (+ (- dial-x 18.0) (* 36.0 hold))
                               (+ y 26.0)
                               (make-color 255 255 255 200)
                               3.0))))

(defmethod minigame-session-draw ((session war-radio-session) node color)
  (declare (ignore node))
  (let ((left (- +virtual-center-x+ 300.0))
        (right (+ +virtual-center-x+ 300.0))
        (y 420.0))
    (draw-war-radio-static session left right (- y 40.0))
    (draw-war-radio-dial session left right y color)
    (draw-centered-text "a / d or left / right arrows tune"
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))

(register-minigame-session-kind :war-radio 'war-radio-session)
