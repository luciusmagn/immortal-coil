(in-package #:immortal-coil)

;;; ----------------------------------------------------------------------------
;;; Scene Builder: an in-menu tile editor over the Kenney 1-bit atlas. Build a
;;; scene on a grid, then label the tiles you used (one by one, with the build
;;; still visible). Conflicting tile names are rejected. Everything autosaves:
;;; the scene to save/scenes/<name>.scene, the labels to save/tile-labels.lisp.
;;;
;;; Build controls: left-click canvas places the brush, right-click erases;
;;; left-click the palette picks a tile. WASD/arrows pan the canvas, Q/E pan the
;;; palette. R rotates the brush, M mirrors it. F starts labelling. ESC opens a
;;; pause menu (resume / fullscreen / resolution / exit). F11 toggles fullscreen
;;; anywhere. A cell stores (tcol trow rotation flip).
;;; ----------------------------------------------------------------------------

(defconstant +sb-atlas-cols+ 48)
(defconstant +sb-atlas-rows+ 22)
(defconstant +sb-atlas-tile+ 16)
(defconstant +sb-grid-w+ 64)
(defconstant +sb-grid-h+ 48)
(defconstant +sb-canvas-x+ 16)
(defconstant +sb-canvas-y+ 44)
(defconstant +sb-canvas-cell+ 28)
(defconstant +sb-canvas-cols+ 30)
(defconstant +sb-canvas-rows+ 20)
(defconstant +sb-pal-x+ 880)
(defconstant +sb-pal-y+ 44)
(defconstant +sb-pal-cell+ 24)
(defconstant +sb-pal-cols+ 16)
(defconstant +sb-pal-rows+ 22)

(defvar *sb-active-p* nil)
(defvar *sb-phase* :name)               ; :name | :build | :label
(defvar *sb-paused-p* nil)
(defvar *sb-pause-sel* 0)
(defvar *sb-name* "")
(defvar *sb-existing* nil)
(defvar *sb-name-sel* -1)
(defvar *sb-grid* nil)                  ; 2D array, each cell nil or (tcol trow rot flip)
(defvar *sb-cam-x* 0)
(defvar *sb-cam-y* 0)
(defvar *sb-sel* (cons 1 0))            ; selected palette tile (tcol . trow)
(defvar *sb-rot* 0)                     ; brush rotation 0/90/180/270
(defvar *sb-flip* nil)                  ; brush horizontal mirror
(defvar *sb-pal-col* 0)
(defvar *sb-label-tiles* nil)
(defvar *sb-label-i* 0)
(defvar *sb-label-input* "")
(defvar *sb-labels* nil)                ; alist ((tcol trow) . "name")
(defvar *sb-message* "")
(defvar *sb-atlas* nil)
(defvar *sb-white* (make-color 255 255 255 255))

;;; --- atlas ---

(defun clear-sb-atlas ()
  (setf *sb-atlas* nil))

(defun sb-atlas ()
  (cond
    ((eq *sb-atlas* :none) nil)
    (*sb-atlas* *sb-atlas*)
    (t
     (let ((path (project-pathname "assets/tiles/kenney-1bit-mono.png")))
       (handler-case
           (if (probe-file path)
               (let ((obj (make-texture (make-texture-asset path :load-now t)
                                        0.0 0.0 :width 16.0 :height 16.0
                                        :tint (make-color 255 255 255 255))))
                 (setf (source obj) (make-instance 'rl-rectangle
                                                   :x 0.0 :y 0.0
                                                   :width 16.0 :height 16.0)
                       (origin obj) (make-vector2 0.0 0.0))
                 (ignore-errors
                  (claylib/ll:set-texture-filter (claylib::c-asset obj)
                                                 +texture-filter-point+))
                 (setf *sb-atlas* obj))
               (setf *sb-atlas* :none))
         (error (c)
           (runtime-warn "Scene Builder atlas load failed: ~a" c)
           (setf *sb-atlas* :none)))))))

(defparameter *sb-tile-crop* 2
  "Pixels trimmed off each tile edge. Every tile in this atlas has a uniform 1px
transparent + 1px black frame; trimming it lets the inner art fill the cell so
placed tiles butt together seamlessly. Tunable if the frame turns out thicker.")

(defun sb-draw-tile (col row x y size &key tint (rot 0) flip)
  "Blit atlas tile (COL,ROW) centred on the SIZE cell at SX,SY, with its border
frame cropped so the content fills the cell, optionally rotated (a multiple of
90, pivoting on the cell centre) and/or horizontally mirrored."
  (let ((atlas (sb-atlas)))
    (when atlas
      (let* ((src (source atlas)) (dst (dest atlas))
             (half (/ size 2.0))
             (k *sb-tile-crop*)
             (inner (- +sb-atlas-tile+ (* 2 k))))
        (setf (x src) (float (+ (* col +sb-atlas-tile+) k) 1.0)
              (y src) (float (+ (* row +sb-atlas-tile+) k) 1.0)
              (width src) (float (if flip (- inner) inner) 1.0)
              (height src) (float inner 1.0)
              (x dst) (float (+ x half) 1.0)        ; pin to the cell centre
              (y dst) (float (+ y half) 1.0)
              (width dst) (float size 1.0)
              (height dst) (float size 1.0)
              (origin atlas) (make-vector2 half half)
              (rot atlas) (float rot 1.0)
              (tint atlas) (or tint *sb-white*))
        (draw-object atlas)))))

;;; --- persistence (autosave) ---

(defun sb-save-root ()
  (let ((d (uiop:getenv "IMMORTAL_COIL_SAVE_DIR")))
    (if d (uiop:ensure-directory-pathname d) (project-pathname "save/"))))

(defun sb-scene-path (name)
  (merge-pathnames (format nil "scenes/~a.scene" name) (sb-save-root)))

(defun sb-labels-path ()
  (merge-pathnames "tile-labels.lisp" (sb-save-root)))

(defun sb-list-scenes ()
  (handler-case
      (sort (mapcar #'pathname-name
                    (directory (merge-pathnames "scenes/*.scene" (sb-save-root))))
            #'string<)
    (error () nil)))

(defun sb-blank-grid ()
  (make-array (list +sb-grid-h+ +sb-grid-w+) :initial-element nil))

(defun sb-save-scene ()
  (when (plusp (length *sb-name*))
    (handler-case
        (let ((path (sb-scene-path *sb-name*)) (cells nil))
          (dotimes (r +sb-grid-h+)
            (dotimes (c +sb-grid-w+)
              (let ((cell (aref *sb-grid* r c)))
                (when cell
                  (push (list c r (first cell) (second cell)
                              (third cell) (and (fourth cell) t))
                        cells)))))
          (ensure-directories-exist path)
          (with-open-file (s path :direction :output :if-exists :supersede
                                  :if-does-not-exist :create)
            (with-standard-io-syntax
              (let ((*print-readably* t))
                (print (list :name *sb-name* :cells cells) s)))))
      (error (c) (runtime-warn "Scene save failed: ~a" c)))))

(defun sb-load-scene (name)
  (setf *sb-grid* (sb-blank-grid))
  (handler-case
      (let ((path (sb-scene-path name)))
        (when (probe-file path)
          (with-open-file (s path)
            (with-standard-io-syntax
              (let ((data (read s nil nil)))
                (dolist (cell (getf data :cells))
                  (destructuring-bind (c r tc tr &optional (rot 0) flip) cell
                    (when (and (< -1 c +sb-grid-w+) (< -1 r +sb-grid-h+))
                      (setf (aref *sb-grid* r c) (list tc tr rot flip))))))))))
    (error (c) (runtime-warn "Scene load failed: ~a" c))))

(defun sb-save-labels ()
  (handler-case
      (let ((path (sb-labels-path)))
        (ensure-directories-exist path)
        (with-open-file (s path :direction :output :if-exists :supersede
                                :if-does-not-exist :create)
          (with-standard-io-syntax
            (let ((*print-readably* t)) (print *sb-labels* s)))))
    (error (c) (runtime-warn "Label save failed: ~a" c))))

(defun sb-load-labels ()
  (setf *sb-labels*
        (handler-case
            (let ((path (sb-labels-path)))
              (when (probe-file path)
                (with-open-file (s path)
                  (with-standard-io-syntax (read s nil nil)))))
          (error () nil))))

;;; --- shared helpers ---

(defun sb-accept-typing (current)
  (let ((s current))
    (loop for code = (get-char-pressed)
          until (zerop code)
          for ch = (ignore-errors (code-char code))
          when (and ch (string-input-character-p ch))
            do (setf s (concatenate 'string s (string ch))))
    (when (and (is-key-pressed-p +key-backspace+) (plusp (length s)))
      (setf s (subseq s 0 (1- (length s)))))
    s))

(defun sb-distinct-tiles ()
  "Distinct (tcol . trow) ids used in the grid (rotation/mirror ignored)."
  (let ((seen (make-hash-table :test #'equal)) (out nil))
    (dotimes (r +sb-grid-h+)
      (dotimes (c +sb-grid-w+)
        (let ((cell (aref *sb-grid* r c)))
          (when cell
            (let ((id (cons (first cell) (second cell))))
              (unless (gethash id seen)
                (setf (gethash id seen) t)
                (push id out)))))))
    (nreverse out)))

(defun sb-exit-to-menu ()
  (sb-save-scene)
  (setf *sb-active-p* nil
        *sb-paused-p* nil
        *suppress-window-shortcuts-p* nil
        *sb-message* ""))

;;; --- name phase ---

(defun sb-enter-build (name)
  (setf *sb-name* name)
  (sb-load-scene name)
  (setf *sb-cam-x* 0 *sb-cam-y* 0 *sb-phase* :build
        *sb-message* (format nil "editing ~s" name)))

(defun update-sb-name ()
  (cond
    ((is-key-pressed-p +key-escape+) (sb-exit-to-menu))
    (t
     (when (or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
       (decf *sb-name-sel*))
     (when (or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
       (incf *sb-name-sel*))
     (setf *sb-name-sel* (max -1 (min *sb-name-sel* (1- (length *sb-existing*)))))
     (when (minusp *sb-name-sel*)
       (setf *sb-name* (sb-accept-typing *sb-name*)))
     (when (or (is-key-pressed-p +key-enter+) (is-key-pressed-p +key-kp-enter+))
       (cond
         ((and (>= *sb-name-sel* 0) (< *sb-name-sel* (length *sb-existing*)))
          (sb-enter-build (nth *sb-name-sel* *sb-existing*)))
         ((plusp (length (string-trim " " *sb-name*)))
          (sb-enter-build (string-trim " " *sb-name*))))))))

(defun draw-sb-name ()
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 255)))
  (draw-centered-text "SCENE BUILDER" +virtual-center-x+ 120 32 *sb-white*)
  (draw-centered-text "type a new scene name (ENTER), or pick one below; ESC to leave"
                      +virtual-center-x+ 168 16 (make-color 255 255 255 170))
  (let ((field-y 220) (sel (minusp *sb-name-sel*)))
    (draw-rectangle-outline 360 (- field-y 6) 560 36
                            (make-color 255 255 255 (if sel 255 120)) :thickness 2)
    (draw-text-at (format nil "new: ~a~a" *sb-name* (if sel "_" ""))
                  376 field-y 20 (make-color 255 255 255 (if sel 255 150))))
  (draw-text-at "existing scenes:" 360 280 16 (make-color 255 255 255 180))
  (if (null *sb-existing*)
      (draw-text-at "(none yet)" 380 312 16 (make-color 255 255 255 120))
      (loop for nm in *sb-existing*
            for i from 0
            for y = (+ 310 (* i 30))
            for sel = (= i *sb-name-sel*)
            do (when sel
                 (claylib/ll:draw-rectangle 360 (- y 4) 560 26
                                            (claylib::c-ptr (make-color 255 255 255 40))))
               (draw-text-at (format nil "~a~a" (if sel "> " "  ") nm)
                             380 y 18 (make-color 255 255 255 (if sel 255 170))))))

;;; --- build phase ---

(defun sb-canvas-cell-at (mx my)
  (when (and (<= +sb-canvas-x+ mx (+ +sb-canvas-x+ (* +sb-canvas-cols+ +sb-canvas-cell+)))
             (<= +sb-canvas-y+ my (+ +sb-canvas-y+ (* +sb-canvas-rows+ +sb-canvas-cell+))))
    (let ((c (+ *sb-cam-x* (floor (- mx +sb-canvas-x+) +sb-canvas-cell+)))
          (r (+ *sb-cam-y* (floor (- my +sb-canvas-y+) +sb-canvas-cell+))))
      (when (and (< -1 c +sb-grid-w+) (< -1 r +sb-grid-h+))
        (cons c r)))))

(defun sb-palette-tile-at (mx my)
  (when (and (<= +sb-pal-x+ mx (+ +sb-pal-x+ (* +sb-pal-cols+ +sb-pal-cell+)))
             (<= +sb-pal-y+ my (+ +sb-pal-y+ (* +sb-pal-rows+ +sb-pal-cell+))))
    (let ((c (+ *sb-pal-col* (floor (- mx +sb-pal-x+) +sb-pal-cell+)))
          (r (floor (- my +sb-pal-y+) +sb-pal-cell+)))
      (when (and (< -1 c +sb-atlas-cols+) (< -1 r +sb-atlas-rows+))
        (cons c r)))))

(defun sb-begin-label ()
  (let ((tiles (sb-distinct-tiles)))
    (if (null tiles)
        (setf *sb-message* "place some tiles first")
        (setf *sb-label-tiles* tiles
              *sb-label-i* 0
              *sb-label-input* (or (cdr (assoc (first tiles) *sb-labels* :test #'equal)) "")
              *sb-phase* :label
              *sb-message* ""))))

(defun update-sb-build ()
  (cond
    ((is-key-pressed-p +key-escape+) (setf *sb-paused-p* t *sb-pause-sel* 0))
    ((is-key-pressed-p +key-f+) (sb-begin-label))
    (t
     (when (is-key-pressed-p +key-r+) (setf *sb-rot* (mod (+ *sb-rot* 90) 360)))
     (when (is-key-pressed-p +key-m+) (setf *sb-flip* (not *sb-flip*)))
     (when (or (is-key-down-p +key-d+) (is-key-down-p +key-right+))
       (setf *sb-cam-x* (min (- +sb-grid-w+ +sb-canvas-cols+) (1+ *sb-cam-x*))))
     (when (or (is-key-down-p +key-a+) (is-key-down-p +key-left+))
       (setf *sb-cam-x* (max 0 (1- *sb-cam-x*))))
     (when (or (is-key-down-p +key-s+) (is-key-down-p +key-down+))
       (setf *sb-cam-y* (min (- +sb-grid-h+ +sb-canvas-rows+) (1+ *sb-cam-y*))))
     (when (or (is-key-down-p +key-w+) (is-key-down-p +key-up+))
       (setf *sb-cam-y* (max 0 (1- *sb-cam-y*))))
     (when (is-key-down-p +key-e+)
       (setf *sb-pal-col* (min (- +sb-atlas-cols+ +sb-pal-cols+) (1+ *sb-pal-col*))))
     (when (is-key-down-p +key-q+)
       (setf *sb-pal-col* (max 0 (1- *sb-pal-col*))))
     (let ((mx (virtual-mouse-x)) (my (virtual-mouse-y)))
       (when (is-mouse-button-down-p +mouse-button-left+)
         (let ((pal (sb-palette-tile-at mx my)))
           (if pal
               (setf *sb-sel* pal)
               (let ((cell (sb-canvas-cell-at mx my)))
                 (when cell
                   (setf (aref *sb-grid* (cdr cell) (car cell))
                         (list (car *sb-sel*) (cdr *sb-sel*) *sb-rot* (and *sb-flip* t)))
                   (sb-save-scene))))))
       (when (is-mouse-button-down-p +mouse-button-right+)
         (let ((cell (sb-canvas-cell-at mx my)))
           (when (and cell (aref *sb-grid* (cdr cell) (car cell)))
             (setf (aref *sb-grid* (cdr cell) (car cell)) nil)
             (sb-save-scene))))))))

(defun draw-sb-cell (cell sx sy size)
  (when cell
    (sb-draw-tile (first cell) (second cell) sx sy size
                  :rot (third cell) :flip (fourth cell))))

(defun draw-sb-canvas (&optional dim)
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 255)))
  (claylib/ll:draw-rectangle +sb-canvas-x+ +sb-canvas-y+
                             (* +sb-canvas-cols+ +sb-canvas-cell+)
                             (* +sb-canvas-rows+ +sb-canvas-cell+)
                             (claylib::c-ptr (make-color 18 18 22 255)))
  (loop for vr below +sb-canvas-rows+ do
    (loop for vc below +sb-canvas-cols+
          for c = (+ *sb-cam-x* vc)
          for r = (+ *sb-cam-y* vr)
          for sx = (+ +sb-canvas-x+ (* vc +sb-canvas-cell+))
          for sy = (+ +sb-canvas-y+ (* vr +sb-canvas-cell+))
          when (and (< c +sb-grid-w+) (< r +sb-grid-h+))
            do (let ((cell (aref *sb-grid* r c)))
                 ;; no gridlines at all in the editing zone - just the tiles
                 (when cell
                   (draw-sb-cell cell sx sy +sb-canvas-cell+))
                 (when (and dim cell)
                   (claylib/ll:draw-rectangle sx sy +sb-canvas-cell+ +sb-canvas-cell+
                                              (claylib::c-ptr (make-color 0 0 0 130))))))))

(defun draw-sb-palette ()
  (claylib/ll:draw-rectangle (- +sb-pal-x+ 6) (- +sb-pal-y+ 28)
                             (+ (* +sb-pal-cols+ +sb-pal-cell+) 12)
                             (+ (* +sb-pal-rows+ +sb-pal-cell+) 40)
                             (claylib::c-ptr (make-color 12 12 16 255)))
  (draw-text-at (format nil "tiles  (Q/E pan)  cols ~a-~a"
                        *sb-pal-col* (+ *sb-pal-col* +sb-pal-cols+ -1))
                +sb-pal-x+ (- +sb-pal-y+ 24) 15 (make-color 255 255 255 170))
  (loop for r below +sb-pal-rows+ do
    (loop for vc below +sb-pal-cols+
          for c = (+ *sb-pal-col* vc)
          for sx = (+ +sb-pal-x+ (* vc +sb-pal-cell+))
          for sy = (+ +sb-pal-y+ (* r +sb-pal-cell+))
          when (< c +sb-atlas-cols+)
            do (claylib/ll:draw-rectangle sx sy +sb-pal-cell+ +sb-pal-cell+
                                          (claylib::c-ptr (make-color 40 40 46 255)))
               (sb-draw-tile c r sx sy +sb-pal-cell+)
               (when (and (= c (car *sb-sel*)) (= r (cdr *sb-sel*)))
                 (draw-rectangle-outline sx sy +sb-pal-cell+ +sb-pal-cell+
                                         (yellow-sign-color 255) :thickness 2)))))

(defun draw-sb-status (text)
  (claylib/ll:draw-rectangle 0 (- +virtual-height+ 30) +virtual-width+ 30
                             (claylib::c-ptr (make-color 0 0 0 220)))
  (draw-text-at text 16 (- +virtual-height+ 24) 15 (make-color 255 255 255 200)))

(defun draw-sb-build ()
  (draw-sb-canvas)
  (draw-sb-palette)
  ;; brush preview with the current rotation/mirror
  (sb-draw-tile (car *sb-sel*) (cdr *sb-sel*) +sb-pal-x+ (- +virtual-height+ 92) 64
                :rot *sb-rot* :flip *sb-flip*)
  (draw-text-at (format nil "brush ~a,~a  rot ~a~a"
                        (car *sb-sel*) (cdr *sb-sel*) *sb-rot*
                        (if *sb-flip* "  mirrored" ""))
                (+ +sb-pal-x+ 74) (- +virtual-height+ 78) 16 (make-color 255 255 255 200))
  (draw-text-at (format nil "SCENE BUILDER - ~a" *sb-name*) 16 12 20 *sb-white*)
  (draw-sb-status
   (format nil "click place / pick   R-click erase   WASD pan   Q/E palette   R rotate   M mirror   F label   ESC menu   ~a"
           *sb-message*)))

;;; --- pause menu ---

(defparameter *sb-pause-items*
  '("RESUME" "FULLSCREEN" "RESOLUTION" "EXIT TO MENU"))

(defun update-sb-pause ()
  (cond
    ((is-key-pressed-p +key-escape+) (setf *sb-paused-p* nil))
    (t
     (when (or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+)) (decf *sb-pause-sel*))
     (when (or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+)) (incf *sb-pause-sel*))
     (setf *sb-pause-sel* (mod *sb-pause-sel* (length *sb-pause-items*)))
     (when (or (is-key-pressed-p +key-enter+) (is-key-pressed-p +key-kp-enter+))
       (case *sb-pause-sel*
         (0 (setf *sb-paused-p* nil))
         (1 (toggle-game-fullscreen))
         (2 (cycle-render-scale 1)
            (setf *requested-window-mode* *window-mode*)
            (save-options))
         (3 (sb-exit-to-menu)))))))

(defun draw-sb-pause ()
  (draw-sb-build)
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 150)))
  (claylib/ll:draw-rectangle 440 220 400 300
                             (claylib::c-ptr (make-color 0 0 0 255)))
  (draw-rectangle-outline 440 220 400 300 (make-color 255 255 255 220) :thickness 2)
  (draw-centered-text "PAUSED" +virtual-center-x+ 256 26 *sb-white*)
  (loop for it in *sb-pause-items*
        for i from 0
        for y = (+ 312 (* i 42))
        for sel = (= i *sb-pause-sel*)
        for label = (cond ((= i 1) (format nil "FULLSCREEN: ~a"
                                           (if (options-fullscreen-enabled-p) "ON" "OFF")))
                          ((= i 2) (format nil "RESOLUTION: ~a" (render-scale-label)))
                          (t it))
        do (when sel
             (claylib/ll:draw-rectangle 470 (- y 8) 340 34
                                        (claylib::c-ptr (make-color 255 255 255 40))))
           (draw-text-at (format nil "~a~a" (if sel "> " "  ") label)
                         492 y 20 (make-color 255 255 255 (if sel 255 170)))))

;;; --- label phase ---

(defun sb-current-label-tile ()
  (nth *sb-label-i* *sb-label-tiles*))

(defun sb-name-conflict-p (name tile)
  (loop for (other . nm) in *sb-labels*
        thereis (and (string-equal nm name) (not (equal other tile)))))

(defun sb-commit-label ()
  (let ((tile (sb-current-label-tile))
        (name (string-trim " " *sb-label-input*)))
    (cond
      ((zerop (length name)) (setf *sb-message* "name cannot be empty"))
      ((sb-name-conflict-p name tile)
       (setf *sb-message* (format nil "\"~a\" is already used by another tile" name)))
      (t
       (setf *sb-labels* (remove tile *sb-labels* :key #'car :test #'equal))
       (push (cons tile name) *sb-labels*)
       (sb-save-labels)
       (if (< (1+ *sb-label-i*) (length *sb-label-tiles*))
           (progn (incf *sb-label-i*)
                  (setf *sb-label-input*
                        (or (cdr (assoc (sb-current-label-tile) *sb-labels* :test #'equal)) "")
                        *sb-message* "saved"))
           (setf *sb-message* "all tiles labelled - ESC to finish"))))))

(defun update-sb-label ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (setf *sb-phase* :build *sb-message* "back to building"))
    ((or (is-key-pressed-p +key-enter+) (is-key-pressed-p +key-kp-enter+))
     (sb-commit-label))
    (t (setf *sb-label-input* (sb-accept-typing *sb-label-input*)))))

(defun draw-sb-label ()
  (draw-sb-canvas t)
  (let ((tile (sb-current-label-tile)))
    (loop for vr below +sb-canvas-rows+ do
      (loop for vc below +sb-canvas-cols+
            for c = (+ *sb-cam-x* vc) for r = (+ *sb-cam-y* vr)
            for cell = (and (< c +sb-grid-w+) (< r +sb-grid-h+) (aref *sb-grid* r c))
            when (and cell (= (first cell) (car tile)) (= (second cell) (cdr tile)))
              do (draw-rectangle-outline (+ +sb-canvas-x+ (* vc +sb-canvas-cell+))
                                         (+ +sb-canvas-y+ (* vr +sb-canvas-cell+))
                                         +sb-canvas-cell+ +sb-canvas-cell+
                                         (yellow-sign-color 255) :thickness 2)))
    (claylib/ll:draw-rectangle 760 250 480 220
                               (claylib::c-ptr (make-color 0 0 0 255)))
    (draw-rectangle-outline 760 250 480 220 (make-color 255 255 255 220) :thickness 2)
    (draw-centered-text (format nil "LABEL TILE ~a / ~a"
                                (1+ *sb-label-i*) (length *sb-label-tiles*))
                        1000 286 22 *sb-white*)
    (sb-draw-tile (car tile) (cdr tile) 968 312 64)
    (draw-text-at (format nil "tile ~a,~a" (car tile) (cdr tile))
                  900 410 15 (make-color 255 255 255 160))
    (draw-rectangle-outline 800 392 400 34 (make-color 255 255 255 200) :thickness 2)
    (draw-text-at (format nil "~a_" *sb-label-input*) 812 400 18 *sb-white*))
  (draw-sb-status
   (format nil "type a name, ENTER to save (must be unique), ESC back to build   ~a"
           *sb-message*)))

;;; --- entry / dispatch ---

(defun open-scene-builder ()
  (sb-load-labels)
  (setf *sb-active-p* t
        *suppress-window-shortcuts-p* t
        *sb-paused-p* nil
        *sb-phase* :name
        *sb-name* ""
        *sb-name-sel* -1
        *sb-existing* (sb-list-scenes)
        *sb-grid* (sb-blank-grid)
        *sb-rot* 0
        *sb-flip* nil
        *sb-message* "")
  (play-choice-switch))

(defun update-scene-builder ()
  (handler-case
      (if *sb-paused-p*
          (update-sb-pause)
          (case *sb-phase*
            (:name (update-sb-name))
            (:build (update-sb-build))
            (:label (update-sb-label))))
    (error (c) (runtime-warn "Scene Builder update failed: ~a" c))))

(defun draw-scene-builder ()
  (handler-case
      (cond
        (*sb-paused-p* (draw-sb-pause))
        (t (case *sb-phase*
             (:name (draw-sb-name))
             (:build (draw-sb-build))
             (:label (draw-sb-label)))))
    (error (c)
      (runtime-warn "Scene Builder draw failed: ~a" c)
      (clear-background :color +black+))))
