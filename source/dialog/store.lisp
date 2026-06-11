(in-package #:immortal-coil)

;;; Model

(defstruct dialog-store-diff
  (key         "" :type dialog-store-key)
  (old-bound-p nil :type boolean)
  old-value
  (new-bound-p nil :type boolean)
  new-value)

(defclass dialog-store ()
  ((table
    :initform (make-hash-table :test #'equal)
    :accessor dialog-store-table)
   (diffs
    :initform nil
    :accessor dialog-store-diffs)
   (recording-p
    :initform t
    :accessor dialog-store-recording-p)))

(-> make-dialog-store () dialog-store)
(defun make-dialog-store ()
  (make-instance 'dialog-store))

(defvar *dialog-store* (make-dialog-store))


;;; Store access

(-> hash-table-dialog-store (hash-table) dialog-store)
(defun hash-table-dialog-store (table)
  (let ((store (make-dialog-store)))
    (maphash (lambda (key value)
               (setf (gethash key (dialog-store-table store)) value))
             table)
    store))

(-> reset-dialog-store () t)
(defun reset-dialog-store ()
  (setf *dialog-store* (make-dialog-store))
  t)

(-> current-dialog-store () dialog-store)
(defun current-dialog-store ()
  (typecase *dialog-store*
    (dialog-store *dialog-store*)
    (hash-table
     (setf *dialog-store* (hash-table-dialog-store *dialog-store*)))
    (t
     (runtime-warn "Resetting invalid dialog store: ~s" *dialog-store*)
     (reset-dialog-store)
     *dialog-store*)))

(-> current-dialog-store-table () hash-table)
(defun current-dialog-store-table ()
  (dialog-store-table (current-dialog-store)))

(-> dialog-store-diff-needed-p (boolean t boolean t) boolean)
(defun dialog-store-diff-needed-p (old-bound-p old-value new-bound-p new-value)
  (not (and (eq old-bound-p new-bound-p)
            (or (not old-bound-p)
                (equal old-value new-value)))))

(-> record-dialog-store-diff (dialog-store-key boolean t boolean t) boolean)
(defun record-dialog-store-diff (key
                                 old-bound-p
                                 old-value
                                 new-bound-p
                                 new-value)
  (let ((store (current-dialog-store)))
    (when (and (dialog-store-recording-p store)
               (dialog-store-diff-needed-p old-bound-p
                                           old-value
                                           new-bound-p
                                           new-value))
      (push (make-dialog-store-diff :key key
                                    :old-bound-p old-bound-p
                                    :old-value old-value
                                    :new-bound-p new-bound-p
                                    :new-value new-value)
            (dialog-store-diffs store))
      t)))

(defvar *suppress-store-save-p* nil)

(-> notify-store-mutation () t)
(defun notify-store-mutation ()
  "Persist progress whenever durable state changes, even mid-node, so
long minigames that keep their progress in the store survive restarts."
  (unless *suppress-store-save-p*
    (when (fboundp 'save-current-game-maybe)
      (funcall 'save-current-game-maybe))))

(defmacro with-batched-store-saves (() &body body)
  "Run BODY with store-save notifications held, then save once."
  `(progn
     (let ((*suppress-store-save-p* t))
       ,@body)
     (notify-store-mutation)))

(-> dialog-store-get (dialog-store-key &optional t) t)
(defun dialog-store-get (key &optional default)
  (gethash key (current-dialog-store-table) default))

(defun (setf dialog-store-get) (value key &optional default)
  (declare (ignore default))
  (let ((table (current-dialog-store-table)))
    (multiple-value-bind (old-value old-bound-p)
        (gethash key table)
      (record-dialog-store-diff key old-bound-p old-value t value)
      (setf (gethash key table) value)
      (when (or (not old-bound-p)
                (not (equal old-value value)))
        (notify-store-mutation))))
  value)

(-> dialog-store-bound-p (dialog-store-key) boolean)
(defun dialog-store-bound-p (key)
  (nth-value 1 (gethash key (current-dialog-store-table))))

(-> dialog-store-remove (dialog-store-key) boolean)
(defun dialog-store-remove (key)
  (let ((table (current-dialog-store-table)))
    (multiple-value-bind (old-value old-bound-p)
        (gethash key table)
      (when old-bound-p
        (record-dialog-store-diff key old-bound-p old-value nil nil))
      (prog1 (remhash key table)
        (when old-bound-p
          (notify-store-mutation))))))

(-> dialog-store-alist () list)
(defun dialog-store-alist ()
  (loop for key being the hash-keys of (current-dialog-store-table)
          using (hash-value value)
        collect (cons key value)))

(-> dialog-store-entry< (cons cons) boolean)
(defun dialog-store-entry< (left right)
  (not (null (string< (princ-to-string (first left))
                      (princ-to-string (first right))))))

(-> dialog-store-snapshot () list)
(defun dialog-store-snapshot ()
  (sort (copy-list (dialog-store-alist)) #'dialog-store-entry<))

(-> restore-dialog-store (list) t)
(defun restore-dialog-store (entries)
  (reset-dialog-store)
  (let ((table (current-dialog-store-table)))
    (dolist (entry entries)
      (if (consp entry)
          (setf (gethash (first entry) table) (rest entry))
          (runtime-warn "Ignoring malformed dialog store entry: ~s" entry)))))


;;; Rewind support

(-> dialog-store-checkpoint () nonnegative-integer)
(defun dialog-store-checkpoint ()
  (length (dialog-store-diffs (current-dialog-store))))

(-> apply-dialog-store-diff-before (dialog-store-diff) t)
(defun apply-dialog-store-diff-before (diff)
  (let ((table (current-dialog-store-table)))
    (if (dialog-store-diff-old-bound-p diff)
        (setf (gethash (dialog-store-diff-key diff) table)
              (dialog-store-diff-old-value diff))
        (remhash (dialog-store-diff-key diff) table))))

(-> dialog-store-rollback-one () boolean)
(defun dialog-store-rollback-one ()
  (let* ((store (current-dialog-store))
         (diff (first (dialog-store-diffs store))))
    (when diff
      (pop (dialog-store-diffs store))
      (let ((old-recording-p (dialog-store-recording-p store)))
        (unwind-protect
             (progn
               (setf (dialog-store-recording-p store) nil)
               (apply-dialog-store-diff-before diff))
          (setf (dialog-store-recording-p store) old-recording-p)))
      t)))

(-> dialog-store-rewind-to (nonnegative-integer) nonnegative-integer)
(defun dialog-store-rewind-to (checkpoint)
  (loop with rewound = 0
        while (> (dialog-store-checkpoint) checkpoint)
        while (dialog-store-rollback-one)
        do (incf rewound)
        finally (return rewound)))

(-> dialog-store-clear-history () t)
(defun dialog-store-clear-history ()
  (setf (dialog-store-diffs (current-dialog-store)) nil)
  t)


;;; Script-facing aliases

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

(defgeneric test-dialog-condition (condition)
  (:documentation "Evaluate a condition designator to a raw truth value.")
  (:method ((condition null))
    nil)
  (:method ((condition (eql t)))
    t)
  (:method ((condition function))
    (funcall condition))
  (:method ((condition cons))
    (eval-dialog-condition-form condition))
  (:method ((condition symbol))
    (cond
      ((fboundp condition) (funcall condition))
      ((boundp condition) (symbol-value condition))
      (t t)))
  (:method (condition)
    (declare (ignore condition))
    t))

(-> dialog-condition-true-p (t) boolean)
(defun dialog-condition-true-p (condition)
  (handler-case
      (not (null (test-dialog-condition condition)))
    (error (runtime-error)
      (runtime-warn "Dialog condition failed: ~s (~a)"
                    condition
                    runtime-error)
      nil)))
