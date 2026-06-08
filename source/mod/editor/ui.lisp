(in-package #:immortal-coil)

;;; Updating

(-> mod-editor-selection-direction () (option navigation-direction))
(defun mod-editor-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(-> mod-editor-move-picker (navigation-direction) t)
(defun mod-editor-move-picker (direction)
  (when *mod-picker-bundles*
    (setf *mod-picker-index*
          (mod (+ *mod-picker-index* direction)
               (length *mod-picker-bundles*)))
    (play-choice-switch)))

(-> mod-editor-close () t)
(defun mod-editor-close ()
  (reset-mod-editor-state)
  (play-choice-switch))

(-> mod-editor-selected-bundle () (option dialog-bundle))
(defun mod-editor-selected-bundle ()
  (nth *mod-picker-index* *mod-picker-bundles*))

(-> update-mod-picker () t)
(defun update-mod-picker ()
  (let ((direction (mod-editor-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (mod-editor-close))
      (direction
       (mod-editor-move-picker direction))
      ((confirm-pressed-p)
       (let ((bundle (mod-editor-selected-bundle)))
         (if bundle
             (open-mod-manifest-editor bundle)
             (setf *mod-manifest-status* "NO MOD SELECTED")))))))

(-> mod-editor-move-manifest-field (navigation-direction) t)
(defun mod-editor-move-manifest-field (direction)
  (setf *mod-manifest-field-index*
        (mod (+ *mod-manifest-field-index* direction)
             (length *mod-manifest-fields*)))
  (reset-mod-editor-backspace-repeat)
  (play-choice-switch))

(-> mod-editor-append-character (character) boolean)
(defun mod-editor-append-character (char)
  (let* ((field (mod-manifest-current-field))
         (value (mod-manifest-field-value field)))
    (when (< (length value) 420)
      (setf (mod-manifest-field-value field)
            (concatenate 'string value (string char)))
      (play-input-click)
      t)))

(-> mod-editor-delete-characters (nonnegative-integer) boolean)
(defun mod-editor-delete-characters (count)
  (let* ((field (mod-manifest-current-field))
         (value (mod-manifest-field-value field)))
    (when (and (plusp count)
               (plusp (length value)))
      (setf (mod-manifest-field-value field)
            (subseq value 0 (max 0 (- (length value) count))))
      (play-choice-switch)
      t)))

(-> mod-editor-backspace-interval () seconds)
(defun mod-editor-backspace-interval ()
  (max 0.025
       (- 0.13 (* *mod-editor-backspace-held-seconds* 0.04))))

(-> mod-editor-backspace-repeat-count (seconds) nonnegative-integer)
(defun mod-editor-backspace-repeat-count (dt)
  (cond
    ((not (is-key-down-p +key-backspace+))
     (reset-mod-editor-backspace-repeat)
     0)
    ((is-key-pressed-p +key-backspace+)
     (reset-mod-editor-backspace-repeat)
     1)
    (t
     (incf *mod-editor-backspace-held-seconds* dt)
     (if (< *mod-editor-backspace-held-seconds* 0.26)
         0
         (let ((interval (mod-editor-backspace-interval))
               (count 0))
           (incf *mod-editor-backspace-repeat-accumulator* dt)
           (loop while (>= *mod-editor-backspace-repeat-accumulator*
                           interval)
                 do (incf count)
                    (decf *mod-editor-backspace-repeat-accumulator*
                          interval))
           count)))))

(-> drain-mod-manifest-text-input (seconds) t)
(defun drain-mod-manifest-text-input (dt)
  (loop for code = (get-char-pressed)
        until (zerop code)
        for char = (code-char code)
        when (and char (string-input-character-p char))
          do (mod-editor-append-character char))
  (mod-editor-delete-characters
   (mod-editor-backspace-repeat-count dt)))

(-> update-mod-manifest-editor (&optional seconds) t)
(defun update-mod-manifest-editor (&optional (dt (get-frame-time)))
  (drain-mod-manifest-text-input dt)
  (let ((direction (mod-editor-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (mod-editor-close))
      ((or (is-key-pressed-p +key-tab+)
           direction)
       (mod-editor-move-manifest-field (or direction 1)))
      ((or (editor-control-key-pressed-p +key-s+)
           (is-key-pressed-p +key-enter+)
           (is-key-pressed-p +key-kp-enter+))
       (mod-editor-save-and-open)))))

(-> update-mod-editor (&optional seconds) t)
(defun update-mod-editor (&optional (dt (get-frame-time)))
  (case *mod-editor-mode*
    (:picker
     (update-mod-picker))
    (:manifest
     (update-mod-manifest-editor dt))
    (t nil)))


;;; Rendering

(-> draw-mod-editor-panel (string scalar scalar scalar scalar t) t)
(defun draw-mod-editor-panel (title left top width height color)
  (claylib/ll:draw-rectangle left
                             top
                             width
                             height
                             (claylib::c-ptr
                              (make-color 0 0 0 238)))
  (draw-rectangle-outline left top width height color)
  (draw-text-at title
                (+ left 24)
                (+ top 20)
                15
                color))

(-> draw-mod-picker-row
    (dialog-bundle nonnegative-integer scalar scalar t)
    t)
(defun draw-mod-picker-row (bundle index x y color)
  (let* ((selected-p (= index *mod-picker-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 132))))
    (when selected-p
      (draw-text-at ">"
                    (- x 24)
                    y
                    18
                    color))
    (draw-text-at (editor-truncate-text (dialog-bundle-name bundle) 32)
                  x
                  y
                  18
                  row-color)
    (draw-text-at (editor-truncate-text (dialog-bundle-id bundle) 42)
                  (+ x 320)
                  (+ y 2)
                  13
                  row-color)))

(-> draw-mod-picker (t) t)
(defun draw-mod-picker (color)
  (let* ((panel-width 760)
         (panel-height 390)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 142))
    (draw-mod-editor-panel "EDIT MOD" left top panel-width panel-height color)
    (loop for bundle in *mod-picker-bundles*
          for index from 0
          do (draw-mod-picker-row bundle
                                  index
                                  (+ left 58)
                                  (+ top 66 (* index 32))
                                  color))
    (draw-text-at "RET OPEN  C-g BACK"
                  (+ left 24)
                  (- (+ top panel-height) 34)
                  12
                  (make-color 255 255 255 156))))

(-> draw-mod-manifest-row
    (mod-manifest-field nonnegative-integer scalar scalar scalar t)
    t)
(defun draw-mod-manifest-row (field index x y width color)
  (let* ((selected-p (= index *mod-manifest-field-index*))
         (row-color (if selected-p
                        color
                        (make-color 255 255 255 132)))
         (label (mod-manifest-field-label field))
         (value (editor-truncate-text (mod-manifest-field-value field) 74)))
    (draw-text-at label
                  x
                  y
                  13
                  row-color)
    (draw-text-at value
                  (+ x 154)
                  y
                  17
                  row-color)
    (claylib/ll:draw-rectangle (round (+ x 154))
                               (round (+ y 23))
                               (round width)
                               3
                               (claylib::c-ptr row-color))
    (when selected-p
      (draw-cursor (+ x 154)
                   y
                   (text-width value 17)
                   17
                   row-color))))

(-> draw-mod-manifest-editor (t) t)
(defun draw-mod-manifest-editor (color)
  (let* ((panel-width 930)
         (panel-height 520)
         (left (round (- +virtual-center-x+ (/ panel-width 2))))
         (top 88)
         (title (if (eq *mod-manifest-action* :create)
                    "CREATE MOD"
                    "EDIT MOD MANIFEST")))
    (draw-mod-editor-panel title left top panel-width panel-height color)
    (loop for field across *mod-manifest-fields*
          for index from 0
          do (draw-mod-manifest-row field
                                    index
                                    (+ left 36)
                                    (+ top 64 (* index 44))
                                    690
                                    color))
    (draw-text-at "TAB FIELD  C-s SAVE+EDIT  C-g BACK"
                  (+ left 24)
                  (- (+ top panel-height) 36)
                  12
                  (make-color 255 255 255 156))))

(-> draw-mod-editor-status (t) t)
(defun draw-mod-editor-status (color)
  (when *mod-manifest-status*
    (draw-centered-text *mod-manifest-status*
                        +virtual-center-x+
                        650
                        13
                        color)))

(-> draw-mod-editor () t)
(defun draw-mod-editor ()
  (let ((color (make-color 255
                           255
                           255
                           (round (* 238 (menu-alpha-scale))))))
    (case *mod-editor-mode*
      (:picker
       (draw-mod-picker color))
      (:manifest
       (draw-mod-manifest-editor color)))
    (draw-mod-editor-status
     (make-color 255
                 255
                 255
                 (round (* 170 (menu-alpha-scale)))))))
