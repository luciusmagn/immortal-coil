(in-package #:immortal-coil)

(defun eval-dialog-effect (effect)
  (handler-case
      (cond
        ((functionp effect)
         (funcall effect))
        ((lambda-expression-p effect)
         (funcall (compile nil effect)))
        ((function-expression-p effect)
         (funcall (eval effect)))
        ((consp effect)
         (eval effect))
        ((and (symbolp effect) (fboundp effect))
         (funcall effect))
        (t
         (runtime-warn "Unknown dialog enter effect: ~s" effect)))
    (error (condition)
      (runtime-warn "Dialog enter effect failed: ~s (~a)"
                    effect
                    condition))))

(defun apply-node-enter-effects (node)
  (dolist (effect (node-enter-effects node))
    (eval-dialog-effect effect)))
