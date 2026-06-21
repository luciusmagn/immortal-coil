(defparameter *forest-wind-count* 84)

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

(defclass forest-wind-system (particle-system) ())

(defmethod particle-system-count ((system forest-wind-system))
  *forest-wind-count*)

(defmethod particle-system-make ((system forest-wind-system))
  (make-forest-wind-particle))

(defmethod particle-system-reset-particle ((system forest-wind-system)
                                           particle
                                           &key initial-p)
  (reset-forest-wind-particle particle :initial-p initial-p))

(defmethod particle-system-update-particle ((system forest-wind-system)
                                            particle
                                            dt)
  (update-forest-wind-particle particle dt))

(defmethod particle-field-draw :before ((system forest-wind-system)
                                        alpha-scale)
  (draw-forest-pines alpha-scale))

(defmethod particle-system-draw-particle ((system forest-wind-system)
                                          particle
                                          alpha-scale)
  (draw-forest-wind-particle particle alpha-scale))

(register-particle-field-definition
 (make-instance 'forest-wind-system :id :forest-wind))


(dialog-particles "forest/threshold" :forest-wind :fade-seconds 4.0)
(dialog-music "forest/threshold" "audio/forest-lyria-drone.mp3" :volume 0.28)

(defun forest-threshold-target ()
  (if (dialog-value "forest-refuge")
      "forest/threshold-again"
      "forest/threshold"))

(dialog-set-next "base/key-turn" #'forest-threshold-target)

(dialog-text "forest/threshold"
             "the brass key is warm enough to hurt. it fits the front door."
             :next "forest/porch")

(dialog-particles "forest/threshold-again" :forest-wind :fade-seconds 4.0)
(dialog-music "forest/threshold-again" "audio/forest-lyria-drone.mp3" :volume 0.28)

(dialog-text "forest/threshold-again"
             "the brass key is warm. the lock takes it on the first try this time."
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
             "in daylight the forest is just pines and cold. you keep the road in sight and follow the tire marks. twice you pass faded surveyor's tape tied at shoulder height."
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

(dialog-say "forest/truck-wave"
            "the driver"
            "morning. you're from the place up the hill, then."
            :next "forest/truck-wave-2")

(dialog-say "forest/truck-wave-2"
            "you"
            "what place up the hill?"
            :next "forest/truck-wave-3")

(dialog-say "forest/truck-wave-3"
            "the driver"
            "the one folk don't ask about. get in if you're getting in. i don't idle here."
            :next "forest/truck-cab")

(dialog-text "forest/truck-cab"
             "the cab smells of dog and diesel. the driver watches the mirrors more than the road. at the county sign he lets out a breath he has been holding since the mailboxes."
             :next "forest/truck-driver-questions")

(dialog-interrogation "forest/truck-driver-questions"
                      "the cab is warm and the driver keeps to his mirrors. the county sign is still a few miles of bad road off."
                      (:next "forest/truck-drop")
                      (:continue-label "ride the rest in quiet")
                      ("ask about the place up the hill"
                       :id "hill"
                       :speaker "the driver"
                       "i don't go up it. i drive the road at the bottom of it. that is a different job and i mean to keep it different.")
                      ("ask why folk don't ask about it"
                       :id "asking"
                       :speaker "the driver"
                       "asking is how you end up part of a thing. i have a dog and a route. i would like to keep both.")
                      ("ask what he gets for the drive"
                       :id "pay"
                       :speaker "the driver"
                       "nothing i would put on a form. somebody leaves diesel money in a mailbox when one of you comes down. i don't ask which box."))

(dialog-text "forest/truck-drop"
             "he drops you at a crossroads store with a phone, says nothing you can thank him for, and is gone. through the store window the clerk is already looking at you. it is a look she has used before."
             :next "forest/store")

(dialog-say "forest/store"
            "the clerk"
            "phone's by the cooler. local's free. you'll want coffee first. you all want coffee first."
            :next "forest/store-2")

(dialog-say "forest/store-2"
            "you"
            "you all?"
            :next "forest/store-3")

(dialog-say "forest/store-3"
            "the clerk"
            "hill folk. you come down maybe one a winter. drink your coffee. the phone will still be there."
            :next "forest/clerk-questions")

(dialog-interrogation "forest/clerk-questions"
                      "the coffee is hot and bad. the clerk leans on the register and lets you take the time you need to take."
                      (:next "forest/phone")
                      (:continue-label "reach for the phone")
                      ("ask about the other hill folk"
                       :id "hill-folk"
                       :speaker "the clerk"
                       "they come down thin and go back up fed, or they don't go back. i stopped telling which by looking. i was wrong too often to keep enjoying it.")
                      ("ask why she keeps the pot on"
                       :id "pot"
                       :speaker "the clerk"
                       "my sister went up the hill once. the coffee is for her, every winter. you are only who happens to drink it.")
                      ("ask what the call will cost"
                       :id "cost"
                       :speaker "the clerk"
                       "local is free, i said. the cost is that you will know who answers. nobody has ever put a coin in for that part."))

(dialog-pick "forest/phone"
             "the receiver is heavy and smells of other people's hands."
             (dialog-option "dial the operator" "forest/operator")
             (dialog-option "dial the number from the wrist tag" "forest/tag-number")
             (dialog-option "put the receiver back" "forest/no-call"))

(dialog-on-enter "forest/operator"
                 '(setf (dialog-value "forest-call") "operator"))

(dialog-text "forest/operator"
             "the operator asks who you need. you open your mouth and the answer is not there. she waits the way operators wait, and then says, gently, that she can connect you to the county office in the morning."
             :next "forest/store-night")

(dialog-on-enter "forest/tag-number"
                 '(setf (dialog-value "forest-call") "tag"))

(dialog-text "forest/tag-number"
             "under RETURN IF FOUND, under the name, there is a number. you dial it. it rings twice, and a voice you know from the hall of the house says, calm as housework, that you can come home now."
             :next "forest/store-night")

(dialog-on-enter "forest/no-call"
                 '(setf (dialog-value "forest-call") "none"))

(dialog-text "forest/no-call"
             "you set the receiver back. the clerk refills your coffee without being asked and writes nothing down. out here that is a kind of citizenship."
             :next "forest/store-night")

(dialog-text "forest/store-night"
             "the clerk lets you sit by the cooler until close. when she locks up she leaves the porch light on, points at the bench under it, and says the bus comes at six, most days."
             :next "forest/bench")

(dialog-text "forest/bench"
             "the bench holds the day's warmth for an hour and then gives it up. you sleep in pieces under the porch light, and nothing comes up the road all night except the road's own sounds, which you are learning."
             :next "forest/bench-dream")

(dialog-text "forest/bench-dream"
             "in one of the pieces of sleep there is a kitchen, and bread cooling on a rack, and someone humming low through a door, and you wake from it warm, which frightens you more than the forest managed all night."
             :next "forest/bus")

(dialog-text "forest/bus"
             "the bus comes at six, most days, and this is one of them. the doors fold open before you stand up, the way they do for people the driver has already decided about."
             :next "forest/board-choice")

(dialog-pick "forest/board-choice"
             "the doors stand open. the engine idles. the driver does not hurry you, which is its own kind of question."
             (dialog-option "get on" "forest/fare")
             (dialog-option "stay on the bench" "winter/doors"))

(dialog-say "forest/fare"
            "the driver"
            "county line's free going out. coming back costs. that's not the company, that's me."
            :next "forest/fare-2")

(dialog-say "forest/fare-2"
            "you"
            "why coming back?"
            :next "forest/fare-3")

(dialog-say "forest/fare-3"
            "the driver"
            "because going out i'm helping. coming back i'm just driving. sit anywhere behind the line."
            :next "forest/passengers")

(dialog-text "forest/passengers"
             "there are four passengers and room for forty. nobody sits near you. nobody makes it unkind. past the gravel pits a woman in a postal jacket passes you half a sandwich over the seat back, without turning around."
             :next "forest/county-line")

(dialog-pick "forest/county-line"
             "the county line stop is a pole in the grass. the bus slows."
             (dialog-option "get off at the line" "forest/get-off")
             (dialog-option "stay on past it" "forest/stay-on")
             (dialog-option "ask the driver about the hill" "forest/ask-driver"))

(dialog-on-enter "forest/get-off"
                 '(setf (dialog-value "forest-bus") "line"))

(dialog-text "forest/get-off"
             "you step down at the pole. across the line the fields are fenced in wire, not plank, and the first mailbox you pass has a name on it that has never been painted over."
             :next "forest/county-dusk")

(dialog-text "forest/county-dusk"
             "dusk beyond the county line looks ordinary: yard lights, wire fence, cut field. relief does not come with it."
             :next "forest/bus-end")

(dialog-on-enter "forest/stay-on"
                 '(setf (dialog-value "forest-bus") "stayed"))

(dialog-text "forest/stay-on"
             "you stay on. the route runs the valley, turns with the river, and climbs. by the second hour you know the shape of it. the road does not leave the hill's country. it circles it, the way water circles a stone."
             :next "forest/bus-end")

(dialog-on-enter "forest/ask-driver"
                 '(setf (dialog-value "forest-bus") "asked"))

(dialog-say "forest/ask-driver"
            "the driver"
            "the hill. you want to know if anyone's gone up and asked."
            :next "forest/ask-driver-2")

(dialog-say "forest/ask-driver-2"
            "you"
            "have they?"
            :next "forest/ask-driver-3")

(dialog-say "forest/ask-driver-3"
            "the driver"
            "twice that i know. county went up in my father's day and came down satisfied. nobody can tell you satisfied with what. that's the part that keeps the rest of us on the road."
            :next "forest/bus-end")

(dialog-text "forest/bus-end"
             "wherever the day ends, it ends with you still moving, the hill somewhere over your shoulder, in no hurry. when you finally sleep it is the deep kind, and it takes you all at once."
             :next "sys/reboot")

(dialog-on-enter "forest/truck-hide"
                 '(setf (dialog-value "forest-dawn") "hid"))

(dialog-text "forest/truck-hide"
             "you stay in the trees. the pickup slows at the boxes anyway, pauses by the newest one, and moves on. whoever it was knew the boxes well enough not to look at them."
             :next "forest/road-back")

(dialog-on-enter "forest/mailbox-open"
                 '(setf (dialog-value "forest-dawn") "opened"))

(dialog-text "forest/mailbox-open"
             "the box opens stiffly. inside: circulars, a seed catalog, and one envelope addressed by hand to {forest-tag-name}, postmarked eleven years ago, unopened. the pickup passes while you are holding it."
             :next "forest/letter-choice")

(dialog-pick "forest/letter-choice"
             "the flap has been steamed and resealed once already, long ago, by someone careful."
             (dialog-option "open the letter" "forest/letter-read")
             (dialog-option "put it back in the box" "forest/letter-back"))

(dialog-on-enter "forest/letter-read"
                 '(setf (dialog-value "forest-letter") "read"))

(dialog-text "forest/letter-read"
             "one page, in the round patient hand of someone writing to a child."
             :next "forest/letter-read-s2")

(dialog-text "forest/letter-read-s2"
             "it says the garden came in, that the dog found her way home, and that there is no shame in coming home the same way."
             :next "forest/letter-read-s3")

(dialog-text "forest/letter-read-s3"
             "it is signed with love, and no name, and you fold it along the old folds."
             :next "forest/road-back")

(dialog-on-enter "forest/letter-back"
                 '(setf (dialog-value "forest-letter") "kept"))

(dialog-text "forest/letter-back"
             "you put it back the way evidence goes back: exactly, and with the sick sense of having signed for it anyway. the box closes on the first try, which boxes out here do not."
             :next "forest/road-back")

(defun forest-porch-again-target ()
  (cond
    ((dialog-value "forest-called-out") "forest/porch-again-call")
    ((dialog-value "forest-door-locked") "forest/porch-again-lock")
    (t "forest/porch-again")))

(dialog-text "forest/road-back"
             "the road bends with the hill, and every branch of it climbs. by noon you understand what the driver could have told you: out here all the lanes are the hill's lanes, and the hill has one house."
             :next #'forest-porch-again-target)

(dialog-text "forest/porch-again"
             "you come out of the trees above the house. on the porch, someone is sweeping. they stop, shade their eyes toward your stretch of woods, and wave, unhurried, the way you wave at family."
             :next "forest/porch-choice")

(dialog-text "forest/porch-again-call"
             "you come out of the trees above the house. on the porch, someone is sweeping, humming two notes over and over, low and patient."
             :next "forest/porch-again-call-s2")

(dialog-text "forest/porch-again-call-s2"
             "they are the two notes of your own call into the hall. they stop, shade their eyes toward your stretch of woods, and wave."
             :next "forest/porch-choice")

(dialog-text "forest/porch-again-lock"
             "you come out of the trees above the house. the front door you locked stands open, the key in the outside of the lock, turned. on the porch, someone is sweeping. they stop, shade their eyes toward your stretch of woods, and wave."
             :next "forest/porch-choice")

(dialog-pick "forest/porch-choice"
             "the broom leans on the rail. the door behind them is open."
             (dialog-option "go down to the house" "forest/go-down")
             (dialog-option "stay still until they stop" "forest/stay-still")
             (dialog-option "turn and keep to the trees" "forest/keep-going"))

(dialog-on-enter "forest/go-down"
                 '(setf (dialog-value "forest-porch") "returned"))

(dialog-text "forest/go-down"
             "you walk down. they hold the door the way it has always been held for you. the warmth inside smells like every winter you can remember. that is the problem with it."
             :next "house/inside")

(dialog-on-enter "forest/stay-still"
                 '(setf (dialog-value "forest-porch") "stood"))

(dialog-text "forest/stay-still"
             "you stand still. they finish waving, pick up the broom, and go on sweeping. they leave the door open. it is still open when the light starts to go."
             :next "forest/door-watch")

(dialog-on-enter "forest/door-watch"
                 '(setf (dialog-value "forest-two-plates") t))

(dialog-text "forest/door-watch"
             "you watch the open door the way you watched the hall sounds, cataloguing: lamplight, woodsmoke, the clink of one plate being laid. then a second plate."
             :next "forest/door-watch-s2")

(dialog-text "forest/door-watch-s2"
             "whoever sets the table sets it for two, every night, on the chance the second chair fills."
             :next "forest/dawn-end")

(dialog-on-enter "forest/keep-going"
                 '(setf (dialog-value "forest-porch") "fled"))

(dialog-text "forest/keep-going"
             "you turn along the ridge and keep moving. behind you the sweeping goes on, unworried, the sound carrying the way sound does when no one is chasing you because no one needs to."
             :next "forest/ridge-dusk")

(dialog-text "forest/ridge-dusk"
             "dusk catches you on the ridge with the house's chimney smoke below, rising straight. somewhere downslope, a lantern is lit, and begins, without hurry, to climb."
             :next "forest/ridge-hide")

(dialog-minigame "forest/ridge-hide"
                 "space, w, or up arrow lets a breath out. stay quiet until the light moves on."
                 :game :forest-hide
                 :success "forest/ridge-passed"
                 :failure "forest/ridge-heard"
                 :config '(:duration 7.0 :breath-rise 0.11))

(dialog-text "forest/ridge-passed"
             "the lantern crests the ridge two pines over, hangs a while looking at the dark you are part of, and goes down the far side. for the first time, you watched it the whole way through, and your count of your own breathing held."
             :next "forest/dawn-end")

(dialog-on-enter "forest/ridge-heard"
                 '(setf (dialog-value "forest-seen") t))

(dialog-text "forest/ridge-heard"
             "the lantern stops below your stretch of dark and stays there through eleven breaths, the long kind. when it finally goes down the far side, it goes without searching, the way you leave a room when you know where everything is."
             :next "forest/dawn-end")

(dialog-text "forest/dawn-end"
             "you walk until walking is all there is. when you finally sleep, it is sudden and dreamless, in the needles, with your back against a fence post you did not check for carvings."
             :next "sys/reboot")
