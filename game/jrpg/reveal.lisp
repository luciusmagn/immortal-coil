;;; King in Yellow path reveal — the yellow crown flash.
;;; Mirrors the rogue @ flash (game/rogue/reveal.lisp): a single large
;;; #ffff00 crown fades in, pulses, and fades out, then opens the city.
;;; This is the one colour in the otherwise black-and-white King path.

(defparameter +crown-flash-visible-seconds+ 3.8)
(defparameter +crown-flash-fade-out-seconds+ 0.9)
(defparameter +crown-flash-skip-min-seconds+ 1.6)
(defparameter +crown-flash-radius+ 92.0)

(defclass crown-flash-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor crown-flash-elapsed)))

(defmethod minigame-session-update ((session crown-flash-session) node dt)
  (incf (crown-flash-elapsed session) dt)
  (when (and (> (crown-flash-elapsed session) +crown-flash-skip-min-seconds+)
             (< (crown-flash-elapsed session) +crown-flash-visible-seconds+)
             (confirm-pressed-p))
    (setf (crown-flash-elapsed session) +crown-flash-visible-seconds+))
  (when (>= (crown-flash-elapsed session)
            (+ +crown-flash-visible-seconds+
               +crown-flash-fade-out-seconds+))
    (finish-minigame-node node (node-success-target node))))

(defmethod minigame-session-draw ((session crown-flash-session) node color)
  (declare (ignore node color))
  (let* ((elapsed (crown-flash-elapsed session))
         (fade-in (smoothstep (/ elapsed 1.4)))
         (fade-out (if (> elapsed +crown-flash-visible-seconds+)
                       (- 1.0
                          (smoothstep (/ (- elapsed +crown-flash-visible-seconds+)
                                         +crown-flash-fade-out-seconds+)))
                       1.0))
         (pulse (+ 0.48 (* 0.52 (sin (* elapsed 2.1)))))
         (alpha (round (* 255 fade-in fade-out pulse)))
         (minimum-alpha (if (< elapsed +crown-flash-visible-seconds+) 20 0)))
    (when (plusp alpha)
      ;; tree-draw-crown sits a little high on its anchor; nudge down so the
      ;; crown's mass lands on the screen centre.
      (tree-draw-crown +virtual-center-x+
                       (+ +virtual-center-y+ (round (* +crown-flash-radius+ 0.12)))
                       +crown-flash-radius+
                       (max minimum-alpha alpha)))))

(register-minigame-session-kind :crown-flash 'crown-flash-session)

;;; The crown flashes the moment the player lights the lantern and steps
;;; onto the King-in-Yellow path, then the night city opens.

(dialog-minigame "jrpg/crown-flash"
                 ""
                 :game :crown-flash
                 :success "jrpg/inn"
                 :failure "jrpg/inn")
