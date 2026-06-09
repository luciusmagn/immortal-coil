(in-package #:immortal-coil)

(-> monitor-count () nonnegative-integer)
(defun monitor-count ()
  (handler-case
      (let ((count (get-monitor-count)))
        (if (integerp count)
            (max 0 count)
            0))
    (error (condition)
      (runtime-warn "Could not read monitor count: ~a" condition)
      0)))

(-> valid-monitor-index-p (t nonnegative-integer) boolean)
(defun valid-monitor-index-p (monitor count)
  (and (integerp monitor)
       (<= 0 monitor)
       (< monitor count)))

(-> current-monitor-index (nonnegative-integer) (option integer))
(defun current-monitor-index (count)
  (let ((monitor (handler-case
                     (get-current-monitor)
                   (error (condition)
                     (runtime-warn "Could not read current monitor: ~a"
                                   condition)
                     nil))))
    (when (valid-monitor-index-p monitor count)
      monitor)))

(-> fallback-monitor-index (nonnegative-integer) (option integer))
(defun fallback-monitor-index (count)
  (or (current-monitor-index count)
      (when (plusp count)
        0)))

(-> fullscreen-monitor-index () (option nonnegative-integer))
(defun fullscreen-monitor-index ()
  (let ((count (monitor-count)))
    (when (plusp count)
      (if (valid-monitor-index-p *fullscreen-monitor-index* count)
          *fullscreen-monitor-index*
          (fallback-monitor-index count)))))

(-> monitor-name (nonnegative-integer) string)
(defun monitor-name (monitor)
  (handler-case
      (let ((name (get-monitor-name monitor)))
        (if (stringp name)
            name
            ""))
    (error (condition)
      (runtime-warn "Could not read monitor name: ~a" condition)
      "")))

(-> monitor-size-label (nonnegative-integer) string)
(defun monitor-size-label (monitor)
  (handler-case
      (let ((width  (get-monitor-width monitor))
            (height (get-monitor-height monitor)))
        (if (positive-window-size-p width height)
            (format nil "~dx~d" width height)
            "unknown"))
    (error (condition)
      (runtime-warn "Could not read monitor size: ~a" condition)
      "unknown")))

(-> monitor-position (nonnegative-integer) (values integer integer))
(defun monitor-position (monitor)
  (handler-case
      (let ((position (make-vector2 0 0)))
        (claylib/ll:get-monitor-position (claylib::c-ptr position)
                                         monitor)
        (values (round (x position))
                (round (y position))))
    (error (condition)
      (runtime-warn "Could not read monitor position: ~a" condition)
      (values 0 0))))

(-> monitor-label () string)
(defun monitor-label ()
  (let ((count (monitor-count)))
    (if (plusp count)
        (let* ((monitor (or (fullscreen-monitor-index) 0))
               (name    (monitor-name monitor))
               (size    (monitor-size-label monitor)))
          (if (plusp (length name))
              (format nil "~d/~d ~a ~a"
                      (1+ monitor)
                      count
                      size
                      (subseq name 0 (min 12 (length name))))
              (format nil "~d/~d ~a" (1+ monitor) count size)))
        "N/A")))

(-> set-fullscreen-monitor-index (integer) boolean)
(defun set-fullscreen-monitor-index (monitor)
  (let ((count (monitor-count)))
    (if (plusp count)
        (progn
          (setf *fullscreen-monitor-index* (mod monitor count)
                *fullscreen-size-ready-p* nil)
          (capture-fullscreen-size)
          t)
        (progn
          (setf *fullscreen-monitor-index* nil
                *fullscreen-size-ready-p* nil)
          nil))))

(-> adjust-fullscreen-monitor-index (navigation-direction) boolean)
(defun adjust-fullscreen-monitor-index (direction)
  (let ((count (monitor-count)))
    (when (plusp count)
      (set-fullscreen-monitor-index
       (+ (or (fullscreen-monitor-index) 0) direction)))))

(-> positive-window-size-p (t t) boolean)
(defun positive-window-size-p (width height)
  (and (integerp width)
       (integerp height)
       (plusp width)
       (plusp height)))

(-> fullscreen-size-ready-p () boolean)
(defun fullscreen-size-ready-p ()
  (and *fullscreen-size-ready-p*
       (positive-window-size-p *fullscreen-width*
                               *fullscreen-height*)))

(-> capture-fullscreen-size () boolean)
(defun capture-fullscreen-size ()
  (let ((monitor (fullscreen-monitor-index)))
    (when monitor
      (handler-case
          (let ((width  (get-monitor-width monitor))
                (height (get-monitor-height monitor)))
            (when (positive-window-size-p width height)
              (setf *fullscreen-width* width
                    *fullscreen-height* height
                    *fullscreen-size-ready-p* t)
              t))
        (error (condition)
          (runtime-warn "Could not capture fullscreen size: ~a" condition)
          nil)))))

(-> fullscreen-window-width () integer)
(defun fullscreen-window-width ()
  (if (positive-window-size-p *fullscreen-width* *fullscreen-height*)
      *fullscreen-width*
      +virtual-width+))

(-> fullscreen-window-height () integer)
(defun fullscreen-window-height ()
  (if (positive-window-size-p *fullscreen-width* *fullscreen-height*)
      *fullscreen-height*
      +virtual-height+))

(-> prepare-fullscreen-window-size () boolean)
(defun prepare-fullscreen-window-size ()
  (not (null (capture-fullscreen-size))))

(-> prime-fullscreen-size-with-temporary-window () boolean)
(defun prime-fullscreen-size-with-temporary-window ()
  (handler-case
      (progn
        (claylib/ll:set-config-flags +flag-window-hidden+)
        (claylib/ll:init-window +virtual-width+
                                +virtual-height+
                                "Immortal Coil")
        (unwind-protect
             (prepare-fullscreen-window-size)
          (when (is-window-ready-p)
            (when (is-window-hidden-p)
              (clear-window-state +flag-window-hidden+))
            (claylib/ll:close-window))))
    (error (condition)
      (runtime-warn "Could not prime fullscreen size: ~a" condition)
      nil)))

(-> prime-fullscreen-window-size () boolean)
(defun prime-fullscreen-window-size ()
  (or (fullscreen-size-ready-p)
      (prepare-fullscreen-window-size)
      (prime-fullscreen-size-with-temporary-window)))

(-> sync-active-fullscreen-window-size () boolean)
(defun sync-active-fullscreen-window-size ()
  (and (is-window-ready-p)
       (capture-fullscreen-size)
       (let ((width  (fullscreen-window-width))
             (height (fullscreen-window-height)))
         (when (or (/= (get-screen-width) width)
                   (/= (get-screen-height) height))
           (claylib/ll:set-window-size width height))
         t)))

(-> apply-fullscreen-monitor () boolean)
(defun apply-fullscreen-monitor ()
  (let ((monitor (fullscreen-monitor-index)))
    (when (and monitor (is-window-ready-p))
      (handler-case
          (when (capture-fullscreen-size)
            (let ((width  (fullscreen-window-width))
                  (height (fullscreen-window-height)))
              (multiple-value-bind (x y)
                  (monitor-position monitor)
                (claylib/ll:set-window-size width height)
                (claylib/ll:set-window-position x y)
                (claylib/ll:set-window-state
                 (+ +flag-window-undecorated+
                    +flag-window-topmost+))
                (claylib/ll:set-window-position x y))
              (claylib/ll:set-window-size width height)
              t))
        (error (condition)
          (runtime-warn "Could not apply fullscreen monitor: ~a" condition)
          nil)))))

(defun request-fullscreen ()
  (capture-fullscreen-size)
  (setf *requested-window-mode* :fullscreen))

(defun request-windowed ()
  (setf *requested-window-mode* :windowed))

(defun toggle-game-fullscreen ()
  (unless *requested-window-mode*
    (case *window-mode*
      (:fullscreen (request-windowed))
      (t (request-fullscreen)))))

(defun current-dialog-input-active-p ()
  (when (and (eq *mode* :game)
             (not *paused-p*)
             *state*)
    (let ((node (current-node)))
      (and (member (node-kind node) '(:number :string))
           (story-text-visible-p node)))))

(-> current-editor-input-active-p () boolean)
(defun current-editor-input-active-p ()
  (and (boundp '*editor-active-p*)
       (boundp '*editor-mode*)
       *editor-active-p*
       (not (eq *editor-mode* :play))))

(defun fullscreen-shortcut-available-p ()
  (not (or (current-dialog-input-active-p)
           (current-editor-input-active-p))))

(defun update-window-controls ()
  (when (and (fullscreen-shortcut-available-p)
             (is-key-pressed-p +key-f+))
    (toggle-game-fullscreen)))
