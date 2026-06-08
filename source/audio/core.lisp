(in-package #:immortal-coil)

(-> load-audio () t)
(defun load-audio ()
  (load-type-clicks)
  (load-choice-switch)
  (load-start-confirm)
  (load-title-music))

(-> clear-audio-resources () t)
(defun clear-audio-resources ()
  (clear-story-music-resources)
  (clear-title-music-resources)
  (clear-short-sound-resources))
