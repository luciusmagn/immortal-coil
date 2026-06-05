(in-package #:immortal-coil)

(defun start-button-text-width ()
  (measure-text "START GAME" *menu-start-text-size*))

(defun start-button-bounds ()
  (let ((width (start-button-text-width))
        (height *menu-start-text-size*))
    (values (- +menu-start-x+ (/ width 2) 18)
            (- +menu-start-y+ (/ height 2) 14)
            (+ width 36)
            (+ height 28))))

(defun point-in-rect-p (x y left top width height)
  (and (>= x left)
       (<= x (+ left width))
       (>= y top)
       (<= y (+ top height))))

(defun mouse-on-start-button-p ()
  (multiple-value-bind (left top width height)
      (start-button-bounds)
    (point-in-rect-p (get-mouse-x)
                     (get-mouse-y)
                     left
                     top
                     width
                     height)))

(defun start-game ()
  (stop-title-music)
  (load-dialog-graph)
  (reset-play-state *story-start-node*)
  (reset-particles)
  (setf *mode* :game
        *game-fade-elapsed* 0.0
        *menu-start-state* :idle
        *menu-start-elapsed* 0.0))

(defun begin-start-transition ()
  (setf *menu-start-state* :starting
        *menu-start-elapsed* 0.0))

(defun start-transition-total-seconds ()
  (+ *start-confirm-seconds* *start-fade-out-seconds*))

(defun start-game-pressed-p ()
  (and (eq *menu-start-state* :idle)
       (or (is-key-pressed-p +key-enter+)
           (is-key-pressed-p +key-space+)
           (and (mouse-on-start-button-p)
                (is-mouse-button-pressed-p +mouse-button-left+)))))

(defun update-menu (dt)
  (incf *menu-elapsed* dt)
  (update-title-music)
  (update-title-particles dt)
  (case *menu-start-state*
    (:idle
     (when (start-game-pressed-p)
       (begin-start-transition)))
    (:starting
     (incf *menu-start-elapsed* dt)
     (when (>= *menu-start-elapsed* (start-transition-total-seconds))
       (start-game)))))

(defun menu-alpha-scale ()
  (smoothstep (/ *menu-elapsed* *menu-fade-seconds*)))

(defun start-button-flash-scale ()
  (if (eq *menu-start-state* :starting)
      (+ 0.25 (* 0.75
                 (if (< (mod (* *menu-start-elapsed* 10.0) 1.0) 0.5)
                     1.0
                     0.35)))
      1.0))

(defun draw-start-button ()
  (let* ((alpha-scale (menu-alpha-scale))
         (button-scale (* alpha-scale (start-button-flash-scale)))
         (color (if (mouse-on-start-button-p)
                    (make-color 255 255 255 (round (* 255 button-scale)))
                    (make-color 235 235 235 (round (* 245 button-scale))))))
    (multiple-value-bind (x y width)
        (draw-centered-text "START GAME"
                            +menu-start-x+
                            +menu-start-y+
                            *menu-start-text-size*
                            color)
      (declare (ignore x))
      (claylib/ll:draw-rectangle (round (- +menu-start-x+ (/ width 2)))
                                 (round (+ y *menu-start-text-size* 8))
                                 (round width)
                                 4
                                 (claylib::c-ptr color)))))

(defun draw-menu ()
  (draw-title-logo (menu-alpha-scale))
  (draw-title-particles (menu-alpha-scale))
  (draw-start-button))
