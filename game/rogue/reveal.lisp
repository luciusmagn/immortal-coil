;;; rogue ASCII reveal

(defconstant +rogue-flash-seconds+ 3.8)

(defclass rogue-at-flash-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor rogue-flash-elapsed)))

(defmethod minigame-session-update ((session rogue-at-flash-session) node dt)
  (incf (rogue-flash-elapsed session) dt)
  (when (or (>= (rogue-flash-elapsed session) +rogue-flash-seconds+)
            (and (> (rogue-flash-elapsed session) 1.6)
                 (confirm-pressed-p)))
    (finish-minigame-node node (node-success-target node))))

(defmethod minigame-session-draw ((session rogue-at-flash-session) node color)
  (declare (ignore node color))
  (let* ((elapsed (rogue-flash-elapsed session))
         (fade-in (smoothstep (/ elapsed 1.4)))
         (pulse (+ 0.48 (* 0.52 (sin (* elapsed 2.1)))))
         (alpha (round (* 255 fade-in pulse))))
    (draw-centered-text "@"
                        +virtual-center-x+
                        +virtual-center-y+
                        190
                        (make-color 255 255 255 (max 20 alpha)))))

(register-minigame-session-kind :rogue-at-flash 'rogue-at-flash-session)
