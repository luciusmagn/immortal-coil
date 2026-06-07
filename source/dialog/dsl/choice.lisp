(in-package #:immortal-coil)

(-> make-fallback-choice () choice)
(defun make-fallback-choice ()
  (make-choice :label "continue"
               :target *runtime-fallback-node-id*
               :condition t))

(-> dialog-option-condition (dialog-condition (option dialog-condition))
    dialog-condition)
(defun dialog-option-condition (when-condition unless-condition)
  (if unless-condition
      #'(lambda ()
          (and (dialog-condition-true-p when-condition)
               (not (dialog-condition-true-p unless-condition))))
      when-condition))

(-> dialog-option (string
                   dialog-id
                   &key
                   (:when dialog-condition)
                   (:unless (option dialog-condition)))
    choice)
(defun dialog-option (label target
                      &key ((:when when-condition) t)
                           ((:unless unless-condition) nil))
  (make-choice :label label
               :target target
               :condition (dialog-option-condition when-condition
                                                   unless-condition)))

(-> choice-active-p (choice) boolean)
(defun choice-active-p (choice)
  (dialog-condition-true-p (choice-condition choice)))

(-> active-node-choices (node) vector)
(defun active-node-choices (node)
  (remove-if-not #'choice-active-p (node-choices node)))

(-> ensure-dialog-option (t) choice)
(defun ensure-dialog-option (value)
  (if (choice-p value)
      value
      (progn
        (runtime-warn "Expected a dialog option, got: ~s" value)
        (make-fallback-choice))))

(-> ensure-dialog-options (list) vector)
(defun ensure-dialog-options (options)
  (if options
      (coerce (mapcar #'ensure-dialog-option options) 'vector)
      (progn
        (runtime-warn "Dialog choice node has no options.")
        (vector (make-fallback-choice)))))

(-> make-dialog-choice-node (dialog-id string choice-layout list) dialog-id)
(defun make-dialog-choice-node (id text layout options)
  (add-node (make-node :id id
                       :kind :choice
                       :text text
                       :layout layout
                       :choices (ensure-dialog-options options)))
  id)

(-> dialog-choice (dialog-id string &rest choice) dialog-id)
(defun dialog-choice (id text &rest options)
  (make-dialog-choice-node id text :horizontal options))

(-> dialog-pick (dialog-id string &rest choice) dialog-id)
(defun dialog-pick (id text &rest options)
  (make-dialog-choice-node id text :vertical options))

(-> dialog-list (dialog-id string &rest choice) dialog-id)
(defun dialog-list (id text &rest options)
  (make-dialog-choice-node id text :list options))

(-> dialog-add-choice (dialog-id
                       string
                       dialog-id
                       &key
                       (:when dialog-condition)
                       (:unless (option dialog-condition)))
    dialog-id)
(defun dialog-add-choice (node-id label target
                          &key ((:when when-condition) t)
                               ((:unless unless-condition) nil))
  (let ((node (find-node node-id)))
    (if (eq (node-kind node) :choice)
        (setf (node-choices node)
              (concatenate 'vector
                           (node-choices node)
                           (vector (dialog-option label
                                                  target
                                                  :when when-condition
                                                  :unless unless-condition))))
        (runtime-warn "Cannot add a choice to non-choice node: ~a" node-id)))
  node-id)
