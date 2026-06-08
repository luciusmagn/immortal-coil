(in-package #:immortal-coil)

;;; Draft persistence

(-> editor-draft-script-pathname () pathname)
(defun editor-draft-script-pathname ()
  (project-pathname *editor-draft-script-path*))

(-> editor-linear-next-node-p (node) boolean)
(defun editor-linear-next-node-p (node)
  (not (null (member (node-kind node)
                     '(:text :say :conversation)))))

(-> editor-generated-child-id-with-prefix (dialog-id) dialog-id)
(defun editor-generated-child-id-with-prefix (prefix)
  (loop for index from 1
        for child-id = (format nil "~a/edit-~d" prefix index)
        unless (node-exists-p child-id)
          return child-id))

(-> editor-generated-child-id (dialog-id) dialog-id)
(defun editor-generated-child-id (parent-id)
  (editor-generated-child-id-with-prefix parent-id))

(-> editor-generated-choice-child-id (dialog-id nonnegative-integer)
    dialog-id)
(defun editor-generated-choice-child-id (parent-id choice-index)
  (editor-generated-child-id-with-prefix
   (format nil "~a/option-~d" parent-id (1+ choice-index))))

(-> editor-target-form (t) t)
(defun editor-target-form (target)
  (cond
    ((null target)
     nil)
    ((stringp target)
     target)
    ((or (symbolp target)
         (lambda-expression-p target)
         (function-expression-p target))
     `(quote ,target))
    (t
     (runtime-warn "Editor cannot persist unreadable target: ~s" target)
     *runtime-fallback-node-id*)))

(-> editor-write-target (t t) t)
(defun editor-write-target (stream target)
  (format stream "~s" (editor-target-form target)))

(-> editor-write-set-next-form (t dialog-id (option dialog-target)) t)
(defun editor-write-set-next-form (stream parent-id child-id)
  (format stream "~&(dialog-set-next ~s " parent-id)
  (editor-write-target stream child-id)
  (format stream ")~2%"))

(-> editor-write-set-choice-target-form
    (t dialog-id nonnegative-integer dialog-target)
    t)
(defun editor-write-set-choice-target-form (stream node-id choice-index target)
  (format stream "~&(dialog-set-choice-target ~s ~d "
          node-id
          choice-index)
  (editor-write-target stream target)
  (format stream ")~2%"))

(-> editor-write-set-choice-visible-predicate-form
    (t dialog-id nonnegative-integer dialog-condition)
    t)
(defun editor-write-set-choice-visible-predicate-form (stream
                                                       node-id
                                                       choice-index
                                                       predicate)
  (format stream "~&(dialog-set-choice-visible-predicate ~s ~d "
          node-id
          choice-index)
  (editor-write-target stream predicate)
  (format stream ")~2%"))

(-> editor-write-set-choice-enabled-predicate-form
    (t dialog-id nonnegative-integer dialog-condition)
    t)
(defun editor-write-set-choice-enabled-predicate-form (stream
                                                       node-id
                                                       choice-index
                                                       predicate)
  (format stream "~&(dialog-set-choice-enabled-predicate ~s ~d "
          node-id
          choice-index)
  (editor-write-target stream predicate)
  (format stream ")~2%"))

(-> editor-write-delete-node-form (t dialog-id) t)
(defun editor-write-delete-node-form (stream node-id)
  (format stream "~&(dialog-delete-node ~s)~2%" node-id))

(-> editor-write-text-form (t dialog-id string (option dialog-target)) t)
(defun editor-write-text-form (stream node-id text next-id)
  (format stream "~&(dialog-text ~s~%             ~s" node-id text)
  (when next-id
    (format stream "~%             :next ")
    (editor-write-target stream next-id))
  (format stream ")~2%"))

(-> editor-write-set-text-form (t dialog-id string) t)
(defun editor-write-set-text-form (stream node-id text)
  (format stream "~&(dialog-set-text ~s~%                 ~s)~2%"
          node-id
          text))

(-> editor-write-say-form
    (t dialog-id string string (option dialog-target))
    t)
(defun editor-write-say-form (stream node-id speaker text next-id)
  (format stream "~&(dialog-say ~s~%            ~s~%            ~s"
          node-id
          speaker
          text)
  (when next-id
    (format stream "~%            :next ")
    (editor-write-target stream next-id))
  (format stream ")~2%"))

(-> editor-write-choice-form
    (t dialog-id string string (option dialog-target))
    t)
(defun editor-write-choice-form (stream node-id text label target-id)
  (format stream "~&(dialog-pick ~s~%             ~s~%             "
          node-id
          text)
  (format stream "~s"
          `(dialog-option ,label
                          ,(editor-target-form
                            (or target-id *runtime-fallback-node-id*))))
  (format stream ")~2%"))

(-> editor-write-conversation-form
    (t dialog-id (option dialog-target))
    t)
(defun editor-write-conversation-form (stream node-id next-id)
  (format stream "~&(dialog-conversation ~s" node-id)
  (when next-id
    (format stream "~%  :next ")
    (editor-write-target stream next-id))
  (format stream "~%  (dialog-left ~s ~s)~%  (dialog-right ~s ~s))~2%"
          "left"
          "new line."
          "right"
          "answer."))

(-> editor-write-number-form
    (t dialog-id string dialog-id (option dialog-target))
    t)
(defun editor-write-number-form (stream node-id text response-key target-id)
  (format stream "~&(dialog-number ~s~%               ~s~%               :response-key ~s~%               :target "
          node-id
          text
          response-key)
  (editor-write-target stream (or target-id *runtime-fallback-node-id*))
  (format stream ")~2%"))

(-> editor-write-string-form
    (t dialog-id string dialog-id (option dialog-target))
    t)
(defun editor-write-string-form (stream node-id text response-key target-id)
  (format stream "~&(dialog-string ~s~%               ~s~%               :response-key ~s~%               :target "
          node-id
          text
          response-key)
  (editor-write-target stream (or target-id *runtime-fallback-node-id*))
  (format stream ")~2%"))

(-> editor-write-insert-node-form
    (t editor-insert-kind dialog-id (option dialog-target))
    t)
(defun editor-write-insert-node-form (stream kind node-id next-id)
  (case kind
    (:say
     (editor-write-say-form stream
                            node-id
                            "speaker"
                            *editor-placeholder-text*
                            next-id))
    (:choice
     (editor-write-choice-form stream
                               node-id
                               "new choice prompt."
                               "continue"
                               next-id))
    (:conversation
     (editor-write-conversation-form stream node-id next-id))
    (:number
     (editor-write-number-form stream
                               node-id
                               "enter a number."
                               (format nil "~a/value" node-id)
                               next-id))
    (:string
     (editor-write-string-form stream
                               node-id
                               "enter text."
                               (format nil "~a/value" node-id)
                               next-id))
    (t
     (editor-write-text-form stream
                             node-id
                             *editor-placeholder-text*
                             next-id))))

(-> editor-append-linear-insert
    (dialog-id dialog-id editor-insert-kind (option dialog-target))
    boolean)
(defun editor-append-linear-insert (parent-id child-id kind old-next-id)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; insert after ~s~%" parent-id)
          (editor-write-set-next-form stream parent-id child-id)
          (editor-write-insert-node-form stream
                                         kind
                                         child-id
                                         old-next-id))
        t)
    (error (condition)
      (runtime-warn "Could not append editor draft: ~a" condition)
      nil)))

(-> editor-append-choice-insert
    (dialog-id nonnegative-integer dialog-id editor-insert-kind dialog-target)
    boolean)
(defun editor-append-choice-insert (parent-id choice-index child-id kind old-target-id)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; insert for option ~d in ~s~%"
                  choice-index
                  parent-id)
          (editor-write-set-choice-target-form stream
                                               parent-id
                                               choice-index
                                               child-id)
          (editor-write-insert-node-form stream
                                         kind
                                         child-id
                                         old-target-id))
        t)
    (error (condition)
      (runtime-warn "Could not append editor choice insert: ~a" condition)
      nil)))

(-> editor-append-text-rewrite (dialog-id string) boolean)
(defun editor-append-text-rewrite (node-id text)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; text rewrite for ~s~%" node-id)
          (editor-write-set-text-form stream node-id text))
        t)
    (error (condition)
      (runtime-warn "Could not append editor text draft: ~a" condition)
      nil)))

(-> editor-append-linear-delete (dialog-id dialog-id (option dialog-target))
    boolean)
(defun editor-append-linear-delete (parent-id node-id next-id)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; delete ~s after ~s~%" node-id parent-id)
          (editor-write-set-next-form stream parent-id next-id)
          (editor-write-delete-node-form stream node-id))
        t)
    (error (condition)
      (runtime-warn "Could not append editor node delete: ~a" condition)
      nil)))

(-> editor-add-insert-node
    (editor-insert-kind dialog-id (option dialog-target))
    dialog-id)
(defun editor-add-insert-node (kind node-id next-id)
  (case kind
    (:say
     (dialog-say node-id "speaker" *editor-placeholder-text* :next next-id))
    (:choice
     (dialog-pick node-id
                  "new choice prompt."
                  (dialog-option "continue"
                                 (or next-id *runtime-fallback-node-id*))))
    (:conversation
     (dialog-conversation node-id
                          :next next-id
                          (dialog-left "left" "new line.")
                          (dialog-right "right" "answer.")))
    (:number
     (dialog-number node-id
                    "enter a number."
                    :response-key (format nil "~a/value" node-id)
                    :target (or next-id *runtime-fallback-node-id*)))
    (:string
     (dialog-string node-id
                    "enter text."
                    :response-key (format nil "~a/value" node-id)
                    :target (or next-id *runtime-fallback-node-id*)))
    (t
     (dialog-text node-id *editor-placeholder-text* :next next-id))))

(-> editor-apply-linear-insert (node dialog-id editor-insert-kind) t)
(defun editor-apply-linear-insert (node child-id kind)
  (let ((old-next-id (node-next node))
        (parent-id (node-id node)))
    (dialog-set-next parent-id child-id)
    (editor-add-insert-node kind child-id old-next-id)
    (setf *editor-status-message*
          (format nil "EDITOR: INSERTED ~a" child-id))
    (jump-to-node child-id)))

(-> editor-selected-choice-link (node)
    (values (option choice) (option nonnegative-integer)))
(defun editor-selected-choice-link (node)
  (when (eq (node-kind node) :choice)
    (let ((choice (selected-active-choice node)))
      (when choice
        (values choice
                (position choice (node-choices node) :test #'eq))))))

(-> editor-choice-insert-target-label (choice) string)
(defun editor-choice-insert-target-label (choice)
  (let ((label (choice-display-label choice)))
    (if (<= (length label) 38)
        label
        (concatenate 'string
                     (subseq label 0 35)
                     "..."))))

(-> editor-insert-target-label () string)
(defun editor-insert-target-label ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (multiple-value-bind (choice choice-index)
            (editor-selected-choice-link node)
          (cond
            ((and choice choice-index)
             (format nil "CHOICE ~d: ~a"
                     (1+ choice-index)
                     (editor-choice-insert-target-label choice)))
            ((editor-linear-next-node-p node)
             "AFTER CURRENT NODE")
            (t
             "UNSUPPORTED HERE"))))
      "NO ACTIVE NODE"))

(-> editor-apply-choice-insert (node choice dialog-id editor-insert-kind) t)
(defun editor-apply-choice-insert (node choice child-id kind)
  (declare (ignore node))
  (let ((old-target-id (choice-target choice)))
    (setf (choice-target choice) child-id)
    (editor-add-insert-node kind child-id old-target-id)
    (setf *editor-status-message*
          (format nil "EDITOR: INSERTED ~a" child-id))
    (jump-to-node child-id)))

(-> editor-insert-node-at-current-link (editor-insert-kind) boolean)
(defun editor-insert-node-at-current-link (kind)
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (multiple-value-bind (choice choice-index)
            (editor-selected-choice-link node)
          (cond
            ((and choice choice-index)
             (let* ((parent-id (node-id node))
                    (old-target-id (choice-target choice))
                    (child-id (editor-generated-choice-child-id parent-id
                                                                choice-index)))
               (if (editor-append-choice-insert parent-id
                                                choice-index
                                                child-id
                                                kind
                                                old-target-id)
                   (progn
                     (editor-apply-choice-insert node choice child-id kind)
                     (play-start-confirm)
                     t)
                   (progn
                     (setf *editor-status-message*
                           "EDITOR: DRAFT WRITE FAILED")
                     (play-choice-switch)
                     nil))))
            ((editor-linear-next-node-p node)
             (let* ((parent-id (node-id node))
                    (old-next-id (node-next node))
                    (child-id (editor-generated-child-id parent-id)))
               (if (editor-append-linear-insert parent-id
                                                child-id
                                                kind
                                                old-next-id)
                   (progn
                     (editor-apply-linear-insert node child-id kind)
                     (play-start-confirm)
                     t)
                   (progn
                     (setf *editor-status-message*
                           "EDITOR: DRAFT WRITE FAILED")
                     (play-choice-switch)
                     nil))))
            (t
             (setf *editor-status-message*
                   "EDITOR: INSERT UNSUPPORTED HERE")
             (play-choice-switch)
             nil))))
      nil))

(-> editor-insert-node-after-current () boolean)
(defun editor-insert-node-after-current ()
  (editor-insert-node-at-current-link *editor-insert-kind*))

(-> editor-insert-text-node-after-current () boolean)
(defun editor-insert-text-node-after-current ()
  (let ((*editor-insert-kind* :text))
    (editor-insert-node-after-current)))

(-> editor-current-delete-parent () (option node))
(defun editor-current-delete-parent ()
  (let ((frame (first *editor-history*)))
    (when frame
      (find-node (editor-history-frame-node-id frame)))))

(-> editor-delete-current-node-supported-p (node node) boolean)
(defun editor-delete-current-node-supported-p (parent node)
  (and (editor-linear-next-node-p parent)
       (editor-linear-next-node-p node)
       (equal (node-next parent) (node-id node))
       (not (equal (node-id node) *runtime-fallback-node-id*))))

(-> editor-apply-linear-delete (node node (option dialog-target)) t)
(defun editor-apply-linear-delete (parent node next-id)
  (let ((parent-id (node-id parent))
        (node-id (node-id node)))
    (dialog-set-next parent-id next-id)
    (dialog-delete-node node-id)
    (setf *editor-status-message*
          (format nil "EDITOR: DELETED ~a" node-id))
    (let ((*editor-suppress-history-p* t))
      (if next-id
          (jump-to-dialog-target next-id)
          (jump-to-node parent-id)))))

(-> editor-delete-current-node () boolean)
(defun editor-delete-current-node ()
  (if (and *editor-active-p* *state*)
      (let* ((node (current-node))
             (parent (editor-current-delete-parent)))
        (cond
          ((not parent)
           (setf *editor-status-message* "EDITOR: DELETE NEEDS PREVIOUS NODE")
           (play-choice-switch)
           nil)
          ((not (editor-delete-current-node-supported-p parent node))
           (setf *editor-status-message* "EDITOR: DELETE SUPPORTS LINEAR LINK")
           (play-choice-switch)
           nil)
          (t
           (let ((next-id (node-next node)))
             (if (editor-append-linear-delete (node-id parent)
                                              (node-id node)
                                              next-id)
                 (progn
                   (editor-apply-linear-delete parent node next-id)
                   (play-start-confirm)
                   t)
                 (progn
                   (setf *editor-status-message* "EDITOR: DELETE WRITE FAILED")
                   (play-choice-switch)
                   nil))))))
      nil))
