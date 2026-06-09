;;; one-pace/brace minigame
;;;
;;; Someone is forcing the door open from the landing; you brace it shut. The
;;; door creeps open under a rising, shoving force; holding the brace key pushes
;;; it back. Survive until they give up. Modeled on the bundled dream-maze
;;; minigame's state/finish conventions, with a mod-loaded shove sound.

(defconstant +one-pace-brace-duration+ 16.0)
(defconstant +one-pace-brace-push+ 0.86)
(defconstant +one-pace-brace-base-force+ 0.20)
(defconstant +one-pace-brace-force-ramp+ 0.019)
(defconstant +one-pace-brace-shove+ 0.62)

(defvar *one-pace-brace* nil)

(defstruct one-pace-brace
  (node-id  *runtime-fallback-node-id* :type dialog-id)
  (open     0.12 :type scalar)
  (elapsed  0.0 :type seconds)
  (shoving-p nil :type boolean))

(defun make-fresh-one-pace-brace (node)
  (make-one-pace-brace :node-id (node-id node)
                       :open 0.12
                       :elapsed 0.0
                       :shoving-p nil))

(defun ensure-one-pace-brace (node)
  (unless (and *one-pace-brace*
               (equal (one-pace-brace-node-id *one-pace-brace*)
                      (node-id node)))
    (setf *one-pace-brace* (make-fresh-one-pace-brace node)))
  *one-pace-brace*)


;;; Shove sound (loaded once, like the dream-maze audio)

(defparameter *one-pace-strain-path*
  (dialog-asset-pathname "audio/strain.wav"))
(defvar *one-pace-strain-asset* nil)
(defvar *one-pace-strain-sound* nil)
(defvar *one-pace-strain-load-attempted-p* nil)

(defun ensure-one-pace-strain-sound ()
  (unless (or *one-pace-strain-sound*
              *one-pace-strain-load-attempted-p*
              (not (audio-device-ready-p)))
    (setf *one-pace-strain-load-attempted-p* t)
    (let ((asset (make-sound-asset-maybe *one-pace-strain-path*
                                         "one-pace door strain")))
      (when asset
        (setf *one-pace-strain-asset* asset
              *one-pace-strain-sound* (asset asset))
        (setf (volume *one-pace-strain-sound*) 0.0
              (pan *one-pace-strain-sound*) 0.5
              (pitch *one-pace-strain-sound*) 1.0))))
  *one-pace-strain-sound*)

(defun clear-one-pace-strain-audio ()
  (setf *one-pace-strain-asset* nil
        *one-pace-strain-sound* nil
        *one-pace-strain-load-attempted-p* nil))

(defun play-one-pace-strain (loudness)
  (handler-case
      (let ((sound (ensure-one-pace-strain-sound)))
        (when sound
          (setf (volume sound)
                (scaled-sound-volume (* 0.55 (clamp01 loudness)))
                (pitch sound) (+ 0.9 (* 0.18 (clamp01 loudness))))
          (play-sound-maybe sound "one-pace door strain")))
    (error (condition)
      (runtime-warn "one-pace strain sound failed: ~a" condition))))

(register-minigame-reset-hook 'clear-one-pace-strain-audio)


;;; Input and outcome

(defun one-pace-brace-pushing-p ()
  (or (is-key-down-p +key-space+)
      (is-key-down-p +key-up+)
      (is-key-down-p +key-w+)))

(defun finish-one-pace-brace (target)
  (setf *one-pace-brace* nil)
  (jump-to-dialog-target target))

(defun succeed-one-pace-brace (node)
  (setf (dialog-value "one-pace-held") t)
  (finish-one-pace-brace (node-success-target node)))

(defun fail-one-pace-brace (node)
  (setf (dialog-value "one-pace-held") nil)
  (finish-one-pace-brace (node-failure-target node)))

(defun one-pace-brace-shove-force (elapsed)
  (* +one-pace-brace-shove+
     (expt (max 0.0 (sin (* elapsed 1.5))) 3)))


;;; Update

(defun update-one-pace-brace-node (node dt)
  (let ((game (ensure-one-pace-brace node)))
    (incf (one-pace-brace-elapsed game) dt)
    (let* ((elapsed (one-pace-brace-elapsed game))
           (shove (one-pace-brace-shove-force elapsed))
           (force (+ +one-pace-brace-base-force+
                     (* +one-pace-brace-force-ramp+ elapsed)
                     shove))
           (push (if (one-pace-brace-pushing-p) +one-pace-brace-push+ 0.0)))
      (setf (one-pace-brace-open game)
            (clamp01 (+ (one-pace-brace-open game)
                        (* (- force push) dt))))
      (let ((shoving (> shove 0.22)))
        (when (and shoving (not (one-pace-brace-shoving-p game)))
          (play-one-pace-strain (one-pace-brace-open game)))
        (setf (one-pace-brace-shoving-p game) shoving))
      (cond
        ((>= (one-pace-brace-open game) 1.0)
         (fail-one-pace-brace node))
        ((>= elapsed +one-pace-brace-duration+)
         (succeed-one-pace-brace node))))))


;;; Draw

(defun draw-one-pace-brace-door (game)
  (let* ((door-w 360.0)
         (door-h 420.0)
         (left   (- +virtual-center-x+ (/ door-w 2.0)))
         (top    170.0)
         (right  (+ left door-w))
         (bottom (+ top door-h))
         (gap    (* (one-pace-brace-open game) door-w))
         (edge   (- right gap))
         (shove  (one-pace-brace-shove-force (one-pace-brace-elapsed game)))
         (frame  (make-color 255 255 255 150)))
    (when (plusp gap)
      (claylib/ll:draw-rectangle (round edge)
                                 (round top)
                                 (round gap)
                                 (round door-h)
                                 (claylib::c-ptr (make-color 255 255 255 60))))
    (draw-thick-line-between left top right top frame 2.0)
    (draw-thick-line-between left bottom right bottom frame 2.0)
    (draw-thick-line-between left top left bottom frame 2.0)
    (draw-thick-line-between right top right bottom frame 2.0)
    (draw-thick-line-between edge
                            top
                            edge
                            bottom
                            (make-color 255 255 255 (round (+ 170 (* 85 (clamp01 (/ shove 0.6))))))
                            (+ 2.0 (* 3.0 (clamp01 (/ shove 0.6)))))))

(defun draw-one-pace-brace-hud (game)
  (let ((remaining (max 0.0 (- +one-pace-brace-duration+
                               (one-pace-brace-elapsed game)))))
    (draw-centered-text (format nil "~d" (ceiling remaining))
                        +virtual-center-x+
                        118
                        24
                        (make-color 255 255 255 220))
    (draw-centered-text "hold space / w / up arrow to brace the door"
                        +virtual-center-x+
                        624
                        16
                        (make-color 255 255 255 170))
    (draw-centered-text "keep it shut until they give up"
                        +virtual-center-x+
                        648
                        14
                        (make-color 255 255 255 120))))

(defun draw-one-pace-brace-node (node color)
  (declare (ignore color))
  (let ((game (ensure-one-pace-brace node)))
    (draw-one-pace-brace-door game)
    (draw-one-pace-brace-hud game)))


(dialog-minigame-kind :one-pace/brace
                      :update #'update-one-pace-brace-node
                      :draw #'draw-one-pace-brace-node)
