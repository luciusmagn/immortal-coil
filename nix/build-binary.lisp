(require :asdf)

(setf uiop:*compile-file-warnings-behaviour* :warn)

(let ((uiop:*compile-file-failure-behaviour* :warn))
  (asdf:load-system :claylib))

(asdf:load-system :immortal-coil)

(defun stop-eager-future-workers ()
  (eager-future2:advise-thread-pool-size 0)
  (loop repeat 100
        until (zerop (eager-future2:thread-pool-size))
        do (sleep 0.05))
  (unless (zerop (eager-future2:thread-pool-size))
    (error "Eager Future2 workers did not stop before image save.")))

(defun release-main ()
  (eager-future2:advise-thread-pool-size 10)
  (immortal-coil:main))

(stop-eager-future-workers)

(sb-ext:save-lisp-and-die
 "immortal-coil"
 :toplevel #'release-main
 :executable t
 :compression t)
