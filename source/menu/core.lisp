(in-package #:immortal-coil)

;;; State

(defparameter *menu-selection*
  (make-command-selection :new-game "NEW GAME"
                          :continue "CONTINUE"
                          :mods "MODS"
                          :exit "EXIT"))

(defvar *menu-status-message* nil)

(-> current-mod-status-text () string)
(defun current-mod-status-text ()
  (if (fboundp 'dialog-mod-status-summary)
      (funcall (symbol-function 'dialog-mod-status-summary))
      "MODS: UNAVAILABLE"))

(-> menu-option-count () nonnegative-integer)
(defun menu-option-count ()
  (selection-count *menu-selection*))

(-> menu-option (integer) (option command-option))
(defun menu-option (index)
  (selection-item *menu-selection* index))

(-> selected-menu-option () (option command-option))
(defun selected-menu-option ()
  (selection-current *menu-selection*))

(-> selected-menu-action () (option command-action))
(defun selected-menu-action ()
  (selection-current-action *menu-selection*))

(-> selected-menu-label () string)
(defun selected-menu-label ()
  (selection-current-label *menu-selection*))

(-> reset-menu-state () selection-model)
(defun reset-menu-state ()
  (setf *menu-elapsed* 0.0
        *menu-start-action* nil
        *menu-start-state* :idle
        *menu-start-elapsed* 0.0
        *menu-status-message* (current-mod-status-text))
  (selection-reset *menu-selection*))

(-> menu-action-available-p (t) boolean)
(defun menu-action-available-p (action)
  (case action
    (:continue (save-game-exists-p))
    (t t)))

(-> selected-menu-action-available-p () boolean)
(defun selected-menu-action-available-p ()
  (menu-action-available-p (selected-menu-action)))


;;; Geometry

(-> menu-option-text-width () nonnegative-integer)
(defun menu-option-text-width ()
  (measure-text (selected-menu-label) *menu-start-text-size*))

(-> menu-option-bounds () (values scalar scalar scalar scalar))
(defun menu-option-bounds ()
  (let ((width (menu-option-text-width))
        (height *menu-start-text-size*))
    (values (- +menu-start-x+ (/ width 2) 18)
            (- +menu-start-y+ (/ height 2) 14)
            (+ width 36)
            (+ height 28))))

(-> point-in-rect-p (scalar scalar scalar scalar scalar scalar) boolean)
(defun point-in-rect-p (x y left top width height)
  (and (>= x left)
       (<= x (+ left width))
       (>= y top)
       (<= y (+ top height))))

(-> mouse-on-menu-option-p () boolean)
(defun mouse-on-menu-option-p ()
  (multiple-value-bind (left top width height)
      (menu-option-bounds)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(-> menu-arrow-center-x (menu-direction) scalar)
(defun menu-arrow-center-x (direction)
  (+ +menu-start-x+
     (* direction (+ +title-orbit-radius+ 86.0))))

(-> menu-arrow-bounds (menu-direction) (values scalar scalar scalar scalar))
(defun menu-arrow-bounds (direction)
  (let ((x (menu-arrow-center-x direction))
        (size 54.0))
    (values (- x (/ size 2))
            (- +menu-start-y+ (/ size 2))
            size
            size)))

(-> mouse-on-menu-arrow-p (menu-direction) boolean)
(defun mouse-on-menu-arrow-p (direction)
  (multiple-value-bind (left top width height)
      (menu-arrow-bounds direction)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(-> menu-arrow-pressed-p (menu-direction) boolean)
(defun menu-arrow-pressed-p (direction)
  (or (and (mouse-on-menu-arrow-p direction)
           (is-mouse-button-down-p +mouse-button-left+))
      (if (minusp direction)
          (is-key-down-p +key-left+)
          (is-key-down-p +key-right+))))


;;; Actions

(-> start-new-game () t)
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

(-> continue-game () boolean)
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

(-> return-to-idle-menu () t)
(defun return-to-idle-menu ()
  (setf *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0)
  (play-choice-switch))

(-> complete-start-action () t)
(defun complete-start-action ()
  (case *menu-start-action*
    (:new-game (start-new-game))
    (:continue
     (unless (continue-game)
       (return-to-idle-menu)))
    (t
     (return-to-idle-menu))))

(-> begin-start-transition (command-action) t)
(defun begin-start-transition (action)
  (play-start-confirm)
  (setf *menu-start-state* :starting
        *menu-start-action* action
        *menu-start-elapsed* 0.0))

(-> refresh-menu-mod-status () t)
(defun refresh-menu-mod-status ()
  (setf *menu-status-message*
        (if (fboundp 'refresh-dialog-mod-status)
            (funcall (symbol-function 'refresh-dialog-mod-status))
            "MODS: UNAVAILABLE"))
  (play-choice-switch))

(-> start-transition-total-seconds () seconds)
(defun start-transition-total-seconds ()
  (+ *start-confirm-seconds* *start-fade-out-seconds*))

(-> menu-start-fade-progress () scalar)
(defun menu-start-fade-progress ()
  (if (eq *menu-start-state* :starting)
      (smoothstep (/ (- *menu-start-elapsed* *start-confirm-seconds*)
                     *start-fade-out-seconds*))
      0.0))

(-> menu-title-music-volume-scale () scalar)
(defun menu-title-music-volume-scale ()
  (- 1.0 (menu-start-fade-progress)))

(-> menu-selection-direction () (option menu-direction))
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

(-> move-menu-selection ((option menu-direction)) t)
(defun move-menu-selection (direction)
  (when (selection-move *menu-selection* direction)
    (play-choice-switch)))

(-> menu-option-pressed-p () boolean)
(defun menu-option-pressed-p ()
  (or (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-space+)
      (and (mouse-on-menu-option-p)
           (is-mouse-button-pressed-p +mouse-button-left+))))

(-> execute-selected-menu-option () t)
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


;;; Rendering

(-> menu-alpha-scale () scalar)
(defun menu-alpha-scale ()
  (smoothstep (/ *menu-elapsed* *menu-fade-seconds*)))

(-> start-button-flash-scale () scalar)
(defun start-button-flash-scale ()
  (if (eq *menu-start-state* :starting)
      (+ 0.25 (* 0.75
                 (if (< (mod (* *menu-start-elapsed* 10.0) 1.0) 0.5)
                     1.0
                     0.35)))
      1.0))

(-> menu-option-alpha () alpha-channel)
(defun menu-option-alpha ()
  (if (selected-menu-action-available-p)
      245
      112))

(-> draw-menu-option () t)
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

(-> menu-status-text () (option string))
(defun menu-status-text ()
  (when (eq (selected-menu-action) :mods)
    *menu-status-message*))

(-> draw-menu-status () t)
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

(-> draw-menu-arrow-triangle (scalar scalar scalar scalar scalar scalar t) t)
(defun draw-menu-arrow-triangle (x1 y1 x2 y2 x3 y3 color)
  (draw-triangle-points x1 y1 x2 y2 x3 y3 color :filled-p t)
  (draw-triangle-points x1 y1 x3 y3 x2 y2 color :filled-p t))

(-> draw-menu-arrow-shape (menu-direction scalar scalar scalar scalar t) t)
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

(-> menu-arrow-scale (menu-direction boolean boolean) scalar)
(defun menu-arrow-scale (direction hovered-p pressed-p)
  (let ((pulse (* 0.035
                  (sin (+ (* *menu-elapsed* 2.7)
                          (if (minusp direction) 0.0 pi))))))
    (* (+ 1.0 pulse (if hovered-p 0.055 0.0))
       (if pressed-p 0.86 1.0))))

(-> draw-menu-arrow-bloom
    (menu-direction scalar scalar scalar scalar scalar boolean)
    t)
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

(-> draw-menu-arrow (menu-direction) t)
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

(-> draw-menu-arrows () t)
(defun draw-menu-arrows ()
  (draw-menu-arrow -1)
  (draw-menu-arrow 1))

(-> draw-menu () t)
(defun draw-menu ()
  (draw-title-logo (menu-alpha-scale))
  (draw-particles (menu-alpha-scale))
  (draw-menu-arrows)
  (draw-menu-option)
  (draw-menu-status))


;;; Updating

(-> update-menu (seconds) t)
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
