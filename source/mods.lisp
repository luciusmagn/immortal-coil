(in-package #:immortal-coil)

(-> mods-enabled-p () boolean)
(defun mods-enabled-p ()
  (not (member (string-downcase
                (or (uiop:getenv "IMMORTAL_COIL_DISABLE_MODS")
                    ""))
               '("1" "true" "yes" "on")
               :test #'string=)))

(-> configured-mod-directory-paths () list)
(defun configured-mod-directory-paths ()
  (append *mod-directory-paths*
          (let ((extra (uiop:getenv "IMMORTAL_COIL_MOD_DIR")))
            (if extra
                (uiop:split-string extra :separator ":")
                nil))))

(-> mod-directory-pathname (t) pathname)
(defun mod-directory-pathname (path)
  (uiop:ensure-directory-pathname (project-pathname path)))

(-> mod-directory-pathnames () list)
(defun mod-directory-pathnames ()
  (loop for path in (configured-mod-directory-paths)
        for pathname = (mod-directory-pathname path)
        when (uiop:directory-exists-p pathname)
          collect pathname))

(-> safe-directory-files (pathname string) list)
(defun safe-directory-files (directory pattern)
  (handler-case
      (uiop:directory-files directory pattern)
    (error (condition)
      (runtime-warn "Could not scan mod directory files in ~a: ~a"
                    directory
                    condition)
      nil)))

(-> safe-subdirectories (pathname) list)
(defun safe-subdirectories (directory)
  (handler-case
      (uiop:subdirectories directory)
    (error (condition)
      (runtime-warn "Could not scan mod subdirectories in ~a: ~a"
                    directory
                    condition)
      nil)))

(-> root-mod-scripts (pathname) list)
(defun root-mod-scripts (directory)
  (safe-directory-files directory "*.lisp"))

(-> subdirectory-mod-scripts (pathname) list)
(defun subdirectory-mod-scripts (directory)
  (loop for subdirectory in (safe-subdirectories directory)
        for script = (merge-pathnames "mod.lisp" subdirectory)
        when (probe-file script)
          collect script))

(-> sort-pathnames (list) list)
(defun sort-pathnames (pathnames)
  (sort (copy-list pathnames) #'string< :key #'namestring))

(-> mod-script-identity (pathname) string)
(defun mod-script-identity (path)
  (handler-case
      (namestring (truename path))
    (error (condition)
      (runtime-warn "Could not resolve mod script path ~a: ~a"
                    path
                    condition)
      (namestring path))))

(-> mod-script-pathnames () list)
(defun mod-script-pathnames ()
  (sort-pathnames
   (remove-duplicates
    (loop for directory in (mod-directory-pathnames)
          append (root-mod-scripts directory)
          append (subdirectory-mod-scripts directory))
    :test #'equal
    :key #'mod-script-identity)))

(-> pathname-parent-name (pathname) (option string))
(defun pathname-parent-name (path)
  (let ((directory (pathname-directory path)))
    (when (consp directory)
      (first (last directory)))))

(-> mod-script-id (pathname) string)
(defun mod-script-id (path)
  (or (and (string= (or (pathname-name path) "") "mod")
           (pathname-parent-name path))
      (pathname-name path)
      (namestring path)))

(-> make-mod-dialog-script (pathname) dialog-script)
(defun make-mod-dialog-script (path)
  (make-dialog-script :path path
                      :origin :mod
                      :id (mod-script-id path)))

(-> mod-dialog-scripts () list)
(defun mod-dialog-scripts ()
  (if (mods-enabled-p)
      (mapcar #'make-mod-dialog-script (mod-script-pathnames))
      nil))

(-> loaded-mod-scripts () list)
(defun loaded-mod-scripts ()
  (remove-if-not (lambda (script)
                   (eq (dialog-script-origin script) :mod))
                 *loaded-dialog-scripts*))

(-> dialog-mod-conflict-count () nonnegative-integer)
(defun dialog-mod-conflict-count ()
  (length *dialog-conflicts*))

(-> discovered-mod-count () nonnegative-integer)
(defun discovered-mod-count ()
  (if (mods-enabled-p)
      (length (mod-script-pathnames))
      0))

(-> loaded-mod-count () nonnegative-integer)
(defun loaded-mod-count ()
  (length (loaded-mod-scripts)))

(-> plural-s (integer) string)
(defun plural-s (count)
  (if (= count 1) "" "S"))

(-> dialog-mod-status-summary () string)
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

(-> refresh-dialog-mod-status () string)
(defun refresh-dialog-mod-status ()
  (handler-case
      (progn
        (load-dialog-graph)
        (dialog-mod-status-summary))
    (error (condition)
      (runtime-warn "Could not refresh mod status: ~a" condition)
      "MODS: ERROR")))
