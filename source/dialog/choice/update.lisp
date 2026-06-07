(in-package #:immortal-coil)

(defun choice-layout (node)
  (or (node-layout node) :horizontal))

(defun horizontal-selection-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)))

(defun vertical-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(defun selection-direction (node)
  (case (choice-layout node)
    (:horizontal (horizontal-selection-direction))
    (t (vertical-selection-direction))))

(defun move-selection (node direction)
  (let ((choice-count (length (active-node-choices node))))
    (when (>= (play-state-selected-index *state*) choice-count)
      (setf (play-state-selected-index *state*)
            (max 0 (1- choice-count))))
    (when (and direction (> choice-count 1))
      (setf (play-state-selected-index *state*)
            (mod (+ (play-state-selected-index *state*) direction)
                 choice-count))
      (play-choice-switch))))

(defun update-choice-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (move-selection node (selection-direction node))
     (when (and (plusp (length (active-node-choices node)))
                (confirm-pressed-p))
       (jump-to-node
        (choice-target (aref (active-node-choices node)
                             (play-state-selected-index *state*))))))))

(defun matching-branch-target (node)
  (loop for branch across (node-branches node)
        when (dialog-condition-true-p (branch-condition branch))
          return (branch-target branch)))

(defun update-branch-node (node)
  (let ((target (matching-branch-target node)))
    (unless target
      (runtime-warn "Branch node has no matching case: ~a" (node-id node))
      (setf target *runtime-fallback-node-id*))
    (jump-to-node target)))
