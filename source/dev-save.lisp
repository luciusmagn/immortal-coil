(in-package #:immortal-coil)

(defparameter *dev-save-overrides-enabled-p* t)

(defun dev-save-overrides-enabled-p ()
  (and *dev-save-overrides-enabled-p*
       (not (member (string-downcase
                     (or (uiop:getenv "IMMORTAL_COIL_DISABLE_DEV_SAVE")
                         ""))
                    '("1" "true" "yes" "on")
                    :test #'string=))))

(defun dev-save-store-key (key)
  (typecase key
    (string key)
    (t (dialog-id-string key))))

(defun dev-save-store-entry-value (entry)
  (if (and (consp (rest entry))
           (null (rest (rest entry))))
      (second entry)
      (rest entry)))

(defun dev-save-store-entry (entry)
  (cond
    ((consp entry)
     (cons (dev-save-store-key (first entry))
           (dev-save-store-entry-value entry)))
    (t
     (runtime-warn "Ignoring malformed dev save store entry: ~s" entry)
     nil)))

(defun dev-save-hash-store-alist (store)
  (loop for key being the hash-keys of store
          using (hash-value value)
        collect (cons (dev-save-store-key key) value)))

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

(defun dev-save-nonnegative-integer (value &optional (default 0))
  (if (integerp value)
      (max 0 value)
      default))

(defun dev-save-visible-count (visible visible-count)
  (let ((value (or visible-count visible 0)))
    (cond
      ((or (eq value t)
           (eq value :all))
       most-positive-fixnum)
      ((integerp value)
       (max 0 value))
      (t
       0))))

(defun dev-save-particle-field-state (particle-mode particle-field)
  (cond
    ((and particle-field
          (listp particle-field))
     particle-field)
    (particle-field
     (runtime-warn "Dev save particle field should be a save plist: ~s"
                   particle-field)
     nil)
    (particle-mode
     (list :mode particle-mode
           :from-mode particle-mode
           :to-mode particle-mode
           :transition-elapsed 0.0
           :transition-seconds 0.0))
    (t
     nil)))

(defun make-dev-save-data (id
                           &key
                             store
                             visible
                             visible-count
                             selected-index
                             input-buffer
                             particle-mode
                             particle-field
                             &allow-other-keys)
  (list :version 1
        :current-id (dialog-id-string id)
        :visible-count (dev-save-visible-count visible visible-count)
        :selected-index (dev-save-nonnegative-integer selected-index)
        :input-buffer (if (stringp input-buffer)
                          input-buffer
                          "")
        :dialog-store (dev-save-store-alist store)
        :particle-field (dev-save-particle-field-state particle-mode
                                                       particle-field)))

(defun dialog-dev-save (id &rest options)
  (if id
      (setf *dev-save-override*
            (apply #'make-dev-save-data id options))
      (progn
        (runtime-warn "dialog-dev-save needs a node id.")
        (setf *dev-save-override* nil)))
  *dev-save-override*)

(defun dialog-dev-save-here (&rest options)
  (if *last-dialog-node-id*
      (apply #'dialog-dev-save *last-dialog-node-id* options)
      (progn
        (runtime-warn "dialog-dev-save-here has no previous dialog node.")
        nil)))

(defun dialog-clear-dev-save ()
  (setf *dev-save-override* nil))

(defun dev-save-override-data ()
  (when (and (dev-save-overrides-enabled-p)
             *dev-save-override*)
    *dev-save-override*))

(defun dev-save-override-exists-p ()
  (not (null (dev-save-override-data))))
