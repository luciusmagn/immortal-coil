(in-package #:immortal-coil)

(-> dialog-asset-pathname (t &key (:bundle (option dialog-bundle))) pathname)
(defun dialog-asset-pathname (path &key (bundle *current-dialog-bundle*))
  (if bundle
      (resolve-relative-pathname (dialog-bundle-asset-root bundle) path)
      (project-pathname path)))
