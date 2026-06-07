(in-package #:immortal-coil)

;;; Fallback handlers

(-> minigame-update-fallback (node seconds) t)
(defun minigame-update-fallback (node dt)
  (declare (ignore node dt))
  nil)

(-> minigame-draw-fallback (node t) t)
(defun minigame-draw-fallback (node color)
  (declare (ignore node color))
  nil)

(defstruct minigame-definition
  (id              :unknown :type minigame-id)
  (update-function #'minigame-update-fallback :type runtime-function)
  (draw-function   #'minigame-draw-fallback :type runtime-function)
  (source          :unknown :type dialog-source))


;;; Definition store

(defvar *minigame-definitions* (make-hash-table :test #'eq))

(-> reset-minigames () t)
(defun reset-minigames ()
  (clrhash *minigame-definitions*))


;;; Id normalization

(-> normalize-minigame-id (t) minigame-id)
(defun normalize-minigame-id (id)
  (typecase id
    (keyword id)
    (symbol (intern (string-upcase (symbol-name id)) "KEYWORD"))
    (string (intern (string-upcase id) "KEYWORD"))
    (t
     (runtime-warn "Expected a minigame id, got: ~s" id)
     :unknown)))


;;; Handler resolution

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


;;; Registration

(-> register-minigame-definition (minigame-id runtime-function runtime-function)
    minigame-definition)
(defun register-minigame-definition (id update-function draw-function)
  (let ((definition (make-minigame-definition
                     :id id
                     :update-function update-function
                     :draw-function draw-function
                     :source (current-dialog-source-name))))
    (setf (gethash id *minigame-definitions*) definition)))

(-> dialog-minigame-kind (t &key (:update t) (:draw t)) minigame-id)
(defun dialog-minigame-kind (id &key update draw)
  (let ((minigame-id (normalize-minigame-id id))
        (update-function (minigame-handler-function update "update handler"))
        (draw-function (minigame-handler-function draw "draw handler")))
    (if (and update-function draw-function)
        (register-minigame-definition minigame-id
                                      update-function
                                      draw-function)
        (runtime-warn "Could not register minigame: ~a" minigame-id))
    minigame-id))

(-> find-minigame-definition (t &key (:warn-p boolean))
    (option minigame-definition))
(defun find-minigame-definition (id &key (warn-p t))
  (let* ((minigame-id (normalize-minigame-id id))
         (definition (gethash minigame-id *minigame-definitions*)))
    (when (and warn-p
               (not definition))
      (runtime-warn "Unknown minigame: ~a" minigame-id))
    definition))


;;; Runtime dispatch

(-> minigame-fallback-target (node) dialog-id)
(defun minigame-fallback-target (node)
  (or (node-failure-target node)
      (node-success-target node)
      *runtime-fallback-node-id*))

(-> fail-minigame-node (node) t)
(defun fail-minigame-node (node)
  (jump-to-node (minigame-fallback-target node)))

(-> update-minigame-definition (minigame-definition node seconds) t)
(defun update-minigame-definition (definition node dt)
  (handler-case
      (funcall (minigame-definition-update-function definition) node dt)
    (error (condition)
      (runtime-warn "Minigame update failed for ~a: ~a"
                    (minigame-definition-id definition)
                    condition)
      (fail-minigame-node node))))

(-> draw-minigame-definition (minigame-definition node t) t)
(defun draw-minigame-definition (definition node color)
  (handler-case
      (funcall (minigame-definition-draw-function definition) node color)
    (error (condition)
      (runtime-warn "Minigame draw failed for ~a: ~a"
                    (minigame-definition-id definition)
                    condition))))
