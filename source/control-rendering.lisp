(in-package #:immortal-coil)

(defun draw-choice-option (choice x y selected-p color)
  (let ((size 20)
        (label (choice-display-label choice)))
    (draw-text-at label x y size color)
    (when selected-p
      (claylib/ll:draw-rectangle (round x)
                                 (round (+ y size 3))
                                 (measure-text label size)
                                 4
                                 (claylib::c-ptr color)))))

(defun draw-choice-option-centered (choice center-x y selected-p color)
  (let* ((size 20)
         (width (measure-text (choice-display-label choice) size))
         (x (- center-x (/ width 2))))
    (draw-choice-option choice x y selected-p color)))

(defun draw-choice-prompt (node y color)
  (let* ((size 20)
         (text (visible-node-text node)))
    (multiple-value-bind (x text-y width)
        (draw-centered-text text
                            +virtual-center-x+
                            y
                            size
                            color)
      (draw-cursor x text-y width size color))))

(defun draw-horizontal-choice-node (node color)
  (let* ((choices (active-node-choices node))
         (count (length choices))
         (spacing 560.0)
         (start-x (- +virtual-center-x+
                     (* spacing (/ (max 0 (1- count)) 2.0)))))
    (draw-choice-prompt node (- +virtual-center-y+ 150) color)
    (when (plusp count)
      (loop for choice across choices
            for i from 0
            for center-x = (+ start-x (* i spacing))
            do (draw-choice-option-centered
                choice
                center-x
                (- +virtual-height+ 170)
                (= i (play-state-selected-index *state*))
                color)))))

(defun draw-vertical-choice-node (node color)
  (let* ((choices (active-node-choices node))
         (count (length choices))
         (spacing 44.0)
         (start-y (- (+ +virtual-center-y+ 98)
                     (* spacing (/ (max 0 (1- count)) 2.0)))))
    (draw-choice-prompt node (- +virtual-center-y+ 150) color)
    (when (plusp count)
      (loop for choice across choices
            for i from 0
            for y = (+ start-y (* i spacing))
            do (draw-choice-option-centered
                choice
                +virtual-center-x+
                y
                (= i (play-state-selected-index *state*))
                color)))))

(defun list-visible-range (choices &optional (selected (play-state-selected-index *state*)))
  (let* ((count (length choices))
         (visible-count (min 7 count))
         (start (min (max 0 (- selected (floor visible-count 2)))
                     (max 0 (- count visible-count)))))
    (values start (+ start visible-count))))

(defun draw-list-choice-node (node color)
  (let ((choices (active-node-choices node)))
    (multiple-value-bind (start end)
        (list-visible-range choices)
      (let ((x (- +virtual-center-x+ 260))
            (y (+ +virtual-center-y+ 18)))
        (draw-choice-prompt node (- +virtual-center-y+ 175) color)
        (loop for i from start below end
              for row from 0
              for choice = (aref choices i)
              do (draw-choice-option
                  choice
                  x
                  (+ y (* row 38))
                  (= i (play-state-selected-index *state*))
                  color))))))

(defun draw-choice-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (case (choice-layout node)
      (:vertical (draw-vertical-choice-node node color))
      (:list (draw-list-choice-node node color))
      (t (draw-horizontal-choice-node node color)))))

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
