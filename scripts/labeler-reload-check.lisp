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

(defun labeler-temp-save-root ()
  (let ((root (merge-pathnames
               (format nil "immortal-coil-labeler-check-~d-~d/"
                       (get-universal-time)
                       (random 1000000))
               (uiop:temporary-directory))))
    (ensure-directories-exist root)
    root))

(defun labeler-write-save-data (data)
  (ensure-directories-exist (hex-labeler-save-path))
  (with-open-file (stream (hex-labeler-save-path)
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (with-standard-io-syntax
      (let ((*print-readably* t))
        (print data stream)))))

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

(defun labeler-check-malformed-save-data ()
  (let ((*hex-labeler-save-root-override* (labeler-temp-save-root)))
    (labeler-write-save-data
     '(:version 1
       :crop (:left 99 :top -4 :right "bad" :bottom)
       :labels ((:sheet "general" :col 1 :row 2 :label "floor")
                (:sheet "general" :col "bad" :row 3 :label "bad-col")
                (:sheet "general" :col 4 :row 5)
                :not-a-label
                (:sheet "odd" :col))
       :skipped ((:sheet "items" :col 3 :row 4)
                 (:sheet "items" :col 3 :row "bad-row")
                 :not-a-skip)))
    (reset-hexany-labeler-state)
    (hex-labeler-load-data)
    (labeler-check (= *hex-labeler-crop-left* +hex-labeler-edge-max+)
                   "malformed crop left was not clamped")
    (labeler-check (zerop *hex-labeler-crop-top*)
                   "malformed crop top was not clamped")
    (labeler-check (zerop *hex-labeler-crop-right*)
                   "malformed crop right was not ignored")
    (labeler-check (zerop *hex-labeler-crop-bottom*)
                   "malformed crop bottom was not ignored")
    (labeler-check (= 1 (length *hex-labeler-labels*))
                   "malformed labels were not filtered")
    (labeler-check (= 1 (length *hex-labeler-skips*))
                   "malformed skips were not filtered")
    (setf *hex-labeler-labels*
          (list '(:sheet "general" :col 1 :row 2 :label "floor")
                '(:sheet "general" :col "bad" :row 3 :label "bad-col")
                :not-a-label)
          *hex-labeler-skips*
          (list '(:sheet "items" :col 3 :row 4)
                '(:sheet "items" :col 3 :row "bad-row")
                :not-a-skip))
    (let ((data (hex-labeler-save-data-plist)))
      (labeler-check (= 1 (length (getf data :labels)))
                     "save plist kept malformed labels")
      (labeler-check (= 1 (length (getf data :skipped)))
                     "save plist kept malformed skips"))))

(labeler-simulate-stale-active-state)
(reset-menu-tools)
(labeler-assert-closed "reset-menu-tools")

(labeler-simulate-stale-active-state)
(dev-reload :system-p nil :graph-p nil)
(labeler-assert-closed "dev-reload")

(labeler-simulate-stale-active-state)
(load (merge-pathnames "source/tile-labeler.lisp" (uiop:getcwd)))
(labeler-assert-closed "source file reload")

(labeler-simulate-stale-active-state)
(asdf:load-system :immortal-coil :force t)
(labeler-assert-closed "forced ASDF reload")

(labeler-check-malformed-save-data)

(format t "~&labeler reload check passed~%")
