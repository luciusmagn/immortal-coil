(require :asdf)

(defparameter *sample-rate* 22050)

(defun write-ascii (stream text)
  (loop for char across text
        do (write-byte (char-code char) stream)))

(defun write-u16-le (stream value)
  (write-byte (logand value #xff) stream)
  (write-byte (logand (ash value -8) #xff) stream))

(defun write-u32-le (stream value)
  (write-u16-le stream (logand value #xffff))
  (write-u16-le stream (logand (ash value -16) #xffff)))

(defun write-s16-le (stream value)
  (let ((sample (if (minusp value)
                    (+ #x10000 value)
                    value)))
    (write-u16-le stream sample)))

(defun clamp-sample (value)
  (round (max -32767 (min 32767 value))))

(defun write-wav (path samples)
  (ensure-directories-exist path)
  (let* ((sample-count (length samples))
         (data-size (* sample-count 2))
         (riff-size (+ 36 data-size)))
    (with-open-file (stream path
                            :direction :output
                            :element-type '(unsigned-byte 8)
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (write-ascii stream "RIFF")
      (write-u32-le stream riff-size)
      (write-ascii stream "WAVE")
      (write-ascii stream "fmt ")
      (write-u32-le stream 16)
      (write-u16-le stream 1)
      (write-u16-le stream 1)
      (write-u32-le stream *sample-rate*)
      (write-u32-le stream (* *sample-rate* 2))
      (write-u16-le stream 2)
      (write-u16-le stream 16)
      (write-ascii stream "data")
      (write-u32-le stream data-size)
      (loop for sample across samples
            do (write-s16-le stream (clamp-sample sample))))))

(defun square-wave (time frequency)
  (if (minusp (sin (* 2 pi frequency time))) -1.0 1.0))

(defun triangle-wave (time frequency)
  (- (* 4.0 (abs (- (mod (* time frequency) 1.0) 0.5))) 1.0))

(defun envelope (time duration attack release)
  (min 1.0
       (if (< time attack)
           (/ time attack)
           1.0)
       (if (> time (- duration release))
           (/ (- duration time) release)
           1.0)))

(defun make-samples (duration function)
  (let* ((count (round (* duration *sample-rate*)))
         (samples (make-array count :element-type 'integer)))
    (loop for index below count
          for time = (/ index (float *sample-rate* 1.0))
          do (setf (aref samples index)
                   (round (* 28000 (funcall function time duration)))))
    samples))

(defun note-frequency (base semitone)
  (* base (expt 2.0 (/ semitone 12.0))))

(defun rogue-music-sample (time duration)
  (let* ((roots #(55.0 51.913 61.735 46.249))
         (root (aref roots (mod (floor (/ time 8.0)) (length roots))))
         (step (mod (floor (/ time 1.25)) 6))
         (interval (aref #(0 7 12 10 7 3) step))
         (slow-env (* 0.74 (+ 0.78 (* 0.22 (sin (* 2 pi time 0.03125))))))
         (fade (envelope time duration 2.0 3.0))
         (bass (* 0.42 (square-wave time root)))
         (fifth (* 0.24 (square-wave time (* root 1.5))))
         (high (* 0.16 (triangle-wave time (note-frequency (* root 4) interval))))
         (undertone (* 0.12 (sin (* 2 pi (* root 0.5) time)))))
    (* fade slow-env (+ bass fifth high undertone))))

(defun blip (frequency duration &key (fall 0.0) (volume 0.55))
  (make-samples
   duration
   (lambda (time total)
     (let* ((f (max 20.0 (+ frequency (* fall time))))
            (env (envelope time total 0.004 0.05)))
       (* volume env (square-wave time f))))))

(defun pickup-sound ()
  (make-samples
   0.24
   (lambda (time total)
     (let* ((step (floor (/ time 0.06)))
            (freq (aref #(392.0 523.25 659.25 783.99)
                        (min 3 step)))
            (env (envelope time total 0.004 0.06)))
       (* 0.50 env (square-wave time freq))))))

(defun stairs-sound ()
  (make-samples
   0.50
   (lambda (time total)
     (let* ((step (floor (/ time 0.08)))
            (freq (aref #(196.0 174.61 146.83 130.81 98.0 73.42)
                        (min 5 step)))
            (env (envelope time total 0.006 0.12)))
       (* 0.46 env (+ (* 0.7 (square-wave time freq))
                      (* 0.3 (triangle-wave time (* 2 freq)))))))))

(defun noise-burst ()
  (let ((state 7331))
    (make-samples
     0.16
     (lambda (time total)
       (setf state (mod (+ (* state 1103515245) 12345) #x80000000))
       (let ((noise (- (/ state #x40000000) 1.0))
             (env (envelope time total 0.002 0.08)))
         (* 0.62 env noise))))))

(defun generate ()
  (let ((root (merge-pathnames "assets/audio/rogue/"
                               (uiop:getcwd))))
    (write-wav (merge-pathnames "chiptune-crypt.wav" root)
               (make-samples 64.0 #'rogue-music-sample))
    (write-wav (merge-pathnames "menu.wav" root)
               (blip 880.0 0.08 :fall -2400.0 :volume 0.30))
    (write-wav (merge-pathnames "class.wav" root)
               (make-samples
                0.38
                (lambda (time total)
                  (* (envelope time total 0.01 0.16)
                     (+ (* 0.36 (square-wave time 130.81))
                        (* 0.28 (square-wave time 196.0))
                        (* 0.20 (triangle-wave time 261.63)))))))
    (write-wav (merge-pathnames "step.wav" root)
               (blip 110.0 0.07 :fall -520.0 :volume 0.20))
    (write-wav (merge-pathnames "bump.wav" root)
               (blip 73.42 0.12 :fall -220.0 :volume 0.34))
    (write-wav (merge-pathnames "pickup.wav" root)
               (pickup-sound))
    (write-wav (merge-pathnames "hit.wav" root)
               (noise-burst))
    (write-wav (merge-pathnames "kill.wav" root)
               (blip 220.0 0.18 :fall -980.0 :volume 0.48))
    (write-wav (merge-pathnames "stairs.wav" root)
               (stairs-sound))))

(generate)
