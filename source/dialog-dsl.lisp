(in-package #:immortal-coil)

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
  (if (choice-p value)
      value
      (progn
        (runtime-warn "Expected a dialog option, got: ~s" value)
        (make-choice :label "continue"
                     :target *runtime-fallback-node-id*
                     :condition t))))

(defun ensure-dialog-options (options)
  (if options
      (coerce (mapcar #'ensure-dialog-option options) 'vector)
      (progn
        (runtime-warn "Dialog choice node has no options.")
        (vector (make-choice :label "continue"
                             :target *runtime-fallback-node-id*
                             :condition t)))))

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
    (runtime-warn "Number node needs a target: ~a" id)
    (setf target *runtime-fallback-node-id*))
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
    (runtime-warn "String node needs a target: ~a" id)
    (setf target *runtime-fallback-node-id*))
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
    (runtime-warn "Minigame node needs a success target: ~a" id)
    (setf success *runtime-fallback-node-id*))
  (unless failure
    (runtime-warn "Minigame node needs a failure target: ~a" id)
    (setf failure *runtime-fallback-node-id*))
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
  (if (branch-p value)
      value
      (progn
        (runtime-warn "Expected a dialog case, got: ~s" value)
        (dialog-default *runtime-fallback-node-id*))))

(defun dialog-branch (id &rest cases)
  (unless cases
    (runtime-warn "Branch node needs at least one case: ~a" id)
    (setf cases (list (dialog-default *runtime-fallback-node-id*))))
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
    (if (eq (node-kind node) :choice)
        (setf (node-choices node)
              (concatenate 'vector
                           (node-choices node)
                           (vector (dialog-option label
                                                  target
                                                  :when when-condition
                                                  :unless unless-condition))))
        (runtime-warn "Cannot add a choice to non-choice node: ~a" node-id)))
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
  (if effects
      (add-node-enter-effects node-id effects)
      (runtime-warn "dialog-on-enter needs at least one effect: ~a" node-id))
  node-id)

(defun dialog-particles (node-id mode
                         &key (fade-seconds *particle-field-fade-seconds*)
                              immediate)
  (dialog-on-enter
   node-id
   `(set-particle-field-mode ,mode
                             :fade-seconds ,fade-seconds
                             :immediate ,immediate)))
