(in-package #:immortal-coil)

;;; State

(defparameter *pause-selection*
  (make-command-selection :resume "RESUME"
                          :options "OPTIONS"
                          :menu "MAIN MENU"
                          :quit "QUIT"))

(-> pause-option-count () nonnegative-integer)
(defun pause-option-count ()
  (selection-count *pause-selection*))

(-> pause-option (integer) (option command-option))
(defun pause-option (index)
  (selection-item *pause-selection* index))

(-> selected-pause-option () (option command-option))
(defun selected-pause-option ()
  (selection-current *pause-selection*))

(-> selected-pause-action () (option pause-action))
(defun selected-pause-action ()
  (selection-current-action *pause-selection*))

(-> selected-pause-label () string)
(defun selected-pause-label ()
  (selection-current-label *pause-selection*))

(-> reset-pause-menu-state () selection-model)
(defun reset-pause-menu-state ()
  (setf *paused-p* nil)
  (selection-reset *pause-selection*))


;;; Actions

(-> open-pause-menu () t)
(defun open-pause-menu ()
  (setf *paused-p* t)
  (selection-reset *pause-selection*)
  (play-choice-switch))

(-> close-pause-menu () t)
(defun close-pause-menu ()
  (reset-pause-menu-state)
  (play-choice-switch))

(-> return-to-title-menu () t)
(defun return-to-title-menu ()
  (unless (editor-active-p)
    (save-current-game))
  (stop-story-music)
  (reset-minigames)
  (setf *paused-p* nil
        *save-current-game-p* nil
        *mode* :menu)
  (reset-editor-state)
  (reset-menu-state)
  (reset-particles :title-menu)
  (play-title-music))

(-> quit-from-pause-menu () t)
(defun quit-from-pause-menu ()
  (play-start-confirm)
  (unless (editor-active-p)
    (save-current-game))
  (reset-minigames)
  (setf *quit-requested-p* t))

(-> execute-selected-pause-option () t)
(defun execute-selected-pause-option ()
  (case (selected-pause-action)
    (:resume
     (close-pause-menu))
    (:options
     (open-options-menu))
    (:menu
     (play-start-confirm)
     (return-to-title-menu))
    (:quit
     (quit-from-pause-menu))
    (t
     (close-pause-menu))))


;;; Rendering

(-> draw-pause-option (integer scalar t) t)
(defun draw-pause-option (index y color)
  (let ((label (command-option-label (pause-option index)))
        (size 22)
        (selected-p (= index (selection-current-index *pause-selection*))))
    (multiple-value-bind (x text-y width)
        (draw-centered-text label
                            +virtual-center-x+
                            y
                            size
                            color)
      (when selected-p
        (claylib/ll:draw-rectangle (round x)
                                   (round (+ text-y size 5))
                                   (round width)
                                   4
                                   (claylib::c-ptr color))))))

(-> draw-pause-options (t) t)
(defun draw-pause-options (color)
  (let ((start-y (- +virtual-center-y+ 8))
        (spacing 48.0))
    (loop for i below (pause-option-count)
          do (draw-pause-option i
                                (+ start-y (* i spacing))
                                color))))

(-> draw-pause-menu () t)
(defun draw-pause-menu ()
  (let ((color (make-color 255 255 255 240)))
    (claylib/ll:draw-rectangle 0
                               0
                               +virtual-width+
                               +virtual-height+
                               (claylib::c-ptr
                                (make-color 0 0 0 176)))
    (if (options-menu-active-p)
        (draw-options-menu)
        (progn
          (draw-centered-text "PAUSED"
                              +virtual-center-x+
                              (- +virtual-center-y+ 108)
                              28
                              color)
          (draw-pause-options color)))))


;;; Updating

(-> pause-selection-direction () (option pause-direction))
(defun pause-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(-> move-pause-selection ((option pause-direction)) t)
(defun move-pause-selection (direction)
  (when (selection-move *pause-selection* direction)
    (play-choice-switch)))

(-> update-pause-menu () t)
(defun update-pause-menu ()
  (if (options-menu-active-p)
      (update-options-menu)
      (cond
        ((is-key-pressed-p +key-escape+)
         (close-pause-menu))
        (t
         (move-pause-selection (pause-selection-direction))
         (when (confirm-pressed-p)
           (execute-selected-pause-option))))))

;; minigame menus (the character screen, the shop, combat submenus) use Escape
;; as back/cancel, so the pause menu must not snatch it out from under them.
(defparameter *escape-owning-minigames* '(:jrpg-character :jrpg-shop :jrpg-combat))

(defun current-minigame-owns-escape-p ()
  (and *state*
       (member (node-minigame (current-node)) *escape-owning-minigames*)
       t))

(-> maybe-open-pause-menu () boolean)
(defun maybe-open-pause-menu ()
  (when (and (eq *mode* :game)
             (not *paused-p*)
             (is-key-pressed-p +key-escape+)
             (not (current-minigame-owns-escape-p)))
    (open-pause-menu)
    t))
