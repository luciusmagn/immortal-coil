(in-package #:immortal-coil)

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
