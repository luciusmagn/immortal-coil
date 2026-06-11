(in-package #:immortal-coil)

;;; Models

(-> minigame-update-fallback (node seconds) t)
(defun minigame-update-fallback (node dt)
  (declare (ignore node dt))
  nil)

(-> minigame-draw-fallback (node t) t)
(defun minigame-draw-fallback (node color)
  (declare (ignore node color))
  nil)

(defclass minigame-definition ()
  ((id
    :initarg :id
    :initform :unknown
    :accessor minigame-definition-id
    :type minigame-id)
   (source
    :initarg :source
    :initform :unknown
    :accessor minigame-definition-source
    :type dialog-source)))

(defclass function-minigame-definition (minigame-definition)
  ((update-function
    :initarg :update-function
    :initform #'minigame-update-fallback
    :accessor minigame-definition-update-function
    :type runtime-function)
   (draw-function
    :initarg :draw-function
    :initform #'minigame-draw-fallback
    :accessor minigame-definition-draw-function
    :type runtime-function)))

(defgeneric minigame-update (definition node dt))
(defgeneric minigame-draw (definition node color))

(defmethod minigame-update ((definition function-minigame-definition) node dt)
  (funcall (minigame-definition-update-function definition) node dt))

(defmethod minigame-draw ((definition function-minigame-definition) node color)
  (funcall (minigame-definition-draw-function definition) node color))


;;; Definition store

(defvar *minigame-definitions* (make-hash-table :test #'eq))
(defvar *minigame-reset-hooks* nil)

(-> register-minigame-reset-hook (t) t)
(defun register-minigame-reset-hook (hook)
  (pushnew hook *minigame-reset-hooks* :test #'equal)
  hook)

(-> minigame-reset-hook-function (t) (option runtime-function))
(defun minigame-reset-hook-function (hook)
  (cond
    ((functionp hook)
     hook)
    ((and (symbolp hook)
          (fboundp hook))
     (symbol-function hook))))

(-> run-minigame-reset-hooks () t)
(defun run-minigame-reset-hooks ()
  (dolist (hook *minigame-reset-hooks*)
    (let ((function (minigame-reset-hook-function hook)))
      (when function
        (handler-case
            (funcall function)
          (error (condition)
            (runtime-warn "Minigame reset hook failed: ~a" condition)))))))

(-> reset-minigames () t)
(defun reset-minigames ()
  (run-minigame-reset-hooks)
  (clrhash *minigame-definitions*))

(-> registered-minigame-ids () list)
(defun registered-minigame-ids ()
  (sort (loop for id being the hash-keys of *minigame-definitions*
              collect id)
        #'string<
        :key #'symbol-name))


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
      (or (resolve-function-designator handler)
          (progn
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

(-> make-function-minigame-definition
    (minigame-id runtime-function runtime-function)
    function-minigame-definition)
(defun make-function-minigame-definition (id update-function draw-function)
  (make-instance 'function-minigame-definition
                 :id id
                 :update-function update-function
                 :draw-function draw-function
                 :source (current-dialog-source-name)))

(-> register-minigame-definition (t &optional t t) minigame-definition)
(defun register-minigame-definition (definition-or-id
                                     &optional update-function draw-function)
  (let ((definition
          (if (typep definition-or-id 'minigame-definition)
              definition-or-id
              (make-function-minigame-definition definition-or-id
                                                 update-function
                                                 draw-function))))
    (setf (gethash (minigame-definition-id definition)
                   *minigame-definitions*)
          definition)))

(-> dialog-minigame-kind (t &key (:update t) (:draw t)) minigame-id)
(defun dialog-minigame-kind (id &key update draw)
  (let ((minigame-id (normalize-minigame-id id))
        (update-function (minigame-handler-function update "update handler"))
        (draw-function (minigame-handler-function draw "draw handler")))
    (if (and update-function draw-function)
        (register-minigame-definition
         (make-function-minigame-definition minigame-id
                                            update-function
                                            draw-function))
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


;;; Config and outcomes
;;;
;;; A minigame node may carry a config plist the minigame reads, and an
;;; outcomes list of the node ids the minigame may finish at, beyond the
;;; classic success and failure targets. The engine never interprets
;;; either: the minigame is a black box that takes outcome ids in through
;;; its config (or keeps static ones) and returns the outcome id it
;;; finished with. The outcomes list exists so authoring tools can see
;;; every possible destination without understanding the minigame.

(-> minigame-config-value (node t &optional t) t)
(defun minigame-config-value (node key &optional default)
  (getf (node-minigame-config node) key default))


;;; Sessions
;;;
;;; A session owns one play-through's state for a class-based minigame.
;;; The shared cache replaces the per-game global-and-ensure scaffolding.

(defclass minigame-session ()
  ((node-id
    :initarg :node-id
    :initform *runtime-fallback-node-id*
    :reader minigame-session-node-id
    :type dialog-id)
   (config
    :initarg :config
    :initform nil
    :reader minigame-session-config
    :type list)))

(defclass session-minigame-definition (minigame-definition)
  ((session-class
    :initarg :session-class
    :reader minigame-definition-session-class
    :type symbol)))

(defgeneric make-minigame-session (definition node)
  (:documentation "Fresh session for DEFINITION at NODE.")
  (:method ((definition session-minigame-definition) node)
    (make-instance (minigame-definition-session-class definition)
                   :node-id (node-id node)
                   :config (node-minigame-config node))))

(defgeneric minigame-session-update (session node dt))

(defgeneric minigame-session-draw (session node color))

(defvar *minigame-session* nil)

(-> session-config-value (minigame-session t &optional t) t)
(defun session-config-value (session key &optional default)
  (getf (minigame-session-config session) key default))

(-> session-store-value (minigame-session dialog-store-key &optional t) t)
(defun session-store-value (session key &optional default)
  (declare (ignore session))
  (dialog-value key default))

(defun (setf session-store-value) (value session key)
  (declare (ignore session))
  (setf (dialog-value key) value))

(-> clear-minigame-session () null)
(defun clear-minigame-session ()
  (setf *minigame-session* nil))

(register-minigame-reset-hook 'clear-minigame-session)

(-> ensure-minigame-session (session-minigame-definition node)
    minigame-session)
(defun ensure-minigame-session (definition node)
  (unless (and *minigame-session*
               (equal (minigame-session-node-id *minigame-session*)
                      (node-id node)))
    (setf *minigame-session* (make-minigame-session definition node)))
  *minigame-session*)

(defmethod minigame-update ((definition session-minigame-definition) node dt)
  (minigame-session-update (ensure-minigame-session definition node) node dt))

(defmethod minigame-draw ((definition session-minigame-definition) node color)
  (minigame-session-draw (ensure-minigame-session definition node) node color))

(-> register-minigame-session-kind (t symbol) minigame-definition)
(defun register-minigame-session-kind (id session-class)
  (register-minigame-definition
   (make-instance 'session-minigame-definition
                  :id (normalize-minigame-id id)
                  :session-class session-class
                  :source (current-dialog-source-name))))


;;; Runtime dispatch

(-> minigame-fallback-target (node) dialog-target)
(defun minigame-fallback-target (node)
  (or (node-failure-target node)
      (node-success-target node)
      *runtime-fallback-node-id*))

(-> finish-minigame-node (node (option dialog-target)) t)
(defun finish-minigame-node (node target)
  (clear-minigame-session)
  (jump-to-dialog-target (or target (minigame-fallback-target node))))

(-> fail-minigame-node (node) t)
(defun fail-minigame-node (node)
  (clear-minigame-session)
  (jump-to-dialog-target (minigame-fallback-target node)))

(-> update-minigame-definition (minigame-definition node seconds) t)
(defun update-minigame-definition (definition node dt)
  (handler-case
      (minigame-update definition node dt)
    (error (condition)
      (runtime-warn "Minigame update failed for ~a: ~a"
                    (minigame-definition-id definition)
                    condition)
      (fail-minigame-node node))))

(-> draw-minigame-definition (minigame-definition node t) t)
(defun draw-minigame-definition (definition node color)
  (handler-case
      (minigame-draw definition node color)
    (error (condition)
      (runtime-warn "Minigame draw failed for ~a: ~a"
                    (minigame-definition-id definition)
                    condition))))
