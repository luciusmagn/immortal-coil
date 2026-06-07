(in-package #:immortal-coil)

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
