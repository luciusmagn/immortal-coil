(in-package #:immortal-coil)

;;; The Lisp-machine reboot. When a path throws the player all the way back
;;; to the waking bed (a real reset, not the ship path's diegetic nap), the
;;; world does not just cut to black: the machine the world runs on cold
;;; boots, with hardware sounds, the way a Lisp machine warms its world band
;;; before it hands you back the cursor. The reset sites route through here;
;;; it finishes to base/awake.

(defparameter +lispm-reboot-duration+ 6.8)
(defparameter +lispm-reboot-skip-after+ 0.6)

(defparameter *lispm-reboot-lines*
  (list (cons 0.0  "COIL LISP MACHINE")
        (cons 0.5  "cold boot.")
        (cons 0.95 (format nil "~a   microcode loaded" (hud-default-sbcl)))
        (cons 1.6  "mounting world band 0 ............ ok")
        (cons 2.3  "checking storage ................. ok")
        (cons 3.0  "garbage collecting ...")
        (cons 3.9  "   reclaimed the night.          ok")
        (cons 4.6  "warm booting IMMORTAL-COIL")
        (cons 5.3  "you are still in the coil.")
        (cons 6.0  "starting."))
  "Boot lines, each shown once ELAPSED reaches its reveal time.")

(defparameter *lispm-reboot-sounds*
  (list (cons 0.0  (dialog-asset-pathname "audio/sys/relay.wav"))
        (cons 0.05 (dialog-asset-pathname "audio/sys/power-hum.wav"))
        (cons 0.5  (dialog-asset-pathname "audio/sys/drive-whir.wav"))
        (cons 1.6  (dialog-asset-pathname "audio/sys/disk-seek.wav"))
        (cons 2.3  (dialog-asset-pathname "audio/sys/disk-seek.wav"))
        (cons 3.0  (dialog-asset-pathname "audio/sys/beep-low.wav"))
        (cons 3.9  (dialog-asset-pathname "audio/sys/beep.wav"))
        (cons 4.6  (dialog-asset-pathname "audio/sys/relay.wav"))
        (cons 6.0  (dialog-asset-pathname "audio/sys/beep-ready.wav")))
  "Hardware sounds, fired as ELAPSED crosses each time (kept in order).")

(defclass lispm-reboot-session (minigame-session)
  ((elapsed :initform 0.0 :accessor reboot-elapsed)
   (pending :initform nil :accessor reboot-pending)))

(defmethod initialize-instance :after ((session lispm-reboot-session) &key)
  (setf (reboot-pending session) (copy-list *lispm-reboot-sounds*)))

(defun reboot-skip-pressed-p ()
  (or (is-key-pressed-p +key-enter+)
      (is-key-pressed-p +key-space+)))

(defmethod minigame-session-update ((session lispm-reboot-session) node dt)
  (let ((now (+ (reboot-elapsed session) dt)))
    (setf (reboot-elapsed session) now)
    (loop while (and (reboot-pending session)
                     (<= (car (first (reboot-pending session))) now))
          do (play-story-sound (cdr (pop (reboot-pending session))) :volume 0.5))
    (when (or (>= now +lispm-reboot-duration+)
              (and (>= now +lispm-reboot-skip-after+)
                   (reboot-skip-pressed-p)))
      (finish-minigame-node node (or (node-success-target node) "base/awake")))))

(defmethod minigame-session-draw ((session lispm-reboot-session) node color)
  (declare (ignore node color))
  (let ((now (reboot-elapsed session))
        (phosphor (make-color 150 245 170 235))
        (x 150.0)
        (size 20))
    (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                               (claylib::c-ptr (make-color 0 0 0 255)))
    (let ((y 130.0))
      (dolist (line *lispm-reboot-lines*)
        (when (>= now (car line))
          (draw-text-at (cdr line) x y size phosphor)
          (incf y 30.0)))
      ;; a blinking block cursor on the line still being written
      (when (< (mod now 1.0) 0.6)
        (draw-text-at "_" x y size phosphor)))))

(register-minigame-session-kind :lispm-reboot 'lispm-reboot-session)

(dialog-stop-music "sys/reboot")

(dialog-minigame "sys/reboot"
                 ""
                 :game :lispm-reboot
                 :success "base/awake"
                 :failure "base/awake")
