(in-package #:immortal-coil)

(defmacro dialog-path (id &body body)
  (multiple-value-bind (texts keys)
      (dialog-pattern-read-body body)
    `(dialog-define-path ,id
                         (list ,@texts)
                         :next ,(getf keys :next))))

(defmacro dialog-choice-path (id prompt &body branches)
  (dialog-choice-pattern-expansion 'dialog-choice id prompt branches))

(defmacro dialog-pick-path (id prompt &body branches)
  (dialog-choice-pattern-expansion 'dialog-pick id prompt branches))

(defmacro dialog-list-path (id prompt &body branches)
  (dialog-choice-pattern-expansion 'dialog-list id prompt branches))
