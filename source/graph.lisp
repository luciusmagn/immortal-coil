(in-package #:immortal-coil)

;;; State

(defvar *nodes* (make-hash-table :test #'equal))
(defvar *node-sources* (make-hash-table :test #'equal))
(defvar *pending-node-enter-effects* (make-hash-table :test #'equal))
(defvar *story-start-node* nil)
(defvar *last-dialog-node-id* nil)
(defvar *dev-save-override* nil)
(defvar *current-dialog-source* :repl)
(defvar *dialog-conflicts* nil)
(defparameter *runtime-fallback-node-id* "runtime/fallback")

(-> reset-nodes () t)
(defun reset-nodes ()
  (clrhash *nodes*)
  (clrhash *node-sources*)
  (clrhash *pending-node-enter-effects*))


;;; Models

(defstruct choice
  (label             "" :type string)
  (target            *runtime-fallback-node-id* :type dialog-target)
  (condition         t :type dialog-condition)
  (enabled-condition t :type dialog-condition))

(defstruct conversation-entry
  (side    :left :type conversation-side)
  (speaker "" :type string)
  (text    "" :type string))

(defstruct dialog-conflict
  (node-id         *runtime-fallback-node-id* :type dialog-id)
  (previous-source :unknown :type dialog-source)
  (new-source      :unknown :type dialog-source)
  (resolution      :latest-wins :type dialog-conflict-resolution))

(defclass node ()
  ((id
    :initarg :id
    :initform *runtime-fallback-node-id*
    :accessor node-id
    :type dialog-id)
   (text
    :initarg :text
    :initform ""
    :accessor node-text
    :type string)
   (enter-effects
    :initarg :enter-effects
    :initform nil
    :accessor node-enter-effects
    :type (list-of dialog-effect))))

(defclass linear-node (node)
  ((next
    :initarg :next
    :initform nil
    :accessor node-next
    :type (option dialog-target))))

(defclass text-node (linear-node)
  ())

(defclass say-node (text-node)
  ((speaker
    :initarg :speaker
    :initform nil
    :accessor node-speaker
    :type (option string))))

(defclass conversation-node (linear-node)
  ((conversation
    :initarg :conversation
    :initform #()
    :accessor node-conversation
    :type vector)))

(defclass choice-node (node)
  ((choices
    :initarg :choices
    :initform #()
    :accessor node-choices
    :type vector)
   (layout
    :initarg :layout
    :initform nil
    :accessor node-layout
    :type (option choice-layout))))

(defclass input-node (node)
  ((target
    :initarg :target
    :initform nil
    :accessor node-target
    :type (option dialog-target))
   (response-key
    :initarg :response-key
    :initform nil
    :accessor node-response-key
    :type (option dialog-id))))

(defclass number-input-node (input-node)
  ((min-value
    :initarg :min-value
    :initform nil
    :accessor node-min-value
    :type (option number))
   (max-value
    :initarg :max-value
    :initform nil
    :accessor node-max-value
    :type (option number))))

(defclass string-input-node (input-node)
  ((max-length
    :initarg :max-length
    :initform 0
    :accessor node-max-length
    :type nonnegative-integer)
   (allow-empty-p
    :initarg :allow-empty-p
    :initform nil
    :accessor node-allow-empty-p
    :type boolean)))

(defclass minigame-node (node)
  ((minigame
    :initarg :minigame
    :initform nil
    :accessor node-minigame
    :type (option minigame-id))
   (success-target
    :initarg :success-target
    :initform nil
    :accessor node-success-target
    :type (option dialog-target))
   (failure-target
    :initarg :failure-target
    :initform nil
    :accessor node-failure-target
    :type (option dialog-target))))


;;; Kind tags

(defgeneric node-kind (node)
  (:documentation "Keyword tag for NODE, used by saves, drafts, and editor menus."))

(defmethod node-kind ((node text-node)) :text)
(defmethod node-kind ((node say-node)) :say)
(defmethod node-kind ((node conversation-node)) :conversation)
(defmethod node-kind ((node choice-node)) :choice)
(defmethod node-kind ((node number-input-node)) :number)
(defmethod node-kind ((node string-input-node)) :string)
(defmethod node-kind ((node minigame-node)) :minigame)

(-> node-kind-class (node-kind) symbol)
(defun node-kind-class (kind)
  (ecase kind
    (:text 'text-node)
    (:say 'say-node)
    (:conversation 'conversation-node)
    (:choice 'choice-node)
    (:number 'number-input-node)
    (:string 'string-input-node)
    (:minigame 'minigame-node)))

(-> make-node (&rest t) node)
(defun make-node (&rest initargs &key (kind :text) &allow-other-keys)
  (let ((args (copy-list initargs)))
    (remf args :kind)
    (apply #'make-instance (node-kind-class kind) args)))


;;; Cross-kind reader defaults
;;;
;;; Editor overlays and runtime fallbacks read kind-specific slots on
;;; arbitrary nodes; these defaults preserve the permissive reads.

(defmethod node-speaker ((node node)) nil)
(defmethod node-next ((node node)) nil)
(defmethod node-conversation ((node node)) #())
(defmethod node-choices ((node node)) #())
(defmethod node-layout ((node node)) nil)
(defmethod node-target ((node node)) nil)
(defmethod node-response-key ((node node)) nil)
(defmethod node-min-value ((node node)) nil)
(defmethod node-max-value ((node node)) nil)
(defmethod node-max-length ((node node)) 0)
(defmethod node-allow-empty-p ((node node)) nil)
(defmethod node-minigame ((node node)) nil)
(defmethod node-success-target ((node node)) nil)
(defmethod node-failure-target ((node node)) nil)


;;; Node behavior

(defgeneric node-update (node dt)
  (:documentation "Per-frame gameplay update while NODE is current."))

(defgeneric node-draw (node)
  (:documentation "Draw NODE as the current gameplay scene."))


;;; Conflict tracking

(-> dialog-source-name (t) string)
(defun dialog-source-name (source)
  (source-designator-name source))

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


;;; Enter effects

(-> node-existing-enter-effects (dialog-id) list)
(defun node-existing-enter-effects (id)
  (let ((node (gethash id *nodes*)))
    (when node
      (node-enter-effects node))))

(-> node-pending-enter-effects (dialog-id) list)
(defun node-pending-enter-effects (id)
  (gethash id *pending-node-enter-effects*))

(-> dialog-particle-effect-p (t) boolean)
(defun dialog-particle-effect-p (effect)
  (and (consp effect)
       (eq (first effect) 'set-particle-field-mode)))

(-> dialog-particle-effect-mode (t) (option t))
(defun dialog-particle-effect-mode (effect)
  (when (and (dialog-particle-effect-p effect)
             (second effect))
    (second effect)))

(-> dialog-without-particle-effects (list) list)
(defun dialog-without-particle-effects (effects)
  (remove-if #'dialog-particle-effect-p effects))

(-> node-particle-field-mode (node) (option t))
(defun node-particle-field-mode (node)
  (loop for effect in (reverse (node-enter-effects node))
        for mode = (dialog-particle-effect-mode effect)
        when mode
          return mode))

(-> dialog-story-music-effect-p (t) boolean)
(defun dialog-story-music-effect-p (effect)
  (or (eq effect 'stop-story-music)
      (and (consp effect)
           (eq (first effect) 'set-story-music))))

(-> dialog-story-music-effect-selection (t) (option t))
(defun dialog-story-music-effect-selection (effect)
  (cond
    ((eq effect 'stop-story-music)
     :stop)
    ((and (dialog-story-music-effect-p effect)
          (consp effect)
          (second effect))
     (second effect))))

(-> dialog-without-story-music-effects (list) list)
(defun dialog-without-story-music-effects (effects)
  (remove-if #'dialog-story-music-effect-p effects))

(-> node-story-music-selection (node) (option t))
(defun node-story-music-selection (node)
  (loop for effect in (reverse (node-enter-effects node))
        for selection = (dialog-story-music-effect-selection effect)
        when selection
          return selection))

(-> dialog-story-sound-effect-p (t) boolean)
(defun dialog-story-sound-effect-p (effect)
  (and (consp effect)
       (eq (first effect) 'play-story-sound)))

(-> dialog-story-sound-effect-selection (t) (option t))
(defun dialog-story-sound-effect-selection (effect)
  (when (and (dialog-story-sound-effect-p effect)
             (second effect))
    (second effect)))

(-> dialog-without-story-sound-effects (list) list)
(defun dialog-without-story-sound-effects (effects)
  (remove-if #'dialog-story-sound-effect-p effects))

(-> node-story-sound-selection (node) (option t))
(defun node-story-sound-selection (node)
  (loop for effect in (reverse (node-enter-effects node))
        for selection = (dialog-story-sound-effect-selection effect)
        when selection
          return selection))

(-> combine-node-enter-effects (node) list)
(defun combine-node-enter-effects (node)
  (let ((id (node-id node)))
    (append (node-existing-enter-effects id)
            (node-pending-enter-effects id)
            (node-enter-effects node))))

(-> eval-dialog-effect (dialog-effect) t)
(defun eval-dialog-effect (effect)
  (handler-case
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
         (runtime-warn "Unknown dialog enter effect: ~s" effect)))
    (error (condition)
      (runtime-warn "Dialog enter effect failed: ~s (~a)"
                    effect
                    condition))))

(-> apply-node-enter-effects (node) t)
(defun apply-node-enter-effects (node)
  (dolist (effect (node-enter-effects node))
    (eval-dialog-effect effect)))


;;; Node store

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

(-> delete-node (dialog-id) boolean)
(defun delete-node (id)
  (let ((existed-p (node-exists-p id)))
    (remhash id *nodes*)
    (remhash id *node-sources*)
    (remhash id *pending-node-enter-effects*)
    (when (equal *last-dialog-node-id* id)
      (setf *last-dialog-node-id* nil))
    (when (equal *story-start-node* id)
      (setf *story-start-node* *runtime-fallback-node-id*))
    existed-p))

(-> resolve-node-id (t) dialog-id)
(defun resolve-node-id (id)
  (if (node-exists-p id)
      id
      (progn
        (runtime-warn "Unknown story node: ~a" id)
        (node-id (ensure-runtime-fallback-node)))))

(-> eval-dialog-target (t) t)
(defun eval-dialog-target (target)
  (handler-case
      (cond
        ((functionp target)
         (funcall target))
        ((lambda-expression-p target)
         (funcall (compile nil target)))
        ((function-expression-p target)
         (funcall (eval target)))
        ((and (symbolp target) (fboundp target))
         (funcall target))
        ((consp target)
         (eval target))
        (t
         target))
    (error (condition)
      (runtime-warn "Dialog target delegate failed: ~s (~a)"
                    target
                    condition)
      nil)))

(-> dialog-target-id (t) (option dialog-id))
(defun dialog-target-id (target)
  (let ((value (if (stringp target)
                   target
                   (eval-dialog-target target))))
    (cond
      ((stringp value)
       value)
      ((null value)
       nil)
      (t
       (runtime-warn "Dialog target did not resolve to a node id: ~s -> ~s"
                     target
                     value)
       nil))))

(-> resolve-dialog-target (t) dialog-id)
(defun resolve-dialog-target (target)
  (resolve-node-id (or (dialog-target-id target)
                       *runtime-fallback-node-id*)))

(-> dialog-target-label (t) string)
(defun dialog-target-label (target)
  (cond
    ((null target)
     "nil")
    ((stringp target)
     target)
    ((symbolp target)
     (format nil "fn ~a" (string-downcase (symbol-name target))))
    ((functionp target)
     "#<function>")
    ((lambda-expression-p target)
     "lambda")
    ((function-expression-p target)
     (format nil "fn ~s" target))
    ((consp target)
     (format nil "expr ~s" target))
    (t
     (princ-to-string target))))

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
