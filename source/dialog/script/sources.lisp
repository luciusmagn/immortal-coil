(in-package #:immortal-coil)

(-> bundled-dialog-bundles (list) list)
(defun bundled-dialog-bundles (sources)
  (loop for source in sources
        for bundle = (make-dialog-bundle-source source :bundled)
        when bundle
          collect bundle))

(-> mod-dialog-bundles-maybe () list)
(defun mod-dialog-bundles-maybe ()
  (if (fboundp 'mod-dialog-bundles)
      (funcall (symbol-function 'mod-dialog-bundles))
      nil))

(-> configured-dialog-bundles (&optional list) list)
(defun configured-dialog-bundles (&optional (sources *dialog-manifest-paths*))
  (sort-dialog-bundles
   (append (bundled-dialog-bundles sources)
           (mod-dialog-bundles-maybe))))
