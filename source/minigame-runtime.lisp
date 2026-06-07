(in-package #:immortal-coil)

(-> minigame-fallback-target (node) dialog-id)
(defun minigame-fallback-target (node)
  (or (node-failure-target node)
      (node-success-target node)
      *runtime-fallback-node-id*))

(-> fail-minigame-node (node) t)
(defun fail-minigame-node (node)
  (jump-to-node (minigame-fallback-target node)))

(-> update-minigame-definition (minigame-definition node seconds) t)
(defun update-minigame-definition (definition node dt)
  (handler-case
      (funcall (minigame-definition-update-function definition) node dt)
    (error (condition)
      (runtime-warn "Minigame update failed for ~a: ~a"
                    (minigame-definition-id definition)
                    condition)
      (fail-minigame-node node))))

(-> draw-minigame-definition (minigame-definition node t) t)
(defun draw-minigame-definition (definition node color)
  (handler-case
      (funcall (minigame-definition-draw-function definition) node color)
    (error (condition)
      (runtime-warn "Minigame draw failed for ~a: ~a"
                    (minigame-definition-id definition)
                    condition))))
