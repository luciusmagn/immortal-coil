(in-package #:immortal-coil)

;;; Particle system base
;;;
;;; A particle system owns its particle vector and the array scaffolding;
;;; concrete systems only provide count, allocation, and per-particle
;;; reset/update/draw behavior.

(defclass particle-system (particle-field-definition)
  ((particles
    :initform #()
    :accessor particle-system-particles
    :type vector)))

(defgeneric particle-system-count (system)
  (:documentation "Target particle count for SYSTEM."))

(defgeneric particle-system-make (system)
  (:documentation "Allocate one fresh particle for SYSTEM."))

(defgeneric particle-system-reset-particle (system particle &key initial-p)
  (:documentation "Re-seed PARTICLE for SYSTEM and return it."))

(defgeneric particle-system-update-particle (system particle dt))

(defgeneric particle-system-draw-particle (system particle alpha-scale))

(-> particle-system-new-particle (particle-system) t)
(defun particle-system-new-particle (system)
  (particle-system-reset-particle system
                                  (particle-system-make system)
                                  :initial-p t))

(defmethod particle-field-reset ((system particle-system))
  (let* ((count (particle-system-count system))
         (particles (make-array count)))
    (loop for i below count
          do (setf (aref particles i)
                   (particle-system-new-particle system)))
    (setf (particle-system-particles system) particles)))

(defmethod particle-field-ensure ((system particle-system))
  (let ((count (particle-system-count system))
        (particles (particle-system-particles system)))
    (unless (= (length particles) count)
      (let ((resized (make-array count)))
        (loop for i below count
              do (setf (aref resized i)
                       (if (< i (length particles))
                           (aref particles i)
                           (particle-system-new-particle system))))
        (setf (particle-system-particles system) resized)))))

(defmethod particle-field-update ((system particle-system) dt)
  (loop for particle across (particle-system-particles system)
        do (particle-system-update-particle system particle dt)))

(defmethod particle-field-draw ((system particle-system) alpha-scale)
  (loop for particle across (particle-system-particles system)
        do (particle-system-draw-particle system particle alpha-scale)))
