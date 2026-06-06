(in-package #:immortal-coil)

(defvar *loaded-mod-scripts* nil)

(defstruct loaded-mod-script
  id
  path)

(defun mods-enabled-p ()
  (not (member (string-downcase
                (or (uiop:getenv "IMMORTAL_COIL_DISABLE_MODS")
                    ""))
               '("1" "true" "yes" "on")
               :test #'string=)))

(defun configured-mod-directory-paths ()
  (append *mod-directory-paths*
          (let ((extra (uiop:getenv "IMMORTAL_COIL_MOD_DIR")))
            (if extra
                (uiop:split-string extra :separator ":")
                nil))))

(defun mod-directory-pathname (path)
  (uiop:ensure-directory-pathname (project-pathname path)))

(defun mod-directory-pathnames ()
  (loop for path in (configured-mod-directory-paths)
        for pathname = (mod-directory-pathname path)
        when (uiop:directory-exists-p pathname)
          collect pathname))

(defun safe-directory-files (directory pattern)
  (handler-case
      (uiop:directory-files directory pattern)
    (error (condition)
      (runtime-warn "Could not scan mod directory files in ~a: ~a"
                    directory
                    condition)
      nil)))

(defun safe-subdirectories (directory)
  (handler-case
      (uiop:subdirectories directory)
    (error (condition)
      (runtime-warn "Could not scan mod subdirectories in ~a: ~a"
                    directory
                    condition)
      nil)))

(defun root-mod-scripts (directory)
  (safe-directory-files directory "*.lisp"))

(defun subdirectory-mod-scripts (directory)
  (loop for subdirectory in (safe-subdirectories directory)
        for script = (merge-pathnames "mod.lisp" subdirectory)
        when (probe-file script)
          collect script))

(defun sort-pathnames (pathnames)
  (sort (copy-list pathnames) #'string< :key #'namestring))

(defun mod-script-identity (path)
  (handler-case
      (namestring (truename path))
    (error (condition)
      (runtime-warn "Could not resolve mod script path ~a: ~a"
                    path
                    condition)
      (namestring path))))

(defun mod-script-pathnames ()
  (sort-pathnames
   (remove-duplicates
    (loop for directory in (mod-directory-pathnames)
          append (root-mod-scripts directory)
          append (subdirectory-mod-scripts directory))
    :test #'equal
    :key #'mod-script-identity)))

(defun pathname-parent-name (path)
  (let ((directory (pathname-directory path)))
    (when (consp directory)
      (first (last directory)))))

(defun mod-script-id (path)
  (or (and (string= (or (pathname-name path) "") "mod")
           (pathname-parent-name path))
      (pathname-name path)
      (namestring path)))

(defun load-dialog-mod-script (path)
  (when (eval-dialog-script path)
    (push (make-loaded-mod-script :id (mod-script-id path)
                                  :path path)
          *loaded-mod-scripts*)
    t))

(defun load-dialog-mods ()
  (setf *loaded-mod-scripts* nil)
  (when (mods-enabled-p)
    (dolist (path (mod-script-pathnames))
      (load-dialog-mod-script path)))
  (setf *loaded-mod-scripts*
        (nreverse *loaded-mod-scripts*)))

(defun dialog-mod-conflict-count ()
  (length *dialog-conflicts*))

(defun discovered-mod-count ()
  (if (mods-enabled-p)
      (length (mod-script-pathnames))
      0))

(defun loaded-mod-count ()
  (length *loaded-mod-scripts*))

(defun plural-s (count)
  (if (= count 1) "" "S"))

(defun dialog-mod-status-summary ()
  (if (mods-enabled-p)
      (let ((loaded (loaded-mod-count))
            (found (discovered-mod-count))
            (conflicts (dialog-mod-conflict-count)))
        (if (plusp loaded)
            (format nil "MODS: ~d LOADED / ~d CONFLICT~a"
                    loaded
                    conflicts
                    (plural-s conflicts))
            (format nil "MODS: ~d FOUND" found)))
      "MODS: DISABLED"))

(defun refresh-dialog-mod-status ()
  (handler-case
      (progn
        (load-dialog-graph)
        (dialog-mod-status-summary))
    (error (condition)
      (runtime-warn "Could not refresh mod status: ~a" condition)
      "MODS: ERROR")))
