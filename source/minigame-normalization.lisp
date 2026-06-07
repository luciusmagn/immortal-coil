(in-package #:immortal-coil)

(-> normalize-minigame-id (t) minigame-id)
(defun normalize-minigame-id (id)
  (typecase id
    (keyword id)
    (symbol (intern (string-upcase (symbol-name id)) "KEYWORD"))
    (string (intern (string-upcase id) "KEYWORD"))
    (t
     (runtime-warn "Expected a minigame id, got: ~s" id)
     :unknown)))
