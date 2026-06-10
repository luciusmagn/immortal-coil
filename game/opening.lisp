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

(dialog-on-enter "base/door-key"
                 '(setf (dialog-value "has-brass-key") t))

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
             :next "ship/second-alarm")

(dialog-text "ship/luck"
             "she laughs and lets it go. from the doorway, Imari says the record speaks for itself."
             :next "ship/second-alarm")

(dialog-text "ship/quiet"
             "the cup is hot, then warm, then empty. Voss takes the silence as modesty."
             :next "ship/second-alarm")

(dialog-text "ship/second-alarm"
             "the cup is still in your hand when the second alarm starts, lower than the first. Imari's voice on the open channel: pressure fault aft, decks six and seven, spreading forward."
             :next "ship/breach-report")

(dialog-conversation "ship/breach-report"
                     (dialog-left "Imari"
                                  "Harrow is in six at the drive trunk. Okafor and two ratings are in seven. Dane is between them with the kit.")
                     (dialog-right "{player-name}"
                                   "time to seal?")
                     (dialog-left "Imari"
                                  "one bulkhead, captain. the actuator will not cycle twice before the trunk goes. six or seven. your call.")
                     :next "ship/breach-choice")

(dialog-pick "ship/breach-choice"
             "the board shows both decks amber, going red."
             (dialog-option "seal deck six" "ship/seal-six")
             (dialog-option "seal deck seven" "ship/seal-seven")
             (dialog-option "hold both open for Dane" "ship/hold-open"))

(dialog-on-enter "ship/seal-six"
                 '(setf (dialog-value "ship-lost-name") "Harrow"))

(dialog-text "ship/seal-six"
             "you seal six. the drive trunk holds because Harrow holds it, and the last thing through the channel is Harrow reading out trunk pressure, steady, until there is no more channel."
             :next "ship/second-flight")

(dialog-on-enter "ship/seal-seven"
                 '(setf (dialog-value "ship-lost-name") "Okafor"))

(dialog-text "ship/seal-seven"
             "you seal seven. Okafor does not call the bridge. the two ratings with him are named Imre and Sel, and you make yourself think both names while the board goes red."
             :next "ship/second-flight")

(dialog-on-enter "ship/hold-open"
                 '(setf (dialog-value "ship-lost-name") "Dane"))

(dialog-text "ship/hold-open"
             "you hold both bulkheads for Dane. Dane clears seven with one rating under each arm, turns back for Okafor, and the trunk goes while the doors are still open. you seal onto silence."
             :next "ship/second-flight")

(dialog-minigame "ship/second-flight"
                 "w/a/s/d or arrow keys steer. hold the ship in the open gates."
                 :game :wire-flight
                 :success "ship/aftermath"
                 :failure "ship/crash-return")

(dialog-text "ship/aftermath"
             "the crossing holds. the board goes green deck by deck, except where it stays dark, and the bridge is very loud with no one saying anything."
             :next "ship/aftermath-praise")

(dialog-conversation "ship/aftermath-praise"
                     (dialog-left "Voss"
                                  "textbook seal, captain. nobody cycles an actuator that clean under fault.")
                     (dialog-right "{player-name}"
                                   "log the names first.")
                     (dialog-left "Imari"
                                  "logged. cause of loss: crossing fault. action of record: correct and timely. that is what the record will say.")
                     :next "ship/letters")

(dialog-text "ship/letters"
             "you write to {ship-lost-name}'s family in the format the manual provides. the manual provides three sentences. you use all three and sit a long time over the fourth that is not provided."
             :next "ship/next-watch")

(dialog-scene "ship/next-watch"
              "the next watch."
              :next "ship/watch-bridge")

(dialog-text "ship/watch-bridge"
             "the bridge runs quiet and exact. Voss recalibrates the lane tables without being asked, twice, the second time more slowly, getting the same answer and not liking it any better."
             :next "ship/log-sign")

(dialog-conversation "ship/log-sign"
                     (dialog-left "Imari"
                                  "the watch log, captain. it needs your signature under mine.")
                     (dialog-right "{player-name}"
                                   "read me the loss entry.")
                     (dialog-left "Imari"
                                  "cause of loss: crossing fault. action of record: correct and timely. it is true, captain. i was careful that every word of it is true.")
                     :next "ship/log-choice")

(dialog-pick "ship/log-choice"
             "the stylus is warm from Imari's hand."
             (dialog-option "sign it as written" "ship/sign-clean")
             (dialog-option "add a commendation" "ship/sign-commend")
             (dialog-option "amend: the order was mine" "ship/sign-amend"))

(dialog-on-enter "ship/sign-clean"
                 '(setf (dialog-value "ship-log") "clean"))

(dialog-text "ship/sign-clean"
             "you sign under Imari's hand. the log closes with the soft click of a thing built to outlast everyone who writes in it."
             :next "ship/watch-voss")

(dialog-on-enter "ship/sign-commend"
                 '(setf (dialog-value "ship-log") "commended"))

(dialog-text "ship/sign-commend"
             "you add the commendation, posthumous, in the space reserved for it. there is a space reserved for it. you try not to think about how the manual knew."
             :next "ship/watch-voss")

(dialog-on-enter "ship/sign-amend"
                 '(setf (dialog-value "ship-log") "amended"))

(dialog-conversation "ship/sign-amend"
                     (dialog-right "{player-name}"
                                   "add a line. the seal order was mine, on my judgment, with time to choose.")
                     (dialog-left "Imari"
                                  "respectfully, captain: no. the record protects the living. your judgment is what let there be living. i will not log it as a confession.")
                     (dialog-right "{player-name}"
                                   "then log that i asked.")
                     (dialog-left "Imari"
                                  "that, i will log.")
                     :next "ship/watch-voss")

(dialog-text "ship/watch-voss"
             "at end of watch, Voss leaves a cup at your elbow without a word. it is exactly too hot to drink, which means she timed it to outlast the paperwork."
             :next "ship/bunk")

(dialog-text "ship/bunk"
             "you lie down in the bunk with your name stenciled at the foot. you are asleep before the lights dim."
             :next "ship/later")

(dialog-scene "ship/later"
              "the same ship. later."
              :next "ship/later-bridge")

(dialog-text "ship/later-bridge"
             "the bridge is dark except for the console light. your checklist is still taped beside it, soft at the corners. you cannot remember when you last heard another voice on board."
             :next "ship/later-galley")

(dialog-text "ship/later-galley"
             "in the galley there is one cup on the rack. the crossing manual lies open to the page with your name beside the procedure."
             :next "ship/later-roster")

(dialog-text "ship/later-roster"
             "the duty roster by the door has not been changed. {ship-lost-name} is still on it, third watch. so is everyone."
             :next "ship/later-chair")

(dialog-text "ship/later-chair"
             "you sit in the captain's chair until the cup goes cold. somewhere below, a door you have stopped checking stays shut."
             :next "ship/later-walk")

(dialog-text "ship/later-walk"
             "you do the rounds because the rounds are what there is. deck two: lights answer the motion sensors one section ahead of you, the way they would for anyone."
             :next "ship/later-medbay")

(dialog-text "ship/later-medbay"
             "medbay is stowed and clean. Dane's kit hangs on its peg, sealed, inventory tag signed off in Dane's hand. the date on the tag is not one you can place against anything."
             :next "ship/later-quarters")

(dialog-text "ship/later-quarters"
             "the crew quarters are made up like the morning of an inspection. in Imari's there is a logbook of personal entries, and you stand in the doorway and do not read it, and are proud of that for the rest of the watch."
             :next "ship/later-comms")

(dialog-text "ship/later-comms"
             "the comms board holds one message in the outbound queue, flagged unsent. it is addressed to {ship-lost-name}'s family. it has four sentences. you do not remember writing the fourth."
             :next "ship/later-hail")

(dialog-text "ship/later-hail"
             "once per watch, the board hails the lane and listens. tonight, like every night you can remember, the lane answers with carrier tone: a clean, patient signal with nobody on it."
             :next "ship/later-bunk")

(dialog-text "ship/later-bunk"
             "you turn in at the bunk with the stenciled name. the stencil is worn now, repainted at least once, the letters traced over themselves a little off true."
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
