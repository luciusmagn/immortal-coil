(in-package #:immortal-coil)

;;; Updating

(defun choice-layout (node)
  (or (node-layout node) :horizontal))

(defparameter *compass-direction-order*
  '(:north :west :east :south))

(defun choice-selectable-index-p (choices index)
  (and (<= 0 index)
       (< index (length choices))))

(defun reset-choice-preview-typewriter
    (&optional (index (play-state-selected-index *state*)))
  (setf (play-state-choice-preview-index *state*) index
        (play-state-choice-preview-elapsed *state*) 0.0
        (play-state-choice-preview-visible-count *state*) 0))

(defun ensure-choice-preview-index-current ()
  (unless (= (play-state-choice-preview-index *state*)
             (play-state-selected-index *state*))
    (reset-choice-preview-typewriter)))

(defun set-choice-selected-index (index)
  (unless (= index (play-state-selected-index *state*))
    (setf (play-state-selected-index *state*) index)
    (reset-choice-preview-typewriter index)
    (play-choice-switch)))

(defun first-selectable-choice-index (choices)
  (loop for choice across choices
        for index from 0
        when choice
          return index))

(defun normalize-choice-selection (choices)
  (let ((count (length choices))
        (old-index (play-state-selected-index *state*)))
    (cond
      ((zerop count)
       (setf (play-state-selected-index *state*) 0)
       (unless (= old-index 0)
         (reset-choice-preview-typewriter 0)))
      (t
       (when (>= (play-state-selected-index *state*) count)
         (setf (play-state-selected-index *state*) (1- count)))
       (let ((fallback (first-selectable-choice-index choices)))
         (when (and fallback
                    (not (choice-selectable-index-p
                          choices
                          (play-state-selected-index *state*))))
           (setf (play-state-selected-index *state*) fallback)))))
    (unless (= old-index (play-state-selected-index *state*))
      (reset-choice-preview-typewriter))))

(defun next-selectable-choice-index (choices selected direction)
  (loop with count = (length choices)
        for step from 1 to count
        for index = (mod (+ selected (* step direction)) count)
        when (aref choices index)
          return index))

(defun horizontal-selection-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)))

(defun vertical-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-s+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-w+)
         (is-key-pressed-p +key-left+))
     -1)))

(defun compass-requested-direction ()
  (cond
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-w+))
     :north)
    ((or (is-key-pressed-p +key-left+)
         (is-key-pressed-p +key-a+))
     :west)
    ((or (is-key-pressed-p +key-right+)
         (is-key-pressed-p +key-d+))
     :east)
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-s+))
     :south)))

(defun choice-compass-direction (choices index)
  (or (choice-direction (aref choices index))
      (nth index *compass-direction-order*)))

(defun compass-choice-index (choices direction)
  (loop for choice across choices
        for index from 0
        when (and choice
                  (eq (choice-compass-direction choices index) direction))
          return index))

(defun move-compass-selection (node)
  (let* ((choices (active-node-choices node))
         (direction (compass-requested-direction)))
    (normalize-choice-selection choices)
    (when direction
      (let ((index (compass-choice-index choices direction)))
        (when index
          (set-choice-selected-index index))))))

(defun selection-direction (node)
  (case (choice-layout node)
    (:horizontal (horizontal-selection-direction))
    (:compass nil)
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
          (set-choice-selected-index next-index))))))

(defun selected-active-choice (node)
  (let ((choices (active-node-choices node)))
    (normalize-choice-selection choices)
    (when (plusp (length choices))
      (aref choices (play-state-selected-index *state*)))))

(defun choice-preview-visible-p (choice)
  (>= (play-state-choice-preview-visible-count *state*)
      (length (choice-display-preview choice))))

(defun skip-choice-preview (choice)
  (setf (play-state-choice-preview-visible-count *state*)
        (length (choice-display-preview choice))))

(defun advance-choice-preview-typewriter (choice dt)
  (ensure-choice-preview-index-current)
  (incf (play-state-choice-preview-elapsed *state*) dt)
  (let* ((old-count (play-state-choice-preview-visible-count *state*))
         (text (choice-display-preview choice))
         (new-count (min (length text)
                         (floor (* (play-state-choice-preview-elapsed *state*)
                                   *characters-per-second*)))))
    (when (> new-count old-count)
      (setf (play-state-choice-preview-visible-count *state*) new-count)
      (play-type-click text old-count new-count))))

(defun update-choice-node (node)
  (if (eq (choice-layout node) :compass)
      (move-compass-selection node)
      (move-selection node (selection-direction node)))
  (cond
    ((not (story-text-visible-p node))
     (when (confirm-pressed-p)
       (skip-typewriter node)))
    (t
     (journal-record-node-visible node)
     (when (confirm-pressed-p)
       (let ((choice (selected-active-choice node)))
         (cond
           ((and (eq (choice-layout node) :compass)
                 choice
                 (not (choice-preview-visible-p choice)))
            (skip-choice-preview choice))
           ((and choice (choice-enabled-p choice))
            (journal-record-choice-selection node choice)
            (jump-to-dialog-target (choice-target choice)))
           (choice
            (play-choice-switch))))))))

;;; Rendering

(defconstant +choice-visible-count+ 7)

(defun editor-hidden-choice-p (choice)
  (and (fboundp 'editor-choice-reveal-active-p)
       (funcall (symbol-function 'editor-choice-reveal-active-p))
       (not (choice-visible-p choice))))

(defun choice-option-color (choice color)
  (cond
    ((editor-hidden-choice-p choice)
     (make-color 255
                 255
                 255
                 (round (* (a color) 0.28))))
    ((choice-enabled-p choice)
     color)
    (t
     (make-color 255
                 255
                 255
                 (round (* (a color) 0.36))))))

(defun choice-render-label (choice)
  (if (editor-hidden-choice-p choice)
      (format nil "~a [hidden]" (choice-display-label choice))
      (choice-display-label choice)))

(defun draw-locked-choice-strike (x y width size color)
  (draw-thick-line-between x
                           (+ y (/ size 2.0))
                           (+ x width)
                           (+ y (/ size 2.0))
                           color
                           1.0))

(defun draw-choice-option (choice x y selected-p color)
  (let* ((size 20)
         (label (choice-render-label choice))
         (width (text-width label size))
         (enabled-p (choice-enabled-p choice))
         (option-color (choice-option-color choice color)))
    (if selected-p
        ;; invert: a filled bar behind the label. as the node fades in, the bar
        ;; rises from the black background toward white while the label crosses
        ;; the other way, white toward black, so the two fade in together
        (let* ((pad-x 8.0)
               (pad-y 3.0)
               (alpha (a option-color))
               (fade (/ alpha 255.0))
               (ink (round (- 255 (* 239.0 fade)))) ; white at 0, near-black at full
               (text-color (make-color ink ink ink alpha)))
          (claylib/ll:draw-rectangle (round (- x pad-x))
                                     (round (- y pad-y))
                                     (round (+ width (* 2.0 pad-x)))
                                     (round (+ size (* 2.0 pad-y)))
                                     (claylib::c-ptr option-color))
          (draw-text-at label x y size text-color)
          (unless enabled-p
            (draw-locked-choice-strike x y width size text-color)))
        (progn
          (draw-text-at label x y size option-color)
          (unless enabled-p
            (draw-locked-choice-strike x y width size option-color))))))

(defun draw-choice-option-centered (choice center-x y selected-p color)
  (let* ((size 20)
         (width (text-width (choice-render-label choice) size))
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

(defun visible-choice-preview-lines (choice size max-width)
  (visible-text-lines (wrap-text-lines (choice-display-preview choice)
                                       size
                                       max-width)
                      (play-state-choice-preview-visible-count *state*)))

(defun draw-compass-choice-preview (choice y color)
  (let* ((size 19)
         (lines (visible-choice-preview-lines choice
                                              size
                                              *dialog-text-max-width*)))
    (multiple-value-bind (x text-y width)
        (draw-centered-text-lines lines
                                  +virtual-center-x+
                                  y
                                  size
                                  color)
      (unless (choice-preview-visible-p choice)
        (draw-cursor x text-y width size color)))))

(defun compass-choice-position (direction center-x center-y)
  (ecase direction
    (:north (values center-x (- center-y 82.0)))
    (:west (values (- center-x 156.0) center-y))
    (:east (values (+ center-x 156.0) center-y))
    (:south (values center-x (+ center-y 82.0)))))

(defun draw-compass-choice-option (choices index center-x center-y color)
  (let* ((choice (aref choices index))
         (direction (choice-compass-direction choices index)))
    (when direction
      (multiple-value-bind (x y)
          (compass-choice-position direction center-x center-y)
        (draw-choice-option-centered choice
                                     x
                                     y
                                     (= index
                                        (play-state-selected-index *state*))
                                     color)))))

(defun draw-compass-choice-node (node color)
  (let* ((choices (active-node-choices node))
         (choice (selected-active-choice node))
         (dial-y (+ +virtual-center-y+ 124.0)))
    (draw-choice-prompt node (- +virtual-center-y+ 198.0) color)
    (when (and choice
               (story-text-visible-p node))
      (draw-compass-choice-preview choice (- +virtual-center-y+ 64.0) color))
    (loop for index from 0 below (length choices)
          do (draw-compass-choice-option choices
                                         index
                                         +virtual-center-x+
                                         dial-y
                                         color))))

(defun draw-choice-node (node)
  (let ((color (make-color 255 255 255 (current-alpha))))
    (case (choice-layout node)
      (:vertical (draw-vertical-choice-node node color))
      (:list (draw-list-choice-node node color))
      (:compass (draw-compass-choice-node node color))
      (t (draw-horizontal-choice-node node color)))))


;;; Node behavior

(defmethod node-update ((node choice-node) dt)
  (advance-typewriter node)
  (when (and (story-text-visible-p node)
             (eq (choice-layout node) :compass))
    (let ((choice (selected-active-choice node)))
      (when choice
        (advance-choice-preview-typewriter choice dt))))
  (update-choice-node node))

(defmethod node-draw ((node choice-node))
  (draw-choice-node node))
