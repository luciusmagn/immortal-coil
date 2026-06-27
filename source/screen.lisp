(in-package #:immortal-coil)

;;; Application-level screens/tools. Claylib scenes manage drawable objects and
;;; assets; this protocol manages the app lifecycle around those scenes.

(defclass app-screen ()
  ((%id :initarg :id
        :reader app-screen-id)
   (%active-p :initform nil
              :accessor app-screen-active-p)))

(defgeneric app-screen-enter (screen)
  (:documentation "Make SCREEN the active UI surface and allocate/load its state."))

(defgeneric app-screen-leave (screen)
  (:documentation "Leave SCREEN, saving or releasing state as needed."))

(defgeneric app-screen-reset (screen)
  (:documentation "Clear SCREEN state after hot reload or fresh game setup."))

(defgeneric app-screen-update (screen)
  (:documentation "Update one frame of SCREEN."))

(defgeneric app-screen-draw (screen)
  (:documentation "Draw one frame of SCREEN."))

(defmethod app-screen-enter ((screen app-screen))
  (setf (app-screen-active-p screen) t))

(defmethod app-screen-leave ((screen app-screen))
  (setf (app-screen-active-p screen) nil))

(defmethod app-screen-reset ((screen app-screen))
  (setf (app-screen-active-p screen) nil))

(defvar *menu-tool-registry* (make-hash-table :test #'eq))
(defvar *active-menu-tool* nil)

(-> register-menu-tool (app-screen) app-screen)
(defun register-menu-tool (tool)
  (let* ((id (app-screen-id tool))
         (old-tool (gethash id *menu-tool-registry*)))
    (when (and old-tool
               (eq old-tool *active-menu-tool*))
      (close-menu-tool old-tool))
    (setf (gethash id *menu-tool-registry*) tool))
  tool)

(-> menu-tool (keyword) (or app-screen null))
(defun menu-tool (id)
  (gethash id *menu-tool-registry*))

(-> active-menu-tool-p (&optional (or keyword null)) boolean)
(defun active-menu-tool-p (&optional id)
  (and *active-menu-tool*
       (app-screen-active-p *active-menu-tool*)
       (or (null id)
           (eq (app-screen-id *active-menu-tool*) id))
       t))

(-> close-menu-tool (&optional (or keyword app-screen null)) boolean)
(defun close-menu-tool (&optional tool-or-id)
  (let ((tool (etypecase tool-or-id
                (null *active-menu-tool*)
                (keyword (menu-tool tool-or-id))
                (app-screen tool-or-id))))
    (when tool
      (handler-case
          (app-screen-leave tool)
        (error (condition)
          (runtime-warn "Could not leave menu tool ~a: ~a"
                        (app-screen-id tool)
                        condition)))
      (when (eq tool *active-menu-tool*)
        (setf *active-menu-tool* nil))
      t)))

(-> open-menu-tool (keyword) boolean)
(defun open-menu-tool (id)
  (let ((tool (menu-tool id)))
    (cond
      ((null tool)
       (runtime-warn "Unknown menu tool ~a" id)
       nil)
      (t
       (when (and *active-menu-tool*
                  (not (eq *active-menu-tool* tool)))
         (close-menu-tool *active-menu-tool*))
       (handler-case
           (progn
             (app-screen-enter tool)
             (setf *active-menu-tool* tool)
             t)
         (error (condition)
           (runtime-warn "Could not open menu tool ~a: ~a" id condition)
           (app-screen-reset tool)
           nil))))))

(-> reset-menu-tools () t)
(defun reset-menu-tools ()
  (when *active-menu-tool*
    (close-menu-tool *active-menu-tool*))
  (maphash (lambda (id tool)
             (declare (ignore id))
             (handler-case
                 (app-screen-reset tool)
               (error (condition)
                 (runtime-warn "Could not reset menu tool ~a: ~a"
                               (app-screen-id tool)
                               condition))))
           *menu-tool-registry*)
  (setf *active-menu-tool* nil)
  t)

(-> update-active-menu-tool () boolean)
(defun update-active-menu-tool ()
  (when (active-menu-tool-p)
    (handler-case
        (app-screen-update *active-menu-tool*)
      (error (condition)
        (runtime-warn "Menu tool update failed for ~a: ~a"
                      (app-screen-id *active-menu-tool*)
                      condition)))
    t))

(-> draw-active-menu-tool () boolean)
(defun draw-active-menu-tool ()
  (when (active-menu-tool-p)
    (handler-case
        (app-screen-draw *active-menu-tool*)
      (error (condition)
        (runtime-warn "Menu tool draw failed for ~a: ~a"
                      (app-screen-id *active-menu-tool*)
                      condition)
        (clear-background :color +black+)))
    t))

(eval-when (:load-toplevel :execute)
  (reset-menu-tools))
