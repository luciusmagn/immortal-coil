(in-package #:immortal-coil)

(-> normalize-bundle-id (t t) dialog-bundle-id)
(defun normalize-bundle-id (id fallback)
  (typecase id
    (string id)
    (symbol (string-downcase (symbol-name id)))
    (t (source-designator-name fallback))))

(-> normalize-bundle-name (t string) string)
(defun normalize-bundle-name (name fallback)
  (typecase name
    (string name)
    (symbol (string-capitalize (string-downcase (symbol-name name))))
    (t fallback)))

(-> normalize-bundle-version (t) (option string))
(defun normalize-bundle-version (version)
  (typecase version
    (null nil)
    (string version)
    (symbol (string-downcase (symbol-name version)))
    (t (princ-to-string version))))

(-> normalize-manifest-string (t) (option string))
(defun normalize-manifest-string (value)
  (typecase value
    (null nil)
    (string value)
    (symbol (string-downcase (symbol-name value)))
    (t nil)))

(-> manifest-list-value (t) list)
(defun manifest-list-value (value)
  (cond
    ((null value)
     nil)
    ((listp value)
     value)
    (t
     (list value))))

(-> manifest-path-designator-p (t) boolean)
(defun manifest-path-designator-p (value)
  (typep value '(or pathname string)))

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

(-> make-dialog-bundle-from-manifest (t dialog-script-origin)
    (option dialog-bundle))
(defun make-dialog-bundle-from-manifest (manifest-path origin)
  (let* ((path (project-pathname manifest-path))
         (root (pathname-parent-directory path))
         (form (read-dialog-manifest-form path)))
    (when form
      (let* ((id (normalize-bundle-id (getf form :id) path))
             (name (normalize-bundle-name (getf form :name) id))
             (version (normalize-bundle-version (getf form :version)))
             (scripts (manifest-script-paths root
                                             path
                                             (getf form :scripts)))
             (dependencies (manifest-dependency-ids
                            path
                            (or (getf form :depends-on)
                                (getf form :depends)))))
        (if scripts
            (make-dialog-bundle :id id
                                :name name
                                :version version
                                :description (manifest-description form)
                                :author (manifest-author form)
                                :origin origin
                                :root root
                                :asset-root (manifest-asset-root root
                                                                 path
                                                                 form)
                                :script-paths scripts
                                :dependencies dependencies
                                :manifest-path path)
            (progn
              (runtime-warn "Dialog manifest has no scripts: ~a" path)
              nil))))))

(-> make-legacy-dialog-bundle (t dialog-script-origin) dialog-bundle)
(defun make-legacy-dialog-bundle (script-path origin)
  (let* ((path (project-pathname script-path))
         (root (pathname-parent-directory path))
         (id (source-designator-name path)))
    (make-dialog-bundle :id id
                        :name id
                        :origin origin
                        :root root
                        :asset-root (merge-pathnames "assets/" root)
                        :script-paths (list path)
                        :dependencies nil
                        :manifest-path nil)))

(-> dialog-manifest-pathname-p (pathname) boolean)
(defun dialog-manifest-pathname-p (path)
  (let ((name (file-namestring path)))
    (and name
         (string= "manifest.lisp"
                  (string-downcase name)))))

(-> make-dialog-bundle-source (t dialog-script-origin) (option dialog-bundle))
(defun make-dialog-bundle-source (source origin)
  (let ((path (project-pathname source)))
    (if (dialog-manifest-pathname-p path)
        (make-dialog-bundle-from-manifest path origin)
        (make-legacy-dialog-bundle path origin))))
