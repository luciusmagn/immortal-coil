;;; forest hide minigame
;;;
;;; The lantern sweeps past while the player hides. Breath pressure
;;; rises on its own; letting a breath out eases it but makes noise.
;;; A class-based session: per-node config can tune duration and
;;; difficulty, and supply :heard-target and :gasped-target outcome ids;
;;; without them, both finishes use the node's failure target.

(defclass forest-hide-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor forest-hide-elapsed)
   (breath
    :initform 0.25
    :accessor forest-hide-breath)
   (noise
    :initform 0.0
    :accessor forest-hide-noise)))

(defun forest-hide-duration (session)
  (session-config-value session :duration 9.0))

(defun forest-hide-breath-rise (session)
  (session-config-value session :breath-rise 0.085))

(defun forest-hide-noise-threshold (session)
  (session-config-value session :noise-threshold 0.55))

(defun forest-hide-exhale-pressed-p ()
  (or (is-key-pressed-p +key-space+)
      (is-key-pressed-p +key-up+)
      (is-key-pressed-p +key-w+)))

(defun forest-hide-light-x (session)
  (let ((progress (clamp01 (/ (forest-hide-elapsed session)
                              (forest-hide-duration session)))))
    (+ 120.0 (* progress (- +virtual-width+ 240.0)))))

(defun forest-hide-danger (session)
  (let ((distance (abs (- (forest-hide-light-x session)
                          +virtual-center-x+))))
    (clamp01 (- 1.0 (/ distance 320.0)))))

(defmethod minigame-session-update ((session forest-hide-session) node dt)
  (incf (forest-hide-elapsed session) dt)
  (incf (forest-hide-breath session)
        (* (forest-hide-breath-rise session) dt))
  (setf (forest-hide-noise session)
        (max 0.0 (- (forest-hide-noise session) (* 0.55 dt))))
  (when (forest-hide-exhale-pressed-p)
    (setf (forest-hide-breath session)
          (max 0.0 (- (forest-hide-breath session) 0.30)))
    (incf (forest-hide-noise session) 0.34))
  (cond
    ((>= (forest-hide-breath session) 1.0)
     (setf (session-store-value session "forest-seen") t)
     (finish-minigame-node node
                           (or (session-config-value session :gasped-target)
                               (node-failure-target node))))
    ((and (> (forest-hide-noise session)
             (forest-hide-noise-threshold session))
          (> (forest-hide-danger session) 0.35))
     (setf (session-store-value session "forest-seen") t)
     (finish-minigame-node node
                           (or (session-config-value session :heard-target)
                               (node-failure-target node))))
    ((>= (forest-hide-elapsed session) (forest-hide-duration session))
     (finish-minigame-node node (node-success-target node)))))

(defun draw-forest-hide-light (session)
  (let ((x (forest-hide-light-x session)))
    (loop for (half-width alpha) in '((90.0 26) (46.0 48) (16.0 92))
          do (claylib/ll:draw-rectangle (round (- x half-width))
                                        120
                                        (round (* half-width 2.0))
                                        330
                                        (claylib::c-ptr
                                         (make-color 255 255 255 alpha))))))

(defun draw-forest-hide-breath (session)
  (let* ((width 320.0)
         (left (- +virtual-center-x+ (/ width 2.0)))
         (y (- +virtual-height+ 96.0))
         (breath (clamp01 (forest-hide-breath session)))
         (noise (clamp01 (forest-hide-noise session))))
    (draw-thick-line-between left y (+ left width) y
                             (make-color 255 255 255 80)
                             1.0)
    (draw-thick-line-between left y (+ left (* width breath)) y
                             (make-color 255 255 255
                                         (round (+ 130 (* 110 breath))))
                             4.0)
    (when (plusp noise)
      (draw-thick-line-between left (- y 12.0)
                               (+ left (* width noise)) (- y 12.0)
                               (make-color 255 255 255 70)
                               2.0))))

(defmethod minigame-session-draw ((session forest-hide-session) node color)
  (declare (ignore node color))
  (draw-forest-hide-light session)
  (draw-forest-hide-breath session)
  (draw-centered-text "space, w, or up arrow lets a breath out"
                      +virtual-center-x+
                      (- +virtual-height+ 42)
                      16
                      (make-color 255 255 255 170)))

(register-minigame-session-kind :forest-hide 'forest-hide-session)
