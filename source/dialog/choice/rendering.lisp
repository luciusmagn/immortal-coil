(in-package #:immortal-coil)

(defconstant +choice-visible-count+ 7)

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

(defun draw-choice-prompt (node y color &key (cursor-p t))
  (let* ((size 20)
         (text (visible-node-text node)))
    (multiple-value-bind (x text-y width)
        (draw-centered-text text
                            +virtual-center-x+
                            y
                            size
                            color)
      (when cursor-p
        (draw-cursor x text-y width size color)))))

(defun choice-visible-range (choices
                             &optional (selected (play-state-selected-index *state*))
                                       (visible-limit +choice-visible-count+))
  (let* ((count (length choices))
         (visible-count (min visible-limit count))
         (start (min (max 0 (- selected (floor visible-count 2)))
                     (max 0 (- count visible-count)))))
    (values start (+ start visible-count) visible-count)))

(defun draw-choice-scrollbar (count start visible-count x y row-height color)
  (when (> count visible-count)
    (let* ((track-height (* row-height visible-count))
           (thumb-height (max 22.0
                              (* track-height (/ visible-count count))))
           (scrollable (- count visible-count))
           (progress (if (plusp scrollable)
                         (/ start scrollable)
                         0.0))
           (thumb-y (+ y (* (- track-height thumb-height) progress)))
           (track-color (make-color 255 255 255 60)))
      (claylib/ll:draw-rectangle (round x)
                                 (round y)
                                 3
                                 (round track-height)
                                 (claylib::c-ptr track-color))
      (claylib/ll:draw-rectangle (round (- x 2))
                                 (round thumb-y)
                                 7
                                 (round thumb-height)
                                 (claylib::c-ptr color)))))

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
         (spacing 44.0))
    (draw-choice-prompt node (- +virtual-center-y+ 150) color)
    (when (plusp count)
      (multiple-value-bind (start end visible-count)
          (choice-visible-range choices)
        (let ((start-y (- (+ +virtual-center-y+ 98)
                          (* spacing (/ (max 0 (1- visible-count)) 2.0)))))
          (loop for i from start below end
                for row from 0
                for choice = (aref choices i)
                for y = (+ start-y (* row spacing))
                do (draw-choice-option-centered
                    choice
                    +virtual-center-x+
                    y
                    (= i (play-state-selected-index *state*))
                    color))
          (draw-choice-scrollbar count
                                 start
                                 visible-count
                                 (+ +virtual-center-x+ 310)
                                 start-y
                                 spacing
                                 color))))))

(defun draw-list-choice-node (node color)
  (let ((choices (active-node-choices node)))
    (multiple-value-bind (start end visible-count)
        (choice-visible-range choices)
      (let ((x (- +virtual-center-x+ 260))
            (y (+ +virtual-center-y+ 18))
            (spacing 38.0))
        (draw-choice-prompt node (- +virtual-center-y+ 175) color)
        (loop for i from start below end
              for row from 0
              for choice = (aref choices i)
              do (draw-choice-option
                  choice
                  x
                  (+ y (* row spacing))
                  (= i (play-state-selected-index *state*))
                  color))
        (draw-choice-scrollbar (length choices)
                               start
                               visible-count
                               (+ x 540)
                               y
                               spacing
                               color)))))

(defun draw-choice-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (case (choice-layout node)
      (:vertical (draw-vertical-choice-node node color))
      (:list (draw-list-choice-node node color))
      (t (draw-horizontal-choice-node node color)))))
