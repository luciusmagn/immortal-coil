(in-package #:immortal-coil)

(-> update-minigame-node (node seconds) t)
(defun update-minigame-node (node dt)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (case (node-minigame node)
       (:wire-flight (update-flight-minigame-node node dt))
       (t
        (runtime-warn "Unknown minigame: ~a" (node-minigame node))
        (jump-to-node (or (node-failure-target node)
                          (node-success-target node)
                          *runtime-fallback-node-id*)))))))

(-> draw-minigame-node (node) t)
(defun draw-minigame-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node 96 color)
    (when (and (story-text-visible-p node)
               (eq (node-minigame node) :wire-flight))
      (draw-flight-minigame node (make-color 255 255 255 230)))))
