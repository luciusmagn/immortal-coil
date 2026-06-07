(in-package #:immortal-coil)

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
