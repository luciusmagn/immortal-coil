(in-package #:immortal-coil)

;;; Rendering

(-> draw-editor-right-text (string scalar nonnegative-integer t) t)
(defun draw-editor-right-text (text y size color)
  (let ((width (text-width text size)))
    (draw-text-at text
                  (- +virtual-width+ 28 width)
                  y
                  size
                  color)))

(-> draw-editor-text-edit-panel (t) t)
(defun draw-editor-text-edit-panel (color)
  (let* ((left 88)
         (top 492)
         (width (- +virtual-width+ 176))
         (height 118)
         (size 15)
         (lines (or (wrap-text-lines *editor-text-buffer*
                                     size
                                     (- width 28))
                    (list "")))
         (visible-lines (last lines (min 4 (length lines)))))
    (claylib/ll:draw-rectangle left
                               top
                               width
                               height
                               (claylib::c-ptr
                                (make-color 0 0 0 226)))
    (claylib/ll:draw-rectangle-lines left
                                      top
                                      width
                                      height
                                      (claylib::c-ptr color))
    (draw-text-at "EDIT TEXT"
                  (+ left 14)
                  (+ top 12)
                  13
                  color)
    (loop for line in visible-lines
          for index from 0
          do (draw-text-at line
                           (+ left 14)
                           (+ top 34 (* index 18))
                           size
                           color))
    (let* ((last-line (car (last visible-lines)))
           (cursor-y (+ top 34 (* (max 0 (1- (length visible-lines))) 18)))
           (cursor-x (+ left 14 (text-width last-line size))))
      (draw-cursor (+ left 14)
                   cursor-y
                   (- cursor-x (+ left 14))
                   size
                   color))
    (draw-editor-right-text "ENTER SAVE  ESC CANCEL"
                            (+ top height 12)
                            12
                            color)))

(-> draw-editor-overlay () t)
(defun draw-editor-overlay ()
  (when (and *editor-active-p* *state*)
    (let* ((node (current-node))
           (color (make-color 255 255 255 178))
           (dim-color (make-color 255 255 255 118))
           (next-label (editor-next-label node)))
      (draw-text-at "EDITOR"
                    28
                    22
                    14
                    color)
      (draw-text-at (format nil "~a" (node-id node))
                    28
                    42
                    12
                    dim-color)
      (when next-label
        (draw-editor-right-text (format nil "NEXT ~a" next-label)
                                22
                                12
                                dim-color))
      (draw-text-at (format nil "PGUP BACK  INS TEXT  ~d"
                            (length *editor-history*))
                    28
                    (- +virtual-height+ 34)
                    12
                    dim-color)
      (when *editor-status-message*
        (draw-editor-right-text *editor-status-message*
                                (- +virtual-height+ 34)
                                12
                                dim-color))
      (when (eq *editor-mode* :edit-text)
        (draw-editor-text-edit-panel color)))))
