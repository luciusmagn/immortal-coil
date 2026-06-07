(in-package #:immortal-coil)

(-> loaded-mod-scripts () list)
(defun loaded-mod-scripts ()
  (remove-if-not (lambda (script)
                   (eq (dialog-script-origin script) :mod))
                 *loaded-dialog-scripts*))

(-> loaded-mod-bundles () list)
(defun loaded-mod-bundles ()
  (remove-if-not (lambda (bundle)
                   (eq (dialog-bundle-origin bundle) :mod))
                 *loaded-dialog-bundles*))

(-> dialog-mod-conflict-count () nonnegative-integer)
(defun dialog-mod-conflict-count ()
  (length *dialog-conflicts*))

(-> discovered-mod-count () nonnegative-integer)
(defun discovered-mod-count ()
  (if (mods-enabled-p)
      (length (mod-source-pathnames))
      0))

(-> loaded-mod-count () nonnegative-integer)
(defun loaded-mod-count ()
  (length (loaded-mod-bundles)))

(-> plural-s (integer) string)
(defun plural-s (count)
  (if (= count 1) "" "S"))

(-> dialog-mod-status-summary () string)
(defun dialog-mod-status-summary ()
  (if (mods-enabled-p)
      (let ((loaded (loaded-mod-count))
            (found (discovered-mod-count))
            (conflicts (dialog-mod-conflict-count)))
        (if (plusp loaded)
            (format nil "MODS: ~d LOADED / ~d CONFLICT~a"
                    loaded
                    conflicts
                    (plural-s conflicts))
            (format nil "MODS: ~d FOUND" found)))
      "MODS: DISABLED"))

(-> refresh-dialog-mod-status () string)
(defun refresh-dialog-mod-status ()
  (handler-case
      (progn
        (load-dialog-graph)
        (dialog-mod-status-summary))
    (error (condition)
      (runtime-warn "Could not refresh mod status: ~a" condition)
      "MODS: ERROR")))
