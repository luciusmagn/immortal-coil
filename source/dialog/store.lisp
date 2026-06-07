(in-package #:immortal-coil)

(defvar *dialog-store* (make-hash-table :test #'equal))

(-> reset-dialog-store () t)
(defun reset-dialog-store ()
  (clrhash *dialog-store*))

(-> dialog-store-get (dialog-store-key &optional t) t)
(defun dialog-store-get (key &optional default)
  (gethash key *dialog-store* default))

(defun (setf dialog-store-get) (value key &optional default)
  (declare (ignore default))
  (setf (gethash key *dialog-store*) value))

(-> dialog-store-bound-p (dialog-store-key) boolean)
(defun dialog-store-bound-p (key)
  (nth-value 1 (gethash key *dialog-store*)))

(-> dialog-store-remove (dialog-store-key) boolean)
(defun dialog-store-remove (key)
  (remhash key *dialog-store*))

(-> dialog-store-alist () list)
(defun dialog-store-alist ()
  (loop for key being the hash-keys of *dialog-store*
          using (hash-value value)
        collect (cons key value)))

(-> restore-dialog-store (list) t)
(defun restore-dialog-store (entries)
  (reset-dialog-store)
  (dolist (entry entries)
    (if (consp entry)
        (setf (dialog-store-get (first entry)) (rest entry))
        (runtime-warn "Ignoring malformed dialog store entry: ~s" entry))))

(-> dialog-value (dialog-store-key &optional t) t)
(defun dialog-value (key &optional default)
  (dialog-store-get key default))

(defun (setf dialog-value) (value key &optional default)
  (declare (ignore default))
  (setf (dialog-store-get key) value))

(-> lambda-expression-p (t) boolean)
(defun lambda-expression-p (value)
  (and (consp value)
       (eq (first value) 'lambda)))

(-> function-expression-p (t) boolean)
(defun function-expression-p (value)
  (and (consp value)
       (eq (first value) 'function)))

(-> eval-dialog-condition-form (t) t)
(defun eval-dialog-condition-form (condition)
  (cond
    ((lambda-expression-p condition)
     (funcall (compile nil condition)))
    ((function-expression-p condition)
     (funcall (eval condition)))
    (t
     (eval condition))))

(-> dialog-condition-true-p (t) boolean)
(defun dialog-condition-true-p (condition)
  (handler-case
      (cond
        ((null condition) nil)
        ((eq condition t) t)
        ((functionp condition) (not (null (funcall condition))))
        ((consp condition) (not (null (eval-dialog-condition-form condition))))
        ((and (symbolp condition) (fboundp condition))
         (not (null (funcall condition))))
        ((and (symbolp condition) (boundp condition))
         (not (null (symbol-value condition))))
        (t
         t))
    (error (runtime-error)
      (runtime-warn "Dialog condition failed: ~s (~a)"
                    condition
                    runtime-error)
      nil)))
