(in-package #:immortal-coil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (-> dialog-id-string (t) string)
  (defun dialog-id-string (value)
    (typecase value
      (string value)
      (symbol (string-downcase (symbol-name value)))
      (t (princ-to-string value))))

  (-> dialog-ascii-alphanumeric-p (character) boolean)
  (defun dialog-ascii-alphanumeric-p (char)
    (or (char<= #\a char #\z)
        (char<= #\A char #\Z)
        (char<= #\0 char #\9)))

  (-> dialog-fragment-character (character) character)
  (defun dialog-fragment-character (char)
    (if (dialog-ascii-alphanumeric-p char)
        (char-downcase char)
        #\-))

  (-> dialog-id-fragment (t) string)
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

  (-> dialog-child-id (t t) dialog-id)
  (defun dialog-child-id (parent child)
    (let ((parent-id (string-right-trim '(#\/) (dialog-id-string parent)))
          (child-id  (dialog-id-fragment child)))
      (if (plusp (length parent-id))
          (format nil "~a/~a" parent-id child-id)
          child-id)))

  (-> dialog-path-node-id (t integer) dialog-id)
  (defun dialog-path-node-id (parent step)
    (if (<= step 1)
        (dialog-id-string parent)
        (dialog-child-id parent step)))

  (-> dialog-path-text-string (t) string)
  (defun dialog-path-text-string (text)
    (typecase text
      (string text)
      (t
       (runtime-warn "Dialog path text should be a string, got: ~s" text)
       (princ-to-string text))))

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

  (-> dialog-pattern-option (t) dialog-pattern-option-data)
  (defun dialog-pattern-option (spec)
    (if (consp spec)
        (multiple-value-bind (texts keys)
            (dialog-pattern-read-body (rest spec))
          (list :label (first spec)
                :texts texts
                :keys keys))
        (progn
          (runtime-warn "Ignoring malformed dialog option pattern: ~s" spec)
          (list :label "continue"
                :texts nil
                :keys nil))))

  (-> dialog-pattern-option-key
      (dialog-pattern-option-data keyword &optional t)
      t)
  (defun dialog-pattern-option-key (option key &optional default)
    (let ((value (getf (getf option :keys) key default)))
      (if (eq value default)
          default
          value)))

  (-> dialog-pattern-option-suffix (dialog-pattern-option-data) t)
  (defun dialog-pattern-option-suffix (option)
    (or (dialog-pattern-option-key option :id)
        (getf option :label)))

  (-> dialog-pattern-option-next (dialog-pattern-option-data) t)
  (defun dialog-pattern-option-next (option)
    (or (dialog-pattern-option-key option :next)
        (dialog-pattern-option-key option :target)))

  (-> dialog-pattern-option-target (symbol dialog-pattern-option-data) t)
  (defun dialog-pattern-option-target (parent option)
    (let ((texts  (getf option :texts))
          (target (dialog-pattern-option-key option :target)))
      (cond
        (texts
         `(dialog-child-id ,parent ,(dialog-pattern-option-suffix option)))
        (target
         target)
        (t
         `(progn
            (runtime-warn "Dialog choice option has no target or text under ~a: ~a"
                          ,parent
                          ,(getf option :label))
            *runtime-fallback-node-id*)))))

  (-> dialog-pattern-option-form (symbol dialog-pattern-option-data) cons)
  (defun dialog-pattern-option-form (parent option)
    `(dialog-option ,(getf option :label)
                    ,(dialog-pattern-option-target parent option)
                    :when ,(dialog-pattern-option-key option :when t)
                    :unless ,(dialog-pattern-option-key option :unless nil)
                    :enabled-when
                    ,(dialog-pattern-option-key option :enabled-when t)
                    :enabled-unless
                    ,(dialog-pattern-option-key option :enabled-unless nil)))

  (-> dialog-pattern-path-form
      (symbol dialog-pattern-option-data)
      (option cons))
  (defun dialog-pattern-path-form (parent option)
    (let ((texts (getf option :texts)))
      (when texts
        `(dialog-define-path
          (dialog-child-id ,parent ,(dialog-pattern-option-suffix option))
          (list ,@texts)
          :next ,(dialog-pattern-option-next option)))))

  (-> dialog-choice-pattern-expansion (symbol t t list) cons)
  (defun dialog-choice-pattern-expansion (choice-function id prompt options)
    (let ((parent (gensym "PARENT-"))
          (parsed-options (mapcar #'dialog-pattern-option options)))
      `(let ((,parent ,id))
         (,choice-function
          ,parent
          ,prompt
          ,@(mapcar (lambda (option)
                      (dialog-pattern-option-form parent option))
                    parsed-options))
         ,@(remove nil
                   (mapcar (lambda (option)
                             (dialog-pattern-path-form parent option))
                           parsed-options))
         ,parent))))

  (-> dialog-interrogation-asked-key (t t) dialog-store-key)
  (defun dialog-interrogation-asked-key (parent suffix)
    (format nil "~a/asked/~a"
            (dialog-id-string parent)
            (dialog-id-fragment suffix)))

  (-> dialog-interrogation-question-target (symbol dialog-pattern-option-data)
      cons)
  (defun dialog-interrogation-question-target (parent option)
    `(dialog-child-id ,parent ,(dialog-pattern-option-suffix option)))

  (-> dialog-interrogation-question-unless
      (symbol dialog-pattern-option-data)
      cons)
  (defun dialog-interrogation-question-unless (parent option)
    (let ((suffix (dialog-pattern-option-suffix option))
          (custom-unless (dialog-pattern-option-key option :unless nil)))
      (if custom-unless
          `#'(lambda ()
               (or (dialog-value
                    (dialog-interrogation-asked-key ,parent ,suffix))
                   (dialog-condition-true-p ,custom-unless)))
          `#'(lambda ()
               (dialog-value
                (dialog-interrogation-asked-key ,parent ,suffix))))))

  (-> dialog-interrogation-question-option-form
      (symbol dialog-pattern-option-data)
      cons)
  (defun dialog-interrogation-question-option-form (parent option)
    `(dialog-option ,(getf option :label)
                    ,(dialog-interrogation-question-target parent option)
                    :when ,(dialog-pattern-option-key option :when t)
                    :unless ,(dialog-interrogation-question-unless parent
                                                                   option)
                    :enabled-when
                    ,(dialog-pattern-option-key option :enabled-when t)
                    :enabled-unless
                    ,(dialog-pattern-option-key option :enabled-unless nil)))

  (-> dialog-interrogation-all-asked-condition
      (symbol list)
      cons)
  (defun dialog-interrogation-all-asked-condition (parent options)
    `#'(lambda ()
         (and ,@(loop for option in options
                      collect `(dialog-value
                                (dialog-interrogation-asked-key
                                 ,parent
                                 ,(dialog-pattern-option-suffix option)))))))

  (-> dialog-interrogation-continue-option-form
      (symbol string t boolean list)
      cons)
  (defun dialog-interrogation-continue-option-form (parent
                                                    label
                                                    target
                                                    require-all-p
                                                    options)
    `(dialog-option ,label
                    ,target
                    :when ,(if require-all-p
                               (dialog-interrogation-all-asked-condition
                                parent
                                options)
                               t)))

  (-> dialog-interrogation-question-answer-forms
      (symbol dialog-pattern-option-data)
      list)
  (defun dialog-interrogation-question-answer-forms (parent option)
    (let ((texts (getf option :texts))
          (suffix (dialog-pattern-option-suffix option))
          (speaker (dialog-pattern-option-key option :speaker nil)))
      (if texts
          `((dialog-on-enter
             ,(dialog-interrogation-question-target parent option)
             `(setf (dialog-value
                     ,(dialog-interrogation-asked-key ,parent ,suffix))
                    t))
            (dialog-define-interrogation-answer
             ,(dialog-interrogation-question-target parent option)
             (list ,@texts)
             :speaker ,speaker
             :next ,parent))
          `((runtime-warn
             "Dialog interrogation question has no answer text under ~a: ~a"
             ,parent
             ,(getf option :label))))))

  (-> dialog-interrogation-expansion (t t list) cons)
  (defun dialog-interrogation-expansion (id prompt body)
    (multiple-value-bind (question-specs keys)
        (dialog-pattern-read-body body)
      (let* ((parent (gensym "PARENT-"))
             (options (mapcar #'dialog-pattern-option question-specs))
             (target (getf keys :next))
             (continue-label (or (getf keys :continue-label) "continue"))
             (require-all-p (not (null (getf keys :require-all)))))
        `(let ((,parent ,id))
           (dialog-pick
            ,parent
            ,prompt
            ,@(mapcar (lambda (option)
                        (dialog-interrogation-question-option-form parent
                                                                   option))
                      options)
            ,(dialog-interrogation-continue-option-form
              parent
              continue-label
              (or target
                  `(progn
                     (runtime-warn "Dialog interrogation needs :next: ~a"
                                   ,parent)
                     *runtime-fallback-node-id*))
              require-all-p
              options))
           ,@(loop for option in options
                   append (dialog-interrogation-question-answer-forms
                           parent
                           option))
           ,parent))))

(-> dialog-define-path (t list &key (:next (option dialog-id))) dialog-id)
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

(defmacro dialog-path (id &body body)
  (multiple-value-bind (texts keys)
      (dialog-pattern-read-body body)
    `(dialog-define-path ,id
                         (list ,@texts)
                         :next ,(getf keys :next))))

(defmacro dialog-choice-path (id prompt &body options)
  (dialog-choice-pattern-expansion 'dialog-choice id prompt options))

(defmacro dialog-pick-path (id prompt &body options)
  (dialog-choice-pattern-expansion 'dialog-pick id prompt options))

(defmacro dialog-list-path (id prompt &body options)
  (dialog-choice-pattern-expansion 'dialog-list id prompt options))

(-> dialog-define-interrogation-answer
    (t list &key (:speaker (option string)) (:next (option dialog-target)))
    dialog-id)
(defun dialog-define-interrogation-answer (id texts &key speaker next)
  (let ((path-id (dialog-id-string id)))
    (if speaker
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
                  do (dialog-say node-id
                                 speaker
                                 (dialog-path-text-string text)
                                 :next next-id))
            (runtime-warn "Dialog interrogation answer has no text: ~a"
                          path-id))
        (dialog-define-path path-id texts :next next))
    path-id))

(defmacro dialog-interrogation (id prompt &body body)
  (dialog-interrogation-expansion id prompt body))
