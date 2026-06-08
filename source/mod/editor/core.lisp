(in-package #:immortal-coil)

;;; State

(defparameter *mod-manifest-fields*
  #(:id :name :version :author :description :scripts :assets :depends-on :start))

(defvar *mod-editor-mode* :inactive)
(defvar *mod-manifest-action* :create)
(defvar *mod-manifest-field-index* 0)
(defvar *mod-manifest-buffers* (make-hash-table :test #'eq))
(defvar *mod-manifest-status* nil)
(defvar *mod-manifest-path* nil)
(defvar *mod-manifest-original-text* nil)
(defvar *mod-manifest-original-form* nil)
(defvar *mod-picker-bundles* nil)
(defvar *mod-picker-index* 0)
(defvar *mod-editor-backspace-held-seconds* 0.0)
(defvar *mod-editor-backspace-repeat-accumulator* 0.0)


;;; General helpers

(-> mod-editor-active-p () boolean)
(defun mod-editor-active-p ()
  (not (eq *mod-editor-mode* :inactive)))

(-> reset-mod-editor-backspace-repeat () t)
(defun reset-mod-editor-backspace-repeat ()
  (setf *mod-editor-backspace-held-seconds* 0.0
        *mod-editor-backspace-repeat-accumulator* 0.0)
  t)

(-> reset-mod-editor-state () t)
(defun reset-mod-editor-state ()
  (setf *mod-editor-mode* :inactive
        *mod-manifest-action* :create
        *mod-manifest-field-index* 0
        *mod-manifest-status* nil
        *mod-manifest-path* nil
        *mod-manifest-original-text* nil
        *mod-manifest-original-form* nil
        *mod-picker-bundles* nil
        *mod-picker-index* 0)
  (clrhash *mod-manifest-buffers*)
  (reset-mod-editor-backspace-repeat))

(-> mod-manifest-current-field () mod-manifest-field)
(defun mod-manifest-current-field ()
  (aref *mod-manifest-fields*
        (min (max 0 *mod-manifest-field-index*)
             (1- (length *mod-manifest-fields*)))))

(-> mod-manifest-field-label (mod-manifest-field) string)
(defun mod-manifest-field-label (field)
  (case field
    (:depends-on "DEPENDS")
    (t (string-upcase (symbol-name field)))))

(-> mod-manifest-field-value (mod-manifest-field) string)
(defun mod-manifest-field-value (field)
  (gethash field *mod-manifest-buffers* ""))

(-> (setf mod-manifest-field-value) (string mod-manifest-field) string)
(defun (setf mod-manifest-field-value) (value field)
  (setf (gethash field *mod-manifest-buffers*) value))

(-> mod-editor-nonempty-string-p (string) boolean)
(defun mod-editor-nonempty-string-p (text)
  (plusp (length (string-trim '(#\Space #\Tab #\Newline #\Return) text))))

(-> mod-editor-trim (string) string)
(defun mod-editor-trim (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return) text))

(-> mod-editor-list-field-values (string) list)
(defun mod-editor-list-field-values (text)
  (remove-if-not #'mod-editor-nonempty-string-p
                 (mapcar #'mod-editor-trim
                         (uiop:split-string text :separator ","))))

(-> mod-editor-join-list-values (list) string)
(defun mod-editor-join-list-values (values)
  (format nil "~{~a~^, ~}" values))

(-> mod-editor-read-file-string (pathname) (option string))
(defun mod-editor-read-file-string (path)
  (handler-case
      (uiop:read-file-string path)
    (error (condition)
      (runtime-warn "Could not read mod manifest text ~a: ~a"
                    path
                    condition)
      nil)))

(-> mod-editor-relative-path-label (pathname pathname) string)
(defun mod-editor-relative-path-label (root path)
  (handler-case
      (enough-namestring path root)
    (error ()
      (namestring path))))

(-> mod-editor-relative-script-labels (dialog-bundle) list)
(defun mod-editor-relative-script-labels (bundle)
  (loop for path in (dialog-bundle-script-paths bundle)
        collect (mod-editor-relative-path-label (dialog-bundle-root bundle)
                                                path)))

(-> mod-editor-relative-asset-label (dialog-bundle) string)
(defun mod-editor-relative-asset-label (bundle)
  (mod-editor-relative-path-label (dialog-bundle-root bundle)
                                  (dialog-bundle-asset-root bundle)))
