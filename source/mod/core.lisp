(in-package #:immortal-coil)

;;; Configuration

(-> mod-disable-env-value-p (string) boolean)
(defun mod-disable-env-value-p (value)
  (not (null (member (string-downcase value)
                     '("1" "true" "yes" "on")
                     :test #'string=))))

(-> mods-enabled-p () boolean)
(defun mods-enabled-p ()
  (not (mod-disable-env-value-p
        (or (uiop:getenv "IMMORTAL_COIL_DISABLE_MODS")
            ""))))

(-> extra-mod-directory-paths () list)
(defun extra-mod-directory-paths ()
  (let ((extra (uiop:getenv "IMMORTAL_COIL_MOD_DIR")))
    (if extra
        (uiop:split-string extra :separator ":")
        nil)))

(-> configured-mod-directory-paths () list)
(defun configured-mod-directory-paths ()
  (append *mod-directory-paths*
          (extra-mod-directory-paths)))

(-> mod-directory-pathname (t) pathname)
(defun mod-directory-pathname (path)
  (uiop:ensure-directory-pathname (project-pathname path)))

(-> mod-directory-pathnames () list)
(defun mod-directory-pathnames ()
  (loop for path in (configured-mod-directory-paths)
        for pathname = (mod-directory-pathname path)
        when (uiop:directory-exists-p pathname)
          collect pathname))


;;; Discovery

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

(-> root-mod-sources (pathname) list)
(defun root-mod-sources (directory)
  (safe-directory-files directory "*.lisp"))

(-> subdirectory-mod-source (pathname) (option pathname))
(defun subdirectory-mod-source (directory)
  (let ((manifest (merge-pathnames "manifest.lisp" directory))
        (legacy-script (merge-pathnames "mod.lisp" directory)))
    (cond
      ((probe-file manifest)
       manifest)
      ((probe-file legacy-script)
       legacy-script)
      (t nil))))

(-> subdirectory-mod-sources (pathname) list)
(defun subdirectory-mod-sources (directory)
  (loop for subdirectory in (safe-subdirectories directory)
        for source = (subdirectory-mod-source subdirectory)
        when source
          collect source))

(-> sort-pathnames (list) list)
(defun sort-pathnames (pathnames)
  (sort (copy-list pathnames) #'string< :key #'namestring))

(-> mod-source-identity (pathname) string)
(defun mod-source-identity (path)
  (handler-case
      (namestring (truename path))
    (error (condition)
      (runtime-warn "Could not resolve mod source path ~a: ~a"
                    path
                    condition)
      (namestring path))))

(-> directory-mod-sources (pathname) list)
(defun directory-mod-sources (directory)
  (append (root-mod-sources directory)
          (subdirectory-mod-sources directory)))

(-> mod-source-pathnames () list)
(defun mod-source-pathnames ()
  (sort-pathnames
   (remove-duplicates
    (loop for directory in (mod-directory-pathnames)
          append (directory-mod-sources directory))
    :test #'equal
    :key #'mod-source-identity)))

(-> make-mod-dialog-bundle (pathname) (option dialog-bundle))
(defun make-mod-dialog-bundle (path)
  (make-dialog-bundle-source path :mod))

(-> mod-dialog-bundles () list)
(defun mod-dialog-bundles ()
  (if (mods-enabled-p)
      (loop for path in (mod-source-pathnames)
            for bundle = (make-mod-dialog-bundle path)
            when bundle
              collect bundle)
      nil))


;;; Status

(-> loaded-mod-scripts () list)
(defun loaded-mod-scripts ()
  (remove-if-not (lambda (script)
                   (eq (dialog-script-origin script) :mod))
                 *loaded-dialog-scripts*))

(-> loaded-mod-bundles () list)
(defun loaded-mod-bundles ()
  (remove-if-not (lambda (bundle)
                   (eq (dialog-bundle-origin bundle) :mod))
                 *loaded-dialog-bundles*))

(-> dialog-mod-conflict-count () nonnegative-integer)
(defun dialog-mod-conflict-count ()
  (length *dialog-conflicts*))

(-> discovered-mod-count () nonnegative-integer)
(defun discovered-mod-count ()
  (if (mods-enabled-p)
      (length (mod-source-pathnames))
      0))

(-> loaded-mod-count () nonnegative-integer)
(defun loaded-mod-count ()
  (length (loaded-mod-bundles)))

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
