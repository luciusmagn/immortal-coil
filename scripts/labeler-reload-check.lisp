(require :asdf)

(pushnew (uiop:getcwd) asdf:*central-registry* :test #'equal)
(asdf:load-system :immortal-coil)

(in-package #:immortal-coil)

(defun labeler-check-fail (message)
  (format *error-output* "~&labeler reload check failed: ~a~%" message)
  (uiop:quit 1))

(defun labeler-check (condition message)
  (unless condition
    (labeler-check-fail message)))

(defun labeler-simulate-stale-active-state ()
  (let ((tool (menu-tool :hexany-labeler)))
    (labeler-check tool "hexany labeler tool is not registered")
    (setf *active-menu-tool* tool
          (app-screen-active-p tool) t
          *hex-labeler-active-p* t
          *hex-labeler-ready-p* nil
          *hex-labeler-phase* :label
          *hex-labeler-sheets* (list :stale-sheet)
          *hex-labeler-tiles* nil
          *hex-labeler-message* "stale labeler state"
          *suppress-window-shortcuts-p* t)))

(defun labeler-assert-closed (context)
  (labeler-check (null *active-menu-tool*)
                 (format nil "~a left an active menu tool" context))
  (labeler-check (not *hex-labeler-active-p*)
                 (format nil "~a left labeler active" context))
  (labeler-check (not *hex-labeler-ready-p*)
                 (format nil "~a left labeler ready" context))
  (labeler-check (eq *hex-labeler-phase* :closed)
                 (format nil "~a left labeler phase ~s"
                         context
                         *hex-labeler-phase*))
  (labeler-check (null *hex-labeler-sheets*)
                 (format nil "~a left sheets loaded" context))
  (labeler-check (null *hex-labeler-tiles*)
                 (format nil "~a left tiles loaded" context))
  (labeler-check (not *suppress-window-shortcuts-p*)
                 (format nil "~a left window shortcuts suppressed" context)))

(labeler-simulate-stale-active-state)
(reset-menu-tools)
(labeler-assert-closed "reset-menu-tools")

(labeler-simulate-stale-active-state)
(dev-reload :system-p nil :graph-p nil)
(labeler-assert-closed "dev-reload")

(labeler-simulate-stale-active-state)
(asdf:load-system :immortal-coil :force t)
(labeler-assert-closed "forced ASDF reload")

(format t "~&labeler reload check passed~%")
