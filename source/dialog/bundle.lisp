(in-package #:immortal-coil)

;;; Paths

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


;;; Model

(defstruct dialog-bundle
  (id            "unknown" :type dialog-bundle-id)
  (name          "Unknown" :type string)
  (version       nil :type (option string))
  (description   nil :type (option string))
  (author        nil :type (option string))
  (origin        :bundled :type dialog-script-origin)
  (root          #P"" :type pathname)
  (asset-root    #P"" :type pathname)
  (title-logo    nil :type (option pathname))
  (start-node    nil :type (option dialog-id))
  (script-paths  nil :type list)
  (dependencies  nil :type list)
  (manifest-path nil :type (option pathname)))


;;; Loaded bundle state

(defvar *loaded-dialog-bundles* nil)
(defvar *current-dialog-bundle* nil)

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

(-> current-dialog-bundle-id () dialog-bundle-id)
(defun current-dialog-bundle-id ()
  (if *current-dialog-bundle*
      (dialog-bundle-id *current-dialog-bundle*)
      "repl"))


;;; Assets

(-> dialog-asset-pathname (t &key (:bundle (option dialog-bundle))) pathname)
(defun dialog-asset-pathname (path &key (bundle *current-dialog-bundle*))
  (if bundle
      (resolve-relative-pathname (dialog-bundle-asset-root bundle) path)
      (project-pathname path)))


;;; Dependency ordering

(-> dialog-bundle-origin-rank (dialog-bundle) nonnegative-integer)
(defun dialog-bundle-origin-rank (bundle)
  (case (dialog-bundle-origin bundle)
    (:bundled 0)
    (:mod 1)
    (t 9)))

(-> dialog-bundle-source-path (dialog-bundle) (option pathname))
(defun dialog-bundle-source-path (bundle)
  (or (dialog-bundle-manifest-path bundle)
      (first (dialog-bundle-script-paths bundle))))

(-> dialog-bundle-sort-key (dialog-bundle) string)
(defun dialog-bundle-sort-key (bundle)
  (format nil "~d:~a"
          (dialog-bundle-origin-rank bundle)
          (or (and (dialog-bundle-source-path bundle)
                   (namestring (dialog-bundle-source-path bundle)))
              (dialog-bundle-id bundle))))

(-> sorted-dialog-bundles-by-fallback (list) list)
(defun sorted-dialog-bundles-by-fallback (bundles)
  (sort (copy-list bundles) #'string< :key #'dialog-bundle-sort-key))

(-> dialog-bundle-id-table (list) hash-table)
(defun dialog-bundle-id-table (bundles)
  (let ((table (make-hash-table :test #'equal)))
    (dolist (bundle bundles)
      (let ((id (dialog-bundle-id bundle)))
        (when (gethash id table)
          (runtime-warn "Duplicate dialog bundle id: ~a" id))
        (setf (gethash id table) bundle)))
    table))

(-> warn-missing-dialog-bundle-dependencies (list hash-table) t)
(defun warn-missing-dialog-bundle-dependencies (bundles bundle-ids)
  (let ((warned (make-hash-table :test #'equal)))
    (dolist (bundle bundles)
      (dolist (dependency (dialog-bundle-dependencies bundle))
        (let ((key (cons (dialog-bundle-id bundle) dependency)))
          (unless (or (gethash dependency bundle-ids)
                      (gethash key warned))
            (runtime-warn "Dialog bundle ~a depends on missing bundle ~a."
                          (dialog-bundle-id bundle)
                          dependency)
            (setf (gethash key warned) t))))))
  t)

(-> dialog-bundle-blocking-dependencies
    (dialog-bundle hash-table hash-table)
    list)
(defun dialog-bundle-blocking-dependencies (bundle loaded-ids bundle-ids)
  (loop for dependency in (dialog-bundle-dependencies bundle)
        when (and (gethash dependency bundle-ids)
                  (not (gethash dependency loaded-ids)))
          collect dependency))

(-> dialog-bundle-ready-p (dialog-bundle hash-table hash-table) boolean)
(defun dialog-bundle-ready-p (bundle loaded-ids bundle-ids)
  (null (dialog-bundle-blocking-dependencies bundle
                                             loaded-ids
                                             bundle-ids)))

(-> sort-dialog-bundles (list) list)
(defun sort-dialog-bundles (bundles)
  (let* ((remaining  (sorted-dialog-bundles-by-fallback bundles))
         (bundle-ids (dialog-bundle-id-table remaining))
         (loaded-ids (make-hash-table :test #'equal))
         (ordered    nil))
    (warn-missing-dialog-bundle-dependencies remaining bundle-ids)
    (loop while remaining
          do (let ((ready   nil)
                   (waiting nil))
               (dolist (bundle remaining)
                 (if (dialog-bundle-ready-p bundle loaded-ids bundle-ids)
                     (push bundle ready)
                     (push bundle waiting)))
               (setf ready (nreverse ready)
                     waiting (nreverse waiting))
               (if ready
                   (progn
                     (dolist (bundle ready)
                       (setf (gethash (dialog-bundle-id bundle) loaded-ids) t)
                       (push bundle ordered))
                     (setf remaining waiting))
                   (progn
                     (runtime-warn
                      "Dialog bundle dependency cycle; using fallback order: ~{~a~^, ~}"
                      (mapcar #'dialog-bundle-id remaining))
                     (dolist (bundle remaining)
                       (push bundle ordered))
                     (setf remaining nil)))))
    (nreverse ordered)))
