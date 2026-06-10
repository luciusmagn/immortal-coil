(in-package #:immortal-coil)

;;; List panel
;;;
;;; The house overlay component: a solid black rectangle with a white
;;; edge, a title, a vertical list with a cursor, and a footer hint.
;;; Items are (value . label) conses; the value is whatever the caller
;;; needs back. Menus, pickers, and editor overlays can share this.

(defclass list-panel ()
  ((title
    :initarg :title
    :initform ""
    :accessor list-panel-title
    :type string)
   (items
    :initarg :items
    :initform nil
    :accessor list-panel-items
    :type list)
   (empty-text
    :initarg :empty-text
    :initform "nothing here"
    :accessor list-panel-empty-text
    :type string)
   (footer
    :initarg :footer
    :initform "UP/DOWN SELECT  RET CONFIRM  ESC BACK"
    :accessor list-panel-footer
    :type string)
   (width
    :initarg :width
    :initform 560
    :accessor list-panel-width
    :type nonnegative-integer)
   (visible-rows
    :initarg :visible-rows
    :initform 9
    :accessor list-panel-visible-rows
    :type nonnegative-integer)
   (selected-index
    :initform 0
    :accessor list-panel-selected-index
    :type nonnegative-integer)))

(-> list-panel-count (list-panel) nonnegative-integer)
(defun list-panel-count (panel)
  (length (list-panel-items panel)))

(-> list-panel-move (list-panel integer) boolean)
(defun list-panel-move (panel direction)
  (let ((count (list-panel-count panel)))
    (when (plusp count)
      (setf (list-panel-selected-index panel)
            (mod (+ (list-panel-selected-index panel) direction) count))
      t)))

(-> list-panel-selected-value (list-panel) t)
(defun list-panel-selected-value (panel)
  (let ((item (nth (list-panel-selected-index panel)
                   (list-panel-items panel))))
    (when item
      (first item))))

(-> list-panel-set-items (list-panel list) list-panel)
(defun list-panel-set-items (panel items)
  (setf (list-panel-items panel) items
        (list-panel-selected-index panel) 0)
  panel)

(-> list-panel-visible-start (list-panel) nonnegative-integer)
(defun list-panel-visible-start (panel)
  (let* ((count (list-panel-count panel))
         (visible (list-panel-visible-rows panel))
         (max-start (max 0 (- count visible))))
    (min max-start
         (max 0 (- (list-panel-selected-index panel)
                   (floor visible 2))))))

(-> list-panel-height (list-panel) nonnegative-integer)
(defun list-panel-height (panel)
  (+ 118 (* 30 (min (max 1 (list-panel-count panel))
                    (list-panel-visible-rows panel)))))

(defgeneric draw-list-panel (panel top color)
  (:documentation "Draw PANEL with its top edge at TOP."))

(defmethod draw-list-panel ((panel list-panel) top color)
  (let* ((width (list-panel-width panel))
         (height (list-panel-height panel))
         (left (- +virtual-center-x+ (/ width 2.0)))
         (items (list-panel-items panel))
         (count (length items))
         (visible (list-panel-visible-rows panel))
         (start (list-panel-visible-start panel)))
    (claylib/ll:draw-rectangle (round left)
                               (round top)
                               width
                               height
                               (claylib::c-ptr (make-color 0 0 0 244)))
    (draw-rectangle-outline left top width height color :thickness 2)
    (draw-text-at (list-panel-title panel)
                  (round (+ left 24))
                  (round (+ top 18))
                  14
                  color)
    (if (zerop count)
        (draw-text-at (list-panel-empty-text panel)
                      (round (+ left 48))
                      (round (+ top 56))
                      15
                      (make-color 255 255 255 140))
        (loop for index from start
                below (min count (+ start visible))
              for row from 0
              for item = (nth index items)
              for selected-p = (= index (list-panel-selected-index panel))
              for row-color = (if selected-p
                                  color
                                  (make-color 255 255 255 132))
              for y = (round (+ top 52 (* row 30)))
              do (when selected-p
                   (draw-text-at ">" (round (+ left 26)) y 15 color))
                 (draw-text-at (rest item)
                               (round (+ left 48))
                               y
                               15
                               row-color)))
    (when (> count visible)
      (draw-text-at (format nil "+ ~d more" (- count visible))
                    (round (+ left 24))
                    (round (- (+ top height) 46))
                    12
                    (make-color 255 255 255 120)))
    (draw-centered-text (list-panel-footer panel)
                        +virtual-center-x+
                        (round (- (+ top height) 24))
                        12
                        (make-color 255 255 255 150))))
