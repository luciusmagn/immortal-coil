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

(defvar *war-radio* nil)

(defstruct war-radio
  (node-id   *runtime-fallback-node-id* :type dialog-id)
  (elapsed   0.0 :type seconds)
  (dial      0.5 :type scalar)
  (target    0.5 :type scalar)
  (held      0.0 :type seconds))

(defun make-fresh-war-radio (node)
  (make-war-radio :node-id (node-id node)
                  :elapsed 0.0
                  :dial 0.5
                  :target (/ (get-random-value 16 84) 100.0)
                  :held 0.0))

(defun ensure-war-radio (node)
  (unless (and *war-radio*
               (equal (war-radio-node-id *war-radio*)
                      (node-id node)))
    (setf *war-radio* (make-fresh-war-radio node)))
  *war-radio*)

(defun war-radio-input ()
  (- (if (or (is-key-down-p +key-right+) (is-key-down-p +key-d+)) 1.0 0.0)
     (if (or (is-key-down-p +key-left+) (is-key-down-p +key-a+)) 1.0 0.0)))

(defun war-radio-noise (game)
  (clamp01 (/ (abs (- (war-radio-dial game) (war-radio-target game)))
              0.5)))

(defun finish-war-radio (target)
  (setf *war-radio* nil)
  (jump-to-dialog-target target))

(defun update-war-radio-node (node dt)
  (let ((game (ensure-war-radio node)))
    (incf (war-radio-elapsed game) dt)
    (setf (war-radio-dial game)
          (clamp01 (+ (war-radio-dial game)
                      (* (war-radio-input) +war-radio-dial-speed+ dt))))
    (if (<= (abs (- (war-radio-dial game) (war-radio-target game)))
            +war-radio-band-width+)
        (incf (war-radio-held game) dt)
        (setf (war-radio-held game) (max 0.0 (- (war-radio-held game)
                                                (* 2.0 dt)))))
    (cond
      ((>= (war-radio-held game) +war-radio-hold-seconds+)
       (setf (dialog-value "war-found-band") t)
       (finish-war-radio (node-success-target node)))
      ((>= (war-radio-elapsed game) +war-radio-duration+)
       (setf (dialog-value "war-found-band") nil)
       (finish-war-radio (node-failure-target node))))))

(defun draw-war-radio-static (game left right y)
  (let* ((noise (war-radio-noise game))
         (elapsed (war-radio-elapsed game))
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

(defun draw-war-radio-dial (game left right y color)
  (let ((dial-x (+ left (* (war-radio-dial game) (- right left))))
        (hold (clamp01 (/ (war-radio-held game) +war-radio-hold-seconds+))))
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

(defun draw-war-radio-node (node color)
  (let* ((game (ensure-war-radio node))
         (left (- +virtual-center-x+ 300.0))
         (right (+ +virtual-center-x+ 300.0))
         (y 420.0))
    (draw-war-radio-static game left right (- y 40.0))
    (draw-war-radio-dial game left right y color)
    (draw-centered-text "a / d or left / right arrows tune"
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))

(dialog-minigame-kind :war-radio
                      :update #'update-war-radio-node
                      :draw #'draw-war-radio-node)
