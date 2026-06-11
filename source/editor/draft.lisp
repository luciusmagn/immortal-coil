(in-package #:immortal-coil)

;;; Draft persistence

(-> editor-draft-script-pathname () pathname)
(defun editor-draft-script-pathname ()
  (project-pathname *editor-draft-script-path*))

(-> editor-append-pathname (dialog-id) pathname)
(defun editor-append-pathname (anchor-id)
  "File that should receive an editor edit anchored at ANCHOR-ID: the
script the node came from, or the draft file for orphans."
  (or (node-source-pathname anchor-id)
      (editor-draft-script-pathname)))

(-> editor-linear-next-node-p (node) boolean)
(defun editor-linear-next-node-p (node)
  (typep node 'linear-node))

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

(-> editor-generated-appended-choice-child-id (node) dialog-id)
(defun editor-generated-appended-choice-child-id (node)
  (editor-generated-choice-child-id (node-id node)
                                    (length (node-choices node))))

(defgeneric editor-target-form (target)
  (:documentation "Readable script form for a target, or the fallback id.")
  (:method ((target null))
    nil)
  (:method ((target string))
    target)
  (:method ((target symbol))
    `(quote ,target))
  (:method ((target cons))
    (if (or (lambda-expression-p target)
            (function-expression-p target))
        `(quote ,target)
        (editor-unpersistable-target target)))
  (:method (target)
    (editor-unpersistable-target target)))

(-> editor-unpersistable-target (t) dialog-id)
(defun editor-unpersistable-target (target)
  (runtime-warn "Editor cannot persist unreadable target: ~s" target)
  *runtime-fallback-node-id*)

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

(-> editor-write-set-choice-label-form
    (t dialog-id nonnegative-integer string)
    t)
(defun editor-write-set-choice-label-form (stream node-id choice-index label)
  (format stream "~&(dialog-set-choice-label ~s ~d ~s)~2%"
          node-id
          choice-index
          label))

(-> editor-write-add-choice-form (t dialog-id string dialog-target) t)
(defun editor-write-add-choice-form (stream node-id label target)
  (format stream "~&(dialog-add-choice ~s ~s "
          node-id
          label)
  (editor-write-target stream target)
  (format stream ")~2%"))

(-> editor-write-set-minigame-form (t dialog-id minigame-id) t)
(defun editor-write-set-minigame-form (stream node-id game-id)
  (format stream "~&(dialog-set-minigame ~s ~s)~2%"
          node-id
          game-id))

(-> editor-write-set-particles-form (t dialog-id particle-field-mode) t)
(defun editor-write-set-particles-form (stream node-id mode)
  (format stream "~&(dialog-set-particles ~s ~s)~2%"
          node-id
          mode))

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

(-> editor-write-set-text-form (t dialog-id string) t)
(defun editor-write-set-text-form (stream node-id text)
  (format stream "~&(dialog-set-text ~s~%                 ~s)~2%"
          node-id
          text))

(-> editor-default-minigame-id () minigame-id)
(defun editor-default-minigame-id ()
  (or (first (registered-minigame-ids))
      :unknown))


;;; Insert templates
;;;
;;; Templates are the single source of editor defaults for new nodes;
;;; the in-memory insert and the draft script form both come from them.

(defgeneric node-insert-template (kind node-id next-id)
  (:documentation "Fresh unregistered node with editor placeholder content."))

(defmethod node-insert-template (kind node-id next-id)
  (declare (ignore kind))
  (make-node :kind :text
             :id node-id
             :text *editor-placeholder-text*
             :next next-id))

(defmethod node-insert-template ((kind (eql :say)) node-id next-id)
  (make-node :kind :say
             :id node-id
             :speaker "speaker"
             :text *editor-placeholder-text*
             :next next-id))

(defmethod node-insert-template ((kind (eql :scene)) node-id next-id)
  (make-node :kind :scene
             :id node-id
             :text "somewhere. later."
             :next next-id))

(defmethod node-insert-template ((kind (eql :choice)) node-id next-id)
  (make-node :kind :choice
             :id node-id
             :text "new choice prompt."
             :layout :vertical
             :choices (vector (dialog-option "continue"
                                             (or next-id
                                                 *runtime-fallback-node-id*)))))

(defmethod node-insert-template ((kind (eql :conversation)) node-id next-id)
  (make-node :kind :conversation
             :id node-id
             :next next-id
             :conversation (vector (dialog-left "left" "new line.")
                                   (dialog-right "right" "answer."))))

(defmethod node-insert-template ((kind (eql :number)) node-id next-id)
  (make-node :kind :number
             :id node-id
             :text "enter a number."
             :response-key (format nil "~a/value" node-id)
             :target (or next-id *runtime-fallback-node-id*)))

(defmethod node-insert-template ((kind (eql :string)) node-id next-id)
  (make-node :kind :string
             :id node-id
             :text "enter text."
             :max-length 32
             :response-key (format nil "~a/value" node-id)
             :target (or next-id *runtime-fallback-node-id*)))

(defmethod node-insert-template ((kind (eql :minigame)) node-id next-id)
  (let ((target (or next-id *runtime-fallback-node-id*)))
    (make-node :kind :minigame
               :id node-id
               :text "play the minigame."
               :minigame (editor-default-minigame-id)
               :success-target target
               :failure-target target)))


;;; Script serialization
;;;
;;; Writes any node as the primitive dialog-* form the draft scripts use.
;;; Choice conditions are not persisted here; editor-created choices are
;;; unconditional, and predicate edits write their own setter forms.

(defgeneric node-write-script-form (node stream)
  (:documentation "Write NODE as a primitive dialog-* script form."))

(defmethod node-write-script-form ((node node) stream)
  (format stream "~&(dialog-text ~s~%             ~s"
          (node-id node)
          (node-text node))
  (when (node-next node)
    (format stream "~%             :next ")
    (editor-write-target stream (node-next node)))
  (format stream ")~2%"))

(defmethod node-write-script-form ((node say-node) stream)
  (format stream "~&(dialog-say ~s~%            ~s~%            ~s"
          (node-id node)
          (or (node-speaker node) "")
          (node-text node))
  (when (node-next node)
    (format stream "~%            :next ")
    (editor-write-target stream (node-next node)))
  (format stream ")~2%"))

(defmethod node-write-script-form ((node scene-node) stream)
  (format stream "~&(dialog-scene ~s~%              ~s"
          (node-id node)
          (node-text node))
  (when (node-next node)
    (format stream "~%              :next ")
    (editor-write-target stream (node-next node)))
  (format stream ")~2%"))

(-> editor-choice-layout-constructor ((option choice-layout)) symbol)
(defun editor-choice-layout-constructor (layout)
  (case layout
    (:horizontal 'dialog-choice)
    (:list 'dialog-list)
    (t 'dialog-pick)))

(defmethod node-write-script-form ((node choice-node) stream)
  (format stream "~&(~(~a~) ~s~%             ~s"
          (editor-choice-layout-constructor (node-layout node))
          (node-id node)
          (node-text node))
  (loop for choice across (node-choices node)
        do (format stream "~%             ~s"
                   `(dialog-option ,(choice-label choice)
                                   ,(editor-target-form
                                     (or (choice-target choice)
                                         *runtime-fallback-node-id*)))))
  (format stream ")~2%"))

(defmethod node-write-script-form ((node conversation-node) stream)
  (format stream "~&(dialog-conversation ~s" (node-id node))
  (when (node-next node)
    (format stream "~%  :next ")
    (editor-write-target stream (node-next node)))
  (loop for entry across (node-conversation node)
        do (format stream "~%  (~(~a~) ~s ~s)"
                   (if (eq (conversation-entry-side entry) :right)
                       'dialog-right
                       'dialog-left)
                   (conversation-entry-speaker entry)
                   (conversation-entry-text entry)))
  (format stream ")~2%"))

(defmethod node-write-script-form ((node number-input-node) stream)
  (format stream "~&(dialog-number ~s~%               ~s~%               :response-key ~s~%               :target "
          (node-id node)
          (node-text node)
          (node-response-key node))
  (editor-write-target stream (or (node-target node)
                                  *runtime-fallback-node-id*))
  (when (node-min-value node)
    (format stream "~%               :min ~s" (node-min-value node)))
  (when (node-max-value node)
    (format stream "~%               :max ~s" (node-max-value node)))
  (format stream ")~2%"))

(defmethod node-write-script-form ((node string-input-node) stream)
  (format stream "~&(dialog-string ~s~%               ~s~%               :response-key ~s~%               :target "
          (node-id node)
          (node-text node)
          (node-response-key node))
  (editor-write-target stream (or (node-target node)
                                  *runtime-fallback-node-id*))
  (unless (= (node-max-length node) 32)
    (format stream "~%               :max-length ~d" (node-max-length node)))
  (when (node-allow-empty-p node)
    (format stream "~%               :allow-empty t"))
  (format stream ")~2%"))

(defmethod node-write-script-form ((node minigame-node) stream)
  (format stream "~&(dialog-minigame ~s~%                 ~s~%                 :game ~s~%                 :success "
          (node-id node)
          (node-text node)
          (node-minigame node))
  (editor-write-target stream (or (node-success-target node)
                                  *runtime-fallback-node-id*))
  (format stream "~%                 :failure ")
  (editor-write-target stream (or (node-failure-target node)
                                  *runtime-fallback-node-id*))
  (when (node-minigame-config node)
    (format stream "~%                 :config '~s"
            (node-minigame-config node)))
  (when (node-minigame-outcomes node)
    (format stream "~%                 :outcomes (list")
    (dolist (target (node-minigame-outcomes node))
      (format stream " ")
      (editor-write-target stream target))
    (format stream ")"))
  (format stream ")~2%"))

(-> editor-write-insert-node-form
    (t editor-insert-kind dialog-id (option dialog-target))
    t)
(defun editor-write-insert-node-form (stream kind node-id next-id)
  (node-write-script-form (node-insert-template kind node-id next-id)
                          stream))

(-> editor-append-linear-insert
    (dialog-id dialog-id editor-insert-kind (option dialog-target))
    boolean)
(defun editor-append-linear-insert (parent-id child-id kind old-next-id)
  (handler-case
      (let ((path (editor-append-pathname parent-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: insert after ~s~%" parent-id)
          (editor-write-set-next-form stream parent-id child-id)
          (editor-write-insert-node-form stream
                                         kind
                                         child-id
                                         old-next-id))
        (setf (node-source-pathname child-id) path)
        t)
    (error (condition)
      (runtime-warn "Could not append editor draft: ~a" condition)
      nil)))

(-> editor-append-choice-insert
    (dialog-id nonnegative-integer dialog-id editor-insert-kind dialog-target)
    boolean)
(defun editor-append-choice-insert (parent-id choice-index child-id kind old-target-id)
  (handler-case
      (let ((path (editor-append-pathname parent-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: insert for option ~d in ~s~%"
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
        (setf (node-source-pathname child-id) path)
        t)
    (error (condition)
      (runtime-warn "Could not append editor choice insert: ~a" condition)
      nil)))

(-> editor-append-choice-add
    (dialog-id string dialog-id editor-insert-kind)
    boolean)
(defun editor-append-choice-add (parent-id label child-id kind)
  (handler-case
      (let ((path (editor-append-pathname parent-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: add option in ~s~%" parent-id)
          (editor-write-add-choice-form stream parent-id label child-id)
          (editor-write-insert-node-form stream kind child-id nil))
        (setf (node-source-pathname child-id) path)
        t)
    (error (condition)
      (runtime-warn "Could not append editor choice add: ~a" condition)
      nil)))

(-> editor-append-node-replace
    (dialog-id editor-insert-kind (option dialog-target))
    boolean)
(defun editor-append-node-replace (node-id kind next-id)
  (handler-case
      (let ((path (editor-append-pathname node-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: replace node ~s~%" node-id)
          (editor-write-insert-node-form stream kind node-id next-id))
        t)
    (error (condition)
      (runtime-warn "Could not append editor node replace: ~a" condition)
      nil)))

(-> editor-append-minigame-edit (dialog-id minigame-id) boolean)
(defun editor-append-minigame-edit (node-id game-id)
  (handler-case
      (let ((path (editor-append-pathname node-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: minigame edit for ~s~%" node-id)
          (editor-write-set-minigame-form stream node-id game-id))
        t)
    (error (condition)
      (runtime-warn "Could not append editor minigame edit: ~a" condition)
      nil)))

(-> editor-append-particles-edit (dialog-id particle-field-mode) boolean)
(defun editor-append-particles-edit (node-id mode)
  (handler-case
      (let ((path (editor-append-pathname node-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: particle edit for ~s~%" node-id)
          (editor-write-set-particles-form stream node-id mode))
        t)
    (error (condition)
      (runtime-warn "Could not append editor particle edit: ~a" condition)
      nil)))

(-> editor-append-text-rewrite (dialog-id string) boolean)
(defun editor-append-text-rewrite (node-id text)
  (handler-case
      (let ((path (editor-append-pathname node-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: text rewrite for ~s~%" node-id)
          (editor-write-set-text-form stream node-id text))
        t)
    (error (condition)
      (runtime-warn "Could not append editor text draft: ~a" condition)
      nil)))

(-> editor-append-linear-delete (dialog-id dialog-id (option dialog-target))
    boolean)
(defun editor-append-linear-delete (parent-id node-id next-id)
  (handler-case
      (let ((path (editor-append-pathname parent-id)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;; editor-generated: delete ~s after ~s~%" node-id parent-id)
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
  (add-node (node-insert-template kind node-id next-id))
  node-id)

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
  (when (typep node 'choice-node)
    (let ((choice (selected-active-choice node)))
      (when choice
        (values choice
                (position choice (node-choices node) :test #'eq))))))

(defgeneric node-primary-target (node)
  (:documentation "The target the editor treats as NODE's main link.")
  (:method ((node node))
    nil)
  (:method ((node linear-node))
    (node-next node))
  (:method ((node input-node))
    (node-target node))
  (:method ((node choice-node))
    (let ((choice (editor-selected-choice-link node)))
      (when choice
        (choice-target choice))))
  (:method ((node minigame-node))
    (or (node-success-target node)
        (node-failure-target node))))

(-> editor-node-primary-target (node) (option dialog-target))
(defun editor-node-primary-target (node)
  (node-primary-target node))

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

(-> editor-choice-add-select-new-option (node) t)
(defun editor-choice-add-select-new-option (node)
  (let ((choices (active-node-choices node)))
    (setf (play-state-selected-index *state*)
          (max 0 (1- (length choices)))))
  t)

(-> editor-add-choice-option-to-current () boolean)
(defun editor-add-choice-option-to-current ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (if (eq (node-kind node) :choice)
            (let* ((parent-id (node-id node))
                   (label "new option")
                   (child-id (editor-generated-appended-choice-child-id node))
                   (kind :text))
              (if (editor-append-choice-add parent-id label child-id kind)
                  (progn
                    (dialog-add-choice parent-id label child-id)
                    (editor-add-insert-node kind child-id nil)
                    (editor-choice-add-select-new-option node)
                    (setf *editor-status-message*
                          (format nil "EDITOR: ADDED OPTION ~a" child-id))
                    (play-start-confirm)
                    (when (fboundp 'editor-start-choice-option-edit)
                      (funcall (symbol-function
                                'editor-start-choice-option-edit)))
                    t)
                  (progn
                    (setf *editor-status-message*
                          "EDITOR: OPTION ADD WRITE FAILED")
                    (play-choice-switch)
                    nil)))
            (progn
              (setf *editor-status-message*
                    "EDITOR: ADD OPTION NEEDS CHOICE NODE")
              (play-choice-switch)
              nil)))
      nil))

(-> editor-reset-current-node-display (dialog-id) t)
(defun editor-reset-current-node-display (node-id)
  (when (and *state*
             (equal (play-state-current-id *state*) node-id))
    (setf (play-state-elapsed *state*) 0.0
          (play-state-type-delay *state*) 0.0
          (play-state-visible-count *state*) 0
          (play-state-selected-index *state*) 0
          (play-state-conversation-index *state*) 0
          (play-state-input-buffer *state*) ""))
  t)

(-> editor-replace-current-node (editor-insert-kind) boolean)
(defun editor-replace-current-node (kind)
  (if (and *editor-active-p* *state*)
      (let* ((node (current-node))
             (node-id (node-id node))
             (next-id (editor-node-primary-target node)))
        (cond
          ((equal node-id *runtime-fallback-node-id*)
           (setf *editor-status-message* "EDITOR: CANNOT REPLACE FALLBACK")
           (play-choice-switch)
           nil)
          ((editor-append-node-replace node-id kind next-id)
           (editor-add-insert-node kind node-id next-id)
           (editor-reset-current-node-display node-id)
           (setf *editor-status-message*
                 (format nil "EDITOR: DESTRUCTIVELY REPLACED ~a" node-id))
           (play-start-confirm)
           t)
          (t
           (setf *editor-status-message*
                 "EDITOR: REPLACE WRITE FAILED")
           (play-choice-switch)
           nil)))
      nil))

(-> editor-next-minigame-id (minigame-id list) minigame-id)
(defun editor-next-minigame-id (current-id ids)
  (let* ((position (position current-id ids))
         (next-position (if position
                            (mod (1+ position) (length ids))
                            0)))
    (nth next-position ids)))

(-> editor-cycle-current-minigame () boolean)
(defun editor-cycle-current-minigame ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (cond
          ((not (eq (node-kind node) :minigame))
           (setf *editor-status-message*
                 "EDITOR: CURRENT NODE IS NOT A MINIGAME")
           (play-choice-switch)
           nil)
          ((null (registered-minigame-ids))
           (setf *editor-status-message* "EDITOR: NO MINIGAMES REGISTERED")
           (play-choice-switch)
           nil)
          (t
           (let ((game-id (editor-next-minigame-id
                           (or (node-minigame node) :unknown)
                           (registered-minigame-ids))))
             (if (editor-append-minigame-edit (node-id node) game-id)
                 (progn
                   (dialog-set-minigame (node-id node) game-id)
                   (setf *editor-status-message*
                         (format nil "EDITOR: MINIGAME ~a" game-id))
                   (play-start-confirm)
                   t)
                 (progn
                   (setf *editor-status-message*
                         "EDITOR: MINIGAME WRITE FAILED")
                   (play-choice-switch)
                   nil))))))
      nil))

(-> editor-current-particle-field-mode (node) particle-field-mode)
(defun editor-current-particle-field-mode (node)
  (particle-field-mode-keyword
   (or (node-particle-field-mode node)
       *particle-field-mode*
       :rising)))

(-> editor-next-particle-field-mode (particle-field-mode list)
    particle-field-mode)
(defun editor-next-particle-field-mode (current-mode modes)
  (let* ((position (position current-mode modes))
         (next-position (if position
                            (mod (1+ position) (length modes))
                            0)))
    (nth next-position modes)))

(-> editor-cycle-current-particles () boolean)
(defun editor-cycle-current-particles ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (cond
          ((null (registered-particle-field-modes))
           (setf *editor-status-message* "EDITOR: NO PARTICLE FIELDS")
           (play-choice-switch)
           nil)
          (t
           (let ((mode (editor-next-particle-field-mode
                        (editor-current-particle-field-mode node)
                        (registered-particle-field-modes))))
             (if (editor-append-particles-edit (node-id node) mode)
                 (progn
                   (dialog-set-particles (node-id node) mode)
                   (set-particle-field-mode mode :immediate t)
                   (setf *editor-status-message*
                         (format nil "EDITOR: PARTICLES ~a" mode))
                   (play-start-confirm)
                   t)
                 (progn
                   (setf *editor-status-message*
                         "EDITOR: PARTICLE WRITE FAILED")
                   (play-choice-switch)
                   nil))))))
      nil))

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
