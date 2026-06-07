(in-package #:immortal-coil)

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
