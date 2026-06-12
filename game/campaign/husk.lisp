;;; The husk: a dark ship branch. A cold contact on the lane turns out
;;; to be a hull of the same class, same fittings, same hand in the log.
;;; Entered from the next-watch arc; exits back through sleep.

(dialog-particles "husk/approach" :stars :fade-seconds 5.0)
(dialog-music "husk/approach" "audio/ship-lyria-drone.mp3" :volume 0.20)

(dialog-text "husk/contact"
             "before lights-down, Imari flags a return on the long sweep: cold, ballistic, transponder silent. the profile matcher offers one hull class with ninety-eight percent confidence, and it is yours."
             :next "husk/contact-choice")

(dialog-pick "husk/contact-choice"
             "Imari waits with the contact log open."
             (dialog-option "close and board her" "husk/orders")
             (dialog-option "log it and hold course" "husk/pass"))

(dialog-text "husk/pass"
             "you log it: derelict return, no transponder, no action taken. Imari signs under you without comment. for the rest of the watch the sweep keeps finding it, every pass, patient as a tide marker."
             :next "ship/checklist")

(dialog-on-enter "husk/orders"
                 '(setf (dialog-value "husk-boarded") t))

(dialog-conversation "husk/orders"
                     (dialog-left "Voss"
                                  "intercept burn is forty minutes. i can put the launch in her drift shadow and hold it there.")
                     (dialog-right "{player-name}"
                                   "two suits. you fly, i board.")
                     (dialog-left "Imari"
                                  "regulations want three, captain. i am not quoting them. i am saying i will be on comms the whole time.")
                     :next "husk/approach")

(dialog-scene "husk/approach"
              "the husk."
              :next "husk/first-sight")

(dialog-text "husk/first-sight"
             "she comes up out of the dark the way a word comes up out of a page: all at once, already familiar. same class. same refit scars along the dorsal line. the hull number is scorched past reading, which is the first mercy of the night."
             :next "husk/suit")

(dialog-text "husk/suit"
             "you suit up in the launch bay while Voss runs the numbers twice. the suit smells of its last wearer, which is you, which tonight feels like a thing worth noticing."
             :next "husk/launch")

(dialog-minigame "husk/launch"
                 "w/a/s/d or arrow keys steer. hold the launch in the open gates."
                 :game :wire-flight
                 :success "husk/grapple"
                 :failure "husk/launch-again")

(dialog-text "husk/launch-again"
             "the drift shadow spits the launch out once. Voss says nothing, brings it around, and the second pass holds. neither of you logs the first."
             :next "husk/grapple")

(dialog-text "husk/grapple"
             "the grapple takes on the service ring, exactly where the service ring is on your own hull. you cross the gap hand over hand with the husk filling the whole sky, and somewhere behind you Imari says, quietly, radio check, and you are glad of the voice."
             :next "husk/airlock")

(dialog-text "husk/airlock"
             "the outer door takes the hand crank the same number of turns yours takes. inside, the lock cycles on residual pressure. there is gravity, faint and steady, which means the ring is still spinning, which means something has been keeping it trimmed."
             :next "husk/first-corridor")

(dialog-text "husk/first-corridor"
             "frost furs the corridor walls in the pattern breath leaves, long since stopped. the emergency strips glow at quarter power. your suit lamp does the rest, four meters of it, and the rest of the ship waits outside that circle in no hurry."
             :next "husk/comms-one")

(dialog-conversation "husk/comms-one"
                     (dialog-left "Imari"
                                  "telemetry says her ring is trimmed to a tenth of a degree. captain, that is better than ours.")
                     (dialog-right "{player-name}"
                                   "noted. going inward. records deck first.")
                     (dialog-left "Imari"
                                  "copy. talk while you walk, please. it is very quiet up here when you don't.")
                     :next "husk/decks")

(dialog-minigame "husk/decks"
                 "wasd or arrow keys step. find the records deck."
                 :game :rogue-delve
                 :success "husk/records"
                 :failure "husk/withdraw"
                 :config (list :save-prefix "husk-decks"
                               :caught-target "husk/paced"
                               :leave-target "husk/withdraw"
                               :maps
                               (list (list "#############"
                                           "#<....#.....#"
                                           "#.###.#.###.#"
                                           "#.#*..#...#.#"
                                           "#.#.#####.#.#"
                                           "#@..#...*.#.#"
                                           "#.###.###.#.#"
                                           "#.....#...#>#"
                                           "#############")
                                     (list "#############"
                                           "#<..#....*..#"
                                           "##.##.#####.#"
                                           "#..#..#...#.#"
                                           "#.##.##.#.#.#"
                                           "#.#...m.#...#"
                                           "#.#.#####.###"
                                           "#*..#......$#"
                                           "#############"))))

(dialog-text "husk/paced"
             "the sound that has been keeping pace one bulkhead over stops being one bulkhead over. you do not run. you walk backward to the lock with your lamp on the corridor, the way you would back away from a dog you respect, and the corridor lets you."
             :next "husk/withdraw-choice")

(dialog-text "husk/withdraw"
             "the decks fold you back toward the lock the way unfamiliar ships do, every junction offering the way out first. you stand in the airlock with your hand on the crank a while."
             :next "husk/withdraw-choice")

(dialog-pick "husk/withdraw-choice"
             "Voss's voice on comms: launch is holding. your call, captain."
             (dialog-option "go back in" "husk/reenter")
             (dialog-option "pull out and stand off" "husk/standoff"))

(dialog-text "husk/reenter"
             "you go back in. the second time the corridors read easier, the way a hard word reads easier the second time, and you do not think about why you know her layout in the dark."
             :next "husk/decks")

(dialog-on-enter "husk/standoff"
                 '(setf (dialog-value "husk-decision") "stood-off"))

(dialog-text "husk/standoff"
             "you cross back to the launch and stand off at a kilometer with the floods on her name. the scorch keeps it. on the ride home nobody talks, and the cup Voss hands you afterward is exactly too hot to drink."
             :next "husk/sleep")

(dialog-text "husk/records"
             "the records deck door is dogged from inside. it takes the pry bar and your whole back, and then you are in a room you know with your eyes shut: same desk, same rack, same drawer that sticks."
             :next "husk/records-2")

(dialog-text "husk/records-2"
             "the log binder lies open on the desk, faced away, as if someone reading it had just stood up."
             :next "husk/log")

(dialog-text "husk/log"
             "you turn the binder around with two fingers. the entries are in a captain's hand, small and even and slanted left at the line ends when the writer is tired. you know the hand. you have signed a manual with it, and a decree of letters home."
             :next "husk/log-read")

(dialog-text "husk/log-read"
             "the entries are crossings. eighty-one seconds. seventy-nine. the same lane, the same gates, dated in a calendar you do not let yourself reconcile with yours. the last entry is not a crossing. it says: COUNTED EVERYONE TWICE. ONE."
             :next "husk/manifest")

(dialog-text "husk/manifest"
             "the crew manifest hangs by the door in its steel frame, the way yours does. you read it with your lamp at arm's length, as if distance helped. Imari. Voss. Harrow. Okafor. Dane. the duty columns differ in small ways, like a story retold by a careful liar."
             :next "husk/comms-two")

(defun husk-manifest-target ()
  (if (dialog-value "ship-lost-name")
      "husk/manifest-lost"
      "husk/mess"))

(dialog-conversation "husk/comms-two"
                     (dialog-left "Imari"
                                  "captain, read me her registry off the manifest frame, bottom corner.")
                     (dialog-right "{player-name}"
                                   "kestrel-nine-nine-one.")
                     (dialog-left "Imari"
                                  "say again, captain.")
                     :next #'husk-manifest-target)

(dialog-text "husk/manifest-lost"
             "you read the manifest once more before leaving it, because there is a thing you are not letting yourself check, and then you check it. {ship-lost-name} is on her roster too, third watch. the duty column reads: relieved. the date column reads nothing at all."
             :next "husk/mess")

(dialog-text "husk/mess"
             "the mess is stowed and clean under its frost. at the long table, one place is set: cup, tray, fork squared, a film of ice over all of it like glass over a photograph. the chair is pushed back the width of a person."
             :next "husk/galley")

(dialog-text "husk/galley"
             "in her galley the rack holds one cup, and the cup holds a ring of something long evaporated, a tide line at the level of two swallows left."
             :next "husk/galley-2")

(dialog-text "husk/galley-2"
             "on the shelf above it the crossing manual lies open, and you do not need the lamp to know which page, and you check with the lamp anyway, and it is that page."
             :next "husk/bunk")

(dialog-text "husk/bunk"
             "you go one deck down because you have stopped pretending you are not going there. the bunk is made."
             :next "husk/bunk-2")

(dialog-text "husk/bunk-2"
             "the name at the foot is stenciled, worn, repainted at least once, the letters traced over themselves a little off true. you do not read it."
             :next "husk/bunk-3")

(dialog-text "husk/bunk-3"
             "you stand in the hatch and do not read it, and that takes everything you have."
             :next "husk/decision")

(dialog-pick "husk/decision"
             "Voss on comms: weather on the lane in forty. captain, what are we doing with her?"
             (dialog-option "take the log and go" "husk/take-log")
             (dialog-option "seal her and leave her" "husk/seal")
             (dialog-option "scuttle her" "husk/scuttle"))

(dialog-on-enter "husk/take-log"
                 '(setf (dialog-value "husk-decision") "log"))

(dialog-text "husk/take-log"
             "you bag the binder and dog the records deck behind you. it rides home on your knee like a thing that might wake. it goes in the safe under the lane tables, and the safe has always had room for it, which you also do not think about."
             :next "husk/ride-home")

(dialog-on-enter "husk/seal"
                 '(setf (dialog-value "husk-decision") "sealed"))

(dialog-text "husk/seal"
             "you crank the lock shut from outside and wire the handle the way you would wire a gate. she stays on the lane, trimmed and patient. the sweep will keep finding her, every pass, and now that is a thing you have chosen."
             :next "husk/ride-home")

(dialog-on-enter "husk/scuttle"
                 '(setf (dialog-value "husk-decision") "scuttled"))

(dialog-text "husk/scuttle"
             "the charges are where charges are kept, which no longer surprises you."
             :next "husk/scuttle-2")

(dialog-text "husk/scuttle-2"
             "from the launch, the flash is small and white and brief, a struck match at a kilometer, and then the lane is empty on the sweep for the first time all watch. Voss exhales."
             :next "husk/scuttle-3")

(dialog-text "husk/scuttle-3"
             "you count the seconds of the silence afterward and stop at eighty-one."
             :next "husk/ride-home")

(dialog-text "husk/ride-home"
             "the ride home is short and very long. halfway, Imari's voice comes on, even and procedural, reading the next watch rotation as if it were scripture, and you understand it is for you, and you let it be."
             :next "husk/debrief")

(dialog-conversation "husk/debrief"
                     (dialog-left "Imari"
                                  "for the log: derelict, registry illegible, no salvage of record. that is what i have written, captain.")
                     (dialog-right "{player-name}"
                                   "the registry was legible.")
                     (dialog-left "Imari"
                                  "the record protects the living. you taught me the sentence. let it work for you once.")
                     :next "husk/voss-after")

(dialog-conversation "husk/voss-after"
                     (dialog-left "Voss"
                                  "i will re-run the lane tables tonight. not because they are wrong.")
                     (dialog-right "{player-name}"
                                   "because the hands want something to do.")
                     (dialog-left "Voss"
                                  "because the hands want something to do. good night, captain.")
                     :next "husk/checklist")

(dialog-text "husk/checklist"
             "before lights-down you read the taped checklist on the console, every line. item nine says count everyone twice, and tonight you read the handwriting itself, the small even hand slanted left at the line ends, and then you stop reading."
             :next "husk/sleep")

(defun husk-sleep-target ()
  (let ((decision (dialog-value "husk-decision" "")))
    (cond
      ((string= decision "log") "husk/sleep-log")
      ((string= decision "sealed") "husk/sleep-sealed")
      ((string= decision "scuttled") "husk/sleep-scuttled")
      (t "husk/sleep-plain"))))

(dialog-text "husk/sleep"
             "the ship hums under the floor, yours, warm, crewed. you do the thing you do with your eyes on the way to the bunk: door, corridor, hatch, counted."
             :next #'husk-sleep-target)

(dialog-text "husk/sleep-log"
             "you do not open the safe. you put your hand flat on it once, the way you would on a bulkhead with weather behind it, and you lie down in the bunk with your name stenciled at the foot, freshly yours, and sleep takes you like a tide."
             :next "base/awake")

(dialog-text "husk/sleep-sealed"
             "on the last sweep before lights-down, the return is there, cold and patient, one kilometer of wire holding her shut. station-keeping, the display calls it. keeping, anyway. you sleep, and the sweep keeps finding her all night, every pass, like a tongue finding a tooth."
             :next "base/awake")

(dialog-text "husk/sleep-scuttled"
             "the lane is clean on every sweep. in the bunk you listen to your own ship breathe, and when the carrier tone sounds the hour it comes a half second late, or you are tired, and you choose tired, and you sleep."
             :next "base/awake")

(dialog-text "husk/sleep-plain"
             "you lie down in the bunk with your name stenciled at the foot. somewhere out on the lane the cold return rides its long orbit, unboarded, unread, and that is also a decision, and you sleep on it."
             :next "base/awake")
