(in-package #:immortal-coil)

(defvar *nodes* (make-hash-table :test #'equal))
(defvar *node-sources* (make-hash-table :test #'equal))
(defvar *pending-node-enter-effects* (make-hash-table :test #'equal))
(defvar *story-start-node* nil)
(defvar *last-dialog-node-id* nil)
(defvar *dev-save-override* nil)
(defvar *current-dialog-source* :repl)
(defvar *dialog-conflicts* nil)
(defparameter *runtime-fallback-node-id* "runtime/fallback")

(defstruct choice
  (label     "" :type string)
  (target    *runtime-fallback-node-id* :type dialog-id)
  (condition t :type dialog-condition))

(defstruct branch
  (condition t :type dialog-condition)
  (target    *runtime-fallback-node-id* :type dialog-id))

(defstruct dialog-conflict
  (node-id         *runtime-fallback-node-id* :type dialog-id)
  (previous-source :unknown :type dialog-source)
  (new-source      :unknown :type dialog-source)
  (resolution      :latest-wins :type dialog-conflict-resolution))

(defstruct node
  (id             *runtime-fallback-node-id* :type dialog-id)
  (kind           :text :type node-kind)
  (text           "" :type string)
  (next           nil :type (option dialog-id))
  (choices        #() :type vector)
  (branches       #() :type vector)
  (layout         nil :type (option choice-layout))
  (target         nil :type (option dialog-id))
  (response-key   nil :type (option dialog-id))
  (min-value      nil :type (option number))
  (max-value      nil :type (option number))
  (max-length     0 :type nonnegative-integer)
  (allow-empty-p  nil :type boolean)
  (minigame       nil :type (option keyword))
  (success-target nil :type (option dialog-id))
  (failure-target nil :type (option dialog-id))
  (enter-effects  nil :type (list-of dialog-effect)))

(-> reset-nodes () t)
(defun reset-nodes ()
  (clrhash *nodes*)
  (clrhash *node-sources*)
  (clrhash *pending-node-enter-effects*))

(-> dialog-source-name (t) string)
(defun dialog-source-name (source)
  (typecase source
    (pathname (namestring source))
    (string source)
    (symbol (string-downcase (symbol-name source)))
    (t (princ-to-string source))))

(-> current-dialog-source-name () string)
(defun current-dialog-source-name ()
  (dialog-source-name *current-dialog-source*))

(-> dialog-source-same-p (t t) boolean)
(defun dialog-source-same-p (left right)
  (string= (dialog-source-name left)
           (dialog-source-name right)))

(-> record-dialog-conflict (dialog-id t t) dialog-conflict)
(defun record-dialog-conflict (node-id previous-source new-source)
  (let ((conflict (make-dialog-conflict
                   :node-id node-id
                   :previous-source previous-source
                   :new-source new-source
                   :resolution :latest-wins)))
    (push conflict *dialog-conflicts*)
    (runtime-warn "Dialog node conflict for ~a: ~a replaced by ~a."
                  node-id
                  (dialog-source-name previous-source)
                  (dialog-source-name new-source))
    conflict))

(-> node-existing-enter-effects (dialog-id) list)
(defun node-existing-enter-effects (id)
  (let ((node (gethash id *nodes*)))
    (when node
      (node-enter-effects node))))

(-> node-pending-enter-effects (dialog-id) list)
(defun node-pending-enter-effects (id)
  (gethash id *pending-node-enter-effects*))

(-> combine-node-enter-effects (node) list)
(defun combine-node-enter-effects (node)
  (let ((id (node-id node)))
    (append (node-existing-enter-effects id)
            (node-pending-enter-effects id)
            (node-enter-effects node))))

(-> add-node (node) node)
(defun add-node (node)
  (let* ((id (node-id node))
         (previous-source (gethash id *node-sources*))
         (new-source (current-dialog-source-name)))
    (when (and previous-source
               (not (dialog-source-same-p previous-source new-source)))
      (record-dialog-conflict id previous-source new-source))
    (setf (gethash id *node-sources*) new-source))
  (setf (node-enter-effects node)
        (combine-node-enter-effects node))
  (remhash (node-id node) *pending-node-enter-effects*)
  (setf *last-dialog-node-id* (node-id node))
  (setf (gethash (node-id node) *nodes*) node))

(-> ensure-runtime-fallback-node () node)
(defun ensure-runtime-fallback-node ()
  (or (gethash *runtime-fallback-node-id* *nodes*)
      (let ((node (make-node :id *runtime-fallback-node-id*
                             :kind :text
                             :text "the thread goes dark.")))
        (add-node node)
        node)))

(-> node-exists-p (t) boolean)
(defun node-exists-p (id)
  (not (null (gethash id *nodes*))))

(-> resolve-node-id (t) dialog-id)
(defun resolve-node-id (id)
  (if (node-exists-p id)
      id
      (progn
        (runtime-warn "Unknown story node: ~a" id)
        (node-id (ensure-runtime-fallback-node)))))

(-> find-node (t) node)
(defun find-node (id)
  (or (gethash id *nodes*)
      (progn
        (runtime-warn "Unknown story node: ~a" id)
        (ensure-runtime-fallback-node))))

(-> reset-dialog-graph () t)
(defun reset-dialog-graph ()
  (reset-nodes)
  (setf *story-start-node* nil
        *last-dialog-node-id* nil
        *dev-save-override* nil
        *dialog-conflicts* nil))
