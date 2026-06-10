(dialog-start "base/awake")

(dialog-particles "base/awake" :rising :immediate t)
(dialog-stop-music "base/awake")
(dialog-particles "ship/wake" :stars :fade-seconds 6.5)
(dialog-music "ship/wake" "audio/ship-lyria-drone.mp3" :volume 0.26)

(dialog-minigame-kind :wire-flight
                      :update #'update-flight-minigame-node
                      :draw #'draw-flight-minigame)

(dialog-minigame-kind :dream-maze
                      :update #'update-dream-maze-minigame-node
                      :draw #'draw-dream-maze-minigame)

(defun base-door-count-target ()
  (if (>= (dialog-value "door-count" 0) 5)
      "base/too-many-doors"
      "base/choose-door"))

(defun dream-maze-exit-target ()
  (let ((exit (dialog-value "dream-maze-exit" "")))
    (cond
      ((string= exit "left") "alice/fall")
      ((string= exit "upper") "rogue/entrance")
      ((string= exit "right") "dream/right-exit")
      (t "dream/maze-lost"))))

(defun ship-galley-target ()
  (if (plusp (dialog-value "ship-failures" 0))
      "ship/galley-remembered"
      "ship/galley"))


;;; Base room

(dialog-text "base/awake"
             "you awake in a strange world..."
             :next "base/feel")

;; Move this below any node while developing, then use New Game.
;; (dialog-dev-save-here
;;  :store '(("player-name" . "dev"))
;;  :visible :all)

(dialog-text "base/feel"
             "or at least that's how you feel..."
             :next "base/exit-bed")

(dialog-choice "base/exit-bed"
               "exit bed?"
               (dialog-option "yes" "base/exited-bed")
               (dialog-option "no" "base/sleep"))

(dialog-text "base/exited-bed"
             "you wearily open your eyes, there is a night stand next to your bed"
             :next "base/room-breath")

(dialog-text "base/room-breath"
             "you stretch and get out of bed"
             :next "base/thirst")

(dialog-choice "base/thirst"
               "drink from the glass on your night stand?"
               (dialog-option "yes" "ship/wake")
               (dialog-option "no"  "base/drawer"))

(dialog-text "base/drawer"
             "there are some drawers in your room, you rummage through the top one looking for something to wear. there's a paper matchbook sticking out of a shirt."
             :next "base/match")

(dialog-choice "base/match"
               "strike a match?"
               (dialog-option "yes" "base/light-lantern")
               (dialog-option "no"  "base/door-shadow"))

(dialog-text "base/light-lantern"
             "the match lights up, you spot a lantern that you can light with the match."
             :next "jrpg/inn")

(dialog-text "base/door-shadow"
             "close to the door, you can make out a lock plate."
             :next "base/door-key")

(dialog-text "base/door-key"
             "the key is on a small table by the door"
             :next "base/unlock-door")

(dialog-choice "base/unlock-door"
               "try it in the lock?"
               (dialog-option "yes" "forest/threshold")
               (dialog-option "no"  "base/count-doors"))

(dialog-number "base/count-doors"
               "how many doors do you count?"
               :response-key "door-count"
               :min 0
               :max 9
               :target #'base-door-count-target)

(dialog-text "base/too-many-doors"
             "you count again and get a different number. you stop counting."
             :next "base/choose-door")

(dialog-pick "base/choose-door"
             "which door do you try?"
             (dialog-option "left" "base/listen")
             (dialog-option "center" "base/listen")
             (dialog-option "right" "base/listen"))

(dialog-list-path "base/listen"
                  "select a sound from the hall."
                  ("breathing"
                   "slow, even breathing, just on the other side of the door.")
                  ("static"
                   "static, and under it a voice reading out numbers.")
                  ("water"
                   "water knocking through pipes above the door frame.")
                  ("glass"
                   "glass rattling in a window frame, keeping time with far-off thuds.")
                  ("keys"
                   "a ring of keys, and one lock after another being tried.")
                  ("bells"
                   "bells, far away, ringing on without stopping.")
                  ("steps"
                   "the steps stop one pace from the threshold.")
                  ("wood"
                   "floorboards creaking overhead, one at a time, crossing the ceiling.")
                  ("silence"
                   "nothing at all. the quiet of a door much thicker than it looks.")
                  ("hinges"
                   :when #'(lambda ()
                             (>= (dialog-value "door-count" 0) 5))
                   "hinges, one after another, as every door down the hall is opened and shut."))

(dialog-text "base/sleep"
             "you rolled over and went back to sleep, nothing of interest happened..."
             :next "dream/drift")


;;; Ship captain

(dialog-text "ship/wake"
             "the glass is cold in your hand. in its reflection, you notice restraint straps beside the bed and indicator lights under the night stand."
             :next "ship/name")

(dialog-string "ship/name"
               "a name is stenciled on the frame at the foot of the bed. what does it say?"
               :response-key "player-name"
               :max-length 24
               :target "ship/alarm")

(dialog-text "ship/alarm"
             "captain {player-name} to the bridge. the crossing is closing early."
             :next "ship/flight")

(dialog-minigame "ship/flight"
                 "w/a/s/d or arrow keys steer. hold the ship in the open gates."
                 :game :wire-flight
                 :success "ship/threaded"
                 :failure "ship/crash-return")

(dialog-text "ship/threaded"
             "you thread the line. for one second, the ship is quiet."
             :next "ship/bridge")

(dialog-text "ship/bridge"
             "on the bridge, Imari logs the crossing without looking up. Voss is already plotting the next lane. someone has taped your old checklist to the console."
             :next "ship/praise")

(dialog-conversation "ship/praise"
                     (dialog-left "Imari"
                                  "eighty-one seconds, captain. cleanest crossing on record.")
                     (dialog-right "{player-name}"
                                   "log it and stand down.")
                     (dialog-left "Imari"
                                  "you make it look rehearsed.")
                     :next #'ship-galley-target)

(dialog-text "ship/galley"
             "in the galley, Voss pours two cups and slides one across."
             :next "ship/voss-question")

(dialog-text "ship/galley-remembered"
             "in the galley, Voss pours two cups. mid-pour, her sleeve is burned to the elbow and the cup is in pieces on the floor. you blink. she hands you the cup, whole, and you hold it with both hands."
             :next "ship/voss-question")

(dialog-pick "ship/voss-question"
             "Voss asks how you knew the lane would hold."
             (dialog-option "tell her you read the drift" "ship/doctrine")
             (dialog-option "say you got lucky" "ship/luck")
             (dialog-option "say nothing and drink" "ship/quiet"))

(dialog-text "ship/doctrine"
             "she nods and writes it into the crossing manual. it is procedure now, with your name beside it."
             :next "ship/bunk")

(dialog-text "ship/luck"
             "she laughs and lets it go. from the doorway, Imari says the record speaks for itself."
             :next "ship/bunk")

(dialog-text "ship/quiet"
             "the cup is hot, then warm, then empty. Voss takes the silence as modesty."
             :next "ship/bunk")

(dialog-text "ship/bunk"
             "you lie down in the bunk with your name stenciled at the foot. you are asleep before the lights dim."
             :next "base/awake")

(dialog-on-enter "ship/crash-return"
                 '(setf (dialog-value "ship-failures")
                        (1+ (dialog-value "ship-failures" 0))))

(dialog-text "ship/crash-return"
             "white lines fill your eyes. when you blink them away, the alarm is still sounding."
             :next "ship/alarm")


;;; Dream maze

(dialog-text "dream/drift"
             "a few moments later, you fall asleep"
             :next "dream/fall")

(dialog-text "dream/fall"
             "you feel a falling sensation"
             :next "dream/maze")

(dialog-minigame "dream/maze"
                 "w/s or up/down move. a/d or left/right turn. find an exit."
                 :game :dream-maze
                 :success #'dream-maze-exit-target
                 :failure "dream/maze-lost")

(dialog-text "dream/right-exit"
             "past the right exit, the corridor straightens, and a painted line runs down the middle of the floor. the door at the end has the same handle as the one that was behind you."
             :next "base/awake")

(dialog-text "dream/maze-lost"
             "you lose the thread of which corridor came first."
             :next "base/awake")
