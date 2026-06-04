(in-package #:immortal-coil)

(defvar *nodes* (make-hash-table :test #'equal))
(defvar *story-start-node* nil)

(defstruct choice
  label
  target)

(defstruct node
  id
  kind
  text
  next
  choices)

(defun reset-nodes ()
  (clrhash *nodes*))

(defun add-node (node)
  (setf (gethash (node-id node) *nodes*) node))

(defun find-node (id)
  (or (gethash id *nodes*)
      (error "Unknown story node: ~a" id)))

(defun reset-dialog-graph ()
  (reset-nodes)
  (setf *story-start-node* nil))

(defun dialog-start (id)
  (setf *story-start-node* id))

(defun dialog-text (id text &key next)
  (add-node (make-node :id id
                       :kind :text
                       :text text
                       :next next))
  id)

(defun dialog-option (label target)
  (make-choice :label label :target target))

(defun ensure-dialog-option (value)
  (unless (choice-p value)
    (error "Expected a dialog option, got: ~s" value))
  value)

(defun dialog-choice (id text &rest options)
  (add-node (make-node :id id
                       :kind :choice
                       :text text
                       :choices (coerce (mapcar #'ensure-dialog-option options)
                                        'vector)))
  id)

(defun dialog-add-choice (node-id label target)
  (let ((node (find-node node-id)))
    (unless (eq (node-kind node) :choice)
      (error "Cannot add a choice to non-choice node: ~a" node-id))
    (setf (node-choices node)
          (concatenate 'vector
                       (node-choices node)
                       (vector (dialog-option label target)))))
  node-id)

(defun dialog-set-next (node-id next-id)
  (setf (node-next (find-node node-id)) next-id)
  node-id)

(defun dialog-script-pathname (path)
  (etypecase path
    (pathname path)
    (string (asdf:system-relative-pathname :immortal-coil path))))

(defun eval-dialog-script (path)
  (let ((eof (gensym "EOF")))
    (with-open-file (stream (dialog-script-pathname path))
      (let ((*package* (find-package "IMMORTAL-COIL")))
        (loop for form = (read stream nil eof)
              until (eq form eof)
              do (eval form))))))

(defun load-dialog-graph (&optional (paths *dialog-script-paths*))
  (reset-dialog-graph)
  (dolist (path paths)
    (eval-dialog-script path))
  (unless *story-start-node*
    (error "No dialog start node was set by scripts: ~s" paths))
  *story-start-node*)
