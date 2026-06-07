(in-package #:immortal-coil)

(defstruct choice
  (label     "" :type string)
  (target    *runtime-fallback-node-id* :type dialog-id)
  (condition t :type dialog-condition))

(defstruct branch
  (condition t :type dialog-condition)
  (target    *runtime-fallback-node-id* :type dialog-id))

(defstruct dialog-conflict
  (node-id         *runtime-fallback-node-id* :type dialog-id)
  (previous-source :unknown :type dialog-source)
  (new-source      :unknown :type dialog-source)
  (resolution      :latest-wins :type dialog-conflict-resolution))

(defstruct node
  (id             *runtime-fallback-node-id* :type dialog-id)
  (kind           :text :type node-kind)
  (text           "" :type string)
  (next           nil :type (option dialog-id))
  (choices        #() :type vector)
  (branches       #() :type vector)
  (layout         nil :type (option choice-layout))
  (target         nil :type (option dialog-id))
  (response-key   nil :type (option dialog-id))
  (min-value      nil :type (option number))
  (max-value      nil :type (option number))
  (max-length     0 :type nonnegative-integer)
  (allow-empty-p  nil :type boolean)
  (minigame       nil :type (option minigame-id))
  (success-target nil :type (option dialog-id))
  (failure-target nil :type (option dialog-id))
  (enter-effects  nil :type (list-of dialog-effect)))
