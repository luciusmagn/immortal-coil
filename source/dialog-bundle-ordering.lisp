(in-package #:immortal-coil)

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
