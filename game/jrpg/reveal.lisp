;;; King in Yellow path reveal - the yellow crown flash.
;;; Mirrors the rogue @ flash (game/rogue/reveal.lisp): a single large
;;; #ffff00 crown fades in, pulses, and fades out, then opens the city.
;;; This is the one colour in the otherwise black-and-white King path.

(defparameter +crown-flash-visible-seconds+ 3.8)
(defparameter +crown-flash-fade-out-seconds+ 0.9)
(defparameter +crown-flash-skip-min-seconds+ 1.6)
(defparameter +crown-flash-radius+ 92.0)
;; the crown flares twice; a bell tolls at each flare, so the sound matches what
;; the eye sees instead of one toll under two pulses
(defparameter +crown-flash-tolls+ '(0.5 2.0))

(defclass crown-flash-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor crown-flash-elapsed)
   (struck
    :initform nil
    :accessor crown-flash-struck)))

(defun crown-flash-flare (elapsed)
  "Brightness 0..1: a dim base that flares to full at each toll, then decays -
so each bell has its own visible swell."
  (let ((swell 0.0))
    (dolist (toll +crown-flash-tolls+)
      (when (>= elapsed toll)
        (setf swell (max swell (exp (* -2.4 (- elapsed toll)))))))
    (min 1.0 (+ 0.4 (* 0.6 swell)))))

(defmethod minigame-session-update ((session crown-flash-session) node dt)
  (incf (crown-flash-elapsed session) dt)
  ;; ring the bell once at each toll
  (dolist (toll +crown-flash-tolls+)
    (when (and (>= (crown-flash-elapsed session) toll)
               (< (crown-flash-elapsed session) +crown-flash-visible-seconds+)
               (not (member toll (crown-flash-struck session))))
      (push toll (crown-flash-struck session))
      (play-jrpg-sound "crown" :volume 0.4)))
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
         (fade-in (smoothstep (/ elapsed 0.7)))
         (fade-out (if (> elapsed +crown-flash-visible-seconds+)
                       (- 1.0
                          (smoothstep (/ (- elapsed +crown-flash-visible-seconds+)
                                         +crown-flash-fade-out-seconds+)))
                       1.0))
         (alpha (round (* 255 fade-in fade-out (crown-flash-flare elapsed))))
         (minimum-alpha (if (< elapsed +crown-flash-visible-seconds+) 24 0)))
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
                 :success "jrpg/title-open"
                 :failure "jrpg/title-open")


;;; --- title cards: a styled interstitial that fades a title (and optional
;;; subtitle) in, holds, and fades out, for act/scene transitions. General;
;;; driven entirely by node :config, so it is reusable anywhere. ---

(defparameter +title-card-fade+ 0.8)
(defparameter +title-card-hold-default+ 2.4)
(defparameter +title-card-skip-min+ 0.7)

(defclass title-card-session (minigame-session)
  ((elapsed :initform 0.0 :accessor title-card-elapsed)))

(defun title-card-hold (node)
  (let ((v (minigame-config-value node :seconds +title-card-hold-default+)))
    (if (numberp v) (float v) +title-card-hold-default+)))

(defun title-card-total (node)
  (+ +title-card-fade+ (title-card-hold node) +title-card-fade+))

(defmethod minigame-session-update ((session title-card-session) node dt)
  (incf (title-card-elapsed session) dt)
  (let ((total (title-card-total node)))
    (when (and (> (title-card-elapsed session) +title-card-skip-min+)
               (< (title-card-elapsed session) (- total +title-card-fade+))
               (confirm-pressed-p))
      (setf (title-card-elapsed session) (- total +title-card-fade+)))
    (when (>= (title-card-elapsed session) total)
      (finish-minigame-node node (node-success-target node)))))

(defmethod minigame-session-draw ((session title-card-session) node color)
  (declare (ignore color))
  (let* ((e (title-card-elapsed session))
         (total (title-card-total node))
         (alpha-f (cond ((< e +title-card-fade+) (/ e +title-card-fade+))
                        ((> e (- total +title-card-fade+))
                         (max 0.0 (/ (- total e) +title-card-fade+)))
                        (t 1.0)))
         (title (let ((v (minigame-config-value node :title ""))) (if (stringp v) v "")))
         (subtitle (minigame-config-value node :subtitle))
         (accent (minigame-config-value node :accent))
         (cx +virtual-center-x+)
         (cy +virtual-center-y+)
         (a (round (* 255 alpha-f))))
    ;; a clean black wash over whatever was behind, then the card
    (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                               (claylib::c-ptr
                                (make-color 0 0 0 (round (* 240 alpha-f)))))
    (when (plusp a)
      (claylib/ll:draw-rectangle (round (- cx 200)) (round (- cy 34)) 400 2
                                 (claylib::c-ptr (make-color 255 255 255 (round (* a 0.7)))))
      (claylib/ll:draw-rectangle (round (- cx 200)) (round (+ cy 30)) 400 2
                                 (claylib::c-ptr (make-color 255 255 255 (round (* a 0.7)))))
      (when (eq accent :crown)
        (tree-draw-crown cx (- cy 86) 22 (round (* a 0.9))))
      (draw-centered-text title cx cy 40 (make-color 255 255 255 a))
      (when (and subtitle (stringp subtitle))
        (draw-centered-text subtitle cx (+ cy 58) 19
                            (make-color 255 255 255 (round (* a 0.78))))))))

(register-minigame-session-kind :title-card 'title-card-session)

(dialog-minigame "jrpg/title-open"
                 ""
                 :game :title-card
                 :success "jrpg/inn"
                 :failure "jrpg/inn"
                 :config (list :title "BEWARE THE SIGN" :seconds 2.6 :accent :crown))
