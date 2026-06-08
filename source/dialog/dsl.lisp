(in-package #:immortal-coil)

;;; Basic nodes

(-> dialog-start (dialog-id) dialog-id)
(defun dialog-start (id)
  (setf *story-start-node* id))

(-> dialog-text (dialog-id string &key (:next (option dialog-id))) dialog-id)
(defun dialog-text (id text &key next)
  (add-node (make-node :id id
                       :kind :text
                       :text text
                       :next next))
  id)

(-> dialog-say (dialog-id string string &key (:next (option dialog-id)))
    dialog-id)
(defun dialog-say (id speaker text &key next)
  (add-node (make-node :id id
                       :kind :say
                       :speaker speaker
                       :text text
                       :next next))
  id)

(-> dialog-required-link ((option dialog-id) dialog-id string) dialog-id)
(defun dialog-required-link (target id warning-text)
  (or target
      (progn
        (runtime-warn "~a: ~a" warning-text id)
        *runtime-fallback-node-id*)))

(-> dialog-set-next (dialog-id dialog-id) dialog-id)
(defun dialog-set-next (node-id next-id)
  (setf (node-next (find-node node-id)) next-id)
  node-id)


;;; Choice nodes

(-> make-fallback-choice () choice)
(defun make-fallback-choice ()
  (make-choice :label "continue"
               :target *runtime-fallback-node-id*
               :condition t
               :enabled-condition t))

(-> dialog-option-condition (dialog-condition (option dialog-condition))
    dialog-condition)
(defun dialog-option-condition (when-condition unless-condition)
  (if unless-condition
      #'(lambda ()
          (and (dialog-condition-true-p when-condition)
               (not (dialog-condition-true-p unless-condition))))
      when-condition))

(-> dialog-option (string
                   dialog-id
                   &key
                   (:when dialog-condition)
                   (:unless (option dialog-condition))
                   (:enabled-when dialog-condition)
                   (:enabled-unless (option dialog-condition)))
    choice)
(defun dialog-option (label target
                      &key ((:when when-condition) t)
                           ((:unless unless-condition) nil)
                           ((:enabled-when enabled-when-condition) t)
                           ((:enabled-unless enabled-unless-condition) nil))
  (make-choice :label label
               :target target
               :condition (dialog-option-condition when-condition
                                                   unless-condition)
               :enabled-condition
               (dialog-option-condition enabled-when-condition
                                        enabled-unless-condition)))

(-> choice-visible-p (choice) boolean)
(defun choice-visible-p (choice)
  (dialog-condition-true-p (choice-condition choice)))

(-> choice-enabled-p (choice) boolean)
(defun choice-enabled-p (choice)
  (dialog-condition-true-p (choice-enabled-condition choice)))

(-> active-node-choices (node) vector)
(defun active-node-choices (node)
  (remove-if-not #'choice-visible-p (node-choices node)))

(-> ensure-dialog-option (t) choice)
(defun ensure-dialog-option (value)
  (if (choice-p value)
      value
      (progn
        (runtime-warn "Expected a dialog option, got: ~s" value)
        (make-fallback-choice))))

(-> ensure-dialog-options (list) vector)
(defun ensure-dialog-options (options)
  (if options
      (coerce (mapcar #'ensure-dialog-option options) 'vector)
      (progn
        (runtime-warn "Dialog choice node has no options.")
        (vector (make-fallback-choice)))))

(-> make-dialog-choice-node (dialog-id string choice-layout list) dialog-id)
(defun make-dialog-choice-node (id text layout options)
  (add-node (make-node :id id
                       :kind :choice
                       :text text
                       :layout layout
                       :choices (ensure-dialog-options options)))
  id)

(-> dialog-choice (dialog-id string &rest choice) dialog-id)
(defun dialog-choice (id text &rest options)
  (make-dialog-choice-node id text :horizontal options))

(-> dialog-pick (dialog-id string &rest choice) dialog-id)
(defun dialog-pick (id text &rest options)
  (make-dialog-choice-node id text :vertical options))

(-> dialog-list (dialog-id string &rest choice) dialog-id)
(defun dialog-list (id text &rest options)
  (make-dialog-choice-node id text :list options))

(-> dialog-add-choice (dialog-id
                       string
                       dialog-id
                       &key
                       (:when dialog-condition)
                       (:unless (option dialog-condition))
                       (:enabled-when dialog-condition)
                       (:enabled-unless (option dialog-condition)))
    dialog-id)
(defun dialog-add-choice (node-id label target
                          &key ((:when when-condition) t)
                               ((:unless unless-condition) nil)
                               ((:enabled-when enabled-when-condition) t)
                               ((:enabled-unless enabled-unless-condition) nil))
  (let ((node (find-node node-id)))
    (if (eq (node-kind node) :choice)
        (setf (node-choices node)
              (concatenate 'vector
                           (node-choices node)
                           (vector (dialog-option label
                                                  target
                                                  :when when-condition
                                                  :unless unless-condition
                                                  :enabled-when
                                                  enabled-when-condition
                                                  :enabled-unless
                                                  enabled-unless-condition))))
        (runtime-warn "Cannot add a choice to non-choice node: ~a" node-id)))
  node-id)


;;; Conversation nodes

(-> dialog-conversation-line (conversation-side string string)
    conversation-entry)
(defun dialog-conversation-line (side speaker text)
  (make-conversation-entry :side side
                           :speaker speaker
                           :text text))

(-> dialog-left (string string) conversation-entry)
(defun dialog-left (speaker text)
  (dialog-conversation-line :left speaker text))

(-> dialog-right (string string) conversation-entry)
(defun dialog-right (speaker text)
  (dialog-conversation-line :right speaker text))

(-> ensure-conversation-entry (t) conversation-entry)
(defun ensure-conversation-entry (value)
  (if (conversation-entry-p value)
      value
      (progn
        (runtime-warn "Expected a conversation entry, got: ~s" value)
        (dialog-left "" ""))))

(-> parse-dialog-conversation-arguments (list)
    (values (option dialog-id) list))
(defun parse-dialog-conversation-arguments (arguments)
  (loop with next = nil
        with entries = nil
        for args = arguments then (rest args)
        while args
        for value = (first args)
        do (if (eq value :next)
               (if (rest args)
                   (progn
                     (setf next (second args))
                     (setf args (rest args)))
                   (runtime-warn "Conversation :next needs a target."))
               (push value entries))
        finally (return (values next (nreverse entries)))))

(-> dialog-conversation (dialog-id &rest t) dialog-id)
(defun dialog-conversation (id &rest arguments)
  (multiple-value-bind (next entries)
      (parse-dialog-conversation-arguments arguments)
    (unless entries
      (runtime-warn "Conversation node has no entries: ~a" id))
    (add-node (make-node
               :id id
               :kind :conversation
               :next next
               :conversation (coerce (mapcar #'ensure-conversation-entry
                                             entries)
                                     'vector))))
  id)


;;; Branch nodes

(-> dialog-case (dialog-condition dialog-id) branch)
(defun dialog-case (condition target)
  (make-branch :condition condition :target target))

(-> dialog-default (dialog-id) branch)
(defun dialog-default (target)
  (dialog-case t target))

(-> make-fallback-branch () branch)
(defun make-fallback-branch ()
  (dialog-default *runtime-fallback-node-id*))

(-> ensure-dialog-case (t) branch)
(defun ensure-dialog-case (value)
  (if (branch-p value)
      value
      (progn
        (runtime-warn "Expected a dialog case, got: ~s" value)
        (make-fallback-branch))))

(-> ensure-dialog-cases (list) vector)
(defun ensure-dialog-cases (cases)
  (coerce (mapcar #'ensure-dialog-case cases) 'vector))

(-> dialog-branch (dialog-id &rest branch) dialog-id)
(defun dialog-branch (id &rest cases)
  (unless cases
    (runtime-warn "Branch node needs at least one case: ~a" id)
    (setf cases (list (make-fallback-branch))))
  (add-node (make-node :id id
                       :kind :branch
                       :text ""
                       :branches (ensure-dialog-cases cases)))
  id)


;;; Input nodes

(-> dialog-number (dialog-id
                   string
                   &key
                   (:target (option dialog-id))
                   (:response-key (option dialog-id))
                   (:min (option number))
                   (:max (option number)))
    dialog-id)
(defun dialog-number (id text &key target response-key min max)
  (add-node (make-node
             :id id
             :kind :number
             :text text
             :target (dialog-required-link target
                                           id
                                           "Number node needs a target")
             :response-key (or response-key id)
             :min-value min
             :max-value max))
  id)

(-> dialog-string (dialog-id
                   string
                   &key
                   (:target (option dialog-id))
                   (:response-key (option dialog-id))
                   (:max-length nonnegative-integer)
                   (:allow-empty t))
    dialog-id)
(defun dialog-string (id text &key target response-key (max-length 32) allow-empty)
  (add-node (make-node
             :id id
             :kind :string
             :text text
             :target (dialog-required-link target
                                           id
                                           "String node needs a target")
             :response-key (or response-key id)
             :max-length max-length
             :allow-empty-p allow-empty))
  id)


;;; Minigame nodes

(-> dialog-minigame (dialog-id
                     string
                     &key
                     (:game (option minigame-id))
                     (:success (option dialog-id))
                     (:failure (option dialog-id)))
    dialog-id)
(defun dialog-minigame (id text &key game success failure)
  (unless game
    (runtime-warn "Minigame node needs a game: ~a" id))
  (add-node (make-node
             :id id
             :kind :minigame
             :text text
             :minigame game
             :success-target (dialog-required-link
                              success
                              id
                              "Minigame node needs a success target")
             :failure-target (dialog-required-link
                              failure
                              id
                              "Minigame node needs a failure target")))
  id)


;;; Node effects

(-> add-node-enter-effects (dialog-id (list-of dialog-effect)) list)
(defun add-node-enter-effects (node-id effects)
  (let ((node (gethash node-id *nodes*)))
    (if node
        (setf (node-enter-effects node)
              (append (node-enter-effects node) effects))
        (setf (gethash node-id *pending-node-enter-effects*)
              (append (node-pending-enter-effects node-id) effects)))))

(-> dialog-on-enter (dialog-id &rest dialog-effect) dialog-id)
(defun dialog-on-enter (node-id &rest effects)
  (if effects
      (add-node-enter-effects node-id effects)
      (runtime-warn "dialog-on-enter needs at least one effect: ~a" node-id))
  node-id)

(-> dialog-particles (dialog-id
                      t
                      &key
                      (:fade-seconds seconds)
                      (:immediate t))
    dialog-id)
(defun dialog-particles (node-id mode
                         &key (fade-seconds *particle-field-fade-seconds*)
                              immediate)
  (dialog-on-enter
   node-id
   `(set-particle-field-mode ,mode
                             :fade-seconds ,fade-seconds
                             :immediate ,immediate)))

(-> dialog-music (dialog-id t &key (:volume scalar)) dialog-id)
(defun dialog-music (node-id path &key (volume 0.28))
  (dialog-on-enter
   node-id
   `(set-story-music ,(namestring (dialog-asset-pathname path))
                     :volume ,volume)))

(-> dialog-stop-music (dialog-id) dialog-id)
(defun dialog-stop-music (node-id)
  (dialog-on-enter node-id 'stop-story-music))
