(in-package #:immortal-coil)

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
  (cond
    ((is-key-pressed-p +key-escape+)
     (close-pause-menu))
    (t
     (move-pause-selection (pause-selection-direction))
     (when (confirm-pressed-p)
       (execute-selected-pause-option)))))

(-> maybe-open-pause-menu () boolean)
(defun maybe-open-pause-menu ()
  (when (and (eq *mode* :game)
             (not *paused-p*)
             (is-key-pressed-p +key-escape+))
    (open-pause-menu)
    t))
