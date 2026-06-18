(in-package #:immortal-coil)

;;; State

(defparameter *menu-selection*
  (make-command-selection :new-game "NEW GAME"
                          :continue "CONTINUE"
                          :load-game "LOAD GAME"
                          :options "OPTIONS"
                          :mods "MODS"
                          :exit "EXIT"))

(defparameter *mods-menu-selection*
  (make-command-selection :mod-list "MOD LIST"
                          :edit-base "EDIT BASE GAME"
                          :create-mod "CREATE MOD"
                          :edit-mod "EDIT MOD"
                          :refresh "REFRESH"
                          :back "BACK"))

(defvar *menu-status-message* nil)
(defvar *mods-menu-active-p* nil)
(defvar *mod-list-active-p* nil)
(defvar *load-menu-active-p* nil)
(defvar *menu-pending-slot* nil)
(defvar *load-menu-delete-pending-slot* nil)

(defparameter *load-menu-panel*
  (make-instance 'list-panel
                 :title "LOAD GAME"
                 :empty-text "no saved games yet"
                 :footer "RET LOAD  D/DEL DELETE  ESC BACK"
                 :width 620))

(defparameter *mod-list-panel*
  (make-instance 'list-panel
                 :title "MOD LIST"
                 :empty-text "no mods found"
                 :footer "RET TOGGLE  R REFRESH  ESC BACK"
                 :width 760
                 :visible-rows 10))

(defconstant +mods-menu-panel-width+ 560)
(defconstant +mods-menu-panel-height+ 440)
(defconstant +mods-menu-panel-top+ 172)

(-> current-mod-status-text () string)
(defun current-mod-status-text ()
  (if (fboundp 'dialog-mod-status-summary)
      (funcall (symbol-function 'dialog-mod-status-summary))
      "MODS: UNAVAILABLE"))

(-> menu-option-count () nonnegative-integer)
(defun menu-option-count ()
  (selection-count *menu-selection*))

(-> menu-option (integer) (option command-option))
(defun menu-option (index)
  (selection-item *menu-selection* index))

(-> selected-menu-option () (option command-option))
(defun selected-menu-option ()
  (selection-current *menu-selection*))

(-> selected-menu-action () (option command-action))
(defun selected-menu-action ()
  (selection-current-action *menu-selection*))

(-> selected-menu-label () string)
(defun selected-menu-label ()
  (selection-current-label *menu-selection*))

(-> selected-mods-action () (option command-action))
(defun selected-mods-action ()
  (selection-current-action *mods-menu-selection*))

(-> mods-menu-option-count () nonnegative-integer)
(defun mods-menu-option-count ()
  (selection-count *mods-menu-selection*))

(-> mods-menu-option (integer) (option command-option))
(defun mods-menu-option (index)
  (selection-item *mods-menu-selection* index))

(-> reset-menu-state () selection-model)
(defun reset-menu-state ()
  (setf *menu-elapsed* 0.0
        *menu-start-action* nil
        *menu-start-state* :idle
        *menu-start-elapsed* 0.0
        *menu-status-message* (current-mod-status-text)
        *mods-menu-active-p* nil
        *mod-list-active-p* nil
        *load-menu-active-p* nil
        *menu-pending-slot* nil
        *load-menu-delete-pending-slot* nil)
  (selection-reset *mods-menu-selection*)
  (selection-reset *menu-selection*))

(-> menu-action-available-p (t) boolean)
(defun menu-action-available-p (action)
  (case action
    (:continue (save-game-exists-p))
    (:load-game (not (null (list-save-slots))))
    (t t)))

(-> selected-menu-action-available-p () boolean)
(defun selected-menu-action-available-p ()
  (menu-action-available-p (selected-menu-action)))


;;; Geometry

(-> menu-option-text-width () nonnegative-integer)
(defun menu-option-text-width ()
  (text-width (selected-menu-label) *menu-start-text-size*))

(-> menu-option-bounds () (values scalar scalar scalar scalar))
(defun menu-option-bounds ()
  (let ((width (menu-option-text-width))
        (height *menu-start-text-size*))
    (values (- +menu-start-x+ (/ width 2) 18)
            (- +menu-start-y+ (/ height 2) 14)
            (+ width 36)
            (+ height 28))))

(-> point-in-rect-p (scalar scalar scalar scalar scalar scalar) boolean)
(defun point-in-rect-p (x y left top width height)
  (and (>= x left)
       (<= x (+ left width))
       (>= y top)
       (<= y (+ top height))))

(-> mouse-on-menu-option-p () boolean)
(defun mouse-on-menu-option-p ()
  (multiple-value-bind (left top width height)
      (menu-option-bounds)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(-> menu-arrow-center-x (menu-direction) scalar)
(defun menu-arrow-center-x (direction)
  (+ +menu-start-x+
     (* direction (+ +title-orbit-radius+ 86.0))))

(-> menu-arrow-bounds (menu-direction) (values scalar scalar scalar scalar))
(defun menu-arrow-bounds (direction)
  (let ((x (menu-arrow-center-x direction))
        (size 54.0))
    (values (- x (/ size 2))
            (- +menu-start-y+ (/ size 2))
            size
            size)))

(-> mouse-on-menu-arrow-p (menu-direction) boolean)
(defun mouse-on-menu-arrow-p (direction)
  (multiple-value-bind (left top width height)
      (menu-arrow-bounds direction)
    (point-in-rect-p (virtual-mouse-x)
                     (virtual-mouse-y)
                     left
                     top
                     width
                     height)))

(-> menu-arrow-pressed-p (menu-direction) boolean)
(defun menu-arrow-pressed-p (direction)
  (or (and (mouse-on-menu-arrow-p direction)
           (is-mouse-button-down-p +mouse-button-left+))
      (if (minusp direction)
          (is-key-down-p +key-left+)
          (is-key-down-p +key-right+))))


;;; Actions

(-> start-new-game () t)
(defun start-new-game ()
  (reset-editor-state)
  (stop-title-music)
  (stop-story-music)
  (setf *active-save-slot* (new-save-slot-id)
        *playtime-seconds* 0.0)
  (load-dialog-graph)
  (reset-particles)
  (unless (restore-dev-save-override)
    (reset-play-state *story-start-node*))
  (setf *save-current-game-p* t)
  (save-current-game)
  (setf *mode* :game
        *game-fade-elapsed* 0.0
        *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0))

(-> continue-game () boolean)
(defun continue-game ()
  (reset-editor-state)
  (load-dialog-graph)
  (reset-particles)
  (when (load-current-game-save)
    (stop-title-music)
    (stop-story-music)
    (setf *save-current-game-p* t
          *mode* :game
          *game-fade-elapsed* 0.0
          *menu-start-state* :idle
          *menu-start-action* nil
          *menu-start-elapsed* 0.0)
    t))

(-> return-to-idle-menu () t)
(defun return-to-idle-menu ()
  (setf *menu-start-state* :idle
        *menu-start-action* nil
        *menu-start-elapsed* 0.0)
  (play-choice-switch))

(-> complete-start-action () t)
(defun complete-start-action ()
  (case *menu-start-action*
    (:new-game (start-new-game))
    (:continue
     (unless (continue-game)
       (return-to-idle-menu)))
    (:load-slot
     (unless (and *menu-pending-slot*
                  (load-slot-game *menu-pending-slot*))
       (return-to-idle-menu)))
    (t
     (return-to-idle-menu))))

(-> begin-start-transition (command-action) t)
(defun begin-start-transition (action)
  (play-start-confirm)
  (setf *menu-start-state* :starting
        *menu-start-action* action
        *menu-start-elapsed* 0.0))

(-> refresh-menu-mod-status () t)
(defun refresh-menu-mod-status ()
  (setf *menu-status-message*
        (if (fboundp 'refresh-dialog-mod-status)
            (funcall (symbol-function 'refresh-dialog-mod-status))
            "MODS: UNAVAILABLE"))
  (load-title-logo)
  (play-choice-switch))

(-> load-menu-selected-slot () (option string))
(defun load-menu-selected-slot ()
  (list-panel-selected-value *load-menu-panel*))

(-> load-menu-delete-pending-p () boolean)
(defun load-menu-delete-pending-p ()
  (and *load-menu-delete-pending-slot*
       (equal *load-menu-delete-pending-slot*
              (load-menu-selected-slot))))

(-> load-menu-footer-text () string)
(defun load-menu-footer-text ()
  (if (load-menu-delete-pending-p)
      "D/DEL CONFIRM DELETE  ESC CANCEL"
      "RET LOAD  D/DEL DELETE  ESC BACK"))

(-> refresh-load-menu-panel () list-panel)
(defun refresh-load-menu-panel ()
  (list-panel-set-items *load-menu-panel*
                        (loop for entry in (list-save-slots)
                              collect (cons (getf entry :slot)
                                            (save-slot-label entry))))
  (setf (list-panel-footer *load-menu-panel*) (load-menu-footer-text))
  *load-menu-panel*)

(-> open-load-menu () t)
(defun open-load-menu ()
  (setf *load-menu-active-p* t
        *load-menu-delete-pending-slot* nil)
  (refresh-load-menu-panel)
  (play-choice-switch))

(-> close-load-menu () t)
(defun close-load-menu ()
  (setf *load-menu-active-p* nil
        *load-menu-delete-pending-slot* nil)
  (play-choice-switch))

(-> load-slot-game (string) boolean)
(defun load-slot-game (slot)
  (reset-editor-state)
  (load-dialog-graph)
  (reset-particles)
  (when (load-game-slot slot)
    (stop-title-music)
    (stop-story-music)
    (setf *save-current-game-p* t
          *load-menu-active-p* nil
          *mode* :game
          *game-fade-elapsed* 0.0
          *menu-start-state* :idle
          *menu-start-action* nil
          *menu-start-elapsed* 0.0)
    t))

(-> load-menu-delete-pressed-p () boolean)
(defun load-menu-delete-pressed-p ()
  (or (is-key-pressed-p +key-d+)
      (is-key-pressed-p +key-delete+)))

(-> request-delete-selected-save () t)
(defun request-delete-selected-save ()
  (let ((slot (load-menu-selected-slot)))
    (cond
      ((null slot)
       (play-choice-switch))
      ((equal slot *load-menu-delete-pending-slot*)
       (when (delete-save-slot slot)
         (setf *load-menu-delete-pending-slot* nil)
         (refresh-load-menu-panel))
       (play-choice-switch))
      (t
       (setf *load-menu-delete-pending-slot* slot)
       (setf (list-panel-footer *load-menu-panel*) (load-menu-footer-text))
       (play-choice-switch)))))

(-> update-load-menu () t)
(defun update-load-menu ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (if *load-menu-delete-pending-slot*
         (progn
           (setf *load-menu-delete-pending-slot* nil)
           (setf (list-panel-footer *load-menu-panel*) (load-menu-footer-text))
           (play-choice-switch))
         (close-load-menu)))
    ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
     (setf *load-menu-delete-pending-slot* nil)
     (when (list-panel-move *load-menu-panel* 1)
       (setf (list-panel-footer *load-menu-panel*) (load-menu-footer-text))
       (play-choice-switch)))
    ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
     (setf *load-menu-delete-pending-slot* nil)
     (when (list-panel-move *load-menu-panel* -1)
       (setf (list-panel-footer *load-menu-panel*) (load-menu-footer-text))
       (play-choice-switch)))
    ((load-menu-delete-pressed-p)
     (request-delete-selected-save))
    ((confirm-pressed-p)
     (let ((slot (load-menu-selected-slot)))
       (if slot
           (progn
             (setf *menu-pending-slot* slot
                   *load-menu-active-p* nil)
             (begin-start-transition :load-slot))
           (close-load-menu))))))

(-> update-mod-list () t)
(defun update-mod-list ()
  (cond
    ((is-key-pressed-p +key-escape+)
     (close-mod-list))
    ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
     (when (list-panel-move *mod-list-panel* 1)
       (play-choice-switch)))
    ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
     (when (list-panel-move *mod-list-panel* -1)
       (play-choice-switch)))
    ((is-key-pressed-p +key-r+)
     (refresh-mod-list-and-status))
    ((confirm-pressed-p)
     (toggle-selected-mod-enabled))))

(-> draw-load-menu () t)
(defun draw-load-menu ()
  (draw-list-panel *load-menu-panel*
                   188
                   (make-color 255
                               255
                               255
                               (round (* 238 (menu-alpha-scale))))))

(-> draw-mod-list () t)
(defun draw-mod-list ()
  (draw-list-panel *mod-list-panel*
                   142
                   (make-color 255
                               255
                               255
                               (round (* 238 (menu-alpha-scale))))))

(-> open-mods-menu () t)
(defun open-mods-menu ()
  (reset-mod-editor-state)
  (setf *mods-menu-active-p* t
        *menu-status-message* (current-mod-status-text))
  (selection-reset *mods-menu-selection*)
  (play-choice-switch))

(-> close-mods-menu () t)
(defun close-mods-menu ()
  (reset-mod-editor-state)
  (setf *mods-menu-active-p* nil
        *mod-list-active-p* nil
        *menu-status-message* (current-mod-status-text))
  (play-choice-switch))

(-> menu-truncate-text (string nonnegative-integer) string)
(defun menu-truncate-text (text max-length)
  (if (<= (length text) max-length)
      text
      (format nil "~a..." (subseq text 0 (max 0 (- max-length 3))))))

(-> mod-list-entry-status-label (mod-list-entry) string)
(defun mod-list-entry-status-label (entry)
  (if (mod-list-entry-enabled-p entry)
      "[ON ]"
      "[OFF]"))

(-> mod-list-entry-label (mod-list-entry) string)
(defun mod-list-entry-label (entry)
  (format nil "~a ~a  ~a"
          (mod-list-entry-status-label entry)
          (menu-truncate-text (mod-list-entry-name entry) 28)
          (menu-truncate-text (mod-list-entry-id entry) 34)))

(-> refresh-mod-list-panel () list-panel)
(defun refresh-mod-list-panel ()
  (list-panel-set-items *mod-list-panel*
                        (loop for entry in (mod-list-entries)
                              collect (cons entry
                                            (mod-list-entry-label entry))))
  *mod-list-panel*)

(-> open-mod-list () t)
(defun open-mod-list ()
  (refresh-mod-list-panel)
  (setf *mod-list-active-p* t)
  (play-choice-switch))

(-> close-mod-list () t)
(defun close-mod-list ()
  (setf *mod-list-active-p* nil
        *menu-status-message* (current-mod-status-text))
  (play-choice-switch))

(-> refresh-mod-list-and-status () t)
(defun refresh-mod-list-and-status ()
  (refresh-mod-list-panel)
  (setf *menu-status-message*
        (if (fboundp 'refresh-dialog-mod-status)
            (funcall (symbol-function 'refresh-dialog-mod-status))
            "MODS: UNAVAILABLE"))
  (load-title-logo)
  (play-choice-switch))

(-> toggle-selected-mod-enabled () t)
(defun toggle-selected-mod-enabled ()
  (let ((entry (list-panel-selected-value *mod-list-panel*)))
    (if entry
        (progn
          (toggle-mod-list-entry entry)
          (refresh-mod-list-and-status))
        (play-choice-switch))))

(-> start-transition-total-seconds () seconds)
(defun start-transition-total-seconds ()
  (+ *start-confirm-seconds* *start-fade-out-seconds*))

(-> menu-start-fade-progress () scalar)
(defun menu-start-fade-progress ()
  (if (eq *menu-start-state* :starting)
      (smoothstep (/ (- *menu-start-elapsed* *start-confirm-seconds*)
                     *start-fade-out-seconds*))
      0.0))

(-> menu-title-music-volume-scale () scalar)
(defun menu-title-music-volume-scale ()
  (- 1.0 (menu-start-fade-progress)))

(-> menu-selection-direction () (option menu-direction))
(defun menu-selection-direction ()
  (cond
    ((is-key-pressed-p +key-right+) 1)
    ((is-key-pressed-p +key-left+) -1)
    ((and (mouse-on-menu-arrow-p 1)
          (is-mouse-button-pressed-p +mouse-button-left+))
     1)
    ((and (mouse-on-menu-arrow-p -1)
          (is-mouse-button-pressed-p +mouse-button-left+))
     -1)))

(-> move-menu-selection ((option menu-direction)) t)
(defun move-menu-selection (direction)
  (when (selection-move *menu-selection* direction)
    (play-choice-switch)))

(-> menu-option-pressed-p () boolean)
(defun menu-option-pressed-p ()
  (or (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-space+)
      (and (mouse-on-menu-option-p)
           (is-mouse-button-pressed-p +mouse-button-left+))))

(-> execute-selected-menu-option () t)
(defun execute-selected-menu-option ()
  (let ((action (selected-menu-action)))
    (case action
      (:exit
       (play-start-confirm)
       (setf *quit-requested-p* t))
      (:mods
       (open-mods-menu))
      (:load-game
       (if (menu-action-available-p :load-game)
           (open-load-menu)
           (play-choice-switch)))
      (:options
       (open-options-menu))
      (t
       (if (menu-action-available-p action)
           (begin-start-transition action)
           (play-choice-switch))))))

(-> mods-menu-selection-direction () (option navigation-direction))
(defun mods-menu-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(-> move-mods-menu-selection ((option navigation-direction)) t)
(defun move-mods-menu-selection (direction)
  (when (selection-move *mods-menu-selection* direction)
    (play-choice-switch)))

(-> execute-selected-mods-menu-option () t)
(defun execute-selected-mods-menu-option ()
  (case (selected-mods-action)
    (:mod-list
     (open-mod-list))
    (:edit-base
     (play-start-confirm)
     (start-base-game-editor))
    (:refresh
     (refresh-menu-mod-status))
    (:back
     (close-mods-menu))
    (:create-mod
     (open-create-mod-editor))
    (:edit-mod
     (open-edit-mod-picker)
     (unless (mod-editor-active-p)
       (setf *menu-status-message* *mod-manifest-status*)))
    (t
     (close-mods-menu))))


;;; Rendering

(-> menu-alpha-scale () scalar)
(defun menu-alpha-scale ()
  (smoothstep (/ *menu-elapsed* *menu-fade-seconds*)))

(-> start-button-flash-scale () scalar)
(defun start-button-flash-scale ()
  (if (eq *menu-start-state* :starting)
      (+ 0.25 (* 0.75
                 (if (< (mod (* *menu-start-elapsed* 10.0) 1.0) 0.5)
                     1.0
                     0.35)))
      1.0))

(-> menu-option-alpha () alpha-channel)
(defun menu-option-alpha ()
  (if (selected-menu-action-available-p)
      245
      112))

(-> draw-menu-option () t)
(defun draw-menu-option ()
  (let* ((alpha-scale (menu-alpha-scale))
         (button-scale (* alpha-scale (start-button-flash-scale)))
         (hovered-p (mouse-on-menu-option-p))
         (base-alpha (if hovered-p 255 (menu-option-alpha)))
         (color (make-color 255 255 255 (round (* base-alpha button-scale)))))
    (draw-centered-text (selected-menu-label)
                        +menu-start-x+
                        +menu-start-y+
                        *menu-start-text-size*
                        color)))

(-> menu-status-text () (option string))
(defun menu-status-text ()
  (when (eq (selected-menu-action) :mods)
    *menu-status-message*))

(-> draw-menu-status () t)
(defun draw-menu-status ()
  (let ((text (menu-status-text)))
    (when text
      (draw-centered-text text
                          +menu-start-x+
                          (+ +menu-start-y+ 42)
                          13
                          (make-color 255
                                      255
                                      255
                                      (round (* 180 (menu-alpha-scale))))))))

(-> draw-menu-arrow-triangle (scalar scalar scalar scalar scalar scalar t) t)
(defun draw-menu-arrow-triangle (x1 y1 x2 y2 x3 y3 color)
  (draw-triangle-points x1 y1 x2 y2 x3 y3 color :filled-p t)
  (draw-triangle-points x1 y1 x3 y3 x2 y2 color :filled-p t))

(-> draw-menu-arrow-shape (menu-direction scalar scalar scalar scalar t) t)
(defun draw-menu-arrow-shape (direction x y width height color)
  (if (minusp direction)
      (draw-menu-arrow-triangle (- x (/ width 2)) y
                                (+ x (/ width 2)) (- y (/ height 2))
                                (+ x (/ width 2)) (+ y (/ height 2))
                                color)
      (draw-menu-arrow-triangle (+ x (/ width 2)) y
                                (- x (/ width 2)) (+ y (/ height 2))
                                (- x (/ width 2)) (- y (/ height 2))
                                color)))

(-> menu-arrow-scale (menu-direction boolean boolean) scalar)
(defun menu-arrow-scale (direction hovered-p pressed-p)
  (let ((pulse (* 0.035
                  (sin (+ (* *menu-elapsed* 2.7)
                          (if (minusp direction) 0.0 pi))))))
    (* (+ 1.0 pulse (if hovered-p 0.055 0.0))
       (if pressed-p 0.86 1.0))))

(-> draw-menu-arrow-bloom
    (menu-direction scalar scalar scalar scalar scalar boolean)
    t)
(defun draw-menu-arrow-bloom (direction x y width height alpha-scale pressed-p)
  (let ((strength (if pressed-p 1.25 1.0)))
    (dolist (layer '((2.20 34) (1.62 62)))
      (destructuring-bind (scale alpha) layer
        (draw-menu-arrow-shape
         direction
         x
         y
         (* width scale)
         (* height scale)
         (make-color 255
                     255
                     255
                     (round (* alpha alpha-scale strength))))))))

(-> draw-menu-arrow (menu-direction) t)
(defun draw-menu-arrow (direction)
  (let* ((alpha-scale (menu-alpha-scale))
         (hovered-p (mouse-on-menu-arrow-p direction))
         (pressed-p (menu-arrow-pressed-p direction))
         (scale (menu-arrow-scale direction hovered-p pressed-p))
         (color (make-color 255 255 255 (round (* 255 alpha-scale))))
         (x (+ (menu-arrow-center-x direction)
               (if pressed-p (* direction 2.0) 0.0)))
         (y +menu-start-y+)
         (w (* 18.0 scale))
         (h (* 26.0 scale)))
    (draw-menu-arrow-bloom direction x y w h alpha-scale pressed-p)
    (draw-menu-arrow-shape direction x y w h color)))

(-> draw-menu-arrows () t)
(defun draw-menu-arrows ()
  (draw-menu-arrow -1)
  (draw-menu-arrow 1))

(-> draw-mods-menu-option (integer scalar t) t)
(defun draw-mods-menu-option (index y color)
  (let ((label (command-option-label (mods-menu-option index)))
        (size 22)
        (selected-p (= index (selection-current-index *mods-menu-selection*))))
    (multiple-value-bind (x text-y width)
        (draw-centered-text label
                            +virtual-center-x+
                            y
                            size
                            color)
      (when selected-p
        (claylib/ll:draw-rectangle (round x)
                                   (round (+ text-y size 5))
                                   (round width)
                                   4
                                   (claylib::c-ptr color))))))

(-> mods-menu-panel-left () scalar)
(defun mods-menu-panel-left ()
  (- +virtual-center-x+ (/ +mods-menu-panel-width+ 2.0)))

(-> mods-menu-panel-bottom () scalar)
(defun mods-menu-panel-bottom ()
  (+ +mods-menu-panel-top+ +mods-menu-panel-height+))

(-> draw-mods-menu-panel () t)
(defun draw-mods-menu-panel ()
  (let ((left (mods-menu-panel-left))
        (top +mods-menu-panel-top+))
    (claylib/ll:draw-rectangle (round left)
                               (round top)
                               +mods-menu-panel-width+
                               +mods-menu-panel-height+
                               (claylib::c-ptr
                                (make-color 0 0 0 255)))
    (draw-rectangle-outline left
                            top
                            +mods-menu-panel-width+
                            +mods-menu-panel-height+
                            (make-color 255 255 255 255)
                            :thickness 2)))

(-> draw-mods-menu-options (t) t)
(defun draw-mods-menu-options (color)
  (let ((start-y (+ +mods-menu-panel-top+ 134))
        (spacing 44.0))
    (loop for i below (mods-menu-option-count)
          do (draw-mods-menu-option i
                                    (+ start-y (* i spacing))
                                    color))))

(-> draw-mods-menu-status (t) t)
(defun draw-mods-menu-status (color)
  (when *menu-status-message*
    (draw-centered-text *menu-status-message*
                        +virtual-center-x+
                        (- (mods-menu-panel-bottom) 42)
                        13
                        color)))

(-> draw-mods-menu () t)
(defun draw-mods-menu ()
  (let ((color (make-color 255
                           255
                           255
                           (round (* 238 (menu-alpha-scale))))))
    (draw-mods-menu-panel)
    (draw-centered-text "MODS"
                        +virtual-center-x+
                        (+ +mods-menu-panel-top+ 58)
                        28
                        color)
    (draw-mods-menu-options color)
    (draw-mods-menu-status
     (make-color 255
                 255
                 255
                 (round (* 170 (menu-alpha-scale)))))))

(-> draw-menu () t)
(defun draw-menu ()
  (draw-title-logo (menu-alpha-scale))
  (draw-particles (menu-alpha-scale))
  (cond
    ((options-menu-active-p)
     (draw-options-menu))
    ((and *mods-menu-active-p*
          (mod-editor-active-p))
     (draw-mod-editor))
    ((and *mods-menu-active-p*
          *mod-list-active-p*)
     (draw-mod-list))
    (*mods-menu-active-p*
     (draw-mods-menu))
    (*load-menu-active-p*
     (draw-load-menu))
    (t
     (draw-menu-arrows)
     (draw-menu-option)
     (draw-menu-status))))


;;; Updating

(-> update-menu (seconds) t)
(defun update-menu (dt)
  (incf *menu-elapsed* dt)
  (set-title-music-volume-scale (menu-title-music-volume-scale))
  (update-particles dt)
  (case *menu-start-state*
    (:idle
     (cond
       ((options-menu-active-p)
        (update-options-menu))
       (*mods-menu-active-p*
        (update-mods-menu))
       (*load-menu-active-p*
        (update-load-menu))
       (t
        (move-menu-selection (menu-selection-direction))
        (when (menu-option-pressed-p)
          (execute-selected-menu-option)))))
    (:starting
     (incf *menu-start-elapsed* dt)
     (when (>= *menu-start-elapsed* (start-transition-total-seconds))
       (complete-start-action)))))

(-> update-mods-menu () t)
(defun update-mods-menu ()
  (cond
    (*mod-list-active-p*
     (update-mod-list))
    ((mod-editor-active-p)
     (update-mod-editor))
    ((is-key-pressed-p +key-escape+)
     (close-mods-menu))
    (t
     (move-mods-menu-selection (mods-menu-selection-direction))
     (when (confirm-pressed-p)
       (execute-selected-mods-menu-option)))))
