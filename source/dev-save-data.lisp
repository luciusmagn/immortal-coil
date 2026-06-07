(in-package #:immortal-coil)

(-> dev-save-nonnegative-integer (t &optional nonnegative-integer)
    nonnegative-integer)
(defun dev-save-nonnegative-integer (value &optional (default 0))
  (if (integerp value)
      (max 0 value)
      default))

(-> dev-save-visible-count (t t) nonnegative-integer)
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

(-> dev-save-particle-field-state (t t) (option list))
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

(-> make-dev-save-data (t
                        &key
                        (:store t)
                        (:visible t)
                        (:visible-count t)
                        (:selected-index t)
                        (:input-buffer t)
                        (:particle-mode t)
                        (:particle-field t)
                        &allow-other-keys)
    save-data)
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
