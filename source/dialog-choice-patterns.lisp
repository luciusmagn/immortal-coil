(in-package #:immortal-coil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (-> dialog-pattern-keyword-p (t) boolean)
  (defun dialog-pattern-keyword-p (value)
    (and (symbolp value)
         (keywordp value)))

  (-> dialog-pattern-clause-p (t) boolean)
  (defun dialog-pattern-clause-p (value)
    (and (consp value)
         (dialog-pattern-keyword-p (first value))))

  (-> dialog-pattern-put-key (plist keyword t) plist)
  (defun dialog-pattern-put-key (keys key value)
    (setf (getf keys key) value)
    keys)

  (-> dialog-pattern-read-body (list) (values list plist))
  (defun dialog-pattern-read-body (forms)
    (let ((keys nil)
          (texts nil))
      (loop while forms
            for form = (first forms)
            do (cond
                 ((dialog-pattern-clause-p form)
                  (setf keys (dialog-pattern-put-key keys
                                                      (first form)
                                                      (second form))
                        forms (rest forms)))
                 ((and (dialog-pattern-keyword-p form)
                       (rest forms))
                  (setf keys (dialog-pattern-put-key keys
                                                      form
                                                      (second forms))
                        forms (rest (rest forms))))
                 ((dialog-pattern-keyword-p form)
                  (setf keys (dialog-pattern-put-key keys form nil)
                        forms (rest forms)))
                 (t
                  (push form texts)
                  (setf forms (rest forms)))))
      (values (nreverse texts) keys)))

  (-> dialog-pattern-branch (t) dialog-pattern-branch-data)
  (defun dialog-pattern-branch (spec)
    (if (consp spec)
        (multiple-value-bind (texts keys)
            (dialog-pattern-read-body (rest spec))
          (list :label (first spec)
                :texts texts
                :keys keys))
        (progn
          (runtime-warn "Ignoring malformed dialog branch pattern: ~s" spec)
          (list :label "continue"
                :texts nil
                :keys nil))))

  (-> dialog-pattern-branch-key
      (dialog-pattern-branch-data keyword &optional t)
      t)
  (defun dialog-pattern-branch-key (branch key &optional default)
    (let ((value (getf (getf branch :keys) key default)))
      (if (eq value default)
          default
          value)))

  (-> dialog-pattern-branch-suffix (dialog-pattern-branch-data) t)
  (defun dialog-pattern-branch-suffix (branch)
    (or (dialog-pattern-branch-key branch :id)
        (getf branch :label)))

  (-> dialog-pattern-branch-next (dialog-pattern-branch-data) t)
  (defun dialog-pattern-branch-next (branch)
    (or (dialog-pattern-branch-key branch :next)
        (dialog-pattern-branch-key branch :target)))

  (-> dialog-pattern-branch-target (symbol dialog-pattern-branch-data) t)
  (defun dialog-pattern-branch-target (parent branch)
    (let ((texts  (getf branch :texts))
          (target (dialog-pattern-branch-key branch :target)))
      (cond
        (texts
         `(dialog-child-id ,parent ,(dialog-pattern-branch-suffix branch)))
        (target
         target)
        (t
         `(progn
            (runtime-warn "Dialog choice branch has no target or text under ~a: ~a"
                          ,parent
                          ,(getf branch :label))
            *runtime-fallback-node-id*)))))

  (-> dialog-pattern-option-form (symbol dialog-pattern-branch-data) cons)
  (defun dialog-pattern-option-form (parent branch)
    `(dialog-option ,(getf branch :label)
                    ,(dialog-pattern-branch-target parent branch)
                    :when ,(dialog-pattern-branch-key branch :when t)
                    :unless ,(dialog-pattern-branch-key branch :unless nil)))

  (-> dialog-pattern-path-form
      (symbol dialog-pattern-branch-data)
      (option cons))
  (defun dialog-pattern-path-form (parent branch)
    (let ((texts (getf branch :texts)))
      (when texts
        `(dialog-define-path
          (dialog-child-id ,parent ,(dialog-pattern-branch-suffix branch))
          (list ,@texts)
          :next ,(dialog-pattern-branch-next branch)))))

  (-> dialog-choice-pattern-expansion (symbol t t list) cons)
  (defun dialog-choice-pattern-expansion (choice-function id prompt branches)
    (let ((parent (gensym "PARENT-"))
          (parsed-branches (mapcar #'dialog-pattern-branch branches)))
      `(let ((,parent ,id))
         (,choice-function
          ,parent
          ,prompt
          ,@(mapcar (lambda (branch)
                      (dialog-pattern-option-form parent branch))
                    parsed-branches))
         ,@(remove nil
                   (mapcar (lambda (branch)
                             (dialog-pattern-path-form parent branch))
                           parsed-branches))
         ,parent))))
