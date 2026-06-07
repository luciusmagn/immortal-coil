(in-package #:immortal-coil)

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
