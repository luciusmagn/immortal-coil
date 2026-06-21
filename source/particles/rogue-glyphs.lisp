(in-package #:immortal-coil)

;;; Rogue-glyph field: a few of the dungeon's own tile letters drifting
;;; loose in the dark, each moving the way its tile would. A bat (B)
;;; flies, a snake (s) slithers, an orc (O) walks the turns of a maze, a
;;; wall (#) falls, and chalk (*) just drifts. Gentle and dimmed, for the
;;; rogue path and its delve.

(defparameter *rogue-glyph-particle-count* 34)

(defparameter *rogue-glyph-kinds*
  '((:bird   "B")
    (:snake  "s")
    (:maze   "O")
    (:faller "#")
    (:drift  "*")))

(defstruct rogue-glyph-particle
  kind
  glyph
  x
  y
  vx
  vy
  phase
  phase-speed
  amp
  timer
  size
  alpha)

(defun rogue-glyph-wrap (value limit)
  (cond ((< value -16.0) (+ limit 16.0))
        ((> value (+ limit 16.0)) -16.0)
        (t value)))

(defun reset-rogue-glyph-particle (particle &key initial-p)
  (let* ((entry (nth (get-random-value 0 (1- (length *rogue-glyph-kinds*)))
                     *rogue-glyph-kinds*))
         (kind (first entry)))
    (setf (rogue-glyph-particle-kind particle) kind
          (rogue-glyph-particle-glyph particle) (second entry)
          (rogue-glyph-particle-x particle)
          (random-float 0.0 (float +virtual-width+))
          (rogue-glyph-particle-y particle)
          (if (eq kind :faller)
              (if initial-p
                  (random-float 0.0 (float +virtual-height+))
                  (random-float -60.0 -10.0))
              (random-float 0.0 (float +virtual-height+)))
          (rogue-glyph-particle-phase particle) (random-float 0.0 (* 2 pi))
          (rogue-glyph-particle-size particle) (get-random-value 14 19)
          (rogue-glyph-particle-alpha particle) (get-random-value 40 110)
          (rogue-glyph-particle-timer particle) (random-float 1.2 3.4))
    (ecase kind
      (:bird
       (setf (rogue-glyph-particle-vx particle) (random-float -22.0 22.0)
             (rogue-glyph-particle-vy particle) 0.0
             (rogue-glyph-particle-phase-speed particle) (random-float 2.0 3.6)
             (rogue-glyph-particle-amp particle) (random-float 14.0 26.0)))
      (:snake
       (setf (rogue-glyph-particle-vx particle) (random-float -14.0 14.0)
             (rogue-glyph-particle-vy particle) 0.0
             (rogue-glyph-particle-phase-speed particle) (random-float 3.4 5.2)
             (rogue-glyph-particle-amp particle) (random-float 22.0 38.0)))
      (:maze
       (setf (rogue-glyph-particle-vx particle)
             (* (if (zerop (get-random-value 0 1)) 1 -1) (random-float 14.0 22.0))
             (rogue-glyph-particle-vy particle) 0.0
             (rogue-glyph-particle-phase-speed particle) 0.0
             (rogue-glyph-particle-amp particle) 0.0))
      (:faller
       (setf (rogue-glyph-particle-vx particle) 0.0
             (rogue-glyph-particle-vy particle) (random-float 24.0 52.0)
             (rogue-glyph-particle-phase-speed particle) 0.0
             (rogue-glyph-particle-amp particle) 0.0))
      (:drift
       (setf (rogue-glyph-particle-vx particle) (random-float -10.0 10.0)
             (rogue-glyph-particle-vy particle) (random-float -8.0 8.0)
             (rogue-glyph-particle-phase-speed particle) (random-float 0.4 1.0)
             (rogue-glyph-particle-amp particle) (random-float 3.0 8.0)))))
  particle)

(defun rogue-glyph-maze-turn (particle)
  "Turn ninety degrees, the way a corridor does."
  (let ((speed (random-float 14.0 22.0)))
    (if (zerop (rogue-glyph-particle-vx particle))
        (setf (rogue-glyph-particle-vx particle)
              (* (if (zerop (get-random-value 0 1)) 1 -1) speed)
              (rogue-glyph-particle-vy particle) 0.0)
        (setf (rogue-glyph-particle-vy particle)
              (* (if (zerop (get-random-value 0 1)) 1 -1) speed)
              (rogue-glyph-particle-vx particle) 0.0))
    (setf (rogue-glyph-particle-timer particle) (random-float 1.2 3.0))))

(defun update-rogue-glyph-particle (particle dt)
  (incf (rogue-glyph-particle-phase particle)
        (* (rogue-glyph-particle-phase-speed particle) dt))
  (ecase (rogue-glyph-particle-kind particle)
    ((:bird :snake)
     (incf (rogue-glyph-particle-x particle)
           (* (rogue-glyph-particle-vx particle) dt))
     (incf (rogue-glyph-particle-y particle)
           (* (rogue-glyph-particle-amp particle)
              (sin (rogue-glyph-particle-phase particle))
              dt))
     (setf (rogue-glyph-particle-x particle)
           (rogue-glyph-wrap (rogue-glyph-particle-x particle) +virtual-width+)
           (rogue-glyph-particle-y particle)
           (rogue-glyph-wrap (rogue-glyph-particle-y particle) +virtual-height+)))
    (:maze
     (decf (rogue-glyph-particle-timer particle) dt)
     (when (<= (rogue-glyph-particle-timer particle) 0.0)
       (rogue-glyph-maze-turn particle))
     (incf (rogue-glyph-particle-x particle)
           (* (rogue-glyph-particle-vx particle) dt))
     (incf (rogue-glyph-particle-y particle)
           (* (rogue-glyph-particle-vy particle) dt))
     (setf (rogue-glyph-particle-x particle)
           (rogue-glyph-wrap (rogue-glyph-particle-x particle) +virtual-width+)
           (rogue-glyph-particle-y particle)
           (rogue-glyph-wrap (rogue-glyph-particle-y particle) +virtual-height+)))
    (:faller
     (incf (rogue-glyph-particle-y particle)
           (* (rogue-glyph-particle-vy particle) dt))
     (when (> (rogue-glyph-particle-y particle) (+ +virtual-height+ 16))
       (reset-rogue-glyph-particle particle)))
    (:drift
     (incf (rogue-glyph-particle-x particle)
           (* (+ (rogue-glyph-particle-vx particle)
                 (* (rogue-glyph-particle-amp particle)
                    (sin (rogue-glyph-particle-phase particle))))
              dt))
     (incf (rogue-glyph-particle-y particle)
           (* (rogue-glyph-particle-vy particle) dt))
     (setf (rogue-glyph-particle-x particle)
           (rogue-glyph-wrap (rogue-glyph-particle-x particle) +virtual-width+)
           (rogue-glyph-particle-y particle)
           (rogue-glyph-wrap (rogue-glyph-particle-y particle) +virtual-height+)))))

(defun draw-rogue-glyph-particle (particle alpha-scale)
  (let ((alpha (round (* (rogue-glyph-particle-alpha particle) alpha-scale))))
    (when (plusp alpha)
      (draw-centered-text (rogue-glyph-particle-glyph particle)
                          (rogue-glyph-particle-x particle)
                          (rogue-glyph-particle-y particle)
                          (rogue-glyph-particle-size particle)
                          (make-color 255 255 255 alpha)))))


;;; System

(defclass rogue-glyph-particle-system (particle-system) ())

(defmethod particle-system-count ((system rogue-glyph-particle-system))
  (max 0 (round *rogue-glyph-particle-count*)))

(defmethod particle-system-make ((system rogue-glyph-particle-system))
  (make-rogue-glyph-particle))

(defmethod particle-system-reset-particle ((system rogue-glyph-particle-system)
                                           particle
                                           &key initial-p)
  (reset-rogue-glyph-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system rogue-glyph-particle-system)
                                            particle
                                            dt)
  (update-rogue-glyph-particle particle dt))

(defmethod particle-system-draw-particle ((system rogue-glyph-particle-system)
                                          particle
                                          alpha-scale)
  (draw-rogue-glyph-particle particle alpha-scale))
