(require :asdf)
(let ((quicklisp-setup (merge-pathnames "quicklisp/setup.lisp"
                                        (user-homedir-pathname))))
  (when (probe-file quicklisp-setup)
    (load quicklisp-setup)))
(asdf:load-system :immortal-coil)

(in-package #:immortal-coil)

(defparameter *editor-rename-check-draft*
  #P"/tmp/immortal-coil-editor-rename-check.lisp")

(defun editor-rename-check-fail (control &rest arguments)
  (error "~?" control arguments))

(defun editor-rename-check-assert (condition control &rest arguments)
  (unless condition
    (apply #'editor-rename-check-fail control arguments)))

(defun run-editor-rename-check ()
  (let ((*editor-draft-script-path* *editor-rename-check-draft*))
    (when (probe-file *editor-rename-check-draft*)
      (delete-file *editor-rename-check-draft*))
    (reset-dialog-graph)
    (dialog-text "editor-check/source"
                 "source"
                 :next "editor-check/old")
    (dialog-text "editor-check/old" "old")
    (reset-editor-node-fields-edit-state)
    (let ((node (find-node "editor-check/old")))
      (setf *editor-node-fields-node-id* (node-id node)
            (editor-node-field-buffer :id) "editor-check/new")
      (editor-rename-check-assert
       (node-fields-valid-p node)
       "editor node rename buffers should validate")
      (editor-rename-check-assert
       (editor-append-node-fields-edit (node-id node) node)
       "editor rename draft write failed")
      (node-apply-fields-edit node)
      (editor-rename-check-assert
       (node-exists-p "editor-check/new")
       "new node id was not present after in-memory rename")
      (editor-rename-check-assert
       (not (node-exists-p "editor-check/old"))
       "old node id remained after in-memory rename")
      (editor-rename-check-assert
       (equal (node-next (find-node "editor-check/source"))
              "editor-check/new")
       "source link was not retargeted after in-memory rename")
      (reset-dialog-graph)
      (dialog-text "editor-check/source"
                   "source"
                   :next "editor-check/old")
      (dialog-text "editor-check/old" "old")
      (let ((*package* (find-package "IMMORTAL-COIL")))
        (load *editor-rename-check-draft*))
      (editor-rename-check-assert
       (node-exists-p "editor-check/new")
       "new node id was not present after draft reload")
      (editor-rename-check-assert
       (not (node-exists-p "editor-check/old"))
       "old node id remained after draft reload")
      (editor-rename-check-assert
       (equal (node-next (find-node "editor-check/source"))
              "editor-check/new")
       "source link was not retargeted after draft reload")))
  (format t "editor rename check passed~%"))

(run-editor-rename-check)
