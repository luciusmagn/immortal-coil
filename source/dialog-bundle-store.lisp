(in-package #:immortal-coil)

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
