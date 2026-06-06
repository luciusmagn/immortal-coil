(in-package #:immortal-coil)

(defparameter *pause-selection*
  (make-command-selection :resume "RESUME"
                          :menu "MAIN MENU"
                          :quit "QUIT"))

(defun pause-option-count ()
  (selection-count *pause-selection*))

(defun pause-option (index)
  (selection-item *pause-selection* index))

(defun selected-pause-option ()
  (selection-current *pause-selection*))

(defun selected-pause-action ()
  (selection-current-action *pause-selection*))

(defun selected-pause-label ()
  (selection-current-label *pause-selection*))

(defun reset-pause-menu-state ()
  (setf *paused-p* nil)
  (selection-reset *pause-selection*))

(defun open-pause-menu ()
  (setf *paused-p* t)
  (selection-reset *pause-selection*)
  (play-choice-switch))

(defun close-pause-menu ()
  (reset-pause-menu-state)
  (play-choice-switch))

(defun return-to-title-menu ()
  (save-current-game)
  (setf *paused-p* nil
        *save-current-game-p* nil
        *mode* :menu)
  (reset-menu-state)
  (reset-title-particles)
  (play-title-music))

(defun execute-selected-pause-option ()
  (case (selected-pause-action)
    (:resume
     (close-pause-menu))
    (:menu
     (play-start-confirm)
     (return-to-title-menu))
    (:quit
     (play-start-confirm)
     (save-current-game)
     (setf *quit-requested-p* t))
    (t
     (close-pause-menu))))

(defun pause-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(defun move-pause-selection (direction)
  (when (selection-move *pause-selection* direction)
    (play-choice-switch)))

(defun update-pause-menu ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (close-pause-menu))
    (t
     (move-pause-selection (pause-selection-direction))
     (when (confirm-pressed-p)
       (execute-selected-pause-option)))))

(defun maybe-open-pause-menu ()
  (when (and (eq *mode* :game)
             (not *paused-p*)
             (is-key-pressed-p +key-escape+))
    (open-pause-menu)
    t))

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

(defun draw-pause-options (color)
  (let ((start-y (- +virtual-center-y+ 8))
        (spacing 48.0))
    (loop for i below (pause-option-count)
          do (draw-pause-option i
                                (+ start-y (* i spacing))
                                color))))

(defun draw-pause-menu ()
  (let ((color (make-color 255 255 255 240)))
    (claylib/ll:draw-rectangle 0
                               0
                               +virtual-width+
                               +virtual-height+
                               (claylib::c-ptr
                                (make-color 0 0 0 176)))
    (draw-centered-text "PAUSED"
                        +virtual-center-x+
                        (- +virtual-center-y+ 108)
                        28
                        color)
    (draw-pause-options color)))
