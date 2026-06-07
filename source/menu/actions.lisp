(in-package #:immortal-coil)

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
