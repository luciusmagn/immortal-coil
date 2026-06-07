(in-package #:immortal-coil)

(defvar *loaded-dialog-bundles* nil)
(defvar *current-dialog-bundle* nil)

(defstruct dialog-bundle
  (id            "unknown" :type string)
  (name          "Unknown" :type string)
  (version       nil :type (option string))
  (origin        :bundled :type dialog-script-origin)
  (root          #P"" :type pathname)
  (asset-root    #P"" :type pathname)
  (script-paths  nil :type list)
  (manifest-path nil :type (option pathname)))

(-> pathname-parent-directory (pathname) pathname)
(defun pathname-parent-directory (path)
  (uiop:ensure-directory-pathname
   (uiop:pathname-directory-pathname path)))

(-> resolve-relative-pathname (pathname t) pathname)
(defun resolve-relative-pathname (root path)
  (let ((pathname (etypecase path
                    (pathname path)
                    (string (parse-namestring path)))))
    (if (uiop:absolute-pathname-p pathname)
        pathname
        (merge-pathnames pathname root))))

(-> normalize-bundle-id (t t) string)
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

(-> read-dialog-manifest-form (pathname) (option plist))
(defun read-dialog-manifest-form (path)
  (handler-case
      (with-open-file (stream path)
        (let ((form (read stream nil nil)))
          (when (plistp form)
            form)))
    (error (condition)
      (runtime-warn "Could not read dialog manifest ~a: ~a"
                    path
                    condition)
      nil)))

(-> manifest-script-paths (pathname list) list)
(defun manifest-script-paths (root scripts)
  (loop for script in scripts
        collect (resolve-relative-pathname root script)))

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
             (scripts (getf form :scripts))
             (asset-root (resolve-relative-pathname
                          root
                          (or (getf form :assets)
                              (getf form :asset-root)
                              "assets/"))))
        (if scripts
            (make-dialog-bundle :id id
                                :name name
                                :version version
                                :origin origin
                                :root root
                                :asset-root (uiop:ensure-directory-pathname
                                             asset-root)
                                :script-paths (manifest-script-paths root
                                                                     scripts)
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
                        :manifest-path nil)))

(-> make-dialog-bundle-source (t dialog-script-origin) dialog-bundle)
(defun make-dialog-bundle-source (source origin)
  (or (make-dialog-bundle-from-manifest source origin)
      (make-legacy-dialog-bundle source origin)))

(-> dialog-bundle-sort-key (dialog-bundle) string)
(defun dialog-bundle-sort-key (bundle)
  (or (and (dialog-bundle-manifest-path bundle)
           (namestring (dialog-bundle-manifest-path bundle)))
      (and (dialog-bundle-script-paths bundle)
           (namestring (first (dialog-bundle-script-paths bundle))))
      (dialog-bundle-id bundle)))

(-> sort-dialog-bundles (list) list)
(defun sort-dialog-bundles (bundles)
  (sort (copy-list bundles) #'string< :key #'dialog-bundle-sort-key))

(-> reset-loaded-dialog-bundles () t)
(defun reset-loaded-dialog-bundles ()
  (setf *loaded-dialog-bundles* nil))

(-> record-loaded-dialog-bundle (dialog-bundle) dialog-bundle)
(defun record-loaded-dialog-bundle (bundle)
  (setf *loaded-dialog-bundles*
        (append *loaded-dialog-bundles* (list bundle)))
  bundle)

(-> loaded-dialog-bundle-count () nonnegative-integer)
(defun loaded-dialog-bundle-count ()
  (length *loaded-dialog-bundles*))

(-> current-dialog-bundle-id () string)
(defun current-dialog-bundle-id ()
  (if *current-dialog-bundle*
      (dialog-bundle-id *current-dialog-bundle*)
      "repl"))

(-> dialog-asset-pathname (t &key (:bundle (option dialog-bundle))) pathname)
(defun dialog-asset-pathname (path &key (bundle *current-dialog-bundle*))
  (if bundle
      (resolve-relative-pathname (dialog-bundle-asset-root bundle) path)
      (project-pathname path)))
