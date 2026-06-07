(in-package #:immortal-coil)

(defvar *loaded-dialog-scripts* nil)

(defstruct dialog-script
  (path      "" :type t)
  (origin    :bundled :type dialog-script-origin)
  (id        nil :type (option string))
  (bundle    nil :type (option dialog-bundle)))

(-> dialog-script-pathname (t) pathname)
(defun dialog-script-pathname (path)
  (project-pathname path))

(-> make-dialog-script-for-bundle (dialog-bundle pathname) dialog-script)
(defun make-dialog-script-for-bundle (bundle path)
  (make-dialog-script :path path
                      :origin (dialog-bundle-origin bundle)
                      :id (source-designator-name path)
                      :bundle bundle))

(-> bundled-dialog-bundles (list) list)
(defun bundled-dialog-bundles (sources)
  (mapcar (lambda (source)
            (make-dialog-bundle-source source :bundled))
          sources))

(-> mod-dialog-bundles-maybe () list)
(defun mod-dialog-bundles-maybe ()
  (if (fboundp 'mod-dialog-bundles)
      (funcall (symbol-function 'mod-dialog-bundles))
      nil))

(-> configured-dialog-bundles (&optional list) list)
(defun configured-dialog-bundles (&optional (sources *dialog-manifest-paths*))
  (append (bundled-dialog-bundles sources)
          (mod-dialog-bundles-maybe)))

(-> dialog-bundle-scripts (dialog-bundle) list)
(defun dialog-bundle-scripts (bundle)
  (loop for path in (dialog-bundle-script-paths bundle)
        collect (make-dialog-script-for-bundle bundle path)))

(-> reset-loaded-dialog-scripts () t)
(defun reset-loaded-dialog-scripts ()
  (setf *loaded-dialog-scripts* nil))

(-> record-loaded-dialog-script (dialog-script) dialog-script)
(defun record-loaded-dialog-script (script)
  (setf *loaded-dialog-scripts*
        (append *loaded-dialog-scripts* (list script)))
  script)

(-> dialog-script-source-label (dialog-script) string)
(defun dialog-script-source-label (script)
  (let ((bundle (dialog-script-bundle script)))
    (if bundle
        (format nil "~a:~a"
                (dialog-bundle-id bundle)
                (source-designator-name (dialog-script-path script)))
        (source-designator-name (dialog-script-path script)))))

(-> eval-dialog-script (dialog-script) boolean)
(defun eval-dialog-script (script)
  (handler-case
      (let* ((script-path (dialog-script-pathname (dialog-script-path script)))
             (eof (gensym "EOF")))
        (with-open-file (stream script-path)
          (let ((*package* (find-package "IMMORTAL-COIL"))
                (*current-dialog-source* (dialog-script-source-label script))
                (*current-dialog-bundle* (dialog-script-bundle script)))
            (loop for form = (read stream nil eof)
                  until (eq form eof)
                  do (handler-case
                         (eval form)
                       (error (condition)
                         (runtime-warn "Dialog form failed in ~a: ~s (~a)"
                                       (dialog-script-path script)
                                       form
                                       condition))))))
        t)
    (error (condition)
      (runtime-warn "Dialog script failed to load: ~a (~a)"
                    (dialog-script-path script)
                    condition)
      nil)))

(-> eval-dialog-script-source (dialog-script) boolean)
(defun eval-dialog-script-source (script)
  (when (eval-dialog-script script)
    (record-loaded-dialog-script script)
    t))

(-> eval-dialog-bundle-source (dialog-bundle) boolean)
(defun eval-dialog-bundle-source (bundle)
  (let ((loaded-any-p nil))
    (dolist (script (dialog-bundle-scripts bundle))
      (when (eval-dialog-script-source script)
        (setf loaded-any-p t)))
    (when loaded-any-p
      (record-loaded-dialog-bundle bundle)
      t)))

(-> load-dialog-graph (&optional list) dialog-id)
(defun load-dialog-graph (&optional (sources *dialog-manifest-paths*))
  (reset-dialog-graph)
  (reset-minigames)
  (reset-loaded-dialog-scripts)
  (reset-loaded-dialog-bundles)
  (let ((bundles (configured-dialog-bundles sources)))
    (dolist (bundle bundles)
      (eval-dialog-bundle-source bundle)))
  (unless *story-start-node*
    (runtime-warn "No dialog start node was set by sources: ~s" sources)
    (setf *story-start-node* *runtime-fallback-node-id*))
  (ensure-runtime-fallback-node)
  (setf *story-start-node* (resolve-node-id *story-start-node*))
  *story-start-node*)
