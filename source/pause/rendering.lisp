(in-package #:immortal-coil)

(-> draw-pause-option (integer scalar t) t)
(defun draw-pause-option (index y color)
  (let ((label (command-option-label (pause-option index)))
        (size 22)
        (selected-p (= index (selection-current-index *pause-selection*))))
    (multiple-value-bind (x text-y width)
        (draw-centered-text label
                            +virtual-center-x+
                            y
                            size
                            color)
      (when selected-p
        (claylib/ll:draw-rectangle (round x)
                                   (round (+ text-y size 5))
                                   (round width)
                                   4
                                   (claylib::c-ptr color))))))

(-> draw-pause-options (t) t)
(defun draw-pause-options (color)
  (let ((start-y (- +virtual-center-y+ 8))
        (spacing 48.0))
    (loop for i below (pause-option-count)
          do (draw-pause-option i
                                (+ start-y (* i spacing))
                                color))))

(-> draw-pause-menu () t)
(defun draw-pause-menu ()
  (let ((color (make-color 255 255 255 240)))
    (claylib/ll:draw-rectangle 0
                               0
                               +virtual-width+
                               +virtual-height+
                               (claylib::c-ptr
                                (make-color 0 0 0 176)))
    (draw-centered-text "PAUSED"
                        +virtual-center-x+
                        (- +virtual-center-y+ 108)
                        28
                        color)
    (draw-pause-options color)))
