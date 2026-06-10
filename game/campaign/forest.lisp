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
             "you press in under the pine boughs. the lantern comes up the trail."
             :next "forest/hold-still")

(dialog-minigame "forest/hold-still"
                 "space, w, or up arrow lets a breath out. stay quiet until the light moves on."
                 :game :forest-hide
                 :success "forest/hide-passed"
                 :failure "forest/hide-heard")

(dialog-text "forest/hide-passed"
             "the light slides past and on up the trail. you let your breath go a little at a time."
             :next "forest/tag")

(dialog-text "forest/hide-heard"
             "the light swings back and hangs level with you for ten breaths. then it moves on, slower than before."
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
             :next "forest/culvert")

(dialog-on-enter "forest/culvert"
                 '(setf (dialog-value "forest-refuge") "culvert"))

(dialog-text "forest/culvert"
             "the creek bed runs under a road through a concrete culvert. you wait in it while two cars pass overhead. neither slows. the lantern light stops at the tree line and turns back."
             :next "forest/unfinished")

(dialog-text "forest/fence"
             "the fence is high and new. every post has the same carved mark as the house key."
             :next "forest/gate")

(dialog-on-enter "forest/gate"
                 '(setf (dialog-value "forest-refuge") "gate"))

(dialog-text "forest/gate"
             "you follow the fence to a gate. the chain on it is new. the sign bolted to the bars faces you: PRIVATE PROPERTY. KEEP OUT."
             :next "forest/unfinished")

(dialog-text "forest/cellar"
             "the cellar door is half buried. someone oiled the hinges recently."
             :next "forest/cellar-dark")

(dialog-on-enter "forest/cellar-dark"
                 '(setf (dialog-value "forest-refuge") "cellar"))

(dialog-text "forest/cellar-dark"
             "you pull the door shut over your head. there is a box of matches on the second step. the first match shows a cot, a water jug, and four paper tags hanging on a nail."
             :next "forest/cellar-overhead")

(dialog-text "forest/cellar-overhead"
             "boards creak overhead, one set of steps, taking their time. dust comes down through the cracks with each pass."
             :next "forest/unfinished")

(dialog-text "forest/unfinished"
             "you wait out the dark in short stretches, never long in one place. by the time the sky greys, you cannot tell if you have moved away from the house or in a circle around it."
             :next "forest/dawn")


;;; First light: the road, the mailboxes, and the way back past the house.

(defun forest-dawn-target ()
  (let ((refuge (dialog-value "forest-refuge" "")))
    (cond
      ((string= refuge "culvert") "forest/dawn-culvert")
      ((string= refuge "gate") "forest/dawn-gate")
      ((string= refuge "cellar") "forest/dawn-cellar")
      (t "forest/dawn-walk"))))

(dialog-scene "forest/dawn"
              "first light."
              :next #'forest-dawn-target)

(dialog-text "forest/dawn-culvert"
             "you wake in the culvert with the creek in your shoes. the road overhead is quiet now, and the frost on the concrete shows one set of boot prints that stopped at the mouth and went away."
             :next "forest/dawn-walk")

(dialog-text "forest/dawn-gate"
             "you wake against the fence with the gate chain printed in your cheek. in daylight the sign is older than it looked, repainted many times, the same words every coat."
             :next "forest/dawn-walk")

(dialog-text "forest/dawn-cellar"
             "you wake on the cot because you let yourself use the cot, near the end. the matches are gone from the shelf. the tags still hang on the nail, and you do not count them again."
             :next "forest/dawn-walk")

(dialog-text "forest/dawn-walk"
             "in daylight the forest is just pines and cold. you keep the road in sight through the trees and walk in the direction the cars went."
             :next "forest/mailboxes")

(dialog-text "forest/mailboxes"
             "where a gravel lane meets the road there is a rack of mailboxes, five of them, names painted and weathered off. on the newest box the name is still readable: {forest-tag-name}."
             :next "forest/mailbox-choice")

(dialog-pick "forest/mailbox-choice"
             "down the road, an engine. a pickup, coming slow."
             (dialog-option "step out and wave it down" "forest/truck-wave")
             (dialog-option "stay in the tree line" "forest/truck-hide")
             (dialog-option "open the mailbox first" "forest/mailbox-open"))

(dialog-on-enter "forest/truck-wave"
                 '(setf (dialog-value "forest-dawn") "waved"))

(dialog-conversation "forest/truck-wave"
                     (dialog-left "the driver"
                                  "morning. you're from the place up the hill, then.")
                     (dialog-right "you"
                                   "what place up the hill?")
                     (dialog-left "the driver"
                                  "the one folk don't ask about. get in if you're getting in. i don't idle here.")
                     :next "forest/truck-cab")

(dialog-text "forest/truck-cab"
             "the cab smells of dog and diesel. the driver watches the mirrors more than the road, and at the county sign he lets out a breath he has been holding since the mailboxes."
             :next "forest/truck-drop")

(dialog-text "forest/truck-drop"
             "he drops you at a crossroads store with a phone, says nothing you can thank him for, and is gone. through the store window, the clerk is already looking at you like a question she has asked before."
             :next "forest/dawn-end")

(dialog-on-enter "forest/truck-hide"
                 '(setf (dialog-value "forest-dawn") "hid"))

(dialog-text "forest/truck-hide"
             "you stay in the trees. the pickup slows at the boxes anyway, pauses by the newest one, and moves on. whoever it was knew the boxes well enough not to look at them."
             :next "forest/road-back")

(dialog-on-enter "forest/mailbox-open"
                 '(setf (dialog-value "forest-dawn") "opened"))

(dialog-text "forest/mailbox-open"
             "the box opens stiffly. inside: circulars, a seed catalog, and one envelope addressed by hand to {forest-tag-name}, postmarked eleven years ago, unopened. the pickup passes while you are holding it."
             :next "forest/road-back")

(dialog-text "forest/road-back"
             "the road bends with the hill, and every branch of it climbs. by noon you understand what the driver could have told you: out here all the lanes are the hill's lanes, and the hill has one house."
             :next "forest/porch-again")

(dialog-text "forest/porch-again"
             "you come out of the trees above the house. on the porch, someone is sweeping. they stop, shade their eyes toward your stretch of woods, and wave, unhurried, the way you wave at family."
             :next "forest/porch-choice")

(dialog-pick "forest/porch-choice"
             "the broom leans on the rail. the door behind them is open."
             (dialog-option "go down to the house" "forest/go-down")
             (dialog-option "stay still until they stop" "forest/stay-still")
             (dialog-option "turn and keep to the trees" "forest/keep-going"))

(dialog-on-enter "forest/go-down"
                 '(setf (dialog-value "forest-porch") "returned"))

(dialog-text "forest/go-down"
             "you walk down. they hold the door the way it has always been held for you, and the warmth inside smells like every winter you can remember, which is the problem with it."
             :next "forest/dawn-end")

(dialog-on-enter "forest/stay-still"
                 '(setf (dialog-value "forest-porch") "stood"))

(dialog-text "forest/stay-still"
             "you stand still. they finish waving, pick up the broom, and go on sweeping. they leave the door open. it is still open when the light starts to go."
             :next "forest/dawn-end")

(dialog-on-enter "forest/keep-going"
                 '(setf (dialog-value "forest-porch") "fled"))

(dialog-text "forest/keep-going"
             "you turn along the ridge and keep moving. behind you the sweeping goes on, unworried, the sound carrying the way sound does when no one is chasing you because no one needs to."
             :next "forest/dawn-end")

(dialog-text "forest/dawn-end"
             "you walk until walking is all there is. when you finally sleep, it is sudden and dreamless, in the needles, with your back against a fence post you did not check for carvings."
             :next "base/awake")
