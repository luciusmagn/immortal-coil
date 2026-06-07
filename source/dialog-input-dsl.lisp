(in-package #:immortal-coil)

(-> dialog-number (dialog-id
                   string
                   &key
                   (:target (option dialog-id))
                   (:response-key (option dialog-id))
                   (:min (option number))
                   (:max (option number)))
    dialog-id)
(defun dialog-number (id text &key target response-key min max)
  (add-node (make-node
             :id id
             :kind :number
             :text text
             :target (dialog-required-link target
                                           id
                                           "Number node needs a target")
             :response-key (or response-key id)
             :min-value min
             :max-value max))
  id)

(-> dialog-string (dialog-id
                   string
                   &key
                   (:target (option dialog-id))
                   (:response-key (option dialog-id))
                   (:max-length nonnegative-integer)
                   (:allow-empty t))
    dialog-id)
(defun dialog-string (id text &key target response-key (max-length 32) allow-empty)
  (add-node (make-node
             :id id
             :kind :string
             :text text
             :target (dialog-required-link target
                                           id
                                           "String node needs a target")
             :response-key (or response-key id)
             :max-length max-length
             :allow-empty-p allow-empty))
  id)
