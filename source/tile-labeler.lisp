(in-package #:immortal-coil)

;;; Hexany Tile Labeler: startup/menu tool for identifying the new 16x16
;;; roguelike sheets. It saves crop calibration, labels, and skips to the normal
;;; save directory so the data can later drive autotiling and scene work.

(defconstant +hex-tile-size+ 16)
(defconstant +hex-labeler-preview-size+ 224)
(defconstant +hex-labeler-preview-x+ 80)
(defconstant +hex-labeler-preview-y+ 184)
(defconstant +hex-labeler-sheet-x+ 430)
(defconstant +hex-labeler-sheet-y+ 104)
(defconstant +hex-labeler-edge-max+ 7)

(defstruct hex-labeler-sheet
  id
  path
  width
  height
  cols
  rows
  texture
  image)

(defparameter *hex-labeler-sheet-specs*
  '(("autotile" "assets/tiles/hexany/Tilesheets/Transparent/autotile_transparent.png" 384 192)
    ("creatures" "assets/tiles/hexany/Tilesheets/Transparent/creatures_transparent.png" 256 320)
    ("general" "assets/tiles/hexany/Tilesheets/Transparent/general_transparent.png" 512 128)
    ("items" "assets/tiles/hexany/Tilesheets/Transparent/items_transparent.png" 384 128)))

(defvar *hex-labeler-active-p* nil)
(defvar *hex-labeler-auto-shown-p* nil)
(defvar *hex-labeler-phase* :crop)
(defvar *hex-labeler-sheets* nil)
(defvar *hex-labeler-sheet-index* 0)
(defvar *hex-labeler-crop-edge* :left)
(defvar *hex-labeler-crop-left* 0)
(defvar *hex-labeler-crop-top* 0)
(defvar *hex-labeler-crop-right* 0)
(defvar *hex-labeler-crop-bottom* 0)
(defvar *hex-labeler-crop-col* 0)
(defvar *hex-labeler-crop-row* 0)
(defvar *hex-labeler-tiles* nil)
(defvar *hex-labeler-index* 0)
(defvar *hex-labeler-label-input* "")
(defvar *hex-labeler-labels* nil)
(defvar *hex-labeler-skips* nil)
(defvar *hex-labeler-message* "")
(defvar *hex-labeler-sample-color* (make-color 0 0 0 0))
(defvar *hex-labeler-white* (make-color 255 255 255 255))


;;; Persistence

(-> hex-labeler-save-root () pathname)
(defun hex-labeler-save-root ()
  (let ((directory (uiop:getenv "IMMORTAL_COIL_SAVE_DIR")))
    (if directory
        (uiop:ensure-directory-pathname directory)
        (project-pathname "save/"))))

(-> hex-labeler-save-path () pathname)
(defun hex-labeler-save-path ()
  (merge-pathnames "hexany-tile-labels.lisp" (hex-labeler-save-root)))

(-> hex-labeler-crop-plist () plist)
(defun hex-labeler-crop-plist ()
  (list :left *hex-labeler-crop-left*
        :top *hex-labeler-crop-top*
        :right *hex-labeler-crop-right*
        :bottom *hex-labeler-crop-bottom*))

(-> hex-labeler-set-crop-from-plist ((option plist)) t)
(defun hex-labeler-set-crop-from-plist (crop)
  (setf *hex-labeler-crop-left* (max 0 (min +hex-labeler-edge-max+
                                            (or (getf crop :left) 0)))
        *hex-labeler-crop-top* (max 0 (min +hex-labeler-edge-max+
                                           (or (getf crop :top) 0)))
        *hex-labeler-crop-right* (max 0 (min +hex-labeler-edge-max+
                                             (or (getf crop :right) 0)))
        *hex-labeler-crop-bottom* (max 0 (min +hex-labeler-edge-max+
                                              (or (getf crop :bottom) 0)))))

(-> hex-labeler-load-data () (option plist))
(defun hex-labeler-load-data ()
  (setf *hex-labeler-labels* nil
        *hex-labeler-skips* nil)
  (let ((data (handler-case
                  (let ((path (hex-labeler-save-path)))
                    (when (probe-file path)
                      (with-open-file (stream path)
                        (with-standard-io-syntax
                          (read stream nil nil)))))
                (error (condition)
                  (runtime-warn "Hexany label data load failed: ~a" condition)
                  nil))))
    (when (listp data)
      (hex-labeler-set-crop-from-plist (getf data :crop))
      (setf *hex-labeler-labels* (copy-list (or (getf data :labels) nil))
            *hex-labeler-skips* (copy-list (or (getf data :skipped) nil))))
    data))

(-> hex-labeler-label-entry-less-p (plist plist) boolean)
(defun hex-labeler-label-entry-less-p (left right)
  (let ((left-sheet (getf left :sheet))
        (right-sheet (getf right :sheet)))
    (cond
      ((string< left-sheet right-sheet) t)
      ((string< right-sheet left-sheet) nil)
      ((< (getf left :row) (getf right :row)) t)
      ((> (getf left :row) (getf right :row)) nil)
      (t (< (getf left :col) (getf right :col))))))

(-> hex-labeler-complete-p () boolean)
(defun hex-labeler-complete-p ()
  (and *hex-labeler-tiles*
       (fboundp 'hex-labeler-tile-handled-p)
       (every (symbol-function 'hex-labeler-tile-handled-p)
              *hex-labeler-tiles*)))

(-> hex-labeler-save-data () t)
(defun hex-labeler-save-data ()
  (handler-case
      (let ((path (hex-labeler-save-path)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :supersede
                                :if-does-not-exist :create)
          (with-standard-io-syntax
            (let ((*print-readably* t))
              (print (list :version 1
                           :tile-size +hex-tile-size+
                           :source "Hexany's Roguelike Tiles 0.3.0"
                           :crop (hex-labeler-crop-plist)
                           :complete (hex-labeler-complete-p)
                           :labels (sort (copy-list *hex-labeler-labels*)
                                         #'hex-labeler-label-entry-less-p)
                           :skipped (sort (copy-list *hex-labeler-skips*)
                                          #'hex-labeler-label-entry-less-p))
                     stream)))))
    (error (condition)
      (runtime-warn "Hexany label data save failed: ~a" condition))))

(-> hex-labeler-startup-needed-p () boolean)
(defun hex-labeler-startup-needed-p ()
  (handler-case
      (let* ((path (hex-labeler-save-path))
             (data (and (probe-file path)
                        (with-open-file (stream path)
                          (with-standard-io-syntax
                            (read stream nil nil))))))
        (not (and (listp data)
                  (getf data :complete))))
    (error ()
      t)))


;;; Sheet and tile data

(-> hex-labeler-load-sheet (list) (option hex-labeler-sheet))
(defun hex-labeler-load-sheet (spec)
  (destructuring-bind (id relative-path width height) spec
    (let ((path (project-pathname relative-path)))
      (handler-case
          (when (probe-file path)
            (let ((texture (make-texture (make-texture-asset path :load-now t)
                                         0.0
                                         0.0
                                         :width 16.0
                                         :height 16.0
                                         :tint (make-color 255 255 255 255)))
                  (image (make-image-asset path :load-now t)))
              (ignore-errors
               (claylib/ll:set-texture-filter (claylib::c-asset texture)
                                              +texture-filter-point+))
              (make-hex-labeler-sheet
               :id id
               :path path
               :width width
               :height height
               :cols (floor width +hex-tile-size+)
               :rows (floor height +hex-tile-size+)
               :texture texture
               :image image)))
        (error (condition)
          (runtime-warn "Could not load Hexany sheet ~a: ~a" id condition)
          nil)))))

(-> hex-labeler-load-sheets () list)
(defun hex-labeler-load-sheets ()
  (setf *hex-labeler-sheets*
        (remove nil (mapcar #'hex-labeler-load-sheet *hex-labeler-sheet-specs*))))

(-> clear-hexany-labeler-sheets () t)
(defun clear-hexany-labeler-sheets ()
  (setf *hex-labeler-sheets* nil
        *hex-labeler-tiles* nil))

(-> hex-labeler-current-sheet () (option hex-labeler-sheet))
(defun hex-labeler-current-sheet ()
  (nth *hex-labeler-sheet-index* *hex-labeler-sheets*))

(-> hex-labeler-clamp-crop-selection () t)
(defun hex-labeler-clamp-crop-selection ()
  (let ((sheet (hex-labeler-current-sheet)))
    (when sheet
      (setf *hex-labeler-crop-col*
            (max 0 (min *hex-labeler-crop-col*
                        (1- (hex-labeler-sheet-cols sheet))))
            *hex-labeler-crop-row*
            (max 0 (min *hex-labeler-crop-row*
                        (1- (hex-labeler-sheet-rows sheet))))))))

(-> hex-labeler-image-alpha-at (hex-labeler-sheet integer integer) integer)
(defun hex-labeler-image-alpha-at (sheet x y)
  (claylib/ll:get-image-color
   (claylib::c-ptr *hex-labeler-sample-color*)
   (claylib::c-ptr (asset (hex-labeler-sheet-image sheet)))
   x
   y)
  (a *hex-labeler-sample-color*))

(-> hex-labeler-tile-nonempty-p (hex-labeler-sheet integer integer) boolean)
(defun hex-labeler-tile-nonempty-p (sheet col row)
  (loop with start-x = (* col +hex-tile-size+)
        with start-y = (* row +hex-tile-size+)
        for y from start-y below (+ start-y +hex-tile-size+)
        thereis
        (loop for x from start-x below (+ start-x +hex-tile-size+)
              thereis (> (hex-labeler-image-alpha-at sheet x y) 0))))

(-> hex-labeler-build-tile-list () list)
(defun hex-labeler-build-tile-list ()
  (let ((tiles nil))
    (dolist (sheet *hex-labeler-sheets*)
      (dotimes (row (hex-labeler-sheet-rows sheet))
        (dotimes (col (hex-labeler-sheet-cols sheet))
          (when (hex-labeler-tile-nonempty-p sheet col row)
            (push (list sheet col row) tiles)))))
    (nreverse tiles)))

(-> hex-labeler-tile-key (list) plist)
(defun hex-labeler-tile-key (tile)
  (destructuring-bind (sheet col row) tile
    (list :sheet (hex-labeler-sheet-id sheet)
          :col col
          :row row)))

(-> hex-labeler-entry-matches-key-p (plist plist) boolean)
(defun hex-labeler-entry-matches-key-p (entry key)
  (and (string= (getf entry :sheet) (getf key :sheet))
       (= (getf entry :col) (getf key :col))
       (= (getf entry :row) (getf key :row))))

(-> hex-labeler-find-label (list) (option plist))
(defun hex-labeler-find-label (tile)
  (let ((key (hex-labeler-tile-key tile)))
    (find-if (lambda (entry)
               (hex-labeler-entry-matches-key-p entry key))
             *hex-labeler-labels*)))

(-> hex-labeler-skipped-p (list) boolean)
(defun hex-labeler-skipped-p (tile)
  (let ((key (hex-labeler-tile-key tile)))
    (and (find-if (lambda (entry)
                    (hex-labeler-entry-matches-key-p entry key))
                  *hex-labeler-skips*)
         t)))

(-> hex-labeler-tile-handled-p (list) boolean)
(defun hex-labeler-tile-handled-p (tile)
  (or (hex-labeler-find-label tile)
      (hex-labeler-skipped-p tile)))

(-> hex-labeler-remove-keyed-entry (plist list) list)
(defun hex-labeler-remove-keyed-entry (key entries)
  (remove-if (lambda (entry)
               (hex-labeler-entry-matches-key-p entry key))
             entries))

(-> hex-labeler-current-tile () (option list))
(defun hex-labeler-current-tile ()
  (nth *hex-labeler-index* *hex-labeler-tiles*))

(-> hex-labeler-load-current-label-input () t)
(defun hex-labeler-load-current-label-input ()
  (let* ((tile (hex-labeler-current-tile))
         (entry (and tile (hex-labeler-find-label tile))))
    (setf *hex-labeler-label-input* (or (and entry (getf entry :label))
                                        ""))))

(-> hex-labeler-first-unhandled-index () (option nonnegative-integer))
(defun hex-labeler-first-unhandled-index ()
  (loop for tile in *hex-labeler-tiles*
        for index from 0
        unless (hex-labeler-tile-handled-p tile)
          do (return index)))

(-> hex-labeler-set-label-index (integer) t)
(defun hex-labeler-set-label-index (index)
  (when *hex-labeler-tiles*
    (setf *hex-labeler-index*
          (mod index (length *hex-labeler-tiles*)))
    (hex-labeler-load-current-label-input)))


;;; Drawing helpers

(-> hex-labeler-inner-width () integer)
(defun hex-labeler-inner-width ()
  (max 1 (- +hex-tile-size+
            *hex-labeler-crop-left*
            *hex-labeler-crop-right*)))

(-> hex-labeler-inner-height () integer)
(defun hex-labeler-inner-height ()
  (max 1 (- +hex-tile-size+
            *hex-labeler-crop-top*
            *hex-labeler-crop-bottom*)))

(-> hex-labeler-draw-sheet-region
    (hex-labeler-sheet scalar scalar scalar scalar scalar scalar scalar scalar t)
    t)
(defun hex-labeler-draw-sheet-region (sheet source-x source-y source-width source-height
                                      dest-x dest-y dest-width dest-height color)
  (let* ((texture (hex-labeler-sheet-texture sheet))
         (source (source texture))
         (dest (dest texture)))
    (setf (x source) (float source-x 1.0)
          (y source) (float source-y 1.0)
          (width source) (float source-width 1.0)
          (height source) (float source-height 1.0)
          (x dest) (float dest-x 1.0)
          (y dest) (float dest-y 1.0)
          (width dest) (float dest-width 1.0)
          (height dest) (float dest-height 1.0)
          (origin texture) (make-vector2 0.0 0.0)
          (rot texture) 0.0
          (tint texture) color)
    (draw-object texture)))

(-> hex-labeler-draw-tile (hex-labeler-sheet integer integer scalar scalar scalar) t)
(defun hex-labeler-draw-tile (sheet col row x y size)
  (hex-labeler-draw-sheet-region
   sheet
   (+ (* col +hex-tile-size+) *hex-labeler-crop-left*)
   (+ (* row +hex-tile-size+) *hex-labeler-crop-top*)
   (hex-labeler-inner-width)
   (hex-labeler-inner-height)
   x
   y
   size
   size
   *hex-labeler-white*))

(-> hex-labeler-context-scale (hex-labeler-sheet) integer)
(defun hex-labeler-context-scale (sheet)
  (max 1
       (min (floor 790 (hex-labeler-sheet-width sheet))
            (floor 500 (hex-labeler-sheet-height sheet)))))

(-> hex-labeler-draw-context
    (hex-labeler-sheet integer integer &key (:show-crop boolean))
    t)
(defun hex-labeler-draw-context (sheet col row &key show-crop)
  (let* ((scale (hex-labeler-context-scale sheet))
         (sheet-width (* (hex-labeler-sheet-width sheet) scale))
         (sheet-height (* (hex-labeler-sheet-height sheet) scale))
         (left +hex-labeler-sheet-x+)
         (top +hex-labeler-sheet-y+))
    (claylib/ll:draw-rectangle (- left 14) (- top 48)
                               (+ sheet-width 28) (+ sheet-height 86)
                               (claylib::c-ptr (make-color 0 0 0 255)))
    (draw-rectangle-outline (- left 14) (- top 48)
                            (+ sheet-width 28) (+ sheet-height 86)
                            (make-color 255 255 255 210)
                            :thickness 2)
    (draw-text-at (format nil "~a  ~dx~d"
                          (string-upcase (hex-labeler-sheet-id sheet))
                          (hex-labeler-sheet-cols sheet)
                          (hex-labeler-sheet-rows sheet))
                  left
                  (- top 36)
                  18
                  (make-color 255 255 255 220))
    (hex-labeler-draw-sheet-region sheet
                                   0
                                   0
                                   (hex-labeler-sheet-width sheet)
                                   (hex-labeler-sheet-height sheet)
                                   left
                                   top
                                   sheet-width
                                   sheet-height
                                   *hex-labeler-white*)
    (let* ((tile-left (+ left (* col +hex-tile-size+ scale)))
           (tile-top (+ top (* row +hex-tile-size+ scale)))
           (tile-size (* +hex-tile-size+ scale)))
      (draw-rectangle-outline tile-left tile-top tile-size tile-size
                              (make-color 255 255 255 255)
                              :thickness 3)
      (when show-crop
        (draw-rectangle-outline (+ tile-left (* *hex-labeler-crop-left* scale))
                                (+ tile-top (* *hex-labeler-crop-top* scale))
                                (* (hex-labeler-inner-width) scale)
                                (* (hex-labeler-inner-height) scale)
                                (make-color 255 255 255 165)
                                :thickness 1)))))

(-> hex-labeler-draw-status (string) t)
(defun hex-labeler-draw-status (text)
  (claylib/ll:draw-rectangle 0 (- +virtual-height+ 32) +virtual-width+ 32
                             (claylib::c-ptr (make-color 0 0 0 230)))
  (draw-text-at text 24 (- +virtual-height+ 25) 15
                (make-color 255 255 255 210)))


;;; Input helpers

(-> hex-labeler-accept-typing (string) string)
(defun hex-labeler-accept-typing (current)
  (let ((text current))
    (loop for code = (get-char-pressed)
          until (zerop code)
          for char = (ignore-errors (code-char code))
          when (and char (string-input-character-p char))
            do (setf text (concatenate 'string text (string char))))
    (when (and (is-key-pressed-p +key-backspace+)
               (plusp (length text)))
      (setf text (subseq text 0 (1- (length text)))))
    text))

(-> hex-labeler-exit-to-menu () t)
(defun hex-labeler-exit-to-menu ()
  (setf *hex-labeler-active-p* nil
        *suppress-window-shortcuts-p* nil
        *hex-labeler-message* "")
  (play-choice-switch))


;;; Crop phase

(-> hex-labeler-cycle-crop-edge () t)
(defun hex-labeler-cycle-crop-edge ()
  (setf *hex-labeler-crop-edge*
        (case *hex-labeler-crop-edge*
          (:left :top)
          (:top :right)
          (:right :bottom)
          (t :left))))

(-> hex-labeler-selected-edge-value () integer)
(defun hex-labeler-selected-edge-value ()
  (case *hex-labeler-crop-edge*
    (:left *hex-labeler-crop-left*)
    (:top *hex-labeler-crop-top*)
    (:right *hex-labeler-crop-right*)
    (t *hex-labeler-crop-bottom*)))

(-> (setf hex-labeler-selected-edge-value) (integer) integer)
(defun (setf hex-labeler-selected-edge-value) (value)
  (let ((clamped (max 0 (min +hex-labeler-edge-max+ value))))
    (case *hex-labeler-crop-edge*
      (:left (setf *hex-labeler-crop-left* clamped))
      (:top (setf *hex-labeler-crop-top* clamped))
      (:right (setf *hex-labeler-crop-right* clamped))
      (t (setf *hex-labeler-crop-bottom* clamped)))
    clamped))

(-> hex-labeler-adjust-crop-edge (integer) t)
(defun hex-labeler-adjust-crop-edge (delta)
  (setf (hex-labeler-selected-edge-value)
        (+ (hex-labeler-selected-edge-value) delta))
  (hex-labeler-save-data)
  (play-choice-switch))

(-> hex-labeler-move-crop-selection (integer integer) t)
(defun hex-labeler-move-crop-selection (dx dy)
  (let ((sheet (hex-labeler-current-sheet)))
    (when sheet
      (setf *hex-labeler-crop-col*
            (max 0 (min (+ *hex-labeler-crop-col* dx)
                        (1- (hex-labeler-sheet-cols sheet))))
            *hex-labeler-crop-row*
            (max 0 (min (+ *hex-labeler-crop-row* dy)
                        (1- (hex-labeler-sheet-rows sheet))))))))

(-> hex-labeler-change-sheet (integer) t)
(defun hex-labeler-change-sheet (delta)
  (when *hex-labeler-sheets*
    (setf *hex-labeler-sheet-index*
          (mod (+ *hex-labeler-sheet-index* delta)
               (length *hex-labeler-sheets*)))
    (hex-labeler-clamp-crop-selection)
    (play-choice-switch)))

(-> hex-labeler-enter-label-phase () t)
(defun hex-labeler-enter-label-phase ()
  (setf *hex-labeler-tiles* (hex-labeler-build-tile-list))
  (let ((first-unhandled (hex-labeler-first-unhandled-index)))
    (cond
      ((null *hex-labeler-tiles*)
       (setf *hex-labeler-phase* :done
             *hex-labeler-message* "no visible tiles found"))
      (first-unhandled
       (setf *hex-labeler-phase* :label
             *hex-labeler-index* first-unhandled
             *hex-labeler-message* "")
       (hex-labeler-load-current-label-input))
      (t
       (setf *hex-labeler-phase* :done
             *hex-labeler-message* "all visible tiles are handled"))))
  (hex-labeler-save-data)
  (play-choice-switch))

(-> update-hex-labeler-crop () t)
(defun update-hex-labeler-crop ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (hex-labeler-exit-to-menu))
    ((or (is-key-pressed-p +key-enter+)
         (is-key-pressed-p +key-kp-enter+))
     (hex-labeler-enter-label-phase))
    (t
     (when (is-key-pressed-p +key-tab+)
       (hex-labeler-cycle-crop-edge)
       (play-choice-switch))
     (when (or (is-key-pressed-p +key-left-bracket+)
               (is-key-pressed-p +key-minus+))
       (hex-labeler-adjust-crop-edge -1))
     (when (or (is-key-pressed-p +key-right-bracket+)
               (is-key-pressed-p +key-equal+))
       (hex-labeler-adjust-crop-edge 1))
     (when (or (is-key-pressed-p +key-q+)
               (is-key-pressed-p +key-page-up+))
       (hex-labeler-change-sheet -1))
     (when (or (is-key-pressed-p +key-e+)
               (is-key-pressed-p +key-page-down+))
       (hex-labeler-change-sheet 1))
     (when (is-key-pressed-p +key-left+)
       (hex-labeler-move-crop-selection -1 0))
     (when (is-key-pressed-p +key-right+)
       (hex-labeler-move-crop-selection 1 0))
     (when (is-key-pressed-p +key-up+)
       (hex-labeler-move-crop-selection 0 -1))
     (when (is-key-pressed-p +key-down+)
       (hex-labeler-move-crop-selection 0 1)))))

(-> draw-hex-labeler-crop () t)
(defun draw-hex-labeler-crop ()
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 255)))
  (draw-text-at "HEXANY TILE CROP" 32 28 26 *hex-labeler-white*)
  (draw-text-at "adjust one edge, inspect the enlarged tile, then press ENTER"
                32 64 16 (make-color 255 255 255 180))
  (let ((sheet (hex-labeler-current-sheet)))
    (if sheet
        (progn
          (hex-labeler-draw-context sheet
                                    *hex-labeler-crop-col*
                                    *hex-labeler-crop-row*
                                    :show-crop t)
          (draw-rectangle-outline +hex-labeler-preview-x+
                                  +hex-labeler-preview-y+
                                  +hex-labeler-preview-size+
                                  +hex-labeler-preview-size+
                                  (make-color 255 255 255 220)
                                  :thickness 2)
          (hex-labeler-draw-tile sheet
                                 *hex-labeler-crop-col*
                                 *hex-labeler-crop-row*
                                 +hex-labeler-preview-x+
                                 +hex-labeler-preview-y+
                                 +hex-labeler-preview-size+)
          (draw-text-at (format nil "tile ~d,~d"
                                *hex-labeler-crop-col*
                                *hex-labeler-crop-row*)
                        +hex-labeler-preview-x+
                        (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 18)
                        16
                        (make-color 255 255 255 180))
          (draw-text-at (format nil "crop L~d T~d R~d B~d"
                                *hex-labeler-crop-left*
                                *hex-labeler-crop-top*
                                *hex-labeler-crop-right*
                                *hex-labeler-crop-bottom*)
                        +hex-labeler-preview-x+
                        (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 46)
                        18
                        *hex-labeler-white*)
          (draw-text-at (format nil "selected edge: ~a"
                                (string-upcase (symbol-name *hex-labeler-crop-edge*)))
                        +hex-labeler-preview-x+
                        (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 76)
                        18
                        (make-color 255 255 255 220)))
        (draw-centered-text "Hexany sheets did not load"
                            +virtual-center-x+
                            +virtual-center-y+
                            24
                            *hex-labeler-white*)))
  (hex-labeler-draw-status
   "arrows tile   Q/E sheet   TAB edge   [/]/-/= crop   ENTER label tiles   ESC menu"))


;;; Label phase

(-> hex-labeler-current-progress-text () string)
(defun hex-labeler-current-progress-text ()
  (format nil "~d / ~d" (1+ *hex-labeler-index*) (length *hex-labeler-tiles*)))

(-> hex-labeler-current-status-text (list) string)
(defun hex-labeler-current-status-text (tile)
  (let ((entry (hex-labeler-find-label tile)))
    (cond
      (entry (format nil "saved as ~s" (getf entry :label)))
      ((hex-labeler-skipped-p tile) "skipped")
      (t "unlabeled"))))

(-> hex-labeler-commit-label () t)
(defun hex-labeler-commit-label ()
  (let ((tile (hex-labeler-current-tile))
        (label (string-trim " " *hex-labeler-label-input*)))
    (cond
      ((null tile)
       (setf *hex-labeler-phase* :done))
      ((zerop (length label))
       (setf *hex-labeler-message* "label cannot be empty"))
      (t
       (let ((key (hex-labeler-tile-key tile)))
         (setf *hex-labeler-labels*
               (cons (append key (list :label label))
                     (hex-labeler-remove-keyed-entry key *hex-labeler-labels*))
               *hex-labeler-skips*
               (hex-labeler-remove-keyed-entry key *hex-labeler-skips*)
               *hex-labeler-message* "saved")
         (hex-labeler-save-data)
         (if (< (1+ *hex-labeler-index*) (length *hex-labeler-tiles*))
             (hex-labeler-set-label-index (1+ *hex-labeler-index*))
             (setf *hex-labeler-phase* :done
                   *hex-labeler-message* "all visible tiles are handled")))))))

(-> hex-labeler-skip-current () t)
(defun hex-labeler-skip-current ()
  (let ((tile (hex-labeler-current-tile)))
    (when tile
      (let ((key (hex-labeler-tile-key tile)))
        (setf *hex-labeler-skips*
              (cons key (hex-labeler-remove-keyed-entry key *hex-labeler-skips*))
              *hex-labeler-labels*
              (hex-labeler-remove-keyed-entry key *hex-labeler-labels*)
              *hex-labeler-message* "skipped")
        (hex-labeler-save-data)
        (if (< (1+ *hex-labeler-index*) (length *hex-labeler-tiles*))
            (hex-labeler-set-label-index (1+ *hex-labeler-index*))
            (setf *hex-labeler-phase* :done
                  *hex-labeler-message* "all visible tiles are handled"))))))

(-> update-hex-labeler-label () t)
(defun update-hex-labeler-label ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (hex-labeler-exit-to-menu))
    ((or (is-key-pressed-p +key-enter+)
         (is-key-pressed-p +key-kp-enter+))
     (hex-labeler-commit-label))
    ((is-key-pressed-p +key-n+)
     (hex-labeler-skip-current))
    ((or (is-key-pressed-p +key-p+)
         (is-key-pressed-p +key-left+))
     (hex-labeler-set-label-index (1- *hex-labeler-index*))
     (play-choice-switch))
    ((is-key-pressed-p +key-right+)
     (hex-labeler-set-label-index (1+ *hex-labeler-index*))
     (play-choice-switch))
    (t
     (setf *hex-labeler-label-input*
           (hex-labeler-accept-typing *hex-labeler-label-input*)))))

(-> draw-hex-labeler-label () t)
(defun draw-hex-labeler-label ()
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 255)))
  (draw-text-at "HEXANY TILE LABELS" 32 28 26 *hex-labeler-white*)
  (draw-text-at (format nil "visible tile ~a" (hex-labeler-current-progress-text))
                32 64 16 (make-color 255 255 255 180))
  (let ((tile (hex-labeler-current-tile)))
    (when tile
      (destructuring-bind (sheet col row) tile
        (hex-labeler-draw-context sheet col row)
        (draw-rectangle-outline +hex-labeler-preview-x+
                                +hex-labeler-preview-y+
                                +hex-labeler-preview-size+
                                +hex-labeler-preview-size+
                                (make-color 255 255 255 220)
                                :thickness 2)
        (hex-labeler-draw-tile sheet
                               col
                               row
                               +hex-labeler-preview-x+
                               +hex-labeler-preview-y+
                               +hex-labeler-preview-size+)
        (draw-text-at (format nil "~a ~d,~d"
                              (hex-labeler-sheet-id sheet)
                              col
                              row)
                      +hex-labeler-preview-x+
                      (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 18)
                      16
                      (make-color 255 255 255 180))
        (draw-text-at (hex-labeler-current-status-text tile)
                      +hex-labeler-preview-x+
                      (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 46)
                      16
                      (make-color 255 255 255 200))
        (draw-rectangle-outline +hex-labeler-preview-x+
                                (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 80)
                                318
                                38
                                (make-color 255 255 255 220)
                                :thickness 2)
        (draw-text-at (format nil "~a_" *hex-labeler-label-input*)
                      (+ +hex-labeler-preview-x+ 12)
                      (+ +hex-labeler-preview-y+ +hex-labeler-preview-size+ 90)
                      20
                      *hex-labeler-white*))))
  (hex-labeler-draw-status
   (format nil "type label   ENTER save   N skip   P/left previous   right next   ESC menu   ~a"
           *hex-labeler-message*)))


;;; Done phase and entry points

(-> update-hex-labeler-done () t)
(defun update-hex-labeler-done ()
  (cond
    ((or (is-key-pressed-p +key-escape+)
         (is-key-pressed-p +key-enter+)
         (is-key-pressed-p +key-kp-enter+))
     (hex-labeler-exit-to-menu))
    ((and *hex-labeler-tiles*
          (is-key-pressed-p +key-p+))
     (setf *hex-labeler-phase* :label)
     (hex-labeler-set-label-index (1- (length *hex-labeler-tiles*)))
     (play-choice-switch))))

(-> draw-hex-labeler-done () t)
(defun draw-hex-labeler-done ()
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 255)))
  (draw-centered-text "HEXANY TILE LABELS"
                      +virtual-center-x+
                      220
                      30
                      *hex-labeler-white*)
  (draw-centered-text (or *hex-labeler-message*
                          "all visible tiles are handled")
                      +virtual-center-x+
                      280
                      20
                      (make-color 255 255 255 220))
  (draw-centered-text (format nil "~d labels, ~d skipped"
                              (length *hex-labeler-labels*)
                              (length *hex-labeler-skips*))
                      +virtual-center-x+
                      326
                      18
                      (make-color 255 255 255 180))
  (draw-centered-text "ENTER/ESC MENU   P LAST TILE"
                      +virtual-center-x+
                      390
                      16
                      (make-color 255 255 255 160)))

(-> open-hexany-labeler (&key (:auto-p boolean)) t)
(defun open-hexany-labeler (&key auto-p)
  (when auto-p
    (setf *hex-labeler-auto-shown-p* t))
  (hex-labeler-load-data)
  (hex-labeler-load-sheets)
  (setf *hex-labeler-active-p* t
        *suppress-window-shortcuts-p* t
        *hex-labeler-phase* :crop
        *hex-labeler-sheet-index* 0
        *hex-labeler-crop-col* 0
        *hex-labeler-crop-row* 0
        *hex-labeler-index* 0
        *hex-labeler-label-input* ""
        *hex-labeler-message* "")
  (hex-labeler-clamp-crop-selection)
  (play-choice-switch))

(-> maybe-open-startup-hexany-labeler () boolean)
(defun maybe-open-startup-hexany-labeler ()
  (when (and (not *hex-labeler-auto-shown-p*)
             (hex-labeler-startup-needed-p))
    (open-hexany-labeler :auto-p t)
    t))

(-> update-hexany-labeler () t)
(defun update-hexany-labeler ()
  (handler-case
      (case *hex-labeler-phase*
        (:crop (update-hex-labeler-crop))
        (:label (update-hex-labeler-label))
        (:done (update-hex-labeler-done))
        (t (setf *hex-labeler-phase* :crop)))
    (error (condition)
      (runtime-warn "Hexany labeler update failed: ~a" condition))))

(-> draw-hexany-labeler () t)
(defun draw-hexany-labeler ()
  (handler-case
      (case *hex-labeler-phase*
        (:crop (draw-hex-labeler-crop))
        (:label (draw-hex-labeler-label))
        (:done (draw-hex-labeler-done))
        (t (draw-hex-labeler-crop)))
    (error (condition)
      (runtime-warn "Hexany labeler draw failed: ~a" condition)
      (clear-background :color +black+))))
