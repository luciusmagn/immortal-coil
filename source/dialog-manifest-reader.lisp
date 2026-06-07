(in-package #:immortal-coil)

(-> read-dialog-manifest-form (pathname) (option plist))
(defun read-dialog-manifest-form (path)
  (handler-case
      (with-open-file (stream path)
        (let ((form (read stream nil :eof)))
          (cond
            ((eq form :eof)
             (runtime-warn "Dialog manifest is empty: ~a" path)
             nil)
            ((plistp form)
             form)
            (t
             (runtime-warn "Dialog manifest is not a keyword plist: ~a"
                           path)
             nil))))
    (error (condition)
      (runtime-warn "Could not read dialog manifest ~a: ~a"
                    path
                    condition)
      nil)))

(-> manifest-relative-paths (pathname pathname t string) list)
(defun manifest-relative-paths (root manifest-path values label)
  (loop for value in (manifest-list-value values)
        if (manifest-path-designator-p value)
          collect (resolve-relative-pathname root value)
        else
          do (runtime-warn "Ignoring invalid ~a in ~a: ~s"
                           label
                           manifest-path
                           value)))

(-> manifest-script-paths (pathname pathname t) list)
(defun manifest-script-paths (root manifest-path scripts)
  (manifest-relative-paths root manifest-path scripts "script path"))

(-> manifest-asset-root (pathname pathname plist) pathname)
(defun manifest-asset-root (root manifest-path form)
  (let ((asset-root (or (getf form :assets)
                        (getf form :asset-root)
                        "assets/")))
    (if (manifest-path-designator-p asset-root)
        (uiop:ensure-directory-pathname
         (resolve-relative-pathname root asset-root))
        (progn
          (runtime-warn "Invalid asset root in dialog manifest ~a: ~s"
                        manifest-path
                        asset-root)
          (merge-pathnames "assets/" root)))))

(-> manifest-dependency-ids (pathname t) list)
(defun manifest-dependency-ids (manifest-path dependencies)
  (remove-duplicates
   (loop for dependency in (manifest-list-value dependencies)
         for id = (normalize-manifest-string dependency)
         if id
           collect id
         else
           do (runtime-warn "Ignoring invalid dependency in ~a: ~s"
                            manifest-path
                            dependency))
   :test #'string=))

(-> manifest-description (plist) (option string))
(defun manifest-description (form)
  (normalize-manifest-string (getf form :description)))

(-> manifest-author (plist) (option string))
(defun manifest-author (form)
  (normalize-manifest-string (getf form :author)))
