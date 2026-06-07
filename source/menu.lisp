(in-package #:immortal-coil)

(defparameter *menu-selection*
  (make-command-selection :new-game "NEW GAME"
                          :continue "CONTINUE"
                          :mods "MODS"
                          :exit "EXIT"))

(defvar *menu-status-message* nil)

(defun current-mod-status-text ()
  (if (fboundp 'dialog-mod-status-summary)
      (funcall (symbol-function 'dialog-mod-status-summary))
      "MODS: UNAVAILABLE"))

(defun menu-option-count ()
  (selection-count *menu-selection*))

(defun menu-option (index)
  (selection-item *menu-selection* index))

(defun selected-menu-option ()
  (selection-current *menu-selection*))

(defun selected-menu-action ()
  (selection-current-action *menu-selection*))

(defun selected-menu-label ()
  (selection-current-label *menu-selection*))

(defun reset-menu-state ()
  (setf *menu-elapsed* 0.0
        *menu-start-action* nil
        *menu-start-state* :idle
        *menu-start-elapsed* 0.0
        *menu-status-message* (current-mod-status-text))
  (selection-reset *menu-selection*))

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

(defun menu-arrow-pressed-p (direction)
  (or (and (mouse-on-menu-arrow-p direction)
           (is-mouse-button-down-p +mouse-button-left+))
      (if (minusp direction)
          (is-key-down-p +key-left+)
          (is-key-down-p +key-right+))))

(defun start-new-game ()
  (stop-title-music)
  (load-dialog-graph)
  (reset-particles)
  (unless (restore-dev-save-override)
    (reset-play-state *story-start-node*))
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

(defun refresh-menu-mod-status ()
  (setf *menu-status-message*
        (if (fboundp 'refresh-dialog-mod-status)
            (funcall (symbol-function 'refresh-dialog-mod-status))
            "MODS: UNAVAILABLE"))
  (play-choice-switch))

(defun start-transition-total-seconds ()
  (+ *start-confirm-seconds* *start-fade-out-seconds*))

(defun menu-start-fade-progress ()
  (if (eq *menu-start-state* :starting)
      (smoothstep (/ (- *menu-start-elapsed* *start-confirm-seconds*)
                     *start-fade-out-seconds*))
      0.0))

(defun menu-title-music-volume-scale ()
  (- 1.0 (menu-start-fade-progress)))

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
  (when (selection-move *menu-selection* direction)
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
      (:mods
       (refresh-menu-mod-status))
      (t
       (if (menu-action-available-p action)
           (begin-start-transition action)
           (play-choice-switch))))))

(defun update-menu (dt)
  (incf *menu-elapsed* dt)
  (update-title-music (menu-title-music-volume-scale))
  (update-particles dt)
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
    (draw-centered-text (selected-menu-label)
                        +menu-start-x+
                        +menu-start-y+
                        *menu-start-text-size*
                        color)))

(defun menu-status-text ()
  (when (eq (selected-menu-action) :mods)
    *menu-status-message*))

(defun draw-menu-status ()
  (let ((text (menu-status-text)))
    (when text
      (draw-centered-text text
                          +menu-start-x+
                          (+ +menu-start-y+ 42)
                          13
                          (make-color 255
                                      255
                                      255
                                      (round (* 180 (menu-alpha-scale))))))))

(defun draw-menu-arrow-triangle (x1 y1 x2 y2 x3 y3 color)
  (draw-triangle-points x1 y1 x2 y2 x3 y3 color :filled-p t)
  (draw-triangle-points x1 y1 x3 y3 x2 y2 color :filled-p t))

(defun draw-menu-arrow-shape (direction x y width height color)
  (if (minusp direction)
      (draw-menu-arrow-triangle (- x (/ width 2)) y
                                (+ x (/ width 2)) (- y (/ height 2))
                                (+ x (/ width 2)) (+ y (/ height 2))
                                color)
      (draw-menu-arrow-triangle (+ x (/ width 2)) y
                                (- x (/ width 2)) (+ y (/ height 2))
                                (- x (/ width 2)) (- y (/ height 2))
                                color)))

(defun menu-arrow-scale (direction hovered-p pressed-p)
  (let ((pulse (* 0.035
                  (sin (+ (* *menu-elapsed* 2.7)
                          (if (minusp direction) 0.0 pi))))))
    (* (+ 1.0 pulse (if hovered-p 0.055 0.0))
       (if pressed-p 0.86 1.0))))

(defun draw-menu-arrow-bloom (direction x y width height alpha-scale pressed-p)
  (let ((strength (if pressed-p 1.25 1.0)))
    (dolist (layer '((2.20 34) (1.62 62)))
      (destructuring-bind (scale alpha) layer
        (draw-menu-arrow-shape
         direction
         x
         y
         (* width scale)
         (* height scale)
         (make-color 255
                     255
                     255
                     (round (* alpha alpha-scale strength))))))))

(defun draw-menu-arrow (direction)
  (let* ((alpha-scale (menu-alpha-scale))
         (hovered-p (mouse-on-menu-arrow-p direction))
         (pressed-p (menu-arrow-pressed-p direction))
         (scale (menu-arrow-scale direction hovered-p pressed-p))
         (color (make-color 255 255 255 (round (* 255 alpha-scale))))
         (x (+ (menu-arrow-center-x direction)
               (if pressed-p (* direction 2.0) 0.0)))
         (y +menu-start-y+)
         (w (* 18.0 scale))
         (h (* 26.0 scale)))
    (draw-menu-arrow-bloom direction x y w h alpha-scale pressed-p)
    (draw-menu-arrow-shape direction x y w h color)))

(defun draw-menu-arrows ()
  (draw-menu-arrow -1)
  (draw-menu-arrow 1))

(defun draw-menu ()
  (draw-title-logo (menu-alpha-scale))
  (draw-particles (menu-alpha-scale))
  (draw-menu-arrows)
  (draw-menu-option)
  (draw-menu-status))
