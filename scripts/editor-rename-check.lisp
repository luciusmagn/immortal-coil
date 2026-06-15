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

(defun setup-editor-rename-check-graph ()
  (reset-dialog-graph)
  (dialog-start "editor-check/old")
  (dialog-text "editor-check/source"
               "source"
               :next "editor-check/old")
  (dialog-choice "editor-check/choice"
                 "choose"
                 (dialog-option "old" "editor-check/old"))
  (dialog-number "editor-check/number"
                 "number"
                 :target "editor-check/old")
  (dialog-string "editor-check/string"
                 "string"
                 :target "editor-check/old")
  (dialog-conversation "editor-check/conversation"
                       (dialog-left "left" "line")
                       :next "editor-check/old")
  (dialog-minigame "editor-check/minigame"
                   "minigame"
                   :game :unknown
                   :success "editor-check/old"
                   :failure "editor-check/old"
                   :outcomes (list "editor-check/old"
                                   "editor-check/other"))
  (dialog-text "editor-check/old" "old")
  (dialog-text "editor-check/other" "other"))

(defun editor-rename-check-choice-target ()
  (choice-target
   (aref (node-choices (find-node "editor-check/choice")) 0)))

(defun assert-editor-rename-check-graph ()
  (editor-rename-check-assert
   (node-exists-p "editor-check/new")
   "new node id was not present after rename")
  (editor-rename-check-assert
   (not (node-exists-p "editor-check/old"))
   "old node id remained after rename")
  (editor-rename-check-assert
   (equal *story-start-node* "editor-check/new")
   "story start was not retargeted after rename")
  (editor-rename-check-assert
   (equal (node-next (find-node "editor-check/source"))
          "editor-check/new")
   "linear link was not retargeted after rename")
  (editor-rename-check-assert
   (equal (editor-rename-check-choice-target)
          "editor-check/new")
   "choice target was not retargeted after rename")
  (editor-rename-check-assert
   (equal (node-target (find-node "editor-check/number"))
          "editor-check/new")
   "number input target was not retargeted after rename")
  (editor-rename-check-assert
   (equal (node-target (find-node "editor-check/string"))
          "editor-check/new")
   "string input target was not retargeted after rename")
  (editor-rename-check-assert
   (equal (node-next (find-node "editor-check/conversation"))
          "editor-check/new")
   "conversation next target was not retargeted after rename")
  (let ((minigame (find-node "editor-check/minigame")))
    (editor-rename-check-assert
     (equal (node-success-target minigame) "editor-check/new")
     "minigame success target was not retargeted after rename")
    (editor-rename-check-assert
     (equal (node-failure-target minigame) "editor-check/new")
     "minigame failure target was not retargeted after rename")
    (editor-rename-check-assert
     (equal (node-minigame-outcomes minigame)
            '("editor-check/new" "editor-check/other"))
     "minigame outcomes were not retargeted after rename")))

(defun run-editor-rename-check ()
  (let ((*editor-draft-script-path* *editor-rename-check-draft*))
    (when (probe-file *editor-rename-check-draft*)
      (delete-file *editor-rename-check-draft*))
    (setup-editor-rename-check-graph)
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
      (assert-editor-rename-check-graph)
      (setup-editor-rename-check-graph)
      (let ((*package* (find-package "IMMORTAL-COIL")))
        (load *editor-rename-check-draft*))
      (assert-editor-rename-check-graph)))
  (format t "editor rename check passed~%"))

(run-editor-rename-check)
