(in-package #:immortal-coil)

(defclass command-option ()
  ((action :initarg :action
           :reader command-option-action)
   (label  :initarg :label
           :reader command-option-label)))

(defclass selection-model ()
  ((items          :initarg :items
                   :accessor selection-items)
   (selected-index :initarg :selected-index
                   :initform 0
                   :accessor selection-selected-index)))

(defun make-command-option (action label)
  (make-instance 'command-option
                 :action action
                 :label label))

(defun make-selection-model (items)
  (make-instance 'selection-model
                 :items (coerce items 'vector)))

(defun command-option-label-string (label)
  (typecase label
    (string label)
    (null "")
    (t (princ-to-string label))))

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

(defun selection-count (selection)
  (length (selection-items selection)))

(defun selection-empty-p (selection)
  (zerop (selection-count selection)))

(defun selection-normalized-index (selection index)
  (if (selection-empty-p selection)
      0
      (mod index (selection-count selection))))

(defun selection-reset (selection &optional (index 0))
  (setf (selection-selected-index selection)
        (selection-normalized-index selection index))
  selection)

(defun selection-current-index (selection)
  (selection-normalized-index selection
                              (selection-selected-index selection)))

(defun selection-item (selection index)
  (unless (selection-empty-p selection)
    (aref (selection-items selection)
          (selection-normalized-index selection index))))

(defun selection-current (selection)
  (selection-item selection
                  (selection-selected-index selection)))

(defun selection-current-action (selection)
  (let ((option (selection-current selection)))
    (when option
      (command-option-action option))))

(defun selection-current-label (selection)
  (let ((option (selection-current selection)))
    (if option
        (command-option-label option)
        "")))

(defun selection-move (selection direction)
  (when (and direction
             (> (selection-count selection) 1))
    (setf (selection-selected-index selection)
          (selection-normalized-index
           selection
           (+ (selection-selected-index selection) direction)))
    t))
