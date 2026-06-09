;;; one-pace/snow particle field
;;;
;;; Small white flakes drifting down with a slow side sway. Registered as a
;;; mod-defined particle field kind, the same way the bundled forest wind is.

(defparameter *one-pace-snow-count* 96)
(defvar *one-pace-snow* #())

(defstruct one-pace-snowflake
  x
  y
  vy
  drift
  phase
  size
  alpha)

(defun reset-one-pace-snowflake (flake &key initial-p)
  (setf (one-pace-snowflake-x flake)
        (random-float -20.0 (+ +virtual-width+ 20.0))
        (one-pace-snowflake-y flake)
        (if initial-p
            (random-float 0.0 (float +virtual-height+))
            (random-float -60.0 -8.0))
        (one-pace-snowflake-vy flake)
        (random-float 16.0 46.0)
        (one-pace-snowflake-drift flake)
        (random-float -9.0 9.0)
        (one-pace-snowflake-phase flake)
        (random-float 0.0 (* 2 pi))
        (one-pace-snowflake-size flake)
        (get-random-value 1 2)
        (one-pace-snowflake-alpha flake)
        (get-random-value 36 140))
  flake)

(defun reset-one-pace-snow ()
  (setf *one-pace-snow* (make-array *one-pace-snow-count*))
  (loop for i below *one-pace-snow-count*
        do (setf (aref *one-pace-snow* i)
                 (reset-one-pace-snowflake (make-one-pace-snowflake)
                                           :initial-p t))))

(defun ensure-one-pace-snow ()
  (unless (= (length *one-pace-snow*) *one-pace-snow-count*)
    (reset-one-pace-snow)))

(defun update-one-pace-snowflake (flake dt)
  (incf (one-pace-snowflake-phase flake) (* dt 0.8))
  (incf (one-pace-snowflake-x flake)
        (* (+ (one-pace-snowflake-drift flake)
              (* 11.0 (sin (one-pace-snowflake-phase flake))))
           dt))
  (incf (one-pace-snowflake-y flake)
        (* (one-pace-snowflake-vy flake) dt))
  (when (> (one-pace-snowflake-y flake) (+ +virtual-height+ 12.0))
    (reset-one-pace-snowflake flake)))

(defun update-one-pace-snow (dt)
  (ensure-one-pace-snow)
  (loop for flake across *one-pace-snow*
        do (update-one-pace-snowflake flake dt)))

(defun draw-one-pace-snowflake (flake alpha-scale)
  (let ((alpha (round (* (one-pace-snowflake-alpha flake) alpha-scale)))
        (size (one-pace-snowflake-size flake)))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (one-pace-snowflake-x flake))
                                 (round (one-pace-snowflake-y flake))
                                 size
                                 size
                                 (claylib::c-ptr
                                  (make-color 255 255 255 alpha))))))

(defun draw-one-pace-snow (alpha-scale)
  (loop for flake across *one-pace-snow*
        do (draw-one-pace-snowflake flake alpha-scale)))

(dialog-particle-field-kind :one-pace/snow
                            :reset #'reset-one-pace-snow
                            :ensure #'ensure-one-pace-snow
                            :update #'update-one-pace-snow
                            :draw #'draw-one-pace-snow)
