(in-package #:immortal-coil)

(-> flight-target-gate-index (flight-minigame) flight-gate-index)
(defun flight-target-gate-index (game)
  (max 1 (ceiling (+ (flight-minigame-distance game) 0.25))))

(-> draw-flight-gate-highlight (scalar scalar scalar scalar) t)
(defun draw-flight-gate-highlight (gate-x gate-y half-size z)
  (draw-flight-rectangle (- gate-x half-size)
                         (- gate-y half-size)
                         (+ gate-x half-size)
                         (+ gate-y half-size)
                         z
                         (make-color 255 255 255 54)
                         7.0))

(-> draw-flight-gate-frame (scalar scalar scalar scalar t t boolean) t)
(defun draw-flight-gate-frame (gate-x gate-y half-size z outer-color
                               opening-color active-p)
  (draw-flight-rectangle -1.0
                         -1.0
                         1.0
                         1.0
                         z
                         outer-color
                         (if active-p 2.0 1.0))
  (draw-flight-rectangle (- gate-x half-size)
                         (- gate-y half-size)
                         (+ gate-x half-size)
                         (+ gate-y half-size)
                         z
                         opening-color
                         (if active-p 3.0 1.4)))

(-> draw-flight-gate (flight-minigame flight-gate-index boolean) t)
(defun draw-flight-gate (game gate-index active-p)
  (let ((z (- gate-index (flight-minigame-distance game))))
    (when (and (> z 0.25)
               (< z +flight-visible-depth+))
      (multiple-value-bind (gate-x gate-y)
          (flight-gate-center gate-index)
        (let* ((half-size (flight-opening-half-size gate-index))
               (outer-alpha (if active-p
                                90
                                (flight-depth-alpha z 24 78)))
               (opening-alpha (if active-p
                                  246
                                  (flight-depth-alpha z 74 150)))
               (outer-color (make-color 255 255 255 outer-alpha))
               (opening-color (make-color 255 255 255 opening-alpha)))
          (when active-p
            (draw-flight-gate-highlight gate-x gate-y half-size z))
          (draw-flight-gate-frame gate-x
                                  gate-y
                                  half-size
                                  z
                                  outer-color
                                  opening-color
                                  active-p))))))

(-> draw-flight-gates (flight-minigame) t)
(defun draw-flight-gates (game)
  (let ((first-gate (max 1 (floor (flight-minigame-distance game))))
        (target-gate (flight-target-gate-index game)))
    (loop for gate from first-gate below (+ first-gate 9)
          unless (= gate target-gate)
            do (draw-flight-gate game gate nil))
    (draw-flight-gate game target-gate t)))
