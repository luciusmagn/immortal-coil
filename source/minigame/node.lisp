(in-package #:immortal-coil)

(-> update-minigame-node (node seconds) t)
(defun update-minigame-node (node dt)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (let ((definition (find-minigame-definition (node-minigame node))))
       (if definition
           (update-minigame-definition definition node dt)
           (fail-minigame-node node))))))

(-> draw-minigame-node (node) t)
(defun draw-minigame-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node 96 color)
    (when (story-text-visible-p node)
      (let ((definition (find-minigame-definition (node-minigame node)
                                                  :warn-p nil)))
        (when definition
          (draw-minigame-definition definition
                                    node
                                    (make-color 255 255 255 230)))))))
