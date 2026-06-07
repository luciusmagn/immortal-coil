(in-package #:immortal-coil)

(defvar *loaded-dialog-scripts* nil)

(defstruct dialog-script
  (path   "" :type t)
  (origin :bundled :type dialog-script-origin)
  (id     nil :type (option string)))

(-> dialog-script-pathname (t) pathname)
(defun dialog-script-pathname (path)
  (project-pathname path))

(-> make-bundled-dialog-script (t) dialog-script)
(defun make-bundled-dialog-script (path)
  (make-dialog-script :path path
                      :origin :bundled
                      :id (dialog-source-name path)))

(-> bundled-dialog-scripts (list) list)
(defun bundled-dialog-scripts (paths)
  (mapcar #'make-bundled-dialog-script paths))

(-> mod-dialog-scripts-maybe () list)
(defun mod-dialog-scripts-maybe ()
  (if (fboundp 'mod-dialog-scripts)
      (funcall (symbol-function 'mod-dialog-scripts))
      nil))

(-> configured-dialog-scripts (&optional list) list)
(defun configured-dialog-scripts (&optional (paths *dialog-script-paths*))
  (append (bundled-dialog-scripts paths)
          (mod-dialog-scripts-maybe)))

(-> reset-loaded-dialog-scripts () t)
(defun reset-loaded-dialog-scripts ()
  (setf *loaded-dialog-scripts* nil))

(-> record-loaded-dialog-script (dialog-script) dialog-script)
(defun record-loaded-dialog-script (script)
  (setf *loaded-dialog-scripts*
        (append *loaded-dialog-scripts* (list script)))
  script)

(-> eval-dialog-script (t) boolean)
(defun eval-dialog-script (path)
  (handler-case
      (let* ((script-path (dialog-script-pathname path))
             (eof (gensym "EOF")))
        (with-open-file (stream script-path)
          (let ((*package* (find-package "IMMORTAL-COIL"))
                (*current-dialog-source* script-path))
            (loop for form = (read stream nil eof)
                  until (eq form eof)
                  do (handler-case
                         (eval form)
                       (error (condition)
                         (runtime-warn "Dialog form failed in ~a: ~s (~a)"
                                       path
                                       form
                                       condition))))))
        t)
    (error (condition)
      (runtime-warn "Dialog script failed to load: ~a (~a)"
                    path
                    condition)
      nil)))

(-> eval-dialog-script-source (dialog-script) boolean)
(defun eval-dialog-script-source (script)
  (when (eval-dialog-script (dialog-script-path script))
    (record-loaded-dialog-script script)
    t))

(-> load-dialog-graph (&optional list) dialog-id)
(defun load-dialog-graph (&optional (paths *dialog-script-paths*))
  (reset-dialog-graph)
  (reset-loaded-dialog-scripts)
  (let ((scripts (configured-dialog-scripts paths)))
    (dolist (script scripts)
      (eval-dialog-script-source script)))
  (unless *story-start-node*
    (runtime-warn "No dialog start node was set by scripts: ~s" paths)
    (setf *story-start-node* *runtime-fallback-node-id*))
  (ensure-runtime-fallback-node)
  (setf *story-start-node* (resolve-node-id *story-start-node*))
  *story-start-node*)
