(in-package #:immortal-coil)

(-> mod-disable-env-value-p (string) boolean)
(defun mod-disable-env-value-p (value)
  (not (null (member (string-downcase value)
                     '("1" "true" "yes" "on")
                     :test #'string=))))

(-> mods-enabled-p () boolean)
(defun mods-enabled-p ()
  (not (mod-disable-env-value-p
        (or (uiop:getenv "IMMORTAL_COIL_DISABLE_MODS")
            ""))))

(-> extra-mod-directory-paths () list)
(defun extra-mod-directory-paths ()
  (let ((extra (uiop:getenv "IMMORTAL_COIL_MOD_DIR")))
    (if extra
        (uiop:split-string extra :separator ":")
        nil)))

(-> configured-mod-directory-paths () list)
(defun configured-mod-directory-paths ()
  (append *mod-directory-paths*
          (extra-mod-directory-paths)))

(-> mod-directory-pathname (t) pathname)
(defun mod-directory-pathname (path)
  (uiop:ensure-directory-pathname (project-pathname path)))

(-> mod-directory-pathnames () list)
(defun mod-directory-pathnames ()
  (loop for path in (configured-mod-directory-paths)
        for pathname = (mod-directory-pathname path)
        when (uiop:directory-exists-p pathname)
          collect pathname))
