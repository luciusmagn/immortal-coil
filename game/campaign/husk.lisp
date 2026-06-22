;;; The husk: a dark ship branch. A cold contact on the lane turns out
;;; to be a hull of the same class, same fittings, same hand in the log.
;;; Entered from the next-watch arc; exits back through sleep.

(dialog-particles "husk/approach" :stars :fade-seconds 5.0)
(dialog-music "husk/approach" "audio/ship-lyria-drone.mp3" :volume 0.20)

(dialog-text "husk/contact"
             "before lights-down Imari flags a return on the long sweep. cold, ballistic, transponder silent. the matcher gives one hull class at ninety-eight percent. it is yours."
             :next "husk/contact-choice")

(dialog-pick "husk/contact-choice"
             "Imari waits with the contact log open."
             (dialog-option "close and board her" "husk/orders")
             (dialog-option "log it and hold course" "husk/pass"))

(dialog-text "husk/pass"
             "you log it. derelict return, no transponder, no action taken. Imari signs under you without comment. for the rest of the watch the sweep finds it again every pass."
             :next "ship/checklist")

(dialog-on-enter "husk/orders"
                 '(setf (dialog-value "husk-boarded") t))

(dialog-say "husk/orders" "Voss"
            "intercept burn is forty minutes. i can put the launch in her drift shadow and hold it there."
            :next "husk/orders-2")

(dialog-say "husk/orders-2" "you"
            "two suits. you fly, i board."
            :next "husk/orders-3")

(dialog-say "husk/orders-3" "Imari"
            "regulations want three, captain. i am not quoting them. i am saying i will be on comms the whole time."
            :next "husk/approach")

(dialog-scene "husk/approach"
              "the husk."
              :next "husk/first-sight")

(dialog-text "husk/first-sight"
             "she comes up out of the dark all at once. you know her at once. same class. same refit scars along the dorsal line. the hull number is scorched past reading. you are glad of that."
             :next "husk/suit")

(dialog-text "husk/suit"
             "you suit up in the launch bay while Voss runs the numbers twice. the suit smells of its last wearer. the last wearer is you. tonight you notice that."
             :next "husk/launch")

(dialog-minigame "husk/launch"
                 "w/a/s/d or arrow keys steer. hold the launch in the open gates."
                 :game :wire-flight
                 :success "husk/grapple"
                 :failure "husk/launch-again")

(dialog-text "husk/launch-again"
             "the drift shadow throws the launch out once. Voss says nothing and brings it around. the second pass holds. neither of you logs the first."
             :next "husk/grapple")

(dialog-text "husk/grapple"
             "the grapple takes on the service ring, in the same place it sits on your own hull. you cross the gap hand over hand. the husk fills the whole sky. behind you Imari says, radio check, and you are glad of the voice."
             :next "husk/airlock")

(dialog-text "husk/airlock"
             "the outer door takes the same number of turns on the crank as yours. inside, the lock cycles on residual pressure. there is gravity, faint and steady. the ring is still spinning. something has been keeping it trimmed."
             :next "husk/first-corridor")

(dialog-text "husk/first-corridor"
             "frost furs the corridor walls where breath froze, a long time ago. the emergency strips glow at quarter power. your suit lamp does the rest. four meters of it. the rest of the ship stands outside that circle and waits."
             :next "husk/comms-one")

(dialog-say "husk/comms-one" "Imari"
            "telemetry says her ring is trimmed to a tenth of a degree. captain, that is better than ours."
            :next "husk/comms-one-2")

(dialog-say "husk/comms-one-2" "you"
            "noted. going inward. records deck first."
            :next "husk/comms-one-3")

(dialog-say "husk/comms-one-3" "Imari"
            "copy. talk while you walk, please. it is very quiet up here when you don't."
            :next "husk/decks")

(dialog-minigame "husk/decks"
                 "wasd or arrow keys step. find the records deck."
                 :game :rogue-delve
                 :success "husk/records"
                 :failure "husk/withdraw"
                 :config (list :save-prefix "husk-decks"
                               :caught-target "husk/paced"
                               :leave-target "husk/withdraw"
                               :step-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/step.wav"))
                               :bump-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/bump.wav"))
                               :menu-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/menu.wav"))
                               :class-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/class.wav"))
                               :pickup-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/pickup.wav"))
                               :hit-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/hit.wav"))
                               :kill-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/kill.wav"))
                               :stairs-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/stairs.wav"))
                               :gen-floors 4
                               :gen-width 21
                               :gen-height 15
                               :gen-hunters 1
                               :gen-monsters 4
                               :gen-items 4
                               :gen-traps 2))

(dialog-text "husk/paced"
             "the sound that has kept pace one bulkhead over is not one bulkhead over now. you do not run. you walk backward to the lock with your lamp on the corridor, the way you back off from a dog. the corridor lets you."
             :next "husk/withdraw-choice")

(dialog-text "husk/withdraw"
             "the decks turn you back toward the lock. every junction shows you the way out first. you stand in the airlock with your hand on the crank a while."
             :next "husk/withdraw-choice")

(dialog-pick "husk/withdraw-choice"
             "Voss's voice on comms: launch is holding. your call, captain."
             (dialog-option "go back in" "husk/reenter")
             (dialog-option "pull out and stand off" "husk/standoff"))

(dialog-text "husk/reenter"
             "you go back in. the second time the corridors come easier. you do not think about why you know her layout in the dark."
             :next "husk/decks")

(dialog-on-enter "husk/standoff"
                 '(setf (dialog-value "husk-decision") "stood-off"))

(dialog-text "husk/standoff"
             "you cross back to the launch and stand off a kilometer with the floods on her name. the scorch keeps it from you. nobody talks on the ride home. the cup Voss hands you after is too hot to drink."
             :next "husk/sleep")

(dialog-text "husk/records"
             "the records deck door is dogged from inside. it takes the pry bar and your whole back. then you are in a room you know with your eyes shut. same desk. same rack. same drawer that sticks."
             :next "husk/records-2")

(dialog-text "husk/records-2"
             "the log binder is open on the desk, turned away, as if the reader had just stood up."
             :next "husk/log")

(dialog-text "husk/log"
             "you turn the binder around with two fingers."
             :next "husk/log-s2")

(dialog-text "husk/log-s2"
             "the entries are in a captain's hand, small and even, slanted left at the ends of the lines when the writer is tired. you know the hand."
             :next "husk/log-s3")

(dialog-text "husk/log-s3"
             "you have signed a manual with it. you have signed letters home with it."
             :next "husk/log-read")

(dialog-text "husk/log-read"
             "the entries are crossings. eighty-one seconds. seventy-nine. the same lane, the same gates. the dates are in a calendar you do not set against your own. the last entry is not a crossing. it says: COUNTED EVERYONE TWICE. ONE."
             :next "husk/manifest")

(dialog-text "husk/manifest"
             "the crew manifest hangs by the door in its steel frame, the way yours does. you read it with the lamp at arm's length. Imari. Voss. Harrow. Okafor. Dane. the duty columns are different in small ways."
             :next "husk/comms-two")

(defun husk-manifest-target ()
  (if (dialog-value "ship-lost-name")
      "husk/manifest-lost"
      "husk/mess"))

(dialog-say "husk/comms-two" "Imari"
            "captain, read me her registry off the manifest frame, bottom corner."
            :next "husk/comms-two-2")

(dialog-say "husk/comms-two-2" "you"
            "kestrel-nine-nine-one."
            :next "husk/comms-two-3")

(dialog-say "husk/comms-two-3" "Imari"
            "say again, captain."
            :next #'husk-manifest-target)

(dialog-text "husk/manifest-lost"
             "you read the manifest once more. there is a thing you are not letting yourself check. then you check it. {ship-lost-name} is on her roster too, third watch. the duty column says relieved. the date column says nothing."
             :next "husk/mess")

(dialog-text "husk/mess"
             "the mess is stowed and clean under the frost. one place is set at the long table. cup, tray, fork squared, a film of ice over all of it. the chair is pushed back the width of a person."
             :next "husk/galley")

(dialog-text "husk/galley"
             "in her galley the rack holds one cup. the cup has a dry ring in it, low down, at the level of the last two swallows."
             :next "husk/galley-2")

(dialog-text "husk/galley-2"
             "on the shelf above it the manual is open. you know the page without the lamp. you put the lamp on it anyway. it is that page."
             :next "husk/bunk")

(dialog-text "husk/bunk"
             "you go one deck down. you have stopped pretending you are not going there. the bunk is made."
             :next "husk/bunk-2")

(dialog-text "husk/bunk-2"
             "the name at the foot is stenciled, worn, repainted at least once, the letters traced over themselves a little off true. you do not read it."
             :next "husk/bunk-3")

(dialog-text "husk/bunk-3"
             "you stand in the hatch and do not read it. it takes everything you have."
             :next "husk/decision")

(dialog-pick "husk/decision"
             "Voss on comms: weather on the lane in forty. captain, what are we doing with her?"
             (dialog-option "take the log and go" "husk/take-log")
             (dialog-option "seal her and leave her" "husk/seal")
             (dialog-option "scuttle her" "husk/scuttle"))

(dialog-on-enter "husk/take-log"
                 '(setf (dialog-value "husk-decision") "log"))

(dialog-text "husk/take-log"
             "you bag the binder and dog the records deck behind you. it rides home on your knee. it goes in the safe under the lane tables. the safe has always had room for it. you do not think about that either."
             :next "husk/ride-home")

(dialog-on-enter "husk/seal"
                 '(setf (dialog-value "husk-decision") "sealed"))

(dialog-text "husk/seal"
             "you crank the lock shut from outside and wire the handle the way you wire a gate. she stays on the lane, trimmed. the sweep will find her again every pass. now that is a thing you chose."
             :next "husk/ride-home")

(dialog-on-enter "husk/scuttle"
                 '(setf (dialog-value "husk-decision") "scuttled"))

(dialog-text "husk/scuttle"
             "the charges are in the aft locker. you go straight to it in the dark, without thinking. that does not surprise you anymore."
             :next "husk/scuttle-2")

(dialog-text "husk/scuttle-2"
             "from the launch the flash is small and white and short, a struck match a kilometer off. then the lane is empty on the sweep for the first time all watch. Voss lets out her breath."
             :next "husk/scuttle-3")

(dialog-text "husk/scuttle-3"
             "you count the seconds of quiet after it and stop at eighty-one."
             :next "husk/ride-home")

(dialog-text "husk/ride-home"
             "the ride home is short and very long. halfway, Imari comes on the channel, even and flat, reading the next watch rotation. it is for you. you let it be."
             :next "husk/debrief")

(dialog-say "husk/debrief" "Imari"
            "for the log: derelict, registry illegible, no salvage of record. that is what i have written, captain."
            :next "husk/debrief-2")

(dialog-say "husk/debrief-2" "you"
            "the registry was legible."
            :next "husk/debrief-3")

(dialog-say "husk/debrief-3" "Imari"
            "the record protects the living. you taught me the sentence. let it work for you once."
            :next "husk/voss-after")

(dialog-say "husk/voss-after" "Voss"
            "i will re-run the lane tables tonight. not because they are wrong."
            :next "husk/voss-after-2")

(dialog-say "husk/voss-after-2" "you"
            "because the hands want something to do."
            :next "husk/voss-after-3")

(dialog-say "husk/voss-after-3" "Voss"
            "because the hands want something to do. good night, captain."
            :next "husk/checklist")

(dialog-text "husk/checklist"
             "before lights-down you read the checklist taped to the console, every line. item nine says count everyone twice. tonight you read the handwriting itself, the small even hand slanted left at the ends. then you stop reading."
             :next "husk/sleep")

(defun husk-sleep-target ()
  (let ((decision (dialog-value "husk-decision" "")))
    (cond
      ((string= decision "log") "husk/sleep-log")
      ((string= decision "sealed") "husk/sleep-sealed")
      ((string= decision "scuttled") "husk/sleep-scuttled")
      (t "husk/sleep-plain"))))

(dialog-text "husk/sleep"
             "the ship hums under the floor. yours, warm, crewed. on the way to the bunk you do the thing you do with your eyes. door, corridor, hatch, counted."
             :next #'husk-sleep-target)

(dialog-text "husk/sleep-log"
             "you do not open the safe. you put your hand flat on it once. then you lie down in the bunk with your name stenciled at the foot. the name is freshly yours tonight. you sleep."
             :next "sys/reboot")

(dialog-text "husk/sleep-sealed"
             "on the last sweep before lights-down the return is there, cold, a kilometer of wire holding her shut. the display calls it station-keeping. keeping, anyway. you sleep. the sweep finds her all night, every pass."
             :next "sys/reboot")

(dialog-text "husk/sleep-scuttled"
             "the lane is clean on every sweep. in the bunk you listen to your own ship. when the carrier tone marks the hour it comes half a second late. or you are tired. you choose tired. you sleep."
             :next "sys/reboot")

(dialog-text "husk/sleep-plain"
             "you lie down in the bunk with your name stenciled at the foot. out on the lane the cold return rides its long orbit, unboarded and unread. that is a decision too. you sleep on it."
             :next "sys/reboot")
