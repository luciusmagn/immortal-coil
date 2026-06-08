(in-package #:immortal-coil)

;;; Updating

(defconstant +conversation-visible-width+ 500.0)
(defconstant +conversation-margin-x+ 92.0)
(defconstant +conversation-top-y+ 68.0)
(defconstant +conversation-bottom-y+ 86.0)
(defconstant +conversation-text-size+ 18)
(defconstant +conversation-speaker-size+ 13)
(defconstant +conversation-line-height+ 25.0)
(defconstant +conversation-speaker-gap+ 18.0)
(defconstant +conversation-entry-gap+ 18.0)

(-> conversation-entry-count (node) nonnegative-integer)
(defun conversation-entry-count (node)
  (length (node-conversation node)))

(-> conversation-current-index (node) nonnegative-integer)
(defun conversation-current-index (node)
  (let ((count (conversation-entry-count node)))
    (if (plusp count)
        (min (play-state-conversation-index *state*)
             (1- count))
        0)))

(-> conversation-current-entry (node) (option conversation-entry))
(defun conversation-current-entry (node)
  (when (plusp (conversation-entry-count node))
    (aref (node-conversation node)
          (conversation-current-index node))))

(-> conversation-current-text (node) string)
(defun conversation-current-text (node)
  (let ((entry (conversation-current-entry node)))
    (if entry
        (conversation-entry-display-text entry)
        "")))

(-> conversation-current-entry-visible-p (node) boolean)
(defun conversation-current-entry-visible-p (node)
  (>= (play-state-visible-count *state*)
      (length (conversation-current-text node))))

(-> advance-conversation-typewriter (node) t)
(defun advance-conversation-typewriter (node)
  (let* ((old-count (play-state-visible-count *state*))
         (text      (conversation-current-text node))
         (new-count (min (length text)
                         (floor (* (typewriter-elapsed)
                                   *characters-per-second*)))))
    (when (> new-count old-count)
      (setf (play-state-visible-count *state*) new-count)
      (play-type-click text old-count new-count))))

(-> skip-conversation-entry (node) nonnegative-integer)
(defun skip-conversation-entry (node)
  (setf (play-state-visible-count *state*)
        (length (conversation-current-text node))))

(-> start-next-conversation-entry () t)
(defun start-next-conversation-entry ()
  (incf (play-state-conversation-index *state*))
  (setf (play-state-elapsed *state*) 0.0
        (play-state-type-delay *state*) 0.0
        (play-state-visible-count *state*) 0)
  (play-choice-switch))

(-> finish-conversation-node (node) t)
(defun finish-conversation-node (node)
  (when (node-next node)
    (jump-to-node (node-next node))))

(-> update-conversation-node (node) t)
(defun update-conversation-node (node)
  (advance-conversation-typewriter node)
  (cond
    ((zerop (conversation-entry-count node))
     (when (confirm-pressed-p)
       (finish-conversation-node node)))
    ((not (conversation-current-entry-visible-p node))
     (when (confirm-pressed-p)
       (skip-conversation-entry node)))
    ((confirm-pressed-p)
     (if (< (conversation-current-index node)
            (1- (conversation-entry-count node)))
         (start-next-conversation-entry)
         (finish-conversation-node node)))))


;;; Rendering

(-> conversation-visible-entry-lines (conversation-entry boolean)
    (list-of string))
(defun conversation-visible-entry-lines (entry current-p)
  (let ((lines (wrap-text-lines (conversation-entry-display-text entry)
                                +conversation-text-size+
                                +conversation-visible-width+)))
    (if current-p
        (visible-text-lines lines (play-state-visible-count *state*))
        lines)))

(-> conversation-entry-speaker-height (string) scalar)
(defun conversation-entry-speaker-height (speaker)
  (if (plusp (length speaker))
      +conversation-speaker-gap+
      0.0))

(-> conversation-entry-height (string (list-of string)) scalar)
(defun conversation-entry-height (speaker lines)
  (+ (conversation-entry-speaker-height speaker)
     (* +conversation-line-height+ (max 1 (length lines)))
     +conversation-entry-gap+))

(-> conversation-left-x () scalar)
(defun conversation-left-x ()
  +conversation-margin-x+)

(-> conversation-right-x () scalar)
(defun conversation-right-x ()
  (- +virtual-width+ +conversation-margin-x+))

(-> conversation-line-x (conversation-side string nonnegative-integer) scalar)
(defun conversation-line-x (side text size)
  (case side
    (:right (- (conversation-right-x) (text-width text size)))
    (t (conversation-left-x))))

(-> draw-conversation-line
    (conversation-side string scalar nonnegative-integer t)
    (values scalar scalar nonnegative-integer))
(defun draw-conversation-line (side text y size color)
  (let* ((width (text-width text size))
         (x     (conversation-line-x side text size)))
    (draw-text-at text x y size color)
    (values x y width)))

(-> draw-conversation-entry
    (conversation-entry string (list-of string) scalar t)
    (values scalar scalar nonnegative-integer))
(defun draw-conversation-entry (entry speaker lines y color)
  (let ((side       (conversation-entry-side entry))
        (last-x     (conversation-left-x))
        (last-y     y)
        (last-width 0))
    (when (plusp (length speaker))
      (multiple-value-setq (last-x last-y last-width)
        (draw-conversation-line side
                                speaker
                                y
                                +conversation-speaker-size+
                                color))
      (incf y +conversation-speaker-gap+))
    (loop for line in (or lines (list ""))
          for row from 0
          for line-y = (+ y (* row +conversation-line-height+))
          do (multiple-value-setq (last-x last-y last-width)
               (draw-conversation-line side
                                       line
                                       line-y
                                       +conversation-text-size+
                                       color)))
    (values last-x last-y last-width)))

(-> conversation-entry-draw-data (node) list)
(defun conversation-entry-draw-data (node)
  (let ((current-index (conversation-current-index node)))
    (loop for entry across (node-conversation node)
          for index from 0 upto current-index
          for current-p = (= index current-index)
          for speaker = (conversation-entry-display-speaker entry)
          for lines = (conversation-visible-entry-lines entry current-p)
          collect (list :entry entry
                        :speaker speaker
                        :lines lines
                        :current-p current-p
                        :height (conversation-entry-height speaker lines)))))

(-> conversation-total-height (list) scalar)
(defun conversation-total-height (entries)
  (loop for entry in entries
        sum (getf entry :height)))

(-> conversation-start-y (scalar) scalar)
(defun conversation-start-y (height)
  (let ((available (- +virtual-height+
                      +conversation-top-y+
                      +conversation-bottom-y+)))
    (- +conversation-top-y+
       (max 0.0 (- height available)))))

(-> draw-conversation-node (node) t)
(defun draw-conversation-node (node)
  (let* ((color (make-color 255 255 255 (current-alpha)))
         (entries (conversation-entry-draw-data node))
         (y (conversation-start-y (conversation-total-height entries))))
    (dolist (data entries)
      (let ((entry (getf data :entry)))
        (multiple-value-bind (x last-y width)
            (draw-conversation-entry entry
                                     (getf data :speaker)
                                     (getf data :lines)
                                     y
                                     color)
          (when (getf data :current-p)
            (draw-cursor x
                         last-y
                         width
                         +conversation-text-size+
                         color))))
      (incf y (getf data :height)))))
