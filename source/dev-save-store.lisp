(in-package #:immortal-coil)

(-> dev-save-store-key (t) dialog-id)
(defun dev-save-store-key (key)
  (typecase key
    (string key)
    (t (dialog-id-string key))))

(-> dev-save-store-entry-value (cons) t)
(defun dev-save-store-entry-value (entry)
  (if (and (consp (rest entry))
           (null (rest (rest entry))))
      (second entry)
      (rest entry)))

(-> dev-save-store-entry (t) (option cons))
(defun dev-save-store-entry (entry)
  (cond
    ((consp entry)
     (cons (dev-save-store-key (first entry))
           (dev-save-store-entry-value entry)))
    (t
     (runtime-warn "Ignoring malformed dev save store entry: ~s" entry)
     nil)))

(-> dev-save-hash-store-alist (hash-table) list)
(defun dev-save-hash-store-alist (store)
  (loop for key being the hash-keys of store
          using (hash-value value)
        collect (cons (dev-save-store-key key) value)))

(-> dev-save-store-alist (t) list)
(defun dev-save-store-alist (store)
  (cond
    ((null store)
     nil)
    ((hash-table-p store)
     (dev-save-hash-store-alist store))
    ((listp store)
     (remove nil (mapcar #'dev-save-store-entry store)))
    (t
     (runtime-warn "Dev save store should be an alist or hash table: ~s" store)
     nil)))
