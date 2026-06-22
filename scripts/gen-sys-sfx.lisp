;;;; Synthesize system / hardware sound effects into assets/audio/sys/.
;;;; Self-contained: no external samples. Run with:
;;;;   sbcl --script scripts/gen-sys-sfx.lisp
;;;; Small mono 16-bit PCM WAVs: the CRT powering on and off, plus a handful of
;;;; hardware-y computer noises (key clack, carriage return, a soft confirm
;;;; bleep) to intersperse over the terminal aesthetic.

(defpackage :coil-sys-sfx (:use :cl))
(in-package :coil-sys-sfx)

(defparameter *sr* 22050)
(defparameter *out* "assets/audio/sys/")

(defun secs (n) (round (* *sr* n)))
(defun make-buf (seconds) (make-array (secs seconds)
                                      :element-type 'single-float
                                      :initial-element 0.0))
(defun noise () (- (random 2.0) 1.0))
(defun tone (freq tt) (sin (* 2 pi freq tt)))

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

;;; The tube waking: a relay thunk and click, a degauss hum that swells and
;;; settles, the flyback whine rising into place, and a burst of static that
;;; falls to a faint hiss.
(defun gen-crt-on ()
  (let* ((dur 0.95) (buf (make-buf dur)) (prev 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (click (if (< tt 0.012) (* 0.7 (- 1.0 (/ tt 0.012)) (noise)) 0.0))
             (thunk (* 0.5 (exp (* -26.0 tt)) (tone 58.0 tt)))
             (hum-env (* (min 1.0 (/ tt 0.06)) (max 0.0 (- 1.0 (/ tt 0.7)))))
             (hum (* 0.22 hum-env
                     (+ (tone 72.0 tt) (* 0.5 (tone 108.0 tt)))
                     (+ 0.85 (* 0.15 (tone 7.0 tt)))))
             (wf (+ 3200.0 (* 4600.0 (min 1.0 (/ tt 0.42)))))
             (whine-env (* (min 1.0 (/ tt 0.18))
                           (min 1.0 (max 0.2 (- 1.2 (/ tt 1.4))))))
             (whine (* 0.10 whine-env (tone wf tt)))
             (nz (noise))
             (hp (- nz prev))
             (st-env (+ (* 0.9 (exp (* -9.0 tt))) (* 0.05 hum-env)))
             (static (* 0.5 st-env hp)))
        (setf prev nz)
        (setf (aref buf i)
              (float (* 0.9 (+ click thunk hum whine static)) 1.0))))
    buf))

;;; The tube dying: the whine drops fast as the flyback collapses, a bright
;;; static snap as the picture squeezes to a line, then a low discharge thunk.
(defun gen-crt-off ()
  (let* ((dur 0.55) (buf (make-buf dur)) (prev 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (wf (max 300.0 (- 7600.0 (* 40000.0 tt))))
             (whine-env (* (min 1.0 (/ tt 0.004)) (exp (* -7.0 tt))))
             (whine (* 0.12 whine-env (tone wf tt)))
             (nz (noise))
             (hp (- nz prev))
             (snap (* 0.5 (exp (* -16.0 tt)) hp))
             (thunk (if (> tt 0.18)
                        (* 0.45 (exp (* -12.0 (- tt 0.18)))
                           (tone 52.0 (- tt 0.18)))
                        0.0)))
        (setf prev nz)
        (setf (aref buf i) (float (* 0.95 (+ whine snap thunk)) 1.0))))
    buf))

;;; A single key clack: a short noisy click with a woody body.
(defun gen-key-clack ()
  (let* ((dur 0.06) (buf (make-buf dur)) (prev 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (nz (noise)) (hp (- nz prev))
             (click (* 0.6 (exp (* -120.0 tt)) hp))
             (body (* 0.35 (exp (* -90.0 tt)) (tone 220.0 tt))))
        (setf prev nz)
        (setf (aref buf i) (float (+ click body) 1.0))))
    buf))

;;; A carriage return / enter: two soft mechanical knocks and a faint ring.
(defun gen-return ()
  (let* ((dur 0.22) (buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (k1 (if (< tt 0.05) (* 0.6 (exp (* -70.0 tt)) (tone 140.0 tt)) 0.0))
             (k2 (if (> tt 0.09)
                     (* 0.5 (exp (* -60.0 (- tt 0.09))) (tone 120.0 (- tt 0.09)))
                     0.0))
             (ring (* 0.08 (exp (* -10.0 tt)) (tone 1600.0 tt))))
        (setf (aref buf i) (float (+ k1 k2 ring) 1.0))))
    buf))

;;; A soft confirm bleep: a clean two-step rising tone, gently enveloped.
(defun gen-bleep ()
  (let* ((dur 0.18) (buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (f (if (< tt 0.08) 660.0 990.0))
             (env (* (min 1.0 (/ tt 0.005)) (max 0.0 (- 1.0 (/ tt dur))))))
        (setf (aref buf i) (float (* 0.4 env (tone f tt)) 1.0))))
    buf))

(write-wav "crt-on.wav" (gen-crt-on))
(write-wav "crt-off.wav" (gen-crt-off))
(write-wav "key-clack.wav" (gen-key-clack))
(write-wav "return.wav" (gen-return))
(write-wav "bleep.wav" (gen-bleep))
(format t "done~%")
