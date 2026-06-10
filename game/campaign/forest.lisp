(defparameter *forest-wind-count* 84)
(defvar *forest-wind-particles* #())

(defstruct forest-wind-particle
  x
  y
  vx
  drift
  phase
  alpha
  length)

(defun reset-forest-wind-particle (particle &key initial-p)
  (setf (forest-wind-particle-x particle)
        (if initial-p
            (random-float -40.0 (+ +virtual-width+ 40.0))
            (random-float -90.0 -10.0))
        (forest-wind-particle-y particle)
        (random-float 36.0 (- +virtual-height+ 28.0))
        (forest-wind-particle-vx particle)
        (random-float 28.0 86.0)
        (forest-wind-particle-drift particle)
        (random-float -10.0 10.0)
        (forest-wind-particle-phase particle)
        (random-float 0.0 (* 2 pi))
        (forest-wind-particle-alpha particle)
        (get-random-value 34 132)
        (forest-wind-particle-length particle)
        (get-random-value 2 9))
  particle)

(defun reset-forest-wind-particles ()
  (setf *forest-wind-particles* (make-array *forest-wind-count*))
  (loop for i below *forest-wind-count*
        do (setf (aref *forest-wind-particles* i)
                 (reset-forest-wind-particle
                  (make-forest-wind-particle)
                  :initial-p t))))

(defun ensure-forest-wind-particles ()
  (unless (= (length *forest-wind-particles*) *forest-wind-count*)
    (reset-forest-wind-particles)))

(defun update-forest-wind-particle (particle dt)
  (incf (forest-wind-particle-phase particle) (* dt 1.7))
  (incf (forest-wind-particle-x particle)
        (* (forest-wind-particle-vx particle) dt))
  (incf (forest-wind-particle-y particle)
        (* (+ (forest-wind-particle-drift particle)
              (* 14.0 (sin (forest-wind-particle-phase particle))))
           dt))
  (when (or (> (forest-wind-particle-x particle) (+ +virtual-width+ 96.0))
            (< (forest-wind-particle-y particle) -20.0)
            (> (forest-wind-particle-y particle) (+ +virtual-height+ 20.0)))
    (reset-forest-wind-particle particle)))

(defun update-forest-wind-particles (dt)
  (ensure-forest-wind-particles)
  (loop for particle across *forest-wind-particles*
        do (update-forest-wind-particle particle dt)))

(defun draw-forest-wind-particle (particle alpha-scale)
  (let ((alpha (round (* (forest-wind-particle-alpha particle)
                         alpha-scale))))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle
       (round (forest-wind-particle-x particle))
       (round (forest-wind-particle-y particle))
       (forest-wind-particle-length particle)
       1
       (claylib::c-ptr (make-color 255 255 255 alpha))))))

(defun forest-pine-x (index)
  (+ 24.0
     (* index 48.0)
     (* 16.0 (sin (* index 1.73)))))

(defun forest-pine-scale (index)
  (+ 0.48 (* 0.32 (clamp01 (* 0.5 (+ 1.0 (sin (* index 2.31))))))))

(defun draw-forest-pine (x base-y scale alpha)
  (let ((color (make-color 255 255 255 alpha))
        (half-width (* scale 12.0))
        (height (* scale 34.0)))
    (draw-triangle-points x
                          (- base-y height)
                          (- x half-width)
                          base-y
                          (+ x half-width)
                          base-y
                          color
                          :filled-p t)
    (claylib/ll:draw-rectangle (round (- x (* scale 1.5)))
                               (round (- base-y 2))
                               (max 1 (round (* scale 3.0)))
                               (max 3 (round (* scale 8.0)))
                               (claylib::c-ptr color))))

(defun draw-forest-pines (alpha-scale)
  (loop for i below 28
        for x = (forest-pine-x i)
        for scale = (forest-pine-scale i)
        for y = (+ 670.0 (* 22.0 (sin (* i 0.91))))
        do (draw-forest-pine x
                             y
                             scale
                             (round (* 58 alpha-scale)))))

(defun draw-forest-wind (alpha-scale)
  (draw-forest-pines alpha-scale)
  (loop for particle across *forest-wind-particles*
        do (draw-forest-wind-particle particle alpha-scale)))

(dialog-particle-field-kind :forest-wind
                            :reset #'reset-forest-wind-particles
                            :ensure #'ensure-forest-wind-particles
                            :update #'update-forest-wind-particles
                            :draw #'draw-forest-wind)


(dialog-particles "forest/threshold" :forest-wind :fade-seconds 4.0)
(dialog-music "forest/threshold" "audio/forest-lyria-drone.mp3" :volume 0.28)

(dialog-text "forest/threshold"
             "the brass key is warm enough to hurt. it fits the front door."
             :next "forest/porch")

(dialog-text "forest/porch"
             "outside, the house stands alone in a black pine forest. the porch boards are wet, but the sky is clear."
             :next "forest/first-choice")

(dialog-pick "forest/first-choice"
             "what do you do with the door?"
             (dialog-option "leave it open" "forest/trail")
             (dialog-option "lock it behind you" "forest/lock-door")
             (dialog-option "call into the house" "forest/call"))

(dialog-text "forest/lock-door"
             "the lock clicks twice. from inside, something clicks back once."
             :next "forest/trail")

(dialog-on-enter "forest/lock-door"
                 '(setf (dialog-value "forest-door-locked") t))

(dialog-text "forest/call"
             "your call comes back from inside the house, in your own voice, half a second late."
             :next "forest/trail")

(dialog-on-enter "forest/call"
                 '(setf (dialog-value "forest-called-out") t))

(dialog-text "forest/trail"
             "a trail begins where the porch light stops. boot prints lead away from the house. bare footprints lead toward it."
             :next "forest/sound")

(dialog-pick "forest/sound"
             "behind you, branches snap, each one closer than the last."
             (dialog-option "run for the creek" "forest/creek")
             (dialog-option "hide under the pines" "forest/hide")
             (dialog-option "turn around" "forest/look-back"))

(dialog-text "forest/creek"
             "you follow water you cannot see. every stone is slick with handprints."
             :next "forest/tag")

(dialog-text "forest/hide"
             "you press in under the pine boughs. a lantern passes, stops level with you, and hangs there for ten breaths before moving on."
             :next "forest/tag")

(dialog-text "forest/look-back"
             "the house is already small behind you, and you do not remember walking that far. one window is bright. one window has bars on the inside."
             :next "forest/tag")

(dialog-text "forest/tag"
             "a paper tag is tied around your wrist. the ink has run, but the first line still reads RETURN IF FOUND."
             :next "forest/name")

(dialog-string "forest/name"
               "what name is written underneath?"
               :response-key "forest-tag-name"
               :max-length 24
               :target "forest/pursuer")

(dialog-text "forest/pursuer"
             "behind you, a voice says {forest-tag-name} with the relief of someone finding misplaced property."
             :next "forest/choice")

(dialog-pick "forest/choice"
             "there are three dark gaps in the pines ahead."
             (dialog-option "the dry creek bed" "forest/creek-bed")
             (dialog-option "the deer fence" "forest/fence")
             (dialog-option "the root cellar" "forest/cellar"))

(dialog-text "forest/creek-bed"
             "you crawl beneath roots and old glass bottles. above you, the lantern follows the trail perfectly."
             :next "forest/unfinished")

(dialog-text "forest/fence"
             "the fence is high and new. every post has the same carved mark as the house key."
             :next "forest/unfinished")

(dialog-text "forest/cellar"
             "the cellar door is half buried. someone oiled the hinges recently."
             :next "forest/unfinished")

(dialog-text "forest/unfinished"
             "for now, you keep moving. you cannot tell if you are walking away from the house or circling back to it."
             :next "base/awake")
