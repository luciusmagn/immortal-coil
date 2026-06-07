(in-package #:immortal-coil)

(defvar *loaded-dialog-scripts* nil)

(-> reset-loaded-dialog-scripts () t)
(defun reset-loaded-dialog-scripts ()
  (setf *loaded-dialog-scripts* nil))

(-> record-loaded-dialog-script (dialog-script) dialog-script)
(defun record-loaded-dialog-script (script)
  (setf *loaded-dialog-scripts*
        (append *loaded-dialog-scripts* (list script)))
  script)
