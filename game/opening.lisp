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

(defparameter *base-wake-echoes*
  '(("alice-thread-pocket" . "thread")
    ("ship-lost-name" . "cup")
    ("war-first-order" . "desk")
    ("forest-refuge" . "pitch")
    ("jrpg-vane-answer" . "bread")
    ("rogue-saw-tally" . "chalk")
    ("facility-designation" . "laminate")))

(defun choose-wake-echo ()
  (let ((available (loop for (flag . echo) in *base-wake-echoes*
                         when (dialog-value flag)
                           collect echo)))
    (setf (dialog-value "wake-echo")
          (when available
            (nth (mod (dialog-value "wakes" 0) (length available))
                 available)))))

(defun wake-echo-p (echo)
  (equal (dialog-value "wake-echo" "") echo))

(defun base-exited-bed-target ()
  (if (wake-echo-p "thread")
      "base/exited-bed-thread"
      "base/exited-bed"))

(defun base-room-breath-target ()
  (cond
    ((wake-echo-p "cup") "base/room-breath-cup")
    ((wake-echo-p "desk") "base/room-breath-desk")
    (t "base/room-breath")))

(defun base-drawer-target ()
  (cond
    ((wake-echo-p "pitch") "base/drawer-pitch")
    ((wake-echo-p "bread") "base/drawer-bread")
    (t "base/drawer")))

(defun base-door-shadow-target ()
  (if (wake-echo-p "laminate")
      "base/door-shadow-laminate"
      "base/door-shadow"))

(defun base-door-key-target ()
  (if (wake-echo-p "chalk")
      "base/door-key-chalk"
      "base/door-key"))

(defun ship-galley-target ()
  (if (plusp (dialog-value "ship-failures" 0))
      "ship/galley-remembered"
      "ship/galley"))

(defun ship-wake-target ()
  (if (dialog-value "ship-lost-name")
      "ship/wake-after"
      "ship/wake"))


;;; Base room

(dialog-on-enter "base/awake"
                 '(setf (dialog-value "wakes")
                        (1+ (dialog-value "wakes" 0)))
                 'choose-wake-echo)

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
               (dialog-option "yes" #'base-exited-bed-target)
               (dialog-option "no" "base/sleep"))

(dialog-text "base/exited-bed"
             "you wearily open your eyes, there is a night stand next to your bed"
             :next #'base-room-breath-target)

(dialog-text "base/exited-bed-thread"
             "you wearily open your eyes, there is a night stand next to your bed. pushing back the blanket takes a moment: a loop of white thread is wound twice around two of your fingers."
             :next #'base-room-breath-target)

(dialog-text "base/room-breath"
             "you stretch and get out of bed"
             :next "base/thirst")

(dialog-text "base/room-breath-cup"
             "you stretch and get out of bed. your right hand stays curled a moment, as if it had been holding a cup."
             :next "base/thirst")

(dialog-text "base/room-breath-desk"
             "you stretch and get out of bed. your neck aches the way it does after sleeping at a desk."
             :next "base/thirst")

(dialog-choice "base/thirst"
               "drink from the glass on your night stand?"
               (dialog-option "yes" "base/drink")
               (dialog-option "no"  #'base-drawer-target))

(dialog-text "base/drink"
             "you drink. the water is colder than anything else in the room."
             :next #'ship-wake-target)

(dialog-text "base/drawer"
             "there are some drawers in your room, you rummage through the top one looking for something to wear. there's a paper matchbook sticking out of a shirt."
             :next "base/match")

(dialog-text "base/drawer-pitch"
             "there are some drawers in your room, you rummage through the top one looking for something to wear. there's a paper matchbook sticking out of a shirt, and pine pitch under two of your fingernails."
             :next "base/match")

(dialog-text "base/drawer-bread"
             "there are some drawers in your room, you rummage through the top one looking for something to wear. there's a paper matchbook sticking out of a shirt. the shirt smells faintly of bread."
             :next "base/match")

(dialog-choice "base/match"
               "strike a match?"
               (dialog-option "yes" "base/light-lantern")
               (dialog-option "no"  #'base-door-shadow-target))

(dialog-text "base/light-lantern"
             "the match lights up, you spot a lantern that you can light with the match."
             :next "jrpg/crown-flash")

(dialog-text "base/door-shadow"
             "close to the door, you can make out a lock plate."
             :next #'base-door-key-target)

(dialog-text "base/door-shadow-laminate"
             "close to the door, you can make out a lock plate. under your fingertips it is smooth as laminate."
             :next #'base-door-key-target)

(dialog-on-enter "base/door-key"
                 '(setf (dialog-value "has-brass-key") t))

(dialog-text "base/door-key"
             "the key is on a small table by the door"
             :next "base/unlock-door")

(dialog-on-enter "base/door-key-chalk"
                 '(setf (dialog-value "has-brass-key") t))

(dialog-text "base/door-key-chalk"
             "the key is on a small table by the door. picking it up leaves chalk dust on the pad of your thumb."
             :next "base/unlock-door")

(dialog-choice "base/unlock-door"
               "try it in the lock?"
               (dialog-option "yes" "base/key-turn")
               (dialog-option "no"  "base/count-doors"))

(dialog-text "base/key-turn"
             "the key turns through one full rotation, then a second. cold air moves through the gap before the door is properly open."
             :next "forest/threshold")

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
             :next "dream/maze")


;;; Ship captain

(dialog-text "ship/wake"
             "the glass is cold in your hand. in the reflection there are straps beside the bed. there are indicator lights under the night stand. they are lit."
             :next "ship/name")

(dialog-particles "ship/wake-after" :stars :fade-seconds 6.5)
(dialog-music "ship/wake-after" "audio/ship-lyria-drone.mp3" :volume 0.26)

(dialog-text "ship/wake-after"
             "the glass is cold in your hand. you drink it standing. you do not look at the reflection."
             :next "ship/alarm")

(dialog-string "ship/name"
               "a name is stenciled on the frame at the foot of the bed. what does it say?"
               :response-key "player-name"
               :max-length 24
               :target "ship/alarm")

(dialog-text "ship/alarm"
             "captain {player-name} to the bridge. the crossing is closing early."
             :next "ship/flight")

(dialog-particles "ship/alarm" :stars :fade-seconds 1.1)

(dialog-minigame "ship/flight"
                 "w/a/s/d or arrow keys steer. hold the ship in the open gates."
                 :game :wire-flight
                 :success "ship/threaded"
                 :failure "ship/loop-reset")

(dialog-text "ship/threaded"
             "you thread the line. for one second, the ship is quiet."
             :next "ship/bridge")

(dialog-text "ship/bridge"
             "on the bridge, Imari logs the crossing without looking up. Voss is plotting the next lane. someone has taped your old checklist to the console."
             :next "ship/praise")

(dialog-say "ship/praise" "Imari"
            "eighty-one seconds, captain. cleanest crossing on record."
            :next "ship/praise-2")

(dialog-say "ship/praise-2" "you"
            "log it and stand down."
            :next "ship/praise-3")

(dialog-say "ship/praise-3" "Imari"
            "you make it look rehearsed."
            :next #'ship-galley-target)

(dialog-text "ship/galley"
             "in the galley, Voss pours two cups and slides one across."
             :next "ship/voss-question")

(dialog-text "ship/galley-remembered"
             "in the galley, Voss pours two cups. her sleeve is burned to the elbow and the cup is in pieces on the floor. you blink. the sleeve is whole. she hands you the cup and you hold it with both hands."
             :next "ship/voss-question")

(dialog-pick "ship/voss-question"
             "Voss asks how you knew the lane would hold."
             (dialog-option "tell her you read the drift" "ship/doctrine")
             (dialog-option "say you got lucky" "ship/luck")
             (dialog-option "say nothing and drink" "ship/quiet")
             (dialog-option "tell her the truth" "mutiny/truth"))

(dialog-on-enter "ship/doctrine"
                 '(setf (dialog-value "ship-voss-answer") "doctrine"))

(dialog-text "ship/doctrine"
             "she nods and writes it into the crossing manual. it is procedure now, with your name beside it."
             :next "ship/second-alarm")

(dialog-on-enter "ship/luck"
                 '(setf (dialog-value "ship-voss-answer") "luck"))

(dialog-text "ship/luck"
             "she laughs and lets it go. from the doorway, Imari says the record speaks for itself."
             :next "ship/second-alarm")

(dialog-on-enter "ship/quiet"
                 '(setf (dialog-value "ship-voss-answer") "quiet"))

(dialog-text "ship/quiet"
             "the cup is hot, then warm, then empty. Voss takes the silence for modesty."
             :next "ship/second-alarm")

(dialog-text "ship/second-alarm"
             "the cup is still in your hand when the second alarm starts, lower than the first. Imari's voice on the open channel: pressure fault aft, decks six and seven, spreading forward."
             :next "ship/breach-report")

(dialog-say "ship/breach-report" "Imari"
            "Harrow is in six at the drive trunk. Okafor and two ratings are in seven. Dane is between them with the kit."
            :next "ship/breach-report-2")

(dialog-say "ship/breach-report-2" "you"
            "time to seal?"
            :next "ship/breach-report-3")

(dialog-say "ship/breach-report-3" "Imari"
            "one bulkhead, captain. the actuator will not cycle twice before the trunk goes. six or seven. your call."
            :next "ship/breach-choice")

(dialog-pick "ship/breach-choice"
             "the board shows both decks amber, going red."
             (dialog-option "seal deck six" "ship/seal-six")
             (dialog-option "seal deck seven" "ship/seal-seven")
             (dialog-option "hold both open for Dane" "ship/hold-open"))

(dialog-on-enter "ship/seal-six"
                 '(setf (dialog-value "ship-lost-name") "Harrow"))

(dialog-text "ship/seal-six"
             "you seal six. Harrow holds the trunk. the last thing on the channel is Harrow reading the pressure, steady, and then there is no more channel."
             :next "ship/second-flight")

(dialog-on-enter "ship/seal-seven"
                 '(setf (dialog-value "ship-lost-name") "Okafor"))

(dialog-text "ship/seal-seven"
             "you seal seven. Okafor does not call the bridge. the two ratings with him are Imre and Sel. you say both names to yourself while the board goes red."
             :next "ship/second-flight")

(dialog-on-enter "ship/hold-open"
                 '(setf (dialog-value "ship-lost-name") "Dane"))

(dialog-text "ship/hold-open"
             "you hold both bulkheads for Dane. Dane clears seven with a rating under each arm and turns back for Okafor. the trunk goes while the doors are open. you seal them on nothing."
             :next "ship/second-flight")

(dialog-minigame "ship/second-flight"
                 "w/a/s/d or arrow keys steer. hold the ship in the open gates."
                 :game :wire-flight
                 :success "ship/aftermath"
                 :failure "ship/loop-reset")

(dialog-text "ship/aftermath"
             "the crossing holds. the board goes green deck by deck. two decks stay dark. on the bridge nobody says anything."
             :next "ship/aftermath-walk")

(dialog-text "ship/aftermath-walk"
             "you walk the green decks first. the manual says a crew steadies when it sees the captain. then you stand outside the dark ones. the manual has nothing for that. you stand there anyway."
             :next "ship/aftermath-praise")

(dialog-say "ship/aftermath-praise" "Voss"
            "textbook seal, captain. nobody cycles an actuator that clean under fault."
            :next "ship/aftermath-praise-2")

(dialog-say "ship/aftermath-praise-2" "you"
            "log the names first."
            :next "ship/aftermath-praise-3")

(dialog-say "ship/aftermath-praise-3" "Imari"
            "logged. cause of loss: crossing fault. action of record: correct and timely. that is what the record will say."
            :next "ship/letters")

(dialog-text "ship/letters"
             "you write to {ship-lost-name}'s family. the manual gives you three sentences. you use all three. then you sit a long time over a fourth that is not in the manual."
             :next "ship/next-watch")

(dialog-scene "ship/next-watch"
              "the next watch."
              :next "ship/mess")

(defun ship-watch-bridge-target ()
  (if (equal (dialog-value "ship-voss-answer" "") "doctrine")
      "ship/watch-bridge-doctrine"
      "ship/watch-bridge"))

(dialog-text "ship/mess"
             "the mess at the change of watch holds the whole crew but one. someone has set the empty place anyway. cup, tray, fork squared. nobody talks about it and nobody clears it."
             :next #'ship-watch-bridge-target)

(dialog-text "ship/watch-bridge"
             "the bridge runs quiet and exact. Voss runs the lane tables again without being asked. she runs them a second time, slower. the answer is the same. she does not like it."
             :next "ship/log-sign")

(dialog-text "ship/watch-bridge-doctrine"
             "the bridge runs quiet and exact. the manual is open at Voss's station. your guess about the drift is printed in it now, as procedure. she has used it twice tonight. she catches you looking at it and does not look away."
             :next "ship/log-sign")

(dialog-say "ship/log-sign" "Imari"
            "the watch log, captain. it needs your signature under mine."
            :next "ship/log-sign-2")

(dialog-say "ship/log-sign-2" "you"
            "read me the loss entry."
            :next "ship/log-sign-3")

(dialog-say "ship/log-sign-3" "Imari"
            "cause of loss: crossing fault. action of record: correct and timely. it is true, captain. i was careful that every word of it is true."
            :next "ship/log-choice")

(dialog-pick "ship/log-choice"
             "the stylus is warm from Imari's hand."
             (dialog-option "sign it as written" "ship/sign-clean")
             (dialog-option "add a commendation" "ship/sign-commend")
             (dialog-option "amend: the order was mine" "ship/sign-amend"))

(dialog-on-enter "ship/sign-clean"
                 '(setf (dialog-value "ship-log") "clean"))

(dialog-text "ship/sign-clean"
             "you sign under Imari's hand. the log closes with a soft click."
             :next "ship/watch-voss")

(dialog-on-enter "ship/sign-commend"
                 '(setf (dialog-value "ship-log") "commended"))

(dialog-text "ship/sign-commend"
             "you add the commendation in the space kept for it. there is a space kept for it. you try not to think about that."
             :next "ship/watch-voss")

(dialog-on-enter "ship/sign-amend"
                 '(setf (dialog-value "ship-log") "amended"))

(dialog-say "ship/sign-amend" "you"
            "add a line. the seal order was mine, on my judgment, with time to choose."
            :next "ship/sign-amend-2")

(dialog-say "ship/sign-amend-2" "Imari"
            "respectfully, captain: no. the record protects the living. your judgment is what let there be living. i will not log it as a confession."
            :next "ship/sign-amend-3")

(dialog-say "ship/sign-amend-3" "you"
            "then log that i asked."
            :next "ship/sign-amend-4")

(dialog-say "ship/sign-amend-4" "Imari"
            "that, i will log."
            :next "ship/watch-voss")

(dialog-text "ship/watch-voss"
             "at the end of the watch Voss sets a cup at your elbow and says nothing. it is too hot to drink. she timed it that way."
             :next "husk/contact")

(dialog-say "ship/checklist" "Voss"
            "next crossing window is in nine hours. i can push it to eleven if you want the lane tables re-run a third time."
            :next "ship/checklist-2")

(dialog-say "ship/checklist-2" "you"
            "run them a third time. not for the tables."
            :next "ship/checklist-3")

(dialog-say "ship/checklist-3" "Voss"
            "understood. for the nine hours."
            :next "ship/checklist-read")

(defun ship-intrusion-target ()
  (let ((lost (dialog-value "ship-lost-name" "")))
    (cond
      ((string= lost "Harrow") "ship/intrusion-harrow")
      ((string= lost "Okafor") "ship/intrusion-okafor")
      ((string= lost "Dane") "ship/intrusion-dane")
      (t "ship/bunk"))))

(dialog-text "ship/checklist-read"
             "before lights-down you read the checklist taped to the console, every line. item nine is in older handwriting than the tape over it. it says: count everyone twice."
             :next #'ship-intrusion-target)

(dialog-text "ship/intrusion-harrow"
             "on the way to the bunk you pass the drive trunk access. for one stride Harrow is at the panel, reading the pressure, steady, his sleeve whole. then the stride ends. the panel is dark and dogged shut. you ordered it left that way."
             :next "ship/corridor-imari")

(dialog-text "ship/intrusion-okafor"
             "on the way to the bunk you pass the deck seven hatch. for one breath there is laughter behind it. three voices. the card game Okafor always said he was losing. then the breath ends. the hatch reads SEALED, in your own initials."
             :next "ship/corridor-imari")

(dialog-text "ship/intrusion-dane"
             "on the way to the bunk you pass medbay. for one step Dane is in the doorway with the kit on one shoulder, turning back. then the step ends. the kit hangs on its peg, sealed and signed."
             :next "ship/corridor-imari")

(dialog-say "ship/corridor-imari" "Imari"
            "captain. the crew knows what the record says, and the crew knows what the record is for. nobody on this ship is confused about either."
            :next "ship/corridor-imari-2")

(dialog-say "ship/corridor-imari-2" "you"
            "that sounds rehearsed."
            :next "ship/corridor-imari-3")

(dialog-say "ship/corridor-imari-3" "Imari"
            "it is. we rehearsed it. good night, captain."
            :next "ship/bunk")

(dialog-text "ship/bunk"
             "you lie down in the bunk with your name stenciled at the foot. you are asleep before the lights dim."
             :next "ship/later")

(dialog-scene "ship/later"
              "the same ship. later."
              :next "ship/later-bridge")

(dialog-text "ship/later-bridge"
             "the bridge is dark except for the console light. your checklist is still taped beside it. item nine says count everyone twice. both counts come to one."
             :next "ship/later-galley")

(dialog-text "ship/later-galley"
             "in the galley there is one cup on the rack. the manual is open to the page with your name on it. someone has underlined the line twice, in two inks. the second hand is steadier than the first. both hands are yours."
             :next "ship/later-roster")

(dialog-text "ship/later-roster"
             "the duty roster by the door has not been changed. {ship-lost-name} is still on it, third watch. so is everyone."
             :next "ship/later-chair")

(dialog-text "ship/later-chair"
             "you sit in the captain's chair until the cup goes cold. somewhere below, a door you have stopped checking stays shut."
             :next "ship/later-log")

(dialog-text "ship/later-log"
             "the watch log is current. it is always current. you write the date, the position, the hail. the entries are all alike."
             :next "ship/later-log-s2")

(dialog-text "ship/later-log-s2"
             "you flip back through them and they do not change. somewhere back there the handwriting steadies, and after that it does not shake again."
             :next "ship/later-walk")

(dialog-text "ship/later-walk"
             "you do the rounds. the rounds are what there is. on deck two the lights come on one section ahead of you. they would do that for anyone."
             :next "ship/later-mess")

(dialog-text "ship/later-mess"
             "the mess is stowed except for one place setting. cup, tray, fork, under a film of dust. you do not touch it. you stopped clearing it a long time ago. you do not remember why it is set."
             :next "ship/later-medbay")

(dialog-text "ship/later-medbay"
             "medbay is stowed and clean. Dane's kit hangs on its peg, sealed. the inventory tag is signed in Dane's hand. you cannot place the date on it against anything."
             :next "ship/later-quarters")

(dialog-text "ship/later-quarters"
             "the crew quarters are made up like the morning of an inspection. there is a logbook of Imari's own entries. you stand in the doorway and do not read it. you are proud of that for the rest of the watch."
             :next "ship/later-comms")

(dialog-text "ship/later-comms"
             "the comms board holds one message in the outbound queue, flagged unsent. it is addressed to {ship-lost-name}'s family. it has four sentences. you do not remember writing the fourth."
             :next "ship/later-hail")

(dialog-text "ship/later-hail"
             "once a watch the board hails the lane and listens. tonight the lane answers the way it always answers. carrier tone, clean and steady, with nobody on it."
             :next "ship/later-beacon")

(dialog-text "ship/later-beacon"
             "under the carrier, on the old port band, the beacon repeats one recorded sentence: HOLD POSITION. RETRIEVAL FOLLOWS. it gives its own date each time. you try not to think about the date."
             :next "ship/later-answer")

(dialog-pick "ship/later-answer"
             "the beacon finishes its sentence and waits out its own pause."
             (dialog-option "hail back, voice" "ship/later-voice")
             (dialog-option "hold position, log it" "ship/later-hold")
             (dialog-option "switch the board off" "ship/later-dark"))

(dialog-on-enter "ship/later-voice"
                 '(setf (dialog-value "ship-future-answer") "voice"))

(dialog-text "ship/later-voice"
             "you key the channel. you say the ship's name and your own and that you are holding as ordered. your voice comes back off the lane half a second late. you log the hail as answered. you do not write down by whom."
             :next "ship/later-bunk")

(dialog-on-enter "ship/later-hold"
                 '(setf (dialog-value "ship-future-answer") "held"))

(dialog-text "ship/later-hold"
             "you hold position. the ship is good at holding position. it is the one order left you can carry out clean, every watch, with no one to lose."
             :next "ship/later-bunk")

(dialog-on-enter "ship/later-dark"
                 '(setf (dialog-value "ship-future-answer") "dark"))

(dialog-text "ship/later-dark"
             "you switch the board off. the quiet that comes is the quiet of the mess hall with one place set. you switch the board back on before the next sweep. item nine. count everyone twice."
             :next "ship/later-bunk")

(dialog-text "ship/later-bunk"
             "you turn in at the bunk with the stenciled name. the stencil is worn now. it has been repainted at least once. the letters are traced over themselves, a little off true."
             :next "sys/reboot")

;;; A catastrophic crossing does not kill you and does not loop on the
;;; bridge. The captain's day resets. You wake in the bunk in a cold
;;; sweat, and the failure reads at first like a dream you are shaking
;;; off, until the day runs the same way again. It is a time loop; the
;;; player is not told. ship-failures climbs unseen, surfacing later as
;;; the galley remembering for you.
(dialog-particles "ship/loop-reset" :stars :fade-seconds 4.0)

(dialog-on-enter "ship/loop-reset"
                 '(setf (dialog-value "ship-failures")
                        (1+ (dialog-value "ship-failures" 0))))

(dialog-text "ship/loop-reset"
             "you wake in the bunk in a cold sweat, the blanket twisted, your heart going hard. for a moment the crossing and the gates have the thinness of a dream you are already losing."
             :next "ship/loop-reset-2")

(dialog-text "ship/loop-reset-2"
             "your name is stenciled at the foot of the bunk. the boards are quiet and green. it is hours yet before the crossing. you tell yourself it was a dream, and you almost hear it."
             :next "ship/alarm")


;;; Dream maze

(dialog-minigame "dream/maze"
                 "w/s or up/down move. a/d or left/right turn. find an exit."
                 :game :dream-maze
                 :success "dream/maze-lost"
                 :failure "dream/maze-lost"
                 :config (list :doors '(("?" "alice/fall")
                                        ("@" "rogue/ascii-reveal")
                                        ("=" "dream/right-exit")))
                 :outcomes (list "alice/fall"
                                 "rogue/ascii-reveal"
                                 "dream/right-exit"))

(dialog-text "dream/right-exit"
             "past the right exit, the corridor straightens. a white line runs down the floor. you follow it."
             :next "facility/found")

(dialog-text "dream/maze-lost"
             "you lose the thread of which corridor came first."
             :next "facility/found")
