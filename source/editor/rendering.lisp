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

(-> editor-truncate-text (string nonnegative-integer) string)
(defun editor-truncate-text (text max-length)
  (if (<= (length text) max-length)
      text
      (concatenate 'string
                   (subseq text 0 (max 0 (- max-length 3)))
                   "...")))

(-> editor-value-label (t) string)
(defun editor-value-label (value)
  (handler-case
      (write-to-string value
                       :escape t
                       :circle t
                       :level 3
                       :length 5)
    (error (condition)
      (format nil "#<unprintable ~a>" condition))))

(-> editor-store-entry-label (cons) string)
(defun editor-store-entry-label (entry)
  (editor-truncate-text
   (format nil "~a = ~a"
           (first entry)
           (editor-value-label (rest entry)))
   58))

(-> draw-editor-store-overlay (t) t)
(defun draw-editor-store-overlay (color)
  (let* ((left 88)
         (top 92)
         (width 470)
         (height 270)
         (entries (dialog-store-snapshot))
         (visible (subseq entries 0 (min 10 (length entries)))))
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
    (draw-text-at "STATE"
                  (+ left 14)
                  (+ top 12)
                  13
                  color)
    (if visible
        (loop for entry in visible
              for index from 0
              do (draw-text-at (editor-store-entry-label entry)
                               (+ left 14)
                               (+ top 38 (* index 21))
                               15
                               color))
        (draw-text-at "empty"
                      (+ left 14)
                      (+ top 38)
                      15
                      color))
    (when (> (length entries) (length visible))
      (draw-text-at (format nil "+ ~d more"
                            (- (length entries) (length visible)))
                    (+ left 14)
                    (- (+ top height) 28)
                    13
                    color))))

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
      (draw-text-at (format nil "PGUP BACK  INS TEXT  F2 TEXT  F3 STATE  ~d"
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
      (when *editor-store-overlay-p*
        (draw-editor-store-overlay color))
      (when (eq *editor-mode* :edit-text)
        (draw-editor-text-edit-panel color)))))
