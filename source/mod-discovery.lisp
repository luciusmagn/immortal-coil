(in-package #:immortal-coil)

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

(-> make-mod-dialog-bundle (pathname) dialog-bundle)
(defun make-mod-dialog-bundle (path)
  (make-dialog-bundle-source path :mod))

(-> mod-dialog-bundles () list)
(defun mod-dialog-bundles ()
  (if (mods-enabled-p)
      (sort-dialog-bundles
       (mapcar #'make-mod-dialog-bundle (mod-source-pathnames)))
      nil))
