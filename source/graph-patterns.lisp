(in-package #:immortal-coil)

(defun dialog-id-string (value)
  (typecase value
    (string value)
    (symbol (string-downcase (symbol-name value)))
    (t (princ-to-string value))))

(defun dialog-ascii-alphanumeric-p (char)
  (or (char<= #\a char #\z)
      (char<= #\A char #\Z)
      (char<= #\0 char #\9)))

(defun dialog-fragment-character (char)
  (if (dialog-ascii-alphanumeric-p char)
      (char-downcase char)
      #\-))

(defun dialog-id-fragment (value)
  (let ((separator-p t))
    (labels ((write-fragment (stream)
               (loop for char across (dialog-id-string value)
                     for fragment-char = (dialog-fragment-character char)
                     do (cond
                          ((char= fragment-char #\-)
                           (unless separator-p
                             (write-char #\- stream)
                             (setf separator-p t)))
                          (t
                           (write-char fragment-char stream)
                           (setf separator-p nil))))))
      (let ((fragment (string-right-trim
                       '(#\-)
                       (with-output-to-string (stream)
                         (write-fragment stream)))))
        (if (plusp (length fragment))
            fragment
            "node")))))

(defun dialog-child-id (parent child)
  (let ((parent-id (string-right-trim '(#\/) (dialog-id-string parent)))
        (child-id  (dialog-id-fragment child)))
    (if (plusp (length parent-id))
        (format nil "~a/~a" parent-id child-id)
        child-id)))

(defun dialog-path-node-id (parent step)
  (if (<= step 1)
      (dialog-id-string parent)
      (dialog-child-id parent step)))

(defun dialog-path-text-string (text)
  (typecase text
    (string text)
    (t
     (runtime-warn "Dialog path text should be a string, got: ~s" text)
     (princ-to-string text))))

(defun dialog-define-path (id texts &key next)
  (let ((path-id (dialog-id-string id)))
    (if texts
        (loop with count = (length texts)
              for text in texts
              for step from 1
              for node-id = (dialog-path-node-id path-id step)
              for next-id = (cond
                              ((< step count)
                               (dialog-path-node-id path-id (1+ step)))
                              (next
                               next))
              do (dialog-text node-id
                              (dialog-path-text-string text)
                              :next next-id))
        (runtime-warn "Dialog path has no text nodes: ~a" path-id))
    path-id))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun dialog-pattern-keyword-p (value)
    (and (symbolp value)
         (keywordp value)))

  (defun dialog-pattern-clause-p (value)
    (and (consp value)
         (dialog-pattern-keyword-p (first value))))

  (defun dialog-pattern-put-key (keys key value)
    (setf (getf keys key) value)
    keys)

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

  (defun dialog-pattern-branch-key (branch key &optional default)
    (let ((value (getf (getf branch :keys) key default)))
      (if (eq value default)
          default
          value)))

  (defun dialog-pattern-branch-suffix (branch)
    (or (dialog-pattern-branch-key branch :id)
        (getf branch :label)))

  (defun dialog-pattern-branch-next (branch)
    (or (dialog-pattern-branch-key branch :next)
        (dialog-pattern-branch-key branch :target)))

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

  (defun dialog-pattern-option-form (parent branch)
    `(dialog-option ,(getf branch :label)
                    ,(dialog-pattern-branch-target parent branch)
                    :when ,(dialog-pattern-branch-key branch :when t)
                    :unless ,(dialog-pattern-branch-key branch :unless nil)))

  (defun dialog-pattern-path-form (parent branch)
    (let ((texts (getf branch :texts)))
      (when texts
        `(dialog-define-path
          (dialog-child-id ,parent ,(dialog-pattern-branch-suffix branch))
          (list ,@texts)
          :next ,(dialog-pattern-branch-next branch)))))

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

(defmacro dialog-path (id &body body)
  (multiple-value-bind (texts keys)
      (dialog-pattern-read-body body)
    `(dialog-define-path ,id
                         (list ,@texts)
                         :next ,(getf keys :next))))

(defmacro dialog-choice-path (id prompt &body branches)
  (dialog-choice-pattern-expansion 'dialog-choice id prompt branches))

(defmacro dialog-pick-path (id prompt &body branches)
  (dialog-choice-pattern-expansion 'dialog-pick id prompt branches))

(defmacro dialog-list-path (id prompt &body branches)
  (dialog-choice-pattern-expansion 'dialog-list id prompt branches))
