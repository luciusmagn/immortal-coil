(in-package #:immortal-coil)

;;; State

(defparameter *options-selection*
  (make-command-selection :fullscreen "FULLSCREEN"
                          :monitor "MONITOR"
                          :text-speed "TEXT SPEED"
                          :music-volume "MUSIC"
                          :sound-volume "SOUND"
                          :light-theme "EMBRACE THE HOLY LIGHT"
                          :back "BACK"))

(defvar *options-active-p* nil)
(defvar *options-mouse-position-ready-p* nil)
(defvar *options-mouse-hover-active-p* nil)
(defvar *options-last-mouse-x* 0.0)
(defvar *options-last-mouse-y* 0.0)

(defparameter *options-min-text-speed* 5.0)
(defparameter *options-max-text-speed* 28.0)
(defparameter *options-text-speed-step* 1.0)
(defparameter *options-volume-step* 0.1)
(defconstant +options-mouse-motion-epsilon+ 0.25)


;;; Persistence

(-> options-file-pathname () pathname)
(defun options-file-pathname ()
  (let ((save-dir (uiop:getenv "IMMORTAL_COIL_SAVE_DIR")))
    (if save-dir
        (merge-pathnames "options.lisp"
                         (uiop:ensure-directory-pathname save-dir))
        (project-pathname "save/options.lisp"))))

(-> reset-options-to-defaults () t)
(defun reset-options-to-defaults ()
  (setf *characters-per-second* 11.0
        *music-volume-scale* 1.0
        *sound-volume-scale* 1.0
        *light-theme-p* nil
        *window-mode* :windowed
        *requested-window-mode* nil
        *fullscreen-monitor-index* nil))

(-> options-data () plist)
(defun options-data ()
  (list :version 1
        :characters-per-second *characters-per-second*
        :music-volume-scale *music-volume-scale*
        :sound-volume-scale *sound-volume-scale*
        :light-theme *light-theme-p*
        :window-mode (or *requested-window-mode* *window-mode*)
        :fullscreen-monitor-index *fullscreen-monitor-index*))

(-> valid-options-data-p (t) boolean)
(defun valid-options-data-p (data)
  (let ((version (and (listp data)
                      (getf data :version))))
    (and (listp data)
         (integerp version)
         (= version 1))))

(-> options-data-scalar (plist keyword scalar scalar scalar) scalar)
(defun options-data-scalar (data key default min-value max-value)
  (let ((value (getf data key)))
    (if (realp value)
        (min max-value (max min-value value))
        default)))

(-> options-data-window-mode (plist) keyword)
(defun options-data-window-mode (data)
  (let ((mode (getf data :window-mode)))
    (if (member mode '(:windowed :fullscreen))
        mode
        :windowed)))

(-> options-data-monitor-index (plist) (option nonnegative-integer))
(defun options-data-monitor-index (data)
  (let ((monitor (getf data :fullscreen-monitor-index)))
    (when (and (integerp monitor)
               (>= monitor 0))
      monitor)))

(-> restore-options-data (plist) t)
(defun restore-options-data (data)
  (when (valid-options-data-p data)
    (setf *characters-per-second*
          (options-data-scalar data
                               :characters-per-second
                               11.0
                               *options-min-text-speed*
                               *options-max-text-speed*)
          *music-volume-scale*
          (options-data-scalar data :music-volume-scale 1.0 0.0 1.0)
          *sound-volume-scale*
          (options-data-scalar data :sound-volume-scale 1.0 0.0 1.0)
          *light-theme-p*
          (and (getf data :light-theme) t)
          *window-mode*
          (options-data-window-mode data)
          *fullscreen-monitor-index*
          (options-data-monitor-index data))))

(-> read-options-data () t)
(defun read-options-data ()
  (handler-case
      (let ((path (options-file-pathname)))
        (when (probe-file path)
          (with-open-file (stream path)
            (with-standard-io-syntax
              (read stream nil nil)))))
    (error (condition)
      (runtime-warn "Could not read options: ~a" condition)
      nil)))

(-> write-options-data (plist) t)
(defun write-options-data (data)
  (let ((path (options-file-pathname)))
    (ensure-directories-exist path)
    (with-open-file (stream path
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (with-standard-io-syntax
        (let ((*print-readably* t))
          (print data stream))))))

(-> save-options () t)
(defun save-options ()
  (handler-case
      (write-options-data (options-data))
    (error (condition)
      (runtime-warn "Could not save options: ~a" condition))))

(-> load-options () t)
(defun load-options ()
  (reset-options-to-defaults)
  (let ((data (read-options-data)))
    (when data
      (restore-options-data data))))


;;; Model

(-> reset-options-mouse-tracking () t)
(defun reset-options-mouse-tracking ()
  (setf *options-mouse-position-ready-p* nil
        *options-mouse-hover-active-p* nil
        *options-last-mouse-x* 0.0
        *options-last-mouse-y* 0.0))

(-> deactivate-options-mouse-hover () t)
(defun deactivate-options-mouse-hover ()
  (setf *options-mouse-hover-active-p* nil))

(-> options-mouse-moved-p () boolean)
(defun options-mouse-moved-p ()
  (multiple-value-bind (x y)
      (virtual-mouse-position)
    (let ((moved-p
            (and *options-mouse-position-ready-p*
                 (or (> (abs (- x *options-last-mouse-x*))
                        +options-mouse-motion-epsilon+)
                     (> (abs (- y *options-last-mouse-y*))
                        +options-mouse-motion-epsilon+)))))
      (setf *options-mouse-position-ready-p* t
            *options-last-mouse-x* x
            *options-last-mouse-y* y)
      moved-p)))

(-> options-menu-active-p () boolean)
(defun options-menu-active-p ()
  *options-active-p*)

(-> reset-options-menu-state () selection-model)
(defun reset-options-menu-state ()
  (setf *options-active-p* nil)
  (reset-options-mouse-tracking)
  (selection-reset *options-selection*))

(-> open-options-menu () t)
(defun open-options-menu ()
  (setf *options-active-p* t)
  (reset-options-mouse-tracking)
  (selection-reset *options-selection*)
  (play-choice-switch))

(-> close-options-menu () t)
(defun close-options-menu ()
  (setf *options-active-p* nil)
  (save-options)
  (play-choice-switch))

(-> selected-options-action () (option command-action))
(defun selected-options-action ()
  (selection-current-action *options-selection*))

(-> options-window-mode () keyword)
(defun options-window-mode ()
  (or *requested-window-mode*
      *window-mode*))

(-> options-fullscreen-enabled-p () boolean)
(defun options-fullscreen-enabled-p ()
  (eq (options-window-mode) :fullscreen))

(-> options-percent-label (scalar) string)
(defun options-percent-label (value)
  (format nil "~d%" (round (* 100 (clamp01 value)))))

(-> options-value-label (t) string)
(defun options-value-label (action)
  (case action
    (:fullscreen
     (if (options-fullscreen-enabled-p) "ON" "OFF"))
    (:monitor
     (monitor-label))
    (:text-speed
     (format nil "~d CPS" (round *characters-per-second*)))
    (:music-volume
     (options-percent-label *music-volume-scale*))
    (:sound-volume
     (options-percent-label *sound-volume-scale*))
    (:light-theme
     (if *light-theme-p* "ON" "OFF"))
    (t "")))

(-> option-adjustable-p (t) boolean)
(defun option-adjustable-p (action)
  (not (null (member action
                     '(:fullscreen
                       :monitor
                       :text-speed
                       :music-volume
                       :sound-volume
                       :light-theme)))))


;;; Actions

(-> options-request-window-mode (keyword) t)
(defun options-request-window-mode (mode)
  (case mode
    (:fullscreen
     (request-fullscreen))
    (:windowed
     (request-windowed))))

(-> toggle-options-fullscreen () t)
(defun toggle-options-fullscreen ()
  (options-request-window-mode
   (if (options-fullscreen-enabled-p)
       :windowed
       :fullscreen)))

(-> adjust-option-value (t integer) t)
(defun adjust-option-value (action direction)
  (case action
    (:fullscreen
     (toggle-options-fullscreen))
    (:monitor
     (when (adjust-fullscreen-monitor-index direction)
       (when (options-fullscreen-enabled-p)
         (request-fullscreen))))
    (:text-speed
     (setf *characters-per-second*
           (min *options-max-text-speed*
                (max *options-min-text-speed*
                     (+ *characters-per-second*
                        (* direction *options-text-speed-step*))))))
    (:music-volume
     (setf *music-volume-scale*
           (clamp01 (+ *music-volume-scale*
                       (* direction *options-volume-step*)))))
    (:sound-volume
     (setf *sound-volume-scale*
           (clamp01 (+ *sound-volume-scale*
                       (* direction *options-volume-step*)))))
    (:light-theme
     (setf *light-theme-p* (not *light-theme-p*))))
  (save-options)
  (play-choice-switch))

(-> activate-selected-option () t)
(defun activate-selected-option ()
  (let ((action (selected-options-action)))
    (case action
      (:back
       (close-options-menu))
      (:fullscreen
       (adjust-option-value action 1))
      (t
       (when (option-adjustable-p action)
         (adjust-option-value action 1))))))
