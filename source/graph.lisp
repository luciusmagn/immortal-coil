(in-package #:immortal-coil)

(defvar *nodes* (make-hash-table :test #'equal))
(defvar *pending-node-enter-effects* (make-hash-table :test #'equal))
(defvar *story-start-node* nil)

(defstruct choice
  label
  target
  condition)

(defstruct branch
  condition
  target)

(defstruct node
  id
  kind
  text
  next
  choices
  branches
  layout
  target
  response-key
  min-value
  max-value
  max-length
  allow-empty-p
  minigame
  success-target
  failure-target
  enter-effects)

(defun reset-nodes ()
  (clrhash *nodes*)
  (clrhash *pending-node-enter-effects*))

(defun node-existing-enter-effects (id)
  (let ((node (gethash id *nodes*)))
    (when node
      (node-enter-effects node))))

(defun node-pending-enter-effects (id)
  (gethash id *pending-node-enter-effects*))

(defun combine-node-enter-effects (node)
  (let ((id (node-id node)))
    (append (node-existing-enter-effects id)
            (node-pending-enter-effects id)
            (node-enter-effects node))))

(defun add-node (node)
  (setf (node-enter-effects node)
        (combine-node-enter-effects node))
  (remhash (node-id node) *pending-node-enter-effects*)
  (setf (gethash (node-id node) *nodes*) node))

(defun find-node (id)
  (or (gethash id *nodes*)
      (error "Unknown story node: ~a" id)))

(defun reset-dialog-graph ()
  (reset-nodes)
  (setf *story-start-node* nil))

(defun dialog-start (id)
  (setf *story-start-node* id))

(defun dialog-text (id text &key next)
  (add-node (make-node :id id
                       :kind :text
                       :text text
                       :next next))
  id)

(defun dialog-option (label target
                      &key ((:when when-condition) t)
                           ((:unless unless-condition) nil))
  (make-choice :label label
               :target target
               :condition (if unless-condition
                              #'(lambda ()
                                  (and (dialog-condition-true-p when-condition)
                                       (not (dialog-condition-true-p
                                             unless-condition))))
                              when-condition)))

(defun choice-active-p (choice)
  (dialog-condition-true-p (choice-condition choice)))

(defun active-node-choices (node)
  (remove-if-not #'choice-active-p (node-choices node)))

(defun ensure-dialog-option (value)
  (unless (choice-p value)
    (error "Expected a dialog option, got: ~s" value))
  value)

(defun ensure-dialog-options (options)
  (unless options
    (error "Dialog choice nodes need at least one option."))
  (coerce (mapcar #'ensure-dialog-option options) 'vector))

(defun make-dialog-choice-node (id text layout options)
  (add-node (make-node :id id
                       :kind :choice
                       :text text
                       :layout layout
                       :choices (ensure-dialog-options options)))
  id)

(defun dialog-choice (id text &rest options)
  (make-dialog-choice-node id text :horizontal options))

(defun dialog-pick (id text &rest options)
  (make-dialog-choice-node id text :vertical options))

(defun dialog-list (id text &rest options)
  (make-dialog-choice-node id text :list options))

(defun dialog-number (id text &key target response-key min max)
  (unless target
    (error "Number node needs a target: ~a" id))
  (add-node (make-node :id id
                       :kind :number
                       :text text
                       :target target
                       :response-key (or response-key id)
                       :min-value min
                       :max-value max))
  id)

(defun dialog-string (id text &key target response-key (max-length 32) allow-empty)
  (unless target
    (error "String node needs a target: ~a" id))
  (add-node (make-node :id id
                       :kind :string
                       :text text
                       :target target
                       :response-key (or response-key id)
                       :max-length max-length
                       :allow-empty-p allow-empty))
  id)

(defun dialog-minigame (id text &key (game :wire-flight) success failure)
  (unless success
    (error "Minigame node needs a success target: ~a" id))
  (unless failure
    (error "Minigame node needs a failure target: ~a" id))
  (add-node (make-node :id id
                       :kind :minigame
                       :text text
                       :minigame game
                       :success-target success
                       :failure-target failure))
  id)

(defun dialog-case (condition target)
  (make-branch :condition condition :target target))

(defun dialog-default (target)
  (dialog-case t target))

(defun ensure-dialog-case (value)
  (unless (branch-p value)
    (error "Expected a dialog case, got: ~s" value))
  value)

(defun dialog-branch (id &rest cases)
  (unless cases
    (error "Branch nodes need at least one case: ~a" id))
  (add-node (make-node :id id
                       :kind :branch
                       :text ""
                       :branches (coerce (mapcar #'ensure-dialog-case cases)
                                         'vector)))
  id)

(defun dialog-add-choice (node-id label target
                          &key ((:when when-condition) t)
                               ((:unless unless-condition) nil))
  (let ((node (find-node node-id)))
    (unless (eq (node-kind node) :choice)
      (error "Cannot add a choice to non-choice node: ~a" node-id))
    (setf (node-choices node)
          (concatenate 'vector
                       (node-choices node)
                       (vector (dialog-option label
                                              target
                                              :when when-condition
                                              :unless unless-condition)))))
  node-id)

(defun dialog-set-next (node-id next-id)
  (setf (node-next (find-node node-id)) next-id)
  node-id)

(defun add-node-enter-effects (node-id effects)
  (let ((node (gethash node-id *nodes*)))
    (if node
        (setf (node-enter-effects node)
              (append (node-enter-effects node) effects))
        (setf (gethash node-id *pending-node-enter-effects*)
              (append (node-pending-enter-effects node-id) effects)))))

(defun dialog-on-enter (node-id &rest effects)
  (unless effects
    (error "dialog-on-enter needs at least one effect: ~a" node-id))
  (add-node-enter-effects node-id effects)
  node-id)

(defun dialog-particles (node-id mode
                         &key (fade-seconds *particle-field-fade-seconds*)
                              immediate)
  (dialog-on-enter
   node-id
   `(set-particle-field-mode ,mode
                             :fade-seconds ,fade-seconds
                             :immediate ,immediate)))

(defun eval-dialog-effect (effect)
  (cond
    ((functionp effect)
     (funcall effect))
    ((lambda-expression-p effect)
     (funcall (compile nil effect)))
    ((function-expression-p effect)
     (funcall (eval effect)))
    ((consp effect)
     (eval effect))
    ((and (symbolp effect) (fboundp effect))
     (funcall effect))
    (t
     (error "Unknown dialog enter effect: ~s" effect))))

(defun apply-node-enter-effects (node)
  (dolist (effect (node-enter-effects node))
    (eval-dialog-effect effect)))

(defun dialog-script-pathname (path)
  (project-pathname path))

(defun eval-dialog-script (path)
  (let ((eof (gensym "EOF")))
    (with-open-file (stream (dialog-script-pathname path))
      (let ((*package* (find-package "IMMORTAL-COIL")))
        (loop for form = (read stream nil eof)
              until (eq form eof)
              do (eval form))))))

(defun load-dialog-graph (&optional (paths *dialog-script-paths*))
  (reset-dialog-graph)
  (dolist (path paths)
    (eval-dialog-script path))
  (unless *story-start-node*
    (error "No dialog start node was set by scripts: ~s" paths))
  *story-start-node*)
