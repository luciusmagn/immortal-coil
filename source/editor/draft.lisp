(in-package #:immortal-coil)

;;; Draft persistence

(-> editor-draft-script-pathname () pathname)
(defun editor-draft-script-pathname ()
  (project-pathname *editor-draft-script-path*))

(-> editor-linear-next-node-p (node) boolean)
(defun editor-linear-next-node-p (node)
  (not (null (member (node-kind node)
                     '(:text :say :conversation)))))

(-> editor-generated-child-id (dialog-id) dialog-id)
(defun editor-generated-child-id (parent-id)
  (loop for index from 1
        for child-id = (format nil "~a/edit-~d" parent-id index)
        unless (node-exists-p child-id)
          return child-id))

(-> editor-write-set-next-form (t dialog-id dialog-id) t)
(defun editor-write-set-next-form (stream parent-id child-id)
  (format stream "~&(dialog-set-next ~s ~s)~2%"
          parent-id
          child-id))

(-> editor-write-text-form (t dialog-id string (option dialog-id)) t)
(defun editor-write-text-form (stream node-id text next-id)
  (format stream "~&(dialog-text ~s~%             ~s" node-id text)
  (when next-id
    (format stream "~%             :next ~s" next-id))
  (format stream ")~2%"))

(-> editor-write-set-text-form (t dialog-id string) t)
(defun editor-write-set-text-form (stream node-id text)
  (format stream "~&(dialog-set-text ~s~%                 ~s)~2%"
          node-id
          text))

(-> editor-append-linear-insert (dialog-id dialog-id string (option dialog-id))
    boolean)
(defun editor-append-linear-insert (parent-id child-id text old-next-id)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; insert after ~s~%" parent-id)
          (editor-write-set-next-form stream parent-id child-id)
          (editor-write-text-form stream child-id text old-next-id))
        t)
    (error (condition)
      (runtime-warn "Could not append editor draft: ~a" condition)
      nil)))

(-> editor-append-text-rewrite (dialog-id string) boolean)
(defun editor-append-text-rewrite (node-id text)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; text rewrite for ~s~%" node-id)
          (editor-write-set-text-form stream node-id text))
        t)
    (error (condition)
      (runtime-warn "Could not append editor text draft: ~a" condition)
      nil)))

(-> editor-apply-linear-insert (node dialog-id string) t)
(defun editor-apply-linear-insert (node child-id text)
  (let ((old-next-id (node-next node))
        (parent-id (node-id node)))
    (dialog-set-next parent-id child-id)
    (dialog-text child-id text :next old-next-id)
    (setf *editor-status-message*
          (format nil "EDITOR: INSERTED ~a" child-id))
    (jump-to-node child-id)))

(-> editor-insert-text-node-after-current () boolean)
(defun editor-insert-text-node-after-current ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (if (editor-linear-next-node-p node)
            (let* ((parent-id (node-id node))
                   (old-next-id (node-next node))
                   (child-id (editor-generated-child-id parent-id))
                   (text *editor-placeholder-text*))
              (if (editor-append-linear-insert parent-id
                                               child-id
                                               text
                                               old-next-id)
                  (progn
                    (editor-apply-linear-insert node child-id text)
                    (play-start-confirm)
                    t)
                  (progn
                    (setf *editor-status-message* "EDITOR: DRAFT WRITE FAILED")
                    (play-choice-switch)
                    nil)))
            (progn
              (setf *editor-status-message*
                    "EDITOR: INSERT SUPPORTS LINEAR NODES")
              (play-choice-switch)
              nil)))
      nil))
