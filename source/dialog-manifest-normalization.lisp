(in-package #:immortal-coil)

(-> normalize-bundle-id (t t) dialog-bundle-id)
(defun normalize-bundle-id (id fallback)
  (typecase id
    (string id)
    (symbol (string-downcase (symbol-name id)))
    (t (source-designator-name fallback))))

(-> normalize-bundle-name (t string) string)
(defun normalize-bundle-name (name fallback)
  (typecase name
    (string name)
    (symbol (string-capitalize (string-downcase (symbol-name name))))
    (t fallback)))

(-> normalize-bundle-version (t) (option string))
(defun normalize-bundle-version (version)
  (typecase version
    (null nil)
    (string version)
    (symbol (string-downcase (symbol-name version)))
    (t (princ-to-string version))))

(-> normalize-manifest-string (t) (option string))
(defun normalize-manifest-string (value)
  (typecase value
    (null nil)
    (string value)
    (symbol (string-downcase (symbol-name value)))
    (t nil)))

(-> manifest-list-value (t) list)
(defun manifest-list-value (value)
  (cond
    ((null value)
     nil)
    ((listp value)
     value)
    (t
     (list value))))

(-> manifest-path-designator-p (t) boolean)
(defun manifest-path-designator-p (value)
  (typep value '(or pathname string)))
