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
             :next "base/ceiling")

(dialog-text "base/ceiling"
             "the ceiling is low enough to be certain of, high enough to keep its corners. a narrow seam runs above you from wall to wall, pale in the dark where old paint has cracked."
             :next "base/feel")

;; Move this below any node while developing, then use New Game.
;; (dialog-dev-save-here
;;  :store '(("player-name" . "dev"))
;;  :visible :all)

(dialog-text "base/feel"
             "or at least that's how you feel. the room is not moving, not making room for itself, not waiting to become anything. it is simply there before you can account for it."
             :next "base/blanket")

(dialog-text "base/blanket"
             "the blanket has worked loose from one corner of the mattress. your hand finds the hem and the hem finds your hand back: coarse thread, one repaired tear, the weight of ordinary cloth."
             :next "base/exit-bed")

(dialog-choice "base/exit-bed"
               "exit bed?"
               (dialog-option "yes" #'base-exited-bed-target)
               (dialog-option "no" "base/sleep"))

(dialog-text "base/exited-bed"
             "you wearily open your eyes, there is a night stand next to your bed"
             :next "base/bed-edge")

(dialog-text "base/exited-bed-thread"
             "you wearily open your eyes, there is a night stand next to your bed. pushing back the blanket takes a moment: a loop of white thread is wound twice around two of your fingers."
             :next "base/bed-edge-thread")

(dialog-text "base/bed-edge"
             "you sit on the mattress edge until the floor stops looking farther away than it is. the night stand is plain wood, scuffed at the lower shelf, with one pale ring where a glass has stood too long."
             :next #'base-room-breath-target)

(dialog-text "base/bed-edge-thread"
             "you work the thread loose without breaking it. it leaves no mark, only a thin pressure memory around two fingers. the night stand beside you has one pale ring where a glass has stood too long."
             :next #'base-room-breath-target)

(dialog-text "base/room-breath"
             "you stretch and get out of bed"
             :next "base/room-hush")

(dialog-text "base/room-breath-cup"
             "you stretch and get out of bed. your right hand stays curled a moment, as if it had been holding a cup."
             :next "base/room-hush-cup")

(dialog-text "base/room-breath-desk"
             "you stretch and get out of bed. your neck aches the way it does after sleeping at a desk."
             :next "base/room-hush-desk")

(dialog-text "base/room-hush"
             "the boards answer your weight one at a time. outside the room there may be a hall, or another room, or only the dark that gathers behind closed doors. nothing hurries you."
             :next "base/thirst")

(dialog-text "base/room-hush-cup"
             "the boards answer your weight one at a time. the curled hand opens slowly, finger by finger, as if setting down something it has already lost. nothing else in the room moves."
             :next "base/thirst")

(dialog-text "base/room-hush-desk"
             "the boards answer your weight one at a time. you roll your shoulders, and the ache at the back of your neck settles into the ordinary shape of a bad night's sleep."
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
             :next "base/shirt-fold")

(dialog-text "base/drawer-pitch"
             "there are some drawers in your room, you rummage through the top one looking for something to wear. there's a paper matchbook sticking out of a shirt, and pine pitch under two of your fingernails."
             :next "base/shirt-pitch")

(dialog-text "base/drawer-bread"
             "there are some drawers in your room, you rummage through the top one looking for something to wear. there's a paper matchbook sticking out of a shirt. the shirt smells faintly of bread."
             :next "base/shirt-bread")

(dialog-text "base/shirt-fold"
             "the shirt unfolds badly, as if it was put away by someone in a hurry and corrected later by someone with no hurry at all. the matchbook falls into your palm."
             :next "base/match")

(dialog-text "base/shirt-pitch"
             "the shirt unfolds badly. the pitch under your nails darkens the cuff when you touch it, and the matchbook falls out with a dry little tap."
             :next "base/match")

(dialog-text "base/shirt-bread"
             "the shirt unfolds badly. the bread smell is strongest at the cuff, warm and stale at once, and the matchbook drops out between two buttons."
             :next "base/match")

(dialog-choice "base/match"
               "strike a match?"
               (dialog-option "yes" "base/light-lantern")
               (dialog-option "no"  #'base-door-shadow-target))

(dialog-text "base/light-lantern"
             "the match lights up, you spot a lantern that you can light with the match."
             :next "base/lantern-glass")

(dialog-text "base/lantern-glass"
             "the lantern glass is cloudy but whole. when the flame catches, the room gains edges: basin, blanket, drawer, door. nothing explains itself in the new light."
             :next "jrpg/inn")

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
             :next "base/key-weight")

(dialog-on-enter "base/door-key-chalk"
                 '(setf (dialog-value "has-brass-key") t))

(dialog-text "base/door-key-chalk"
             "the key is on a small table by the door. picking it up leaves chalk dust on the pad of your thumb."
             :next "base/key-weight-chalk")

(dialog-text "base/key-weight"
             "it is heavier than it looks. not ornate, not old enough to be interesting, only brass rubbed dull where a thumb would press it."
             :next "base/unlock-door")

(dialog-text "base/key-weight-chalk"
             "it is heavier than it looks. the chalk dust stays in the grooves of your thumbprint, pale enough that you notice it every time you turn your hand."
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
             :next "base/sleep-sheet")

(dialog-text "base/sleep-sheet"
             "the sheet is cool at first, then not. the pillow keeps the dent from your head as if preserving evidence for someone patient enough to read fabric."
             :next "base/sleep-room")

(dialog-text "base/sleep-room"
             "the room goes on being itself around you: night stand, glass, door, low ceiling, repaired blanket. sleep comes back by the same route it left, quietly and without asking."
             :next "dream/drift")


;;; Ship captain

(dialog-text "ship/wake"
             "the glass is cold in your hand. in its reflection, you notice restraint straps beside the bed and indicator lights under the night stand."
             :next "ship/name")

(dialog-particles "ship/wake-after" :stars :fade-seconds 6.5)
(dialog-music "ship/wake-after" "audio/ship-lyria-drone.mp3" :volume 0.26)

(dialog-text "ship/wake-after"
             "the glass is cold in your hand. you drink it standing, without looking at the reflection, the way you have learned to."
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
             :next "ship/aftermath-walk")

(dialog-text "ship/aftermath-walk"
             "you walk the green decks first, because the manual says presence steadies a crew, and then you stand a while outside the dark ones, because no manual has a chapter for that, and a captain writes the missing chapters with their feet."
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
              :next "ship/mess")

(defun ship-watch-bridge-target ()
  (if (equal (dialog-value "ship-voss-answer" "") "doctrine")
      "ship/watch-bridge-doctrine"
      "ship/watch-bridge"))

(dialog-text "ship/mess"
             "the mess at change of watch holds the whole crew minus one, which is a kind of arithmetic a captain does without deciding to. someone has set the empty place anyway: cup, tray, fork squared. nobody talks about it and nobody clears it."
             :next #'ship-watch-bridge-target)

(dialog-text "ship/watch-bridge"
             "the bridge runs quiet and exact. Voss recalibrates the lane tables without being asked, twice, the second time more slowly, getting the same answer and not liking it any better."
             :next "ship/log-sign")

(dialog-text "ship/watch-bridge-doctrine"
             "the bridge runs quiet and exact. the crossing manual lies open at Voss's station, and your guess about the drift sits in it as procedure, printed, consulted twice tonight already. she catches you looking and does not look away first."
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
             :next "husk/contact")

(dialog-conversation "ship/checklist"
                     (dialog-left "Voss"
                                  "next crossing window is in nine hours. i can push it to eleven if you want the lane tables re-run a third time.")
                     (dialog-right "{player-name}"
                                   "run them a third time. not for the tables.")
                     (dialog-left "Voss"
                                  "understood. for the nine hours.")
                     :next "ship/checklist-read")

(defun ship-intrusion-target ()
  (let ((lost (dialog-value "ship-lost-name" "")))
    (cond
      ((string= lost "Harrow") "ship/intrusion-harrow")
      ((string= lost "Okafor") "ship/intrusion-okafor")
      ((string= lost "Dane") "ship/intrusion-dane")
      (t "ship/bunk"))))

(dialog-text "ship/checklist-read"
             "before lights-down you read the taped checklist on the console, every line, the way some people read letters they know by heart. item nine is in handwriting older than the tape over it. item nine says: count everyone twice."
             :next #'ship-intrusion-target)

(dialog-text "ship/intrusion-harrow"
             "on the way to the bunk you pass the drive trunk access, and for the length of one stride Harrow is at the panel, reading out pressure, steady, sleeve whole. the stride ends. the panel is dark and dogged shut, the way you ordered it left."
             :next "ship/corridor-imari")

(dialog-text "ship/intrusion-okafor"
             "on the way to the bunk you pass deck seven's hatch, and for the length of one breath there is laughter behind it, three voices, the card game Okafor always claimed to be losing. the breath ends. the hatch reads SEALED in your own initials."
             :next "ship/corridor-imari")

(dialog-text "ship/intrusion-dane"
             "on the way to the bunk you pass medbay, and for one step Dane is in the doorway with the kit over one shoulder, turning back the way Dane turned back. the step ends. the kit hangs on its peg, sealed, signed."
             :next "ship/corridor-imari")

(dialog-conversation "ship/corridor-imari"
                     (dialog-left "Imari"
                                  "captain. the crew knows what the record says, and the crew knows what the record is for. nobody on this ship is confused about either.")
                     (dialog-right "{player-name}"
                                   "that sounds rehearsed.")
                     (dialog-left "Imari"
                                  "it is. we rehearsed it. good night, captain.")
                     :next "ship/bunk")

(dialog-text "ship/bunk"
             "you lie down in the bunk with your name stenciled at the foot. you are asleep before the lights dim."
             :next "ship/later")

(dialog-scene "ship/later"
              "the same ship. later."
              :next "ship/later-bridge")

(dialog-text "ship/later-bridge"
             "the bridge is dark except for the console light. your checklist is still taped beside it, soft at the corners. you cannot remember when you last heard another voice on board. item nine still says count everyone twice, and you still do, both counts agreeing the way they have agreed for longer than you let yourself measure: one."
             :next "ship/later-galley")

(dialog-text "ship/later-galley"
             "in the galley there is one cup on the rack. the crossing manual lies open to the page with your name beside the procedure, and someone has underlined it, twice, in two different inks, the second time with a steadier hand, and both hands are yours."
             :next "ship/later-roster")

(dialog-text "ship/later-roster"
             "the duty roster by the door has not been changed. {ship-lost-name} is still on it, third watch. so is everyone."
             :next "ship/later-chair")

(dialog-text "ship/later-chair"
             "you sit in the captain's chair until the cup goes cold. somewhere below, a door you have stopped checking stays shut."
             :next "ship/later-log")

(dialog-text "ship/later-log"
             "the watch log is current. it is always current. you write the date, the position held, the hail logged, in entries so alike that flipping back through them is like riffling a deck of one card, and somewhere in that sameness is a date where the handwriting steadies and never wavers again."
             :next "ship/later-walk")

(dialog-text "ship/later-walk"
             "you do the rounds because the rounds are what there is. deck two: lights answer the motion sensors one section ahead of you, the way they would for anyone."
             :next "ship/later-mess")

(dialog-text "ship/later-mess"
             "the mess is stowed except one place setting, squared away under a film of dust you do not disturb: cup, tray, fork. you stopped clearing it before you stopped remembering why it was set."
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
             :next "ship/later-beacon")

(dialog-text "ship/later-beacon"
             "under the carrier, on the old port band, the beacon repeats its one recorded sentence: HOLD POSITION. RETRIEVAL FOLLOWS. the recording gives its own date each cycle, and the date does not bear thinking about."
             :next "ship/later-answer")

(dialog-pick "ship/later-answer"
             "the beacon finishes its sentence and waits out its own pause."
             (dialog-option "hail back, voice" "ship/later-voice")
             (dialog-option "hold position, log it" "ship/later-hold")
             (dialog-option "switch the board off" "ship/later-dark"))

(dialog-on-enter "ship/later-voice"
                 '(setf (dialog-value "ship-future-answer") "voice"))

(dialog-text "ship/later-voice"
             "you key the channel and say the ship's name, and yours, and that you are holding as instructed. your voice comes back off the lane a half second late, in your own voice, the way a call comes back from a hall. you log the hail as answered. you do not write by whom."
             :next "ship/later-bunk")

(dialog-on-enter "ship/later-hold"
                 '(setf (dialog-value "ship-future-answer") "held"))

(dialog-text "ship/later-hold"
             "you hold position. the ship is good at holding position. it is the one order left that you can carry out perfectly, every watch, with no one to lose."
             :next "ship/later-bunk")

(dialog-on-enter "ship/later-dark"
                 '(setf (dialog-value "ship-future-answer") "dark"))

(dialog-text "ship/later-dark"
             "you switch the board off. the silence afterward has a shape, and the shape is the mess hall with one place set: something kept ready for a return nobody schedules. you switch it back on before the next sweep. item nine. count everyone twice."
             :next "ship/later-bunk")

(dialog-text "ship/later-bunk"
             "you turn in at the bunk with the stenciled name. the stencil is worn now, repainted at least once, the letters traced over themselves a little off true."
             :next "base/awake")

(dialog-on-enter "ship/crash-return"
                 '(setf (dialog-value "ship-failures")
                        (1+ (dialog-value "ship-failures" 0))))

(dialog-particles "ship/crash-return" :warp :immediate t)

(dialog-text "ship/crash-return"
             "white lines fill your eyes, all of them running away from a black point you cannot look away from."
             :next "ship/crash-return-hands")

(dialog-text "ship/crash-return-hands"
             "your hands are still on the controls. the gloves have creased white at the knuckles. you cannot feel the pressure yet, only see where it should hurt."
             :next "ship/crash-return-alarm")

(dialog-text "ship/crash-return-alarm"
             "the lines break apart. the bridge comes back in pieces: console, warning strip, checklist, alarm."
             :next "ship/alarm")


;;; Dream maze

(dialog-text "dream/drift"
             "a few moments later, you fall asleep"
             :next "dream/blanket")

(dialog-text "dream/blanket"
             "the blanket does not get heavier. the room gets quieter under it, as if somebody has put the whole house under a glass and set the glass down carefully."
             :next "dream/bed-edge")

(dialog-text "dream/bed-edge"
             "your hand finds the edge of the mattress and then keeps finding it, edge after edge, each one lower than the last. you do not move. the room is doing the lowering."
             :next "dream/night-stand")

(dialog-text "dream/night-stand"
             "the night stand is still beside you for a while, falling at the same pace. the glass on it holds its water perfectly level, which is how you know the falling is serious."
             :next "dream/glass-level")

(dialog-text "dream/glass-level"
             "you watch the water for proof of motion. no ripple, no tilt, no meniscus climbing the side. the room can fall forever, apparently, provided it keeps good manners."
             :next "dream/drawer-open")

(dialog-text "dream/drawer-open"
             "one drawer slides open by a finger's width. inside is only darkness, folded with your clothes, and the smell of paper matches after rain."
             :next "dream/door-below")

(dialog-text "dream/door-below"
             "below the bed, where floor should be, a door passes in the dark: brass handle first, then keyhole, then the panel. it is not the bedroom door. it is one of the doors the bedroom keeps in reserve."
             :next "dream/first-step")

(dialog-text "dream/first-step"
             "you put one foot down because sleep has rules about dignity, and the first stair accepts it. the bed is gone when you look back. the stair remembers it for you."
             :next "dream/stair-memory")

(dialog-text "dream/stair-memory"
             "on each step behind you, bedroom details show in the dark: blanket edge, floorboard grain, chair leg, the brass shine of a key. none of it follows. the stair has been carrying those details with it."
             :next "dream/fall")

(dialog-text "dream/fall"
             "you feel a falling sensation"
             :next "dream/fall-2")

(dialog-text "dream/fall-2"
             "then the sensation gives you enough detail to stand in: walls at arm's length, ceiling too high to test, floor smooth enough that your steps arrive late, like sound through water."
             :next "dream/corners")

(dialog-text "dream/corners"
             "corners appear before you reach them and vanish behind you without drama. the corridor is not changing. you are only seeing as much of it as sleep allows at once."
             :next "dream/line")

(dialog-text "dream/line"
             "a thin white line runs along the floor. it does not point anywhere. it only proves there is a floor. you follow it because proof is better than dark."
             :next "dream/intersection")

(dialog-text "dream/intersection"
             "the line reaches an intersection and splits three ways without choosing for you. left, upper, right. all three branches are equally ordinary until you stand before one."
             :next "dream/listen")

(dialog-text "dream/listen"
             "from the left comes falling air. from above, dry stone. from the right, a quiet mechanical hum that might be a light or a machine, if dreams cared about the difference."
             :next "dream/no-map")

(dialog-text "dream/no-map"
             "there is no map. you know this with the certainty dreams allow, and also with the certainty of a person who has already been expected somewhere without being told where."
             :next "dream/maze")

(dialog-minigame "dream/maze"
                 "w/s or up/down move. a/d or left/right turn. find an exit."
                 :game :dream-maze
                 :success "dream/maze-lost"
                 :failure "dream/maze-lost"
                 :config (list :left "alice/fall"
                               :upper "rogue/entrance"
                               :right "dream/right-exit")
                 :outcomes (list "alice/fall"
                                 "rogue/entrance"
                                 "dream/right-exit"))

(dialog-text "dream/right-exit"
             "past the right exit, the corridor straightens, and a painted line runs down the middle of the floor. the door at the end has the same handle as the one that was behind you."
             :next "dream/right-line")

(dialog-text "dream/right-line"
             "the painted line is not bright. it is old floor paint, rubbed thin where many shoes have obeyed it. yours fall into the same lane before you decide to be careful."
             :next "dream/right-window")

(dialog-text "dream/right-window"
             "a window passes on the left. behind it is a dark room with a bed and a small table. you see it for less than a breath, not long enough to make it yours, long enough to know it was there."
             :next "dream/right-clipboard")

(dialog-text "dream/right-clipboard"
             "a clipboard hangs below the window. the paper on it has boxes, dates, and one line of handwriting dragged through by a black bar. you keep walking before the words arrange themselves."
             :next "dream/right-card")

(dialog-text "dream/right-card"
             "something flat taps your chest when you walk: a card on a cord, blank side out. you do not remember putting it on. the cord is warm where it crosses the back of your neck."
             :next "dream/right-name")

(dialog-text "dream/right-name"
             "you turn the card over. whatever was printed there has been rubbed white by a thumb. below the blank is a small ruled space, waiting for a designation."
             :next "dream/right-threshold")

(dialog-text "dream/right-threshold"
             "at the door, the painted line ends under your toes. on the other side, someone has already turned on a desk lamp."
             :next "dream/right-knock")

(dialog-text "dream/right-knock"
             "you do not knock. somebody on the other side writes once, a small check mark on paper, and the door opens before your hand reaches the handle."
             :next "base/awake")

(dialog-text "dream/maze-lost"
             "you lose the thread of which corridor came first."
             :next "dream/lost-wall")

(dialog-text "dream/lost-wall"
             "you stop with one hand on the wall. the wall is cool, painted, and very slightly rough, the way corridor paint gets rough when it has been washed too often."
             :next "dream/lost-count")

(dialog-text "dream/lost-count"
             "you count backward from ten because that is what people do when they do not want to admit they are calling for help. at six, a second set of footsteps joins yours and keeps the same count."
             :next "dream/lost-light")

(dialog-text "dream/lost-light"
             "a light appears around the next corner, not bright, not friendly, just official enough that the dark steps back from it. the footsteps stop before you turn."
             :next "dream/lost-sign")

(dialog-text "dream/lost-sign"
             "beside the light, a wall sign points both directions with the same arrow. the word under the arrows has been painted over so many times it has become a raised white block."
             :next "dream/lost-coat")

(dialog-text "dream/lost-coat"
             "there is a grey coat in the light. you cannot see the face above it yet. the coat waits with the posture of someone assigned to wait."
             :next "dream/lost-page")

(dialog-text "dream/lost-page"
             "the coat holds one page on a clipboard. your name is not on it. that should be comforting, but the blank beside NAME is too clean, too ready."
             :next "dream/lost-found")

(dialog-text "dream/lost-found"
             "when you reach the corner, the coat turns in the direction the corridor has already decided you will go."
             :next "dream/lost-follow")

(dialog-text "dream/lost-follow"
             "you follow because being lost has already made one decision for you, and because the coat walks at the pace of someone who knows exactly how slowly a frightened person can move."
             :next "base/awake")
