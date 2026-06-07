(in-package #:immortal-coil)

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
