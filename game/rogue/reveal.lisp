;;; rogue ASCII reveal

(defparameter +rogue-flash-visible-seconds+ 3.8)
(defparameter +rogue-flash-fade-out-seconds+ 0.9)
(defparameter +rogue-flash-skip-min-seconds+ 1.6)

(defclass rogue-at-flash-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor rogue-flash-elapsed)))

(defmethod minigame-session-update ((session rogue-at-flash-session) node dt)
  (incf (rogue-flash-elapsed session) dt)
  (when (and (> (rogue-flash-elapsed session) +rogue-flash-skip-min-seconds+)
             (< (rogue-flash-elapsed session) +rogue-flash-visible-seconds+)
             (confirm-pressed-p))
    (setf (rogue-flash-elapsed session) +rogue-flash-visible-seconds+))
  (when (>= (rogue-flash-elapsed session)
            (+ +rogue-flash-visible-seconds+
               +rogue-flash-fade-out-seconds+))
    (finish-minigame-node node (node-success-target node))))

(defmethod minigame-session-draw ((session rogue-at-flash-session) node color)
  (declare (ignore node color))
  (let* ((elapsed (rogue-flash-elapsed session))
         (fade-in (smoothstep (/ elapsed 1.4)))
         (fade-out (if (> elapsed +rogue-flash-visible-seconds+)
                       (- 1.0
                          (smoothstep (/ (- elapsed +rogue-flash-visible-seconds+)
                                         +rogue-flash-fade-out-seconds+)))
                       1.0))
         (pulse (+ 0.48 (* 0.52 (sin (* elapsed 2.1)))))
         (alpha (round (* 255 fade-in fade-out pulse)))
         (minimum-alpha (if (< elapsed +rogue-flash-visible-seconds+) 20 0)))
    (when (plusp alpha)
      (draw-centered-text "@"
                          +virtual-center-x+
                          +virtual-center-y+
                          190
                          (make-color 255 255 255
                                      (max minimum-alpha alpha))))))

(register-minigame-session-kind :rogue-at-flash 'rogue-at-flash-session)
