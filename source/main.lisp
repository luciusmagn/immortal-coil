(defpackage #:immortal-coil
  (:use #:cl
        #:claylib)
  (:import-from :serapeum :->))

(in-package :immortal-coil)

(defparameter *scene*
  (make-scene ()
              ((info (list (make-text "I'm game develoooping" 10 40 :size 20 :color +black+)
                           (make-text "In ahh LISP"           10 80 :size 20 :color +black+))))))

(defun main ()
  (with-window (:title "claylib raylib ahhhh stuff")
    (with-scenes *scene* ()
      (do-game-loop (:livesupport t)
        (with-drawing ()
          (clear-background :color +white+)
          (draw-scene-all *scene*))))))
