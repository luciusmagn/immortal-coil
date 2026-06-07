(in-package #:immortal-coil)

(-> minigame-handler-function (t t) (option runtime-function))
(defun minigame-handler-function (handler description)
  (handler-case
      (cond
        ((functionp handler)
         handler)
        ((and (symbolp handler)
              (fboundp handler))
         (symbol-function handler))
        ((consp handler)
         (let ((value (eval handler)))
           (if (functionp value)
               value
               (progn
                 (runtime-warn "Minigame ~a did not evaluate to a function: ~s"
                               description
                               handler)
                 nil))))
        (t
         (runtime-warn "Minigame ~a is not a function designator: ~s"
                       description
                       handler)
         nil))
    (error (condition)
      (runtime-warn "Minigame ~a failed to resolve: ~s (~a)"
                    description
                    handler
                    condition)
      nil)))
