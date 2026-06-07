(in-package #:immortal-coil)

(-> make-sound-asset-maybe (pathname string) t)
(defun make-sound-asset-maybe (path description)
  (handler-case
      (make-sound-asset path :load-now t)
    (error (condition)
      (runtime-warn "Could not load ~a: ~a (~a)"
                    description
                    path
                    condition)
      nil)))

(-> make-music-asset-maybe (pathname string) t)
(defun make-music-asset-maybe (path description)
  (handler-case
      (make-music-asset path :load-now t)
    (error (condition)
      (runtime-warn "Could not load ~a: ~a (~a)"
                    description
                    path
                    condition)
      nil)))

(-> play-sound-maybe (t string) t)
(defun play-sound-maybe (sound description)
  (handler-case
      (claylib/ll:play-sound (claylib::c-ptr sound))
    (error (condition)
      (runtime-warn "Could not play ~a: ~a" description condition))))
