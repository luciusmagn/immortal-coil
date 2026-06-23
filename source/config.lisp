(in-package #:immortal-coil)

(defconstant +virtual-width+ 1280)
(defconstant +virtual-height+ 720)
(defconstant +virtual-center-x+ (/ +virtual-width+ 2.0))
(defconstant +virtual-center-y+ (/ +virtual-height+ 2.0))
(defconstant +particle-size+ 2)
(defconstant +star-particle-size+ 1)

(defconstant +menu-start-x+ +virtual-center-x+)
(defconstant +menu-start-y+ 410.0)
(defconstant +title-orbit-radius+ 145.0)
(defconstant +title-logo-width+ 900.0)
(defconstant +title-logo-y+ 34.0)

(defparameter *characters-per-second* 11.0)
(defparameter *fade-seconds* 1.2)
(defparameter *menu-fade-seconds* 3.0)
(defparameter *start-confirm-seconds* 0.55)
(defparameter *start-fade-out-seconds* 2.1)
(defparameter *game-fade-in-seconds* 2.8)
(defparameter *game-start-type-delay-seconds* 1.1)
(defparameter *dialog-text-max-width* 900.0)
(defparameter *dialog-text-line-height* 30.0)
(defparameter *menu-start-text-size* 18)
(defparameter *particle-count* 8)
(defparameter *star-particle-count* 120)
(defparameter *particle-field-fade-seconds* 6.5)
(defparameter *title-particle-count* 1000)
(defparameter *title-particle-spawn-rate* 70.0)
(defparameter *dialog-manifest-paths* '("game/manifest.lisp"))
(defparameter *dialog-script-paths* '("game/opening.lisp"))
(defparameter *mod-directory-paths* '("mods/"))
(defparameter *music-stream-buffer-size* 65536)
(defparameter *music-volume-scale* 1.0)
(defparameter *sound-volume-scale* 1.0)

(defvar *mode* :menu)
(defvar *menu-elapsed* 0.0)
(defvar *menu-start-action* nil)
(defvar *menu-start-state* :idle)
(defvar *menu-start-elapsed* 0.0)
(defvar *game-fade-elapsed* 0.0)
(defvar *quit-requested-p* nil)
(defvar *paused-p* nil)
(defvar *window-mode* :windowed)
(defvar *requested-window-mode* nil)
(defvar *fullscreen-width* +virtual-width+)
(defvar *fullscreen-height* +virtual-height+)
(defvar *fullscreen-size-ready-p* nil)
(defvar *fullscreen-monitor-index* nil)

;; set while a tool captures keystrokes (the Scene Builder) so the global
;; single-key window shortcuts (F = fullscreen) do not fire while typing
(defvar *suppress-window-shortcuts-p* nil)

;; Internal render resolution. The layout is authored in 1280x720; this scales
;; the render texture (and a matching camera zoom) so the vector graphics - the
;; map, sprites, panels, bars - are rasterized at a higher resolution and read
;; crisply when the window is scaled up. 1.0 = 720p, 1.5 = Full HD (1920x1080).
;; Bitmap text does not sharpen. Default Full HD.
(defparameter *render-scale-choices* '(("720P" . 1.0) ("FULL HD" . 1.5)))
(defvar *render-scale* 1.5)

;; Visual theme: nil = ink on black (default), t = "Embrace the Holy Light",
;; which inverts black and white in the CRT shader while sparing the yellow
;; crown and any other chromatic accent.
(defvar *light-theme-p* nil)

;; CRT power animation. *crt-off-amount* runs 1.0 (dark) -> 0.0 (lit). The
;; screen boots in :warming so the very first window powers on; it never warms
;; again (a fullscreen toggle reopens the window without re-booting). Quitting
;; runs :cooling, and the process only exits once the tube has gone dark.
(defparameter *crt-warm-seconds* 0.9)
(defparameter *crt-cool-seconds* 0.55)
(defvar *crt-off-amount* 1.0)
(defvar *crt-power-state* :warming)
(defvar *crt-power-booted-p* nil)
