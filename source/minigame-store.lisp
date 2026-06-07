(in-package #:immortal-coil)

(defvar *minigame-definitions* (make-hash-table :test #'eq))

(-> reset-minigames () t)
(defun reset-minigames ()
  (clrhash *minigame-definitions*))
