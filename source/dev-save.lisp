(in-package #:immortal-coil)

(-> dialog-dev-save (t &rest t) (option save-data))
(defun dialog-dev-save (id &rest options)
  (if id
      (setf *dev-save-override*
            (apply #'make-dev-save-data id options))
      (progn
        (runtime-warn "dialog-dev-save needs a node id.")
        (setf *dev-save-override* nil)))
  *dev-save-override*)

(-> dialog-dev-save-here (&rest t) (option save-data))
(defun dialog-dev-save-here (&rest options)
  (if *last-dialog-node-id*
      (apply #'dialog-dev-save *last-dialog-node-id* options)
      (progn
        (runtime-warn "dialog-dev-save-here has no previous dialog node.")
        nil)))

(-> dialog-clear-dev-save () null)
(defun dialog-clear-dev-save ()
  (setf *dev-save-override* nil))

(-> dev-save-override-data () (option save-data))
(defun dev-save-override-data ()
  (when (and (dev-save-overrides-enabled-p)
             *dev-save-override*)
    *dev-save-override*))

(-> dev-save-override-exists-p () boolean)
(defun dev-save-override-exists-p ()
  (not (null (dev-save-override-data))))
