(in-package #:immortal-coil)

;;; Rendering

(defconstant +editor-corner-margin-x+ 172)
(defconstant +editor-corner-margin-y+ 124)
(defconstant +editor-corner-heading-size+ 16)
(defconstant +editor-corner-body-size+ 14)
(defconstant +editor-corner-line-gap+ 25)

(-> draw-editor-right-text (string scalar nonnegative-integer t) t)
(defun draw-editor-right-text (text y size color)
  (let ((width (text-width text size)))
    (draw-text-at text
                  (- +virtual-width+ +editor-corner-margin-x+ width)
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

(-> editor-store-visible-start (list nonnegative-integer) nonnegative-integer)
(defun editor-store-visible-start (entries visible-count)
  (let* ((count (length entries))
         (max-start (max 0 (- count visible-count))))
    (min max-start
         (max 0 *editor-store-selected-index*))))

(-> editor-visible-store-entries (list nonnegative-integer)
    (values list nonnegative-integer))
(defun editor-visible-store-entries (entries visible-count)
  (let ((start (editor-store-visible-start entries visible-count)))
    (values (subseq entries start (min (length entries)
                                       (+ start visible-count)))
            start)))

(-> draw-editor-store-entry (cons nonnegative-integer nonnegative-integer t) t)
(defun draw-editor-store-entry (entry index visible-index color)
  (let* ((selected-p (= index *editor-store-selected-index*))
         (x 102)
         (y (+ 130 (* visible-index 21)))
         (entry-color (if selected-p
                          color
                          (make-color 255 255 255 132))))
    (when selected-p
      (draw-text-at ">"
                    100
                    y
                    15
                    color))
    (draw-text-at (editor-store-entry-label entry)
                  x
                  y
                  15
                  entry-color)))

(-> draw-editor-store-overlay (t) t)
(defun draw-editor-store-overlay (color)
  (let* ((left 88)
         (top 92)
         (width 470)
         (height 270)
         (entries (dialog-store-snapshot))
         (visible-count 10))
    (claylib/ll:draw-rectangle left
                               top
                               width
                               height
                               (claylib::c-ptr
                                (make-color 0 0 0 226)))
    (draw-rectangle-outline left top width height color)
    (draw-text-at "STATE"
                  (+ left 14)
                  (+ top 12)
                  13
                  color)
    (if entries
        (multiple-value-bind (visible start)
            (editor-visible-store-entries entries visible-count)
          (loop for entry in visible
                for visible-index from 0
                for index from start
                do (draw-editor-store-entry entry
                                            index
                                            visible-index
                                            color)))
        (draw-text-at "empty"
                      (+ left 14)
                      (+ top 38)
                      15
                      color))
    (draw-text-at "C-e EDIT  C-n NEW  C-d REMOVE"
                  (+ left 14)
                  (- (+ top height) 28)
                  13
                  color)
    (when (> (length entries) visible-count)
      (draw-text-at (format nil "+ ~d more"
                            (- (length entries) visible-count))
                    (+ left 286)
                    (- (+ top height) 28)
                    13
                    color))))

(-> draw-editor-store-field
    (string string boolean scalar scalar scalar t)
    t)
(defun draw-editor-store-field (label value active-p x y width color)
  (let* ((size 15)
         (field-color (if active-p
                          color
                          (make-color 255 255 255 132)))
         (text (editor-truncate-text value 74)))
    (draw-text-at label
                  x
                  y
                  13
                  field-color)
    (draw-text-at text
                  x
                  (+ y 22)
                  size
                  field-color)
    (claylib/ll:draw-rectangle (round x)
                               (round (+ y 44))
                               (round width)
                               3
                               (claylib::c-ptr field-color))
    (when active-p
      (draw-cursor x
                   (+ y 22)
                   (text-width text size)
                   size
                   field-color))))

(-> draw-editor-store-edit-panel (t) t)
(defun draw-editor-store-edit-panel (color)
  (let ((left 88)
        (top 398)
        (width (- +virtual-width+ 176))
        (height 120))
    (claylib/ll:draw-rectangle left
                               top
                               width
                               height
                               (claylib::c-ptr
                                (make-color 0 0 0 226)))
    (draw-rectangle-outline left top width height color)
    (draw-text-at "EDIT STATE"
                  (+ left 14)
                  (+ top 12)
                  13
                  color)
    (draw-editor-store-field "KEY"
                             *editor-store-key-buffer*
                             (eq *editor-store-edit-phase* :key)
                             (+ left 14)
                             (+ top 36)
                             360
                             color)
    (draw-editor-store-field "VALUE"
                             *editor-store-value-buffer*
                             (eq *editor-store-edit-phase* :value)
                             (+ left 404)
                             (+ top 36)
                             (- width 430)
                             color)
    (draw-editor-right-text "TAB NEXT  C-s SAVE  C-g CANCEL"
                            (+ top height 12)
                            12
                            color)))

(-> editor-text-visible-start
    (nonnegative-integer nonnegative-integer nonnegative-integer)
    nonnegative-integer)
(defun editor-text-visible-start (line-count cursor-line visible-count)
  (let ((max-start (max 0 (- line-count visible-count))))
    (min max-start
         (max 0 (- cursor-line (floor visible-count 2))))))

(-> editor-visible-text-edit-lines
    ((list-of string) nonnegative-integer nonnegative-integer)
    (values list nonnegative-integer))
(defun editor-visible-text-edit-lines (lines cursor-line visible-count)
  (let ((start (editor-text-visible-start (length lines)
                                          cursor-line
                                          visible-count)))
    (values (subseq lines start (min (length lines) (+ start visible-count)))
            start)))

(-> draw-editor-text-edit-panel (t) t)
(defun draw-editor-text-edit-panel (color)
  (let* ((left 88)
         (top 456)
         (width (- +virtual-width+ 176))
         (height 144)
         (size 18)
         (line-spacing 22)
         (max-text-width (- width 28))
         (layout-lines (text-cursor-layout-lines *editor-text-buffer*
                                                 size
                                                 max-text-width))
         (lines (text-cursor-layout-line-strings layout-lines))
         (cursor (editor-clamp-text-cursor))
         (visible-count (min 4 (length lines))))
    (claylib/ll:draw-rectangle left
                               top
                               width
                               height
                               (claylib::c-ptr
                                (make-color 0 0 0 226)))
    (draw-rectangle-outline left top width height color)
    (draw-text-at "EDIT TEXT"
                  (+ left 14)
                  (+ top 12)
                  13
                  color)
    (multiple-value-bind (cursor-line-index cursor-width)
        (text-cursor-layout-placement layout-lines cursor size)
      (multiple-value-bind (visible-lines visible-start)
          (editor-visible-text-edit-lines lines cursor-line-index visible-count)
        (loop for line in visible-lines
              for index from 0
              do (draw-text-at line
                               (+ left 14)
                               (+ top 38 (* index line-spacing))
                               size
                               color))
        (let ((cursor-visible-index (- cursor-line-index visible-start)))
          (when (and (>= cursor-visible-index 0)
                     (< cursor-visible-index (length visible-lines)))
            (draw-cursor (+ left 14)
                         (+ top 38 (* cursor-visible-index line-spacing))
                         cursor-width
                         size
                         color)))))
    (draw-editor-right-text "RET/C-s SAVE  C-g CANCEL"
                            (+ top height 12)
                            12
                            color)))

(defgeneric editor-insert-kind-description (kind)
  (:documentation "Insert menu blurb for a node kind.")
  (:method (kind) (declare (ignore kind)) "TEXT")
  (:method ((kind (eql :say))) "SPEAKER LINE")
  (:method ((kind (eql :choice))) "CHOICE PROMPT")
  (:method ((kind (eql :conversation))) "TWO-SIDED TALK")
  (:method ((kind (eql :number))) "NUMBER INPUT")
  (:method ((kind (eql :string))) "TEXT INPUT")
  (:method ((kind (eql :minigame))) "MINIGAME NODE"))

(-> draw-editor-insert-kind-row (editor-insert-kind nonnegative-integer scalar scalar t) t)
(defun draw-editor-insert-kind-row (kind index x y color)
  (let* ((selected-p (= index *editor-insert-menu-selected-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 128)))
         (label (editor-insert-kind-label kind)))
    (when selected-p
      (draw-text-at ">"
                    (- x 22)
                    y
                    18
                    color))
    (draw-text-at label
                  x
                  y
                  18
                  row-color)
    (draw-text-at (editor-insert-kind-description kind)
                  (+ x 210)
                  (+ y 2)
                  13
                  row-color)))

(-> draw-editor-insert-menu (t) t)
(defun draw-editor-insert-menu (color)
  (let* ((panel-width 560)
         (panel-height 284)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 248)
         (replace-p (eq *editor-insert-action* :replace))
         (title (if replace-p "DESTRUCTIVE REPLACE" "NON-DESTRUCTIVE INSERT"))
         (target (if replace-p
                     "CURRENT NODE"
                     (editor-insert-target-label))))
    (claylib/ll:draw-rectangle left
                               top
                               panel-width
                               panel-height
                               (claylib::c-ptr
                                (make-color 0 0 0 234)))
    (draw-rectangle-outline left top panel-width panel-height color)
    (draw-text-at title
                  (+ left 24)
                  (+ top 20)
                  14
                  color)
    (draw-text-at target
                  (+ left 24)
                  (+ top 44)
                  13
                  (make-color 255 255 255 142))
    (loop for kind across *editor-insert-kinds*
          for index from 0
          do (draw-editor-insert-kind-row kind
                                          index
                                          (+ left 64)
                                          (+ top 78 (* index 28))
                                          color))
    (draw-editor-right-text (if replace-p
                                "RET REPLACE NODE  C-g CANCEL"
                                "RET INSERT BETWEEN LINKS  C-g CANCEL")
                            (+ top panel-height 14)
                            12
                            color)))

(-> editor-choice-option-field-label (editor-choice-option-field) string)
(defun editor-choice-option-field-label (field)
  (case field
    (:label "LABEL")
    (:target-kind "DESTINATION")
    (:target "VALUE")
    (:visible "VISIBLE IF")
    (:enabled "ENABLED IF")
    (t "")))

(-> editor-choice-option-field-value (editor-choice-option-field) string)
(defun editor-choice-option-field-value (field)
  (case field
    (:label
     *editor-choice-option-label-buffer*)
    (:target-kind
     (editor-choice-option-target-kind-label))
    (:visible
     *editor-choice-option-visible-buffer*)
    (:enabled
     *editor-choice-option-enabled-buffer*)
    (:target
     *editor-choice-option-target-buffer*)
    (t "")))

(-> draw-editor-choice-option-row
    (editor-choice-option-field nonnegative-integer scalar scalar t)
    t)
(defun draw-editor-choice-option-row (field index x y color)
  (let* ((selected-p (= index *editor-choice-option-field-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 128)))
         (label (editor-choice-option-field-label field))
         (value (editor-truncate-text
                 (editor-choice-option-field-value field)
                 58)))
    (when selected-p
      (draw-text-at ">"
                    (- x 22)
                    y
                    17
                    color))
    (draw-text-at label
                  x
                  y
                  14
                  row-color)
    (draw-text-at value
                  (+ x 190)
                  y
                  17
                  row-color)
    (when (and selected-p
               (not (eq field :target-kind)))
      (draw-cursor (+ x 190)
                   y
                   (text-width value 17)
                   17
                   row-color))))

(-> draw-editor-choice-option-panel (t) t)
(defun draw-editor-choice-option-panel (color)
  (let* ((panel-width 680)
         (panel-height 276)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 286))
    (claylib/ll:draw-rectangle left
                               top
                               panel-width
                               panel-height
                               (claylib::c-ptr
                                (make-color 0 0 0 234)))
    (draw-rectangle-outline left top panel-width panel-height color)
    (draw-text-at (format nil "OPTION ~d"
                          (1+ *editor-choice-option-index*))
                  (+ left 24)
                  (+ top 18)
                  14
                  color)
    (draw-text-at (or *editor-choice-option-node-id* "")
                  (+ left 24)
                  (+ top 42)
                  12
                  (make-color 255 255 255 142))
    (loop for field across *editor-choice-option-fields*
          for index from 0
          do (draw-editor-choice-option-row field
                                            index
                                            (+ left 58)
                                            (+ top 72 (* index 31))
                                            color))
    (draw-editor-right-text "C-s SAVE  C-g CANCEL  TAB NEXT"
                            (+ top panel-height 14)
                            12
                            color)))

(-> editor-conversation-side-label () string)
(defun editor-conversation-side-label ()
  (case *editor-conversation-entry-side*
    (:right "RIGHT")
    (t "LEFT")))

(-> editor-conversation-field-label (editor-conversation-entry-field) string)
(defun editor-conversation-field-label (field)
  (case field
    (:side "SIDE")
    (:speaker "SPEAKER")
    (:text "TEXT")
    (t "")))

(-> editor-conversation-field-value (editor-conversation-entry-field) string)
(defun editor-conversation-field-value (field)
  (case field
    (:side
     (editor-conversation-side-label))
    (:speaker
     *editor-conversation-entry-speaker-buffer*)
    (:text
     *editor-conversation-entry-text-buffer*)
    (t "")))

(-> draw-editor-conversation-entry-row
    (editor-conversation-entry-field nonnegative-integer scalar scalar t)
    t)
(defun draw-editor-conversation-entry-row (field index x y color)
  (let* ((selected-p (= index *editor-conversation-entry-field-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 128)))
         (label (editor-conversation-field-label field))
         (value (editor-truncate-text
                 (editor-conversation-field-value field)
                 66)))
    (when selected-p
      (draw-text-at ">"
                    (- x 22)
                    y
                    17
                    color))
    (draw-text-at label
                  x
                  y
                  14
                  row-color)
    (draw-text-at value
                  (+ x 164)
                  y
                  17
                  row-color)
    (when (and selected-p
               (not (eq field :side)))
      (draw-cursor (+ x 164)
                   y
                   (text-width value 17)
                   17
                   row-color))))

(-> draw-editor-conversation-entry-panel (t) t)
(defun draw-editor-conversation-entry-panel (color)
  (let* ((panel-width 760)
         (panel-height 236)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 326))
    (claylib/ll:draw-rectangle left
                               top
                               panel-width
                               panel-height
                               (claylib::c-ptr
                                (make-color 0 0 0 234)))
    (draw-rectangle-outline left top panel-width panel-height color)
    (draw-text-at (format nil "CONVERSATION LINE ~d"
                          (1+ *editor-conversation-entry-index*))
                  (+ left 24)
                  (+ top 18)
                  14
                  color)
    (draw-text-at (or *editor-conversation-entry-node-id* "")
                  (+ left 24)
                  (+ top 42)
                  12
                  (make-color 255 255 255 142))
    (loop for field across *editor-conversation-entry-fields*
          for index from 0
          do (draw-editor-conversation-entry-row field
                                                 index
                                                 (+ left 58)
                                                 (+ top 76 (* index 36))
                                                 color))
    (draw-editor-right-text "C-s SAVE  C-g CANCEL  TAB NEXT"
                            (+ top panel-height 14)
                            12
                            color)))

(-> editor-node-field-display-value (editor-field) string)
(defun editor-node-field-display-value (field)
  (editor-truncate-text (editor-field-buffer field) 64))

(-> draw-editor-node-field-row
    (editor-field nonnegative-integer scalar scalar t)
    t)
(defun draw-editor-node-field-row (field index x y color)
  (let* ((selected-p (= index *editor-node-fields-field-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 128)))
         (label (editor-field-label field))
         (value (editor-node-field-display-value field)))
    (when selected-p
      (draw-text-at ">"
                    (- x 22)
                    y
                    17
                    color))
    (draw-text-at label
                  x
                  y
                  14
                  row-color)
    (draw-text-at value
                  (+ x 184)
                  y
                  17
                  row-color)
    (when (and selected-p
               (field-editable-p field))
      (draw-cursor (+ x 184)
                   y
                   (text-width value 17)
                   17
                   row-color))))

(-> draw-editor-node-fields-panel (t) t)
(defun draw-editor-node-fields-panel (color)
  (let* ((panel-width 720)
         (panel-height 238)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 324)
         (node-id (or *editor-node-fields-node-id* ""))
         (node (and *editor-node-fields-node-id*
                    (node-exists-p *editor-node-fields-node-id*)
                    (find-node *editor-node-fields-node-id*))))
    (claylib/ll:draw-rectangle left
                               top
                               panel-width
                               panel-height
                               (claylib::c-ptr
                                (make-color 0 0 0 234)))
    (draw-rectangle-outline left top panel-width panel-height color)
    (draw-text-at "EDIT DETAILS"
                  (+ left 24)
                  (+ top 18)
                  14
                  color)
    (draw-text-at node-id
                  (+ left 24)
                  (+ top 42)
                  12
                  (make-color 255 255 255 142))
    (when node
      (loop for field across (editor-node-fields node)
            for index from 0
            do (draw-editor-node-field-row field
                                           index
                                           (+ left 58)
                                           (+ top 78 (* index 34))
                                           color)))
    (draw-editor-right-text "TYPE/ADJUST  C-s SAVE  C-g CANCEL"
                            (+ top panel-height 14)
                            12
                            color)))

(-> editor-node-target-field-label (editor-node-target-field) string)
(defun editor-node-target-field-label (field)
  (case field
    (:next "NEXT")
    (:target "TARGET")
    (:success "SUCCESS")
    (:failure "FAILURE")
    (t "")))

(-> editor-node-target-kind-label (editor-node-target-field) string)
(defun editor-node-target-kind-label (field)
  (case (editor-node-target-buffer-kind field)
    (:function "FUNCTION")
    (t "NODE ID")))

(-> draw-editor-node-target-row
    (editor-node-target-field nonnegative-integer scalar scalar t)
    t)
(defun draw-editor-node-target-row (field index x y color)
  (let* ((selected-p (= index *editor-node-target-field-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 128)))
         (label (editor-node-target-field-label field))
         (kind-label (editor-node-target-kind-label field))
         (value (editor-truncate-text
                 (editor-node-target-buffer-value field)
                 54)))
    (when selected-p
      (draw-text-at ">"
                    (- x 22)
                    y
                    17
                    color))
    (draw-text-at label
                  x
                  y
                  14
                  row-color)
    (draw-text-at kind-label
                  (+ x 132)
                  y
                  14
                  row-color)
    (draw-text-at value
                  (+ x 270)
                  y
                  17
                  row-color)
    (when selected-p
      (draw-cursor (+ x 270)
                   y
                   (text-width value 17)
                   17
                   row-color))))

(-> draw-editor-node-target-panel (t) t)
(defun draw-editor-node-target-panel (color)
  (let* ((panel-width 760)
         (panel-height 226)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 332)
         (node-id (or *editor-node-target-node-id* ""))
         (node (and *editor-node-target-node-id*
                    (node-exists-p *editor-node-target-node-id*)
                    (find-node *editor-node-target-node-id*))))
    (claylib/ll:draw-rectangle left
                               top
                               panel-width
                               panel-height
                               (claylib::c-ptr
                                (make-color 0 0 0 234)))
    (draw-rectangle-outline left top panel-width panel-height color)
    (draw-text-at "EDIT LINKS"
                  (+ left 24)
                  (+ top 18)
                  14
                  color)
    (draw-text-at node-id
                  (+ left 24)
                  (+ top 42)
                  12
                  (make-color 255 255 255 142))
    (when node
      (loop for field across (editor-node-target-fields node)
            for index from 0
            do (draw-editor-node-target-row field
                                            index
                                            (+ left 58)
                                            (+ top 78 (* index 34))
                                            color)))
    (draw-editor-right-text "LEFT/RIGHT TYPE  C-s SAVE  C-g CANCEL"
                            (+ top panel-height 14)
                            12
                            color)))

(-> draw-editor-help-row (string string nonnegative-integer scalar scalar t) t)
(defun draw-editor-help-row (binding description index x y color)
  (let ((row-y (+ y (* index 24)))
        (dim-color (make-color 255 255 255 150)))
    (draw-text-at binding
                  x
                  row-y
                  15
                  color)
    (draw-text-at description
                  (+ x 118)
                  row-y
                  15
                  dim-color)))

(-> draw-editor-help-overlay (t) t)
(defun draw-editor-help-overlay (color)
  (let* ((panel-width 610)
         (panel-height 610)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 68)
         (rows '(("C-h" "close this help overlay")
                 ("C-b" "rewind to previous editor step")
                 ("C-i" "non-destructive insert at current link")
                 ("C-r" "destructive replace current node")
                 ("C-a" "add option or conversation line")
                 ("C-p" "cycle the current minigame")
                 ("C-f" "cycle the current node particle field")
                 ("C-k" "cycle the current node sound")
                 ("C-m" "cycle the current node music")
                 ("C-l" "edit current node destinations")
                 ("C-v" "show or hide predicate-filtered choices")
                 ("C-y" "edit current node id and details")
                 ("C-o" "edit node details or highlighted item")
                 ("C-e" "edit the current node text")
                 ("C-s" "show shared state or save active panel")
                 ("C-d" "delete current linear editor node")
                 ("C-g" "cancel active editor panel")
                 ("C-x r m" "bookmark current node")
                 ("C-x r j" "jump through editor bookmarks")
                 ("LEFT/RIGHT" "move text cursor while editing")
                 ("HOME/END" "text start or end while editing")
                 ("TAB" "move to the next panel field")
                 ("RET" "confirm selection or save a panel")
                 ("ARROWS" "move choices, fields, and menu rows"))))
    (claylib/ll:draw-rectangle left
                               top
                               panel-width
                               panel-height
                               (claylib::c-ptr
                                (make-color 0 0 0 238)))
    (draw-rectangle-outline left top panel-width panel-height color)
    (draw-text-at "EDITOR BINDINGS"
                  (+ left 24)
                  (+ top 20)
                  14
                  color)
    (loop for row in rows
          for index from 0
          do (destructuring-bind (binding description) row
               (draw-editor-help-row binding
                                     description
                                     index
                                     (+ left 42)
                                     (+ top 56)
                                     color)))))

(-> draw-editor-overlay () t)
(defun draw-editor-overlay ()
  (when (and *editor-active-p* *state*)
    (let* ((node (current-node))
           (color (make-color 255 255 255 255))
           (dim-color (make-color 255 255 255 255))
           (bottom-y (- +virtual-height+
                        +editor-corner-margin-y+
                        +editor-corner-body-size+))
           (next-label (editor-next-label node)))
      (draw-text-at "EDITOR"
                    +editor-corner-margin-x+
                    +editor-corner-margin-y+
                    +editor-corner-heading-size+
                    color)
      (draw-text-at (format nil "~a" (node-id node))
                    +editor-corner-margin-x+
                    (+ +editor-corner-margin-y+ +editor-corner-line-gap+)
                    +editor-corner-body-size+
                    dim-color)
      (when next-label
        (draw-editor-right-text (format nil "NEXT ~a" next-label)
                                +editor-corner-margin-y+
                                +editor-corner-body-size+
                                dim-color))
      (draw-text-at (format nil "C-h HELP  HISTORY ~d  BOOKMARKS ~d~@[  ~a~]"
                            (length *editor-history*)
                            (editor-bookmark-count)
                            (when *editor-show-all-choices-p*
                              "ALL CHOICES"))
                    +editor-corner-margin-x+
                    bottom-y
                    +editor-corner-body-size+
                    dim-color)
      (when *editor-status-message*
        (draw-editor-right-text *editor-status-message*
                                bottom-y
                                +editor-corner-body-size+
                                dim-color))
      (when *editor-store-overlay-p*
        (draw-editor-store-overlay color))
      (let ((panel (active-editor-panel)))
        (when panel
          (panel-draw panel color)))
      (when *editor-help-overlay-p*
        (draw-editor-help-overlay color)))))


;;; Panel drawing

(defmethod panel-draw ((panel editor-insert-panel) color)
  (draw-editor-insert-menu color))

(defmethod panel-draw ((panel editor-store-edit-panel) color)
  (draw-editor-store-edit-panel color))

(defmethod panel-draw ((panel editor-choice-option-panel) color)
  (draw-editor-choice-option-panel color))

(defmethod panel-draw ((panel editor-conversation-entry-panel) color)
  (draw-editor-conversation-entry-panel color))

(defmethod panel-draw ((panel editor-node-target-panel) color)
  (draw-editor-node-target-panel color))

(defmethod panel-draw ((panel editor-node-fields-panel) color)
  (draw-editor-node-fields-panel color))

(defmethod panel-draw ((panel editor-text-edit-panel) color)
  (draw-editor-text-edit-panel color))
