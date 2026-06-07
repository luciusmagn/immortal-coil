(in-package #:immortal-coil)

(defparameter *pause-selection*
  (make-command-selection :resume "RESUME"
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
