;;;; Synthesize King-in-Yellow path sound effects into assets/audio/jrpg/.
;;;; Self-contained: no external samples. Run with:
;;;;   sbcl --script scripts/gen-jrpg-sfx.lisp
;;;; Small mono 16-bit PCM WAVs for the night city and Carcosa: a church organ,
;;;; a viper's hiss, a marble chime, the crown's shimmer, the lake, a door.

(defpackage :coil-jrpg-sfx (:use :cl))
(in-package :coil-jrpg-sfx)

(defparameter *sr* 22050)
(defparameter *out* "assets/audio/jrpg/")

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

;;; A church organ chord, just out of true — a minor triad of detuned sines
;;; with one beating partial, slow vibrato, swelling and falling.
(defun gen-organ ()
  (let* ((dur 2.4) (buf (make-buf dur))
         (roots '(110.0 130.8 164.8 220.0))) ; A minor-ish, plus an octave
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (env (* (min 1.0 (/ tt 0.4)) (min 1.0 (/ (- dur tt) 0.5))))
             (vib (+ 1.0 (* 0.004 (tone 5.2 tt))))
             (s 0.0))
        (dolist (f roots)
          (incf s (* 0.22 (tone (* f vib) tt))))
        ;; a sour partial that beats against the chord
        (incf s (* 0.10 (tone 167.0 tt)))
        (setf (aref buf i) (float (* 0.5 env s) 1.0))))
    buf))

;;; A viper's hiss: band-limited noise rising then cut, with a faint dry rattle.
(defun gen-viper ()
  (let* ((dur 0.7) (buf (make-buf dur)) (lp 0.0) (bp 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (env (* (min 1.0 (/ tt 0.05)) (expt (max 0.0 (- 1.0 (/ tt dur))) 1.3)))
             (nz (noise)))
        (setf lp (+ (* 0.7 lp) (* 0.3 nz)))           ; low-passed body
        (setf bp (+ (* 0.5 bp) (* 0.5 (- nz lp))))    ; hiss band
        (let ((rattle (if (< (mod tt 0.04) 0.006) (* 0.3 nz) 0.0)))
          (setf (aref buf i) (float (* 0.5 env (+ bp rattle)) 1.0)))))
    buf))

;;; A marble chime: a struck-glass tone with an inharmonic partial, long decay.
(defun gen-chime ()
  (let* ((dur 1.4) (buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (env (exp (* -3.2 tt)))
             (s (+ (* 0.6 (tone 1180.0 tt))
                   (* 0.3 (tone 1772.0 tt))      ; near a fifth
                   (* 0.2 (tone 2630.0 tt)))))   ; inharmonic glassiness
        (setf (aref buf i) (float (* 0.5 env s) 1.0))))
    buf))

;;; The crown's shimmer: a cluster of high sines beating into a bright,
;;; slightly wrong gold, swelling and ringing out. For the flash and throne.
(defun gen-crown ()
  (let* ((dur 1.6) (buf (make-buf dur))
         (parts '(660.0 990.0 1320.0 1657.0 1979.0)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (env (* (min 1.0 (/ tt 0.25)) (exp (* -1.6 tt))))
             (shimmer (+ 1.0 (* 0.01 (tone 7.0 tt))))
             (s 0.0))
        (dolist (f parts)
          (incf s (* 0.2 (tone (* f shimmer) tt))))
        (setf (aref buf i) (float (* 0.42 env s) 1.0))))
    buf))

;;; The lake of Hali: slow noise surf swelling and falling, a far gull cry.
(defun gen-lake ()
  (let* ((dur 3.0) (buf (make-buf dur)) (lp 0.0))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (swell (+ 0.5 (* 0.5 (sin (* 2 pi 0.33 tt)))))
             (nz (noise)))
        (setf lp (+ (* 0.92 lp) (* 0.08 nz)))         ; deep surf
        (let* ((gull-t (- tt 1.6))
               (gull (if (and (> gull-t 0.0) (< gull-t 0.5))
                         (* 0.12 (exp (* -6.0 gull-t))
                            (tone (+ 900.0 (* 500.0 gull-t)) tt))
                         0.0)))
          (setf (aref buf i) (float (+ (* 0.55 swell lp) gull) 1.0)))))
    buf))

;;; A heavy door: a wooden creak (a glissing tremolo'd saw) then a latch knock.
(defun gen-door ()
  (let* ((dur 0.9) (buf (make-buf dur)))
    (dotimes (i (length buf))
      (let* ((tt (/ i (float *sr*)))
             (creak-env (* (min 1.0 (/ tt 0.03))
                           (max 0.0 (- 1.0 (/ tt 0.62)))))
             (f (+ 70.0 (* 22.0 tt)))
             (saw (- (* 2.0 (mod (* f tt) 1.0)) 1.0))
             (trem (+ 0.6 (* 0.4 (sin (* 2 pi 17.0 tt)))))
             (creak (* 0.3 creak-env trem saw))
             (knock (if (and (> tt 0.66) (< tt 0.72))
                        (* 0.6 (exp (* -60.0 (- tt 0.66))) (noise))
                        0.0)))
        (setf (aref buf i) (float (+ creak knock) 1.0))))
    buf))

(write-wav "organ.wav" (gen-organ))
(write-wav "viper.wav" (gen-viper))
(write-wav "chime.wav" (gen-chime))
(write-wav "crown.wav" (gen-crown))
(write-wav "lake.wav" (gen-lake))
(write-wav "door.wav" (gen-door))
(format t "done~%")
