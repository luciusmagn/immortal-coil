(in-package #:immortal-coil)

(defvar *state* nil)
(defvar *save-current-game-function* nil)
(defvar *save-current-game-p* nil)

(defstruct play-state
  (current-id     *runtime-fallback-node-id* :type dialog-id)
  (elapsed        0.0 :type seconds)
  (type-delay     0.0 :type seconds)
  (visible-count  0 :type nonnegative-integer)
  (selected-index 0 :type nonnegative-integer)
  (input-buffer   "" :type string))
