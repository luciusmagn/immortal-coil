(in-package #:immortal-coil)

(defconstant +virtual-width+ 800)
(defconstant +virtual-height+ 600)
(defconstant +particle-size+ 2)

(defconstant +menu-start-x+ 400.0)
(defconstant +menu-start-y+ 300.0)
(defconstant +menu-start-text-size+ 24)
(defconstant +title-orbit-radius+ 145.0)

(defparameter *characters-per-second* 18.0)
(defparameter *fade-seconds* 0.5)
(defparameter *menu-fade-seconds* 1.4)
(defparameter *particle-count* 8)
(defparameter *title-particle-count* 260)
(defparameter *dialog-script-paths* '("game/opening.lisp"))

(defvar *mode* :menu)
(defvar *menu-elapsed* 0.0)
(defvar *borderless-fullscreen-p* nil)
