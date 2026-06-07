(in-package #:immortal-coil)

(defun draw-input-field (color &key (field-width 220))
  (let* ((size 20)
         (buffer (play-state-input-buffer *state*))
         (field-x (- +virtual-center-x+ (/ field-width 2)))
         (field-y (+ +virtual-center-y+ 88)))
    (multiple-value-bind (x y width)
        (draw-centered-text buffer
                            +virtual-center-x+
                            field-y
                            size
                            color)
      (claylib/ll:draw-rectangle (round field-x)
                                 (+ (round field-y) size 8)
                                 (round field-width)
                                 4
                                 (claylib::c-ptr color))
      (draw-cursor x y width size color))))

(defun draw-number-input-field (color)
  (draw-input-field color :field-width 220))

(defun draw-string-input-field (color)
  (draw-input-field color :field-width 460))

(defun draw-number-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node (- +virtual-center-y+ 80) color)
    (when (story-text-visible-p node)
      (draw-number-input-field color))))

(defun draw-string-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (draw-choice-prompt node (- +virtual-center-y+ 80) color)
    (when (story-text-visible-p node)
      (draw-string-input-field color))))
