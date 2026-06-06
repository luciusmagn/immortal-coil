(in-package #:immortal-coil)

(defparameter *menu-options*
  #((:new-game "NEW GAME")
    (:continue "CONTINUE")
    (:options "OPTIONS")
    (:exit "EXIT")))

(defun menu-option-count ()
  (length *menu-options*))

(defun menu-option (index)
  (aref *menu-options*
        (mod index (menu-option-count))))

(defun selected-menu-option ()
  (menu-option *menu-selected-index*))

(defun selected-menu-action ()
  (first (selected-menu-option)))

(defun selected-menu-label ()
  (second (selected-menu-option)))

(defun menu-action-available-p (action)
  (case action
    (:continue (save-game-exists-p))
    (t t)))

(defun selected-menu-action-available-p ()
  (menu-action-available-p (selected-menu-action)))

(defun menu-option-text-width ()
  (measure-text (selected-menu-label) *menu-start-text-size*))

(defun menu-option-bounds ()
  (let ((width (menu-option-text-width))
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

(defun mouse-on-menu-option-p ()
  (multiple-value-bind (left top width height)
      (menu-option-bounds)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(defun menu-arrow-center-x (direction)
  (+ +menu-start-x+
     (* direction (+ +title-orbit-radius+ 86.0))))

(defun menu-arrow-bounds (direction)
  (let ((x (menu-arrow-center-x direction))
        (size 54.0))
    (values (- x (/ size 2))
            (- +menu-start-y+ (/ size 2))
            size
            size)))

(defun mouse-on-menu-arrow-p (direction)
  (multiple-value-bind (left top width height)
      (menu-arrow-bounds direction)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(defun start-new-game ()
  (stop-title-music)
  (load-dialog-graph)
  (reset-particles)
  (reset-play-state *story-start-node*)
  (setf *save-current-game-p* t)
  (save-current-game)
  (setf *mode* :game
        *game-fade-elapsed* 0.0
        *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0))

(defun continue-game ()
  (load-dialog-graph)
  (reset-particles)
  (when (load-current-game-save)
    (stop-title-music)
    (setf *save-current-game-p* t
          *mode* :game
          *game-fade-elapsed* 0.0
          *menu-start-state* :idle
          *menu-start-action* nil
          *menu-start-elapsed* 0.0)
    t))

(defun return-to-idle-menu ()
  (setf *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0)
  (play-choice-switch))

(defun complete-start-action ()
  (case *menu-start-action*
    (:new-game (start-new-game))
    (:continue
     (unless (continue-game)
       (return-to-idle-menu)))
    (t
     (return-to-idle-menu))))

(defun begin-start-transition (action)
  (play-start-confirm)
  (setf *menu-start-state* :starting
        *menu-start-action* action
        *menu-start-elapsed* 0.0))

(defun start-transition-total-seconds ()
  (+ *start-confirm-seconds* *start-fade-out-seconds*))

(defun menu-selection-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)
    ((and (mouse-on-menu-arrow-p 1)
          (is-mouse-button-pressed-p +mouse-button-left+))
     1)
    ((and (mouse-on-menu-arrow-p -1)
          (is-mouse-button-pressed-p +mouse-button-left+))
     -1)))

(defun move-menu-selection (direction)
  (when direction
    (setf *menu-selected-index*
          (mod (+ *menu-selected-index* direction)
               (menu-option-count)))
    (play-choice-switch)))

(defun menu-option-pressed-p ()
  (or (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-space+)
      (and (mouse-on-menu-option-p)
           (is-mouse-button-pressed-p +mouse-button-left+))))

(defun execute-selected-menu-option ()
  (let ((action (selected-menu-action)))
    (case action
      (:exit
       (play-start-confirm)
       (setf *quit-requested-p* t))
      (:options
       (play-choice-switch))
      (t
       (if (menu-action-available-p action)
           (begin-start-transition action)
           (play-choice-switch))))))

(defun update-menu (dt)
  (incf *menu-elapsed* dt)
  (update-title-music)
  (update-title-particles dt)
  (case *menu-start-state*
    (:idle
     (move-menu-selection (menu-selection-direction))
     (when (menu-option-pressed-p)
       (execute-selected-menu-option)))
    (:starting
     (incf *menu-start-elapsed* dt)
     (when (>= *menu-start-elapsed* (start-transition-total-seconds))
       (complete-start-action)))))

(defun menu-alpha-scale ()
  (smoothstep (/ *menu-elapsed* *menu-fade-seconds*)))

(defun start-button-flash-scale ()
  (if (eq *menu-start-state* :starting)
      (+ 0.25 (* 0.75
                 (if (< (mod (* *menu-start-elapsed* 10.0) 1.0) 0.5)
                     1.0
                     0.35)))
      1.0))

(defun menu-option-alpha ()
  (if (selected-menu-action-available-p)
      245
      112))

(defun draw-menu-option ()
  (let* ((alpha-scale (menu-alpha-scale))
         (button-scale (* alpha-scale (start-button-flash-scale)))
         (hovered-p (mouse-on-menu-option-p))
         (base-alpha (if hovered-p 255 (menu-option-alpha)))
         (color (make-color 255 255 255 (round (* base-alpha button-scale)))))
    (multiple-value-bind (x y width)
        (draw-centered-text (selected-menu-label)
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

(defun draw-menu-arrow (direction)
  (let* ((alpha-scale (menu-alpha-scale))
         (hovered-p (mouse-on-menu-arrow-p direction))
         (alpha (round (* alpha-scale
                          (if hovered-p 255 190))))
         (color (make-color 255 255 255 alpha))
         (x (menu-arrow-center-x direction))
         (y +menu-start-y+)
         (w 28.0)
         (h 42.0))
    (if (minusp direction)
        (draw-triangle-points (- x (/ w 2)) y
                              (+ x (/ w 2)) (- y (/ h 2))
                              (+ x (/ w 2)) (+ y (/ h 2))
                              color
                              :filled-p hovered-p)
        (draw-triangle-points (+ x (/ w 2)) y
                              (- x (/ w 2)) (+ y (/ h 2))
                              (- x (/ w 2)) (- y (/ h 2))
                              color
                              :filled-p hovered-p))))

(defun draw-menu-arrows ()
  (draw-menu-arrow -1)
  (draw-menu-arrow 1))

(defun draw-menu ()
  (draw-title-logo (menu-alpha-scale))
  (draw-title-particles (menu-alpha-scale))
  (draw-menu-arrows)
  (draw-menu-option))
