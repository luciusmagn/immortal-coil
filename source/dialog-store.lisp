(in-package #:immortal-coil)

(defvar *dialog-store* (make-hash-table :test #'equal))

(defun reset-dialog-store ()
  (clrhash *dialog-store*))

(defun dialog-store-get (key &optional default)
  (gethash key *dialog-store* default))

(defun (setf dialog-store-get) (value key &optional default)
  (declare (ignore default))
  (setf (gethash key *dialog-store*) value))

(defun dialog-store-bound-p (key)
  (nth-value 1 (gethash key *dialog-store*)))

(defun dialog-store-remove (key)
  (remhash key *dialog-store*))

(defun dialog-store-alist ()
  (loop for key being the hash-keys of *dialog-store*
          using (hash-value value)
        collect (cons key value)))

(defun restore-dialog-store (entries)
  (reset-dialog-store)
  (dolist (entry entries)
    (setf (dialog-store-get (first entry)) (rest entry))))

(defun dialog-value (key &optional default)
  (dialog-store-get key default))

(defun (setf dialog-value) (value key &optional default)
  (declare (ignore default))
  (setf (dialog-store-get key) value))

(defun lambda-expression-p (value)
  (and (consp value)
       (eq (first value) 'lambda)))

(defun function-expression-p (value)
  (and (consp value)
       (eq (first value) 'function)))

(defun eval-dialog-condition-form (condition)
  (cond
    ((lambda-expression-p condition)
     (funcall (compile nil condition)))
    ((function-expression-p condition)
     (funcall (eval condition)))
    (t
     (eval condition))))

(defun dialog-condition-true-p (condition)
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
     t)))
