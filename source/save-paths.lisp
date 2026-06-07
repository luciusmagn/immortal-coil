(in-package #:immortal-coil)

(defparameter *save-file-path* nil)

(-> save-file-pathname () pathname)
(defun save-file-pathname ()
  (or *save-file-path*
      (let ((save-dir (uiop:getenv "IMMORTAL_COIL_SAVE_DIR")))
        (if save-dir
            (merge-pathnames "current.lisp"
                             (uiop:ensure-directory-pathname save-dir))
            (project-pathname "save/current.lisp")))))
