(in-package #:immortal-coil)

(defun dialog-script-pathname (path)
  (project-pathname path))

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

(defun load-dialog-mods-maybe ()
  (when (fboundp 'load-dialog-mods)
    (funcall (symbol-function 'load-dialog-mods))))

(defun load-dialog-graph (&optional (paths *dialog-script-paths*))
  (reset-dialog-graph)
  (dolist (path paths)
    (eval-dialog-script path))
  (load-dialog-mods-maybe)
  (unless *story-start-node*
    (runtime-warn "No dialog start node was set by scripts: ~s" paths)
    (setf *story-start-node* *runtime-fallback-node-id*))
  (ensure-runtime-fallback-node)
  (setf *story-start-node* (resolve-node-id *story-start-node*))
  *story-start-node*)
