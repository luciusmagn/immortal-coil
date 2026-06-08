(in-package #:immortal-coil)

;;; Basic nodes

(-> dialog-start (dialog-id) dialog-id)
(defun dialog-start (id)
  (setf *story-start-node* id))

(-> dialog-text (dialog-id string &key (:next (option dialog-target))) dialog-id)
(defun dialog-text (id text &key next)
  (add-node (make-node :id id
                       :kind :text
                       :text text
                       :next next))
  id)

(-> dialog-say (dialog-id string string &key (:next (option dialog-target)))
    dialog-id)
(defun dialog-say (id speaker text &key next)
  (add-node (make-node :id id
                       :kind :say
                       :speaker speaker
                       :text text
                       :next next))
  id)

(-> dialog-required-link ((option dialog-target) dialog-id string) dialog-target)
(defun dialog-required-link (target id warning-text)
  (or target
      (progn
        (runtime-warn "~a: ~a" warning-text id)
        *runtime-fallback-node-id*)))

(-> dialog-set-next (dialog-id (option dialog-target)) dialog-id)
(defun dialog-set-next (node-id next-id)
  (setf (node-next (find-node node-id)) next-id)
  node-id)

(-> dialog-node-kind-p (dialog-id list string) (option node))
(defun dialog-node-kind-p (node-id kinds warning-text)
  (let ((node (find-node node-id)))
    (if (member (node-kind node) kinds)
        node
        (progn
          (runtime-warn "~a on ~a node: ~a"
                        warning-text
                        (node-kind node)
                        node-id)
          nil))))

(-> dialog-set-target (dialog-id dialog-target) dialog-id)
(defun dialog-set-target (node-id target)
  (let ((node (dialog-node-kind-p node-id
                                  '(:number :string)
                                  "Cannot set target")))
    (when node
      (setf (node-target node) target)))
  node-id)

(-> dialog-set-minigame-success (dialog-id dialog-target) dialog-id)
(defun dialog-set-minigame-success (node-id target)
  (let ((node (dialog-node-kind-p node-id
                                  '(:minigame)
                                  "Cannot set minigame success target")))
    (when node
      (setf (node-success-target node) target)))
  node-id)

(-> dialog-set-minigame-failure (dialog-id dialog-target) dialog-id)
(defun dialog-set-minigame-failure (node-id target)
  (let ((node (dialog-node-kind-p node-id
                                  '(:minigame)
                                  "Cannot set minigame failure target")))
    (when node
      (setf (node-failure-target node) target)))
  node-id)

(-> dialog-choice-at (dialog-id nonnegative-integer string) (option choice))
(defun dialog-choice-at (node-id choice-index warning-text)
  (let ((node (find-node node-id)))
    (cond
      ((not (eq (node-kind node) :choice))
       (runtime-warn "~a on non-choice node: ~a"
                     warning-text
                     node-id)
       nil)
      ((>= choice-index (length (node-choices node)))
       (runtime-warn "~a index ~d out of range for node: ~a"
                     warning-text
                     choice-index
                     node-id)
       nil)
      (t
       (aref (node-choices node) choice-index)))))

(-> dialog-set-choice-target (dialog-id nonnegative-integer dialog-target)
    dialog-id)
(defun dialog-set-choice-target (node-id choice-index target)
  (let ((choice (dialog-choice-at node-id choice-index "Cannot retarget choice")))
    (when choice
      (setf (choice-target choice) target)))
  node-id)

(-> dialog-set-choice-label (dialog-id nonnegative-integer string) dialog-id)
(defun dialog-set-choice-label (node-id choice-index label)
  (let ((choice (dialog-choice-at node-id
                                  choice-index
                                  "Cannot relabel choice")))
    (when choice
      (setf (choice-label choice) label)))
  node-id)

(-> dialog-set-choice-visible-predicate
    (dialog-id nonnegative-integer dialog-condition)
    dialog-id)
(defun dialog-set-choice-visible-predicate (node-id choice-index predicate)
  (let ((choice (dialog-choice-at node-id
                                  choice-index
                                  "Cannot set choice visibility")))
    (when choice
      (setf (choice-condition choice) predicate)))
  node-id)

(-> dialog-set-choice-enabled-predicate
    (dialog-id nonnegative-integer dialog-condition)
    dialog-id)
(defun dialog-set-choice-enabled-predicate (node-id choice-index predicate)
  (let ((choice (dialog-choice-at node-id
                                  choice-index
                                  "Cannot set choice availability")))
    (when choice
      (setf (choice-enabled-condition choice) predicate)))
  node-id)

(-> dialog-delete-node (dialog-id) dialog-id)
(defun dialog-delete-node (node-id)
  (unless (delete-node node-id)
    (runtime-warn "Cannot delete missing dialog node: ~a" node-id))
  node-id)

(-> dialog-set-text (dialog-id string) dialog-id)
(defun dialog-set-text (node-id text)
  (setf (node-text (find-node node-id)) text)
  node-id)

(-> dialog-set-speaker (dialog-id (option string)) dialog-id)
(defun dialog-set-speaker (node-id speaker)
  (let ((node (dialog-node-kind-p node-id
                                  '(:say)
                                  "Cannot set speaker")))
    (when node
      (setf (node-speaker node) speaker)))
  node-id)

(-> dialog-set-response-key (dialog-id dialog-id) dialog-id)
(defun dialog-set-response-key (node-id response-key)
  (let ((node (dialog-node-kind-p node-id
                                  '(:number :string)
                                  "Cannot set response key")))
    (when node
      (setf (node-response-key node) response-key)))
  node-id)

(-> dialog-set-number-bounds
    (dialog-id (option number) (option number))
    dialog-id)
(defun dialog-set-number-bounds (node-id min-value max-value)
  (let ((node (dialog-node-kind-p node-id
                                  '(:number)
                                  "Cannot set number bounds")))
    (when node
      (if (and min-value max-value (> min-value max-value))
          (runtime-warn "Cannot set inverted number bounds on ~a: ~a > ~a"
                        node-id
                        min-value
                        max-value)
          (setf (node-min-value node) min-value
                (node-max-value node) max-value))))
  node-id)

(-> dialog-set-string-max-length (dialog-id nonnegative-integer) dialog-id)
(defun dialog-set-string-max-length (node-id max-length)
  (let ((node (dialog-node-kind-p node-id
                                  '(:string)
                                  "Cannot set string max length")))
    (when node
      (setf (node-max-length node) max-length)))
  node-id)

(-> dialog-set-string-allow-empty (dialog-id boolean) dialog-id)
(defun dialog-set-string-allow-empty (node-id allow-empty-p)
  (let ((node (dialog-node-kind-p node-id
                                  '(:string)
                                  "Cannot set string emptiness")))
    (when node
      (setf (node-allow-empty-p node) allow-empty-p)))
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
                   dialog-target
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
  (if (and (fboundp 'editor-choice-reveal-active-p)
           (funcall (symbol-function 'editor-choice-reveal-active-p)))
      (node-choices node)
      (remove-if-not #'choice-visible-p (node-choices node))))

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
                       dialog-target
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

(-> dialog-conversation-side (t) conversation-side)
(defun dialog-conversation-side (side)
  (case side
    (:right :right)
    (:left :left)
    (t
     (runtime-warn "Unknown conversation side: ~s" side)
     :left)))

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
    (values (option dialog-target) list))
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

(-> dialog-conversation-node (dialog-id string) (option node))
(defun dialog-conversation-node (node-id warning-text)
  (let ((node (find-node node-id)))
    (if (eq (node-kind node) :conversation)
        node
        (progn
          (runtime-warn "~a on non-conversation node: ~a"
                        warning-text
                        node-id)
          nil))))

(-> dialog-conversation-entry
    (t string string)
    conversation-entry)
(defun dialog-conversation-entry (side speaker text)
  (dialog-conversation-line (dialog-conversation-side side)
                            speaker
                            text))

(-> dialog-set-conversation-entry
    (dialog-id nonnegative-integer t string string)
    dialog-id)
(defun dialog-set-conversation-entry (node-id entry-index side speaker text)
  (let ((node (dialog-conversation-node node-id
                                        "Cannot edit conversation entry")))
    (cond
      ((null node)
       nil)
      ((>= entry-index (length (node-conversation node)))
       (runtime-warn "Conversation entry index ~d out of range for node: ~a"
                     entry-index
                     node-id))
      (t
       (setf (aref (node-conversation node) entry-index)
             (dialog-conversation-entry side speaker text)))))
  node-id)

(-> dialog-insert-conversation-entry
    (dialog-id nonnegative-integer t string string)
    dialog-id)
(defun dialog-insert-conversation-entry (node-id entry-index side speaker text)
  (let ((node (dialog-conversation-node node-id
                                        "Cannot insert conversation entry")))
    (when node
      (let* ((entries (node-conversation node))
             (count (length entries))
             (index (min count (max 0 entry-index)))
             (entry (vector (dialog-conversation-entry side speaker text))))
        (setf (node-conversation node)
              (concatenate 'vector
                           (subseq entries 0 index)
                           entry
                           (subseq entries index))))))
  node-id)


;;; Input nodes

(-> dialog-number (dialog-id
                   string
                   &key
                   (:target (option dialog-target))
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
                   (:target (option dialog-target))
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
                     (:success (option dialog-target))
                     (:failure (option dialog-target)))
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

(-> dialog-set-minigame (dialog-id minigame-id) dialog-id)
(defun dialog-set-minigame (node-id game-id)
  (let ((node (find-node node-id)))
    (if (eq (node-kind node) :minigame)
        (setf (node-minigame node) game-id)
        (runtime-warn "Cannot set minigame on non-minigame node: ~a"
                      node-id)))
  node-id)


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

(-> dialog-set-particles (dialog-id
                          t
                          &key
                          (:fade-seconds seconds)
                          (:immediate t))
    dialog-id)
(defun dialog-set-particles (node-id mode
                             &key (fade-seconds *particle-field-fade-seconds*)
                                  immediate)
  (let ((effect `(set-particle-field-mode ,mode
                                           :fade-seconds ,fade-seconds
                                           :immediate ,immediate))
        (node (gethash node-id *nodes*)))
    (if node
        (setf (node-enter-effects node)
              (append (dialog-without-particle-effects
                       (node-enter-effects node))
                      (list effect)))
        (setf (gethash node-id *pending-node-enter-effects*)
              (append (dialog-without-particle-effects
                       (node-pending-enter-effects node-id))
                      (list effect)))))
  node-id)

(-> dialog-music (dialog-id t &key (:volume scalar)) dialog-id)
(defun dialog-music (node-id path &key (volume 0.28))
  (dialog-on-enter
   node-id
   `(set-story-music ,(namestring (dialog-asset-pathname path))
                     :volume ,volume)))

(-> dialog-stop-music (dialog-id) dialog-id)
(defun dialog-stop-music (node-id)
  (dialog-on-enter node-id 'stop-story-music))

(-> dialog-story-music-effect (t scalar) dialog-effect)
(defun dialog-story-music-effect (path volume)
  (if (eq path :stop)
      'stop-story-music
      `(set-story-music ,(namestring (dialog-asset-pathname path))
                        :volume ,volume)))

(-> dialog-set-music (dialog-id t &key (:volume scalar)) dialog-id)
(defun dialog-set-music (node-id path &key (volume 0.28))
  (let ((effect (dialog-story-music-effect path volume))
        (node (gethash node-id *nodes*)))
    (if node
        (setf (node-enter-effects node)
              (append (dialog-without-story-music-effects
                       (node-enter-effects node))
                      (list effect)))
        (setf (gethash node-id *pending-node-enter-effects*)
              (append (dialog-without-story-music-effects
                       (node-pending-enter-effects node-id))
                      (list effect)))))
  node-id)

(-> dialog-sound (dialog-id t &key (:volume scalar)) dialog-id)
(defun dialog-sound (node-id path &key (volume 0.50))
  (dialog-on-enter
   node-id
   `(play-story-sound ,(namestring (dialog-asset-pathname path))
                      :volume ,volume)))

(-> dialog-story-sound-effect (t scalar) (option dialog-effect))
(defun dialog-story-sound-effect (path volume)
  (unless (or (null path)
              (eq path :none))
    `(play-story-sound ,(namestring (dialog-asset-pathname path))
                       :volume ,volume)))

(-> dialog-set-sound (dialog-id t &key (:volume scalar)) dialog-id)
(defun dialog-set-sound (node-id path &key (volume 0.50))
  (let ((effect (dialog-story-sound-effect path volume))
        (node (gethash node-id *nodes*)))
    (if node
        (setf (node-enter-effects node)
              (append (dialog-without-story-sound-effects
                       (node-enter-effects node))
                      (when effect (list effect))))
        (setf (gethash node-id *pending-node-enter-effects*)
              (append (dialog-without-story-sound-effects
                       (node-pending-enter-effects node-id))
                      (when effect (list effect))))))
  node-id)

(-> dialog-clear-sound (dialog-id) dialog-id)
(defun dialog-clear-sound (node-id)
  (dialog-set-sound node-id :none))
