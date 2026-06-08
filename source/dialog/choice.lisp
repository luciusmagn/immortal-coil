(in-package #:immortal-coil)

;;; Updating

(defun choice-layout (node)
  (or (node-layout node) :horizontal))

(defun choice-selectable-index-p (choices index)
  (and (<= 0 index)
       (< index (length choices))
       (choice-enabled-p (aref choices index))))

(defun first-selectable-choice-index (choices)
  (loop for choice across choices
        for index from 0
        when (choice-enabled-p choice)
          return index))

(defun normalize-choice-selection (choices)
  (let ((count (length choices)))
    (cond
      ((zerop count)
       (setf (play-state-selected-index *state*) 0))
      (t
       (when (>= (play-state-selected-index *state*) count)
         (setf (play-state-selected-index *state*) (1- count)))
       (let ((fallback (first-selectable-choice-index choices)))
         (when (and fallback
                    (not (choice-selectable-index-p
                          choices
                          (play-state-selected-index *state*))))
           (setf (play-state-selected-index *state*) fallback)))))))

(defun next-selectable-choice-index (choices selected direction)
  (loop with count = (length choices)
        for step from 1 to count
        for index = (mod (+ selected (* step direction)) count)
        when (choice-enabled-p (aref choices index))
          return index))

(defun horizontal-selection-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)))

(defun vertical-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(defun selection-direction (node)
  (case (choice-layout node)
    (:horizontal (horizontal-selection-direction))
    (t (vertical-selection-direction))))

(defun move-selection (node direction)
  (let ((choices (active-node-choices node)))
    (normalize-choice-selection choices)
    (when (and direction (> (length choices) 1))
      (let ((next-index (next-selectable-choice-index
                         choices
                         (play-state-selected-index *state*)
                         direction)))
        (when (and next-index
                   (/= next-index (play-state-selected-index *state*)))
          (setf (play-state-selected-index *state*) next-index)
          (play-choice-switch))))))

(defun selected-active-choice (node)
  (let ((choices (active-node-choices node)))
    (normalize-choice-selection choices)
    (when (plusp (length choices))
      (aref choices (play-state-selected-index *state*)))))

(defun update-choice-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (move-selection node (selection-direction node))
     (when (confirm-pressed-p)
       (let ((choice (selected-active-choice node)))
         (cond
           ((and choice (choice-enabled-p choice))
            (jump-to-node (choice-target choice)))
           (choice
            (play-choice-switch))))))))

(defun matching-branch-target (node)
  (loop for branch across (node-branches node)
        when (dialog-condition-true-p (branch-condition branch))
          return (branch-target branch)))

(defun update-branch-node (node)
  (let ((target (matching-branch-target node)))
    (unless target
      (runtime-warn "Branch node has no matching case: ~a" (node-id node))
      (setf target *runtime-fallback-node-id*))
    (jump-to-node target)))


;;; Rendering

(defconstant +choice-visible-count+ 7)

(defun choice-option-color (choice color)
  (if (choice-enabled-p choice)
      color
      (make-color 255
                  255
                  255
                  (round (* (a color) 0.36)))))

(defun draw-locked-choice-strike (x y width size color)
  (draw-thick-line-between x
                           (+ y (/ size 2.0))
                           (+ x width)
                           (+ y (/ size 2.0))
                           color
                           1.0))

(defun draw-choice-option (choice x y selected-p color)
  (let* ((size 20)
         (label (choice-display-label choice))
         (width (measure-text label size))
         (enabled-p (choice-enabled-p choice))
         (option-color (choice-option-color choice color)))
    (draw-text-at label x y size option-color)
    (unless enabled-p
      (draw-locked-choice-strike x y width size option-color))
    (when (and selected-p enabled-p)
      (claylib/ll:draw-rectangle (round x)
                                 (round (+ y size 3))
                                 width
                                 4
                                 (claylib::c-ptr color)))))

(defun draw-choice-option-centered (choice center-x y selected-p color)
  (let* ((size 20)
         (width (measure-text (choice-display-label choice) size))
         (x (- center-x (/ width 2))))
    (draw-choice-option choice x y selected-p color)))

(defun draw-choice-prompt (node y color &key (cursor-p t))
  (let* ((size 20)
         (lines (visible-node-text-lines node size *dialog-text-max-width*)))
    (multiple-value-bind (x text-y width)
        (draw-centered-text-lines lines
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
