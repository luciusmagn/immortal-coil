;;;; Synthesize hardware-style sound effects into assets/audio/sys/.
;;;; Self-contained: no external samples. Run with:
;;;;   sbcl --script scripts/gen-sfx.lisp
;;;; Produces small mono 16-bit PCM WAVs used by the Lisp-machine reboot
;;;; sequence (and reusable anywhere a machine should sound like hardware).

(defpackage :coil-sfx (:use :cl))
(in-package :coil-sfx)

(defparameter *sr* 22050)
(defparameter *out* "assets/audio/sys/")

(defun secs (n) (round (* *sr* n)))
(defun make-buf (seconds) (make-array (secs seconds)
                                      :element-type 'single-float
                                      :initial-element 0.0))
(defun noise () (- (random 2.0) 1.0))

(defun write-wav (name samples)
  (ensure-directories-exist *out*)
  (let* ((path (merge-pathnames name *out*))
         (n (length samples))
         (data-bytes (* n 2))
         (byte-rate (* *sr* 2)))
    (with-open-file (s path :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-exists :supersede :if-does-not-exist :create)
      (flet ((u16 (v) (write-byte (ldb (byte 8 0) v) s)
                      (write-byte (ldb (byte 8 8) v) s))
             (u32 (v) (write-byte (ldb (byte 8 0) v) s)
                      (write-byte (ldb (byte 8 8) v) s)
                      (write-byte (ldb (byte 8 16) v) s)
                      (write-byte (ldb (byte 8 24) v) s))
             (chars (str) (loop for c across str do (write-byte (char-code c) s))))
        (chars "RIFF") (u32 (+ 36 data-bytes)) (chars "WAVE")
        (chars "fmt ") (u32 16) (u16 1) (u16 1) (u32 *sr*) (u32 byte-rate)
        (u16 2) (u16 16)
        (chars "data") (u32 data-bytes)
        (loop for x across samples
              for v = (round (* 32767 (max -1.0 (min 1.0 x))))
              do (u16 (logand v #xffff)))))
    (format t "wrote ~a (~a samples)~%" path n)))

;;; A relay/contactor closing: a click transient over a short low thud.
(defun gen-relay ()
  (let* ((dur 0.16) (buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (env (exp (* -26.0 tt)))
             (thud (* (sin (* 2 pi 52 tt)) env))
             (click (if (< tt 0.0025) (* 0.7 (noise)) 0.0)))
        (setf (aref buf i) (float (* 0.7 (+ (* 0.85 thud) click)) 1.0))))
    buf))

;;; Power-on mains hum: a 60/120 Hz drone fading in, with faint hiss.
(defun gen-hum ()
  (let* ((dur 2.2) (buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (fade (min 1.0 (/ tt 0.8)))
             (s (+ (* 0.6 (sin (* 2 pi 120 tt)))
                   (* 0.4 (sin (* 2 pi 60 tt)))
                   (* 0.05 (noise)))))
        (setf (aref buf i) (float (* 0.18 fade s) 1.0))))
    buf))

;;; A drive spinning up: a tone gliding from 40 to ~220 Hz under bearing hiss.
(defun gen-whir ()
  (let* ((dur 1.3) (buf (make-buf dur)) (ph 0.0d0) (lp 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (f (+ 40.0 (* 180.0 (min 1.0 (/ tt 1.0)))))
             (env (* (min 1.0 (/ tt 0.2)) (min 1.0 (/ (- dur tt) 0.25)))))
        (incf ph (/ (* 2 pi f) *sr*))
        (setf lp (+ (* 0.85 lp) (* 0.15 (noise))))
        (setf (aref buf i) (float (* 0.16 env (+ (* 0.7 (sin ph)) (* 0.5 lp))) 1.0))))
    buf))

;;; Disk head seeking: rapid filtered noise clicks.
(defun gen-seek ()
  (let* ((dur 0.85) (buf (make-buf dur)) (lp 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (phase (mod tt 0.055))
             (click (if (< phase 0.004) 1.0 0.0))
             (nz (* click (noise))))
        (setf lp (+ (* 0.6 lp) (* 0.4 nz)))
        (setf (aref buf i) (float (* 0.5 lp) 1.0))))
    buf))

;;; A POST beep: a square tone with a quick attack and decay.
(defun gen-beep (name freq dur gain)
  (let* ((buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (env (* (min 1.0 (/ tt 0.005)) (min 1.0 (/ (- dur tt) 0.02))))
             (sq (if (plusp (sin (* 2 pi freq tt))) 1.0 -1.0)))
        (setf (aref buf i) (float (* gain env sq) 1.0))))
    (write-wav name buf)))

(write-wav "relay.wav" (gen-relay))
(write-wav "power-hum.wav" (gen-hum))
(write-wav "drive-whir.wav" (gen-whir))
(write-wav "disk-seek.wav" (gen-seek))
(gen-beep "beep-low.wav" 440.0 0.16 0.22)
(gen-beep "beep.wav" 880.0 0.16 0.22)
(gen-beep "beep-ready.wav" 1320.0 0.22 0.20)
(format t "done~%")
