(in-package #:immortal-coil)

(defclass command-option ()
  ((action :initarg :action
           :type command-action
           :reader command-option-action)
   (label  :initarg :label
           :type string
           :reader command-option-label)))

(defclass selection-model ()
  ((items          :initarg :items
                   :type vector
                   :accessor selection-items)
   (selected-index :initarg :selected-index
                   :initform 0
                   :type nonnegative-integer
                   :accessor selection-selected-index)))

(-> make-command-option (command-action string) command-option)
(defun make-command-option (action label)
  (make-instance 'command-option
                 :action action
                 :label label))

(-> make-selection-model (sequence) selection-model)
(defun make-selection-model (items)
  (make-instance 'selection-model
                 :items (coerce items 'vector)))

(-> command-option-label-string (t) string)
(defun command-option-label-string (label)
  (typecase label
    (string label)
    (null "")
    (t (princ-to-string label))))

(-> make-command-selection (&rest t) selection-model)
(defun make-command-selection (&rest specs)
  (make-selection-model
   (loop for rest on specs by #'cddr
         for action = (first rest)
         for label = (second rest)
         when action
           collect (make-command-option action
                                        (command-option-label-string label))
         else
           do (runtime-warn "Ignoring menu option without an action: ~s"
                            rest))))

(-> selection-count (selection-model) nonnegative-integer)
(defun selection-count (selection)
  (length (selection-items selection)))

(-> selection-empty-p (selection-model) boolean)
(defun selection-empty-p (selection)
  (zerop (selection-count selection)))

(-> selection-normalized-index (selection-model integer) nonnegative-integer)
(defun selection-normalized-index (selection index)
  (if (selection-empty-p selection)
      0
      (mod index (selection-count selection))))

(-> selection-reset (selection-model &optional integer) selection-model)
(defun selection-reset (selection &optional (index 0))
  (setf (selection-selected-index selection)
        (selection-normalized-index selection index))
  selection)

(-> selection-current-index (selection-model) nonnegative-integer)
(defun selection-current-index (selection)
  (selection-normalized-index selection
                              (selection-selected-index selection)))

(-> selection-item (selection-model integer) (option command-option))
(defun selection-item (selection index)
  (unless (selection-empty-p selection)
    (aref (selection-items selection)
          (selection-normalized-index selection index))))

(-> selection-current (selection-model) (option command-option))
(defun selection-current (selection)
  (selection-item selection
                  (selection-selected-index selection)))

(-> selection-current-action (selection-model) (option command-action))
(defun selection-current-action (selection)
  (let ((option (selection-current selection)))
    (when option
      (command-option-action option))))

(-> selection-current-label (selection-model) string)
(defun selection-current-label (selection)
  (let ((option (selection-current selection)))
    (if option
        (command-option-label option)
        "")))

(-> selection-move (selection-model (option integer)) boolean)
(defun selection-move (selection direction)
  (when (and direction
             (> (selection-count selection) 1))
    (setf (selection-selected-index selection)
          (selection-normalized-index
           selection
           (+ (selection-selected-index selection) direction)))
    t))
