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

(-> fullscreen-monitor-index () (option integer))
(defun fullscreen-monitor-index ()
  (let ((count (monitor-count)))
    (when (plusp count)
      (let ((monitor (handler-case
                         (get-current-monitor)
                       (error (condition)
                         (runtime-warn "Could not read current monitor: ~a"
                                       condition)
                         nil))))
        (if (valid-monitor-index-p monitor count)
            monitor
            0)))))

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
  (max +virtual-width+ *fullscreen-width*))

(-> fullscreen-window-height () integer)
(defun fullscreen-window-height ()
  (max +virtual-height+ *fullscreen-height*))

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
           (set-window-size width height))
         t)))

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

(defun fullscreen-shortcut-available-p ()
  (not (current-dialog-input-active-p)))

(defun update-window-controls ()
  (when (and (fullscreen-shortcut-available-p)
             (is-key-pressed-p +key-f+))
    (toggle-game-fullscreen)))
