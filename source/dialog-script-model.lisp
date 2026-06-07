(in-package #:immortal-coil)

(defstruct dialog-script
  (path   "" :type t)
  (origin :bundled :type dialog-script-origin)
  (id     nil :type (option string))
  (bundle nil :type (option dialog-bundle)))

(-> dialog-script-pathname (t) pathname)
(defun dialog-script-pathname (path)
  (project-pathname path))

(-> make-dialog-script-for-bundle (dialog-bundle pathname) dialog-script)
(defun make-dialog-script-for-bundle (bundle path)
  (make-dialog-script :path path
                      :origin (dialog-bundle-origin bundle)
                      :id (source-designator-name path)
                      :bundle bundle))

(-> dialog-bundle-scripts (dialog-bundle) list)
(defun dialog-bundle-scripts (bundle)
  (loop for path in (dialog-bundle-script-paths bundle)
        collect (make-dialog-script-for-bundle bundle path)))
