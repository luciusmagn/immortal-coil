(in-package #:immortal-coil)

(defvar *particle-field-mode* :rising)
(defvar *particle-field-from-mode* :rising)
(defvar *particle-field-to-mode* :rising)
(defvar *particle-field-transition-elapsed* 0.0)
(defvar *particle-field-transition-seconds* 0.0)

(-> valid-particle-field-mode-p (t) boolean)
(defun valid-particle-field-mode-p (mode)
  (typep mode 'particle-field-mode))

(-> normalize-particle-field-mode (t) particle-field-mode)
(defun normalize-particle-field-mode (mode)
  (let ((normalized (typecase mode
                      (keyword mode)
                      (symbol (intern (symbol-name mode) "KEYWORD"))
                      (string (intern (string-upcase mode) "KEYWORD")))))
    (cond
      ((valid-particle-field-mode-p normalized)
       normalized)
      (t
       (runtime-warn "Unknown particle field mode: ~a" mode)
       *particle-field-mode*))))
