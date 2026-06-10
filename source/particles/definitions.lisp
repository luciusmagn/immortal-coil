(in-package #:immortal-coil)

;;; Definitions

(-> particle-field-reset-fallback () t)
(defun particle-field-reset-fallback ()
  nil)

(-> particle-field-ensure-fallback () t)
(defun particle-field-ensure-fallback ()
  nil)

(-> particle-field-update-fallback (seconds) t)
(defun particle-field-update-fallback (dt)
  (declare (ignore dt))
  nil)

(-> particle-field-draw-fallback (scalar) t)
(defun particle-field-draw-fallback (alpha-scale)
  (declare (ignore alpha-scale))
  nil)

(defclass particle-field-definition ()
  ((id
    :initarg :id
    :initform :rising
    :accessor particle-field-definition-id
    :type particle-field-mode)
   (builtin-p
    :initarg :builtin-p
    :initform nil
    :accessor particle-field-definition-builtin-p
    :type boolean)))

(defclass function-particle-field-definition (particle-field-definition)
  ((reset-function
    :initarg :reset-function
    :initform #'particle-field-reset-fallback
    :accessor particle-field-definition-reset-function
    :type runtime-function)
   (ensure-function
    :initarg :ensure-function
    :initform #'particle-field-ensure-fallback
    :accessor particle-field-definition-ensure-function
    :type runtime-function)
   (update-function
    :initarg :update-function
    :initform #'particle-field-update-fallback
    :accessor particle-field-definition-update-function
    :type runtime-function)
   (draw-function
    :initarg :draw-function
    :initform #'particle-field-draw-fallback
    :accessor particle-field-definition-draw-function
    :type runtime-function)))

(defgeneric particle-field-reset (definition))
(defgeneric particle-field-ensure (definition))
(defgeneric particle-field-update (definition dt))
(defgeneric particle-field-draw (definition alpha-scale))

(defmethod particle-field-reset ((definition function-particle-field-definition))
  (funcall (particle-field-definition-reset-function definition)))

(defmethod particle-field-ensure ((definition function-particle-field-definition))
  (funcall (particle-field-definition-ensure-function definition)))

(defmethod particle-field-update ((definition function-particle-field-definition) dt)
  (funcall (particle-field-definition-update-function definition) dt))

(defmethod particle-field-draw ((definition function-particle-field-definition)
                                alpha-scale)
  (funcall (particle-field-definition-draw-function definition) alpha-scale))
