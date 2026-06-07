(in-package #:immortal-coil)

(-> save-current-game-maybe () t)
(defun save-current-game-maybe ()
  (when (and *save-current-game-p*
             *save-current-game-function*)
    (handler-case
        (funcall *save-current-game-function*)
      (error (condition)
        (runtime-warn "Could not save game: ~a" condition)))))
