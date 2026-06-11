;;; Behavioral checks for dialog target, effect, and condition
;;; designators in every supported shape. Run headless after the
;;; system loads; pairs with scripts/graph-lint.lisp.

(in-package #:immortal-coil)

(defun delegate-check-fn ()
  "checked/fn")

(handler-case
    (progn
      (load-dialog-graph)
      ;; targets in every designator shape
      (assert (equal "a/b" (eval-dialog-target "a/b")))
      (assert (equal "checked/fn" (eval-dialog-target 'delegate-check-fn)))
      (assert (equal "checked/fn" (eval-dialog-target #'delegate-check-fn)))
      (assert (equal "checked/fn"
                     (eval-dialog-target '(lambda () (delegate-check-fn)))))
      (assert (equal "checked/fn"
                     (eval-dialog-target '(function delegate-check-fn))))
      (assert (equal "checked/fn"
                     (eval-dialog-target '(delegate-check-fn))))
      (assert (null (eval-dialog-target nil)))
      ;; labels never error and stay readable
      (assert (equal "nil" (dialog-target-label nil)))
      (assert (equal "x/y" (dialog-target-label "x/y")))
      (assert (search "fn" (dialog-target-label 'delegate-check-fn)))
      (assert (stringp (dialog-target-label #'delegate-check-fn)))
      (assert (stringp (dialog-target-label '(lambda () nil))))
      (assert (stringp (dialog-target-label '(+ 1 2))))
      ;; effects run through the store
      (dialog-store-remove "delegate-check")
      (eval-dialog-effect '(setf (dialog-value "delegate-check") 7))
      (assert (= 7 (dialog-value "delegate-check")))
      ;; conditions in every shape
      (assert (dialog-condition-true-p t))
      (assert (not (dialog-condition-true-p nil)))
      (assert (dialog-condition-true-p '(dialog-value "delegate-check")))
      (assert (dialog-condition-true-p #'(lambda () t)))
      (assert (dialog-condition-true-p 'delegate-check-fn))
      (dialog-store-remove "delegate-check")
      (format t "~&DELEGATES OK~%"))
  (error (e)
    (format t "~&DELEGATES FAIL: ~a~%" e)
    (sb-ext:exit :code 1)))
