;;; War leader path, grafted from the hall-sound leaves. The sounds keep
;;; their first reading; the building answers them with a knock.

(dialog-set-next "base/listen/static" "war/static")
(dialog-set-next "base/listen/bells" "war/bells")
(dialog-set-next "base/listen/glass" "war/glass")

(dialog-text "war/static"
             "the voice finishes its numbers and starts the same list over. closer than the radio, someone in the hall shifts their weight."
             :next "war/knock")

(dialog-text "war/bells"
             "the bells ring on. footsteps pass your door at a walk, unhurried. whoever it is has heard them for days."
             :next "war/knock")

(dialog-text "war/glass"
             "the thuds keep their slow count. the window glass is taped in a wide X. you do not remember taping it."
             :next "war/knock")

(dialog-text "war/knock"
             "two knocks, a pause, one knock. the door opens before you answer."
             :next "war/aide")

(dialog-conversation "war/aide"
                     (dialog-left "Brandt"
                                  "you slept four hours, chancellor. the eastern line held.")
                     (dialog-right "you"
                                   "and the city?")
                     (dialog-left "Brandt"
                                  "the third district is still ringing. the cabinet is waiting.")
                     :next "war/corridor")

(dialog-text "war/corridor"
             "the corridor is carpeted and dim, every window taped and curtained. Brandt walks half a step behind with a folder he does not offer you."
             :next "war/doors")

(dialog-text "war/doors"
             "the doors along the corridor are numbered. the cabinet room is door {door-count}."
             :next "war/cabinet")

(dialog-text "war/cabinet"
             "a long table, mostly empty chairs. Olen stands at the map, where three tape lines have moved since the last briefing."
             :next "war/briefing")

(dialog-pick "war/briefing"
             "Olen waits by the map."
             (dialog-option "ask what moved" "war/moved")
             (dialog-option "ask about the bells" "war/bells-answer")
             (dialog-option "sit down and listen" "war/sit"))

(dialog-say "war/moved"
            "Olen"
            "the river line moved. we hold the bridge or we hold the rail yard. by morning, not both."
            :next "war/decision")

(dialog-say "war/bells-answer"
            "Olen"
            "the third district rings until the all-clear. there has been no all-clear since tuesday."
            :next "war/decision")

(dialog-text "war/sit"
             "you sit. Olen begins without being asked: the river line, the bridge, the rail yard. one of them can be held by morning."
             :next "war/decision")

(dialog-pick "war/decision"
             "Olen sets two pins beside the map and waits."
             (dialog-option "hold the bridge" "war/bridge")
             (dialog-option "hold the rail yard" "war/rail-yard")
             (dialog-option "ask for an hour" "war/hour"))

(dialog-on-enter "war/bridge"
                 '(setf (dialog-value "war-first-order") "bridge"))

(dialog-text "war/bridge"
             "Olen moves one tape line. east of the river, the rail yard crews will wait for trains that have already been rerouted. no one will tell them why."
             :next "war/return")

(dialog-on-enter "war/rail-yard"
                 '(setf (dialog-value "war-first-order") "rail-yard"))

(dialog-text "war/rail-yard"
             "Olen moves one tape line. the bridge garrison's final supply run is logged for 0400. the log does not say final."
             :next "war/return")

(dialog-on-enter "war/hour"
                 '(setf (dialog-value "war-first-order") "delay"))

(dialog-say "war/hour"
            "Olen"
            "you have until the bells stop."
            :next "war/hour-window")

(dialog-text "war/hour-window"
             "Brandt looks at the curtained window. the bells have not stopped since tuesday."
             :next "war/return")

(dialog-text "war/return"
             "Brandt walks you back along the numbered doors. in your room, the radio is still on."
             :next "war/radio")

(dialog-minigame "war/radio"
                 "a / d or left / right arrow keys tune the dial. find a clear band."
                 :game :war-radio
                 :success "war/radio-found"
                 :failure "war/radio-give-up")

(dialog-text "war/radio-found"
             "the static opens onto a clear band. a voice is reading numbers there too. you turn it down, not off, and sleep in your clothes."
             :next "war/day2")

(dialog-text "war/radio-give-up"
             "every band is the same weather. you turn it down, not off, and sleep in your clothes."
             :next "war/day2")


;;; Day two: the figures, the cabinet, and the rerouting order.

(defun war-day2-report-target ()
  (let ((order (dialog-value "war-first-order" "delay")))
    (cond
      ((string= order "bridge") "war/figures-bridge")
      ((string= order "rail-yard") "war/figures-rail")
      (t "war/figures-delay"))))

(dialog-scene "war/day2"
              "the second morning."
              :next "war/day2-knock")

(dialog-text "war/day2-knock"
             "the same knock, earlier than yesterday. Brandt carries two folders now and offers you the thin one."
             :next #'war-day2-report-target)

(dialog-text "war/figures-bridge"
             "the bridge held. the rail yard changed hands overnight. the folder gives the yard crews one line: forty-one unaccounted for, pending."
             :next "war/figures-after")

(dialog-text "war/figures-rail"
             "the rail yard held. the bridge garrison's 0400 supply run is logged as delivered. there is no entry for the garrison after that."
             :next "war/figures-after")

(dialog-text "war/figures-delay"
             "you asked for an hour. the folder splits the night between both positions: neither held entirely, and the word pending appears eleven times."
             :next "war/figures-after")

(dialog-conversation "war/figures-after"
                     (dialog-left "Brandt"
                                  "the cabinet convenes at eight. minister Vey asked for you beforehand. alone.")
                     (dialog-right "you"
                                   "and the thick folder?")
                     (dialog-left "Brandt"
                                  "supply manifests. Sorel flagged them. i would read them first, chancellor.")
                     :next "war/manifests")

(dialog-text "war/manifests"
             "the manifests cover the tuesday trains. four were rerouted from the third district the night the bells began. Sorel has paired what was loaded against what arrived."
             :next "war/audit")

(dialog-minigame "war/audit"
                 "w/s or arrows move. space flags the line that does not match."
                 :game :war-audit
                 :success "war/audit-caught"
                 :failure "war/audit-brandt")

(dialog-text "war/audit-caught"
             "car four. eight hundred short between loading and arrival, and nothing in the margin to explain it. the rerouting order is attached."
             :next "war/signature")

(dialog-text "war/audit-brandt"
             "the figures swim. Brandt leans over and sets one finger on car four without being asked. the rerouting order is attached."
             :next "war/signature")

(dialog-text "war/signature"
             "the signature on the order is yours. you do not remember signing it. it is dated tuesday, 0200, in your own hand, steadier than your hand has been for weeks."
             :next "war/anteroom")

(dialog-text "war/anteroom"
             "in the anteroom, Vey stands when you enter. Sorel does not look up from a ledger. Olen is already in the cabinet room, by the map."
             :next "war/day2-choice")

(dialog-pick "war/day2-choice"
             "the eight o'clock bell has not rung yet."
             (dialog-option "hear Vey alone" "war/vey")
             (dialog-option "ask Sorel about the trains" "war/sorel")
             (dialog-option "take the order to Olen" "war/olen"))

(dialog-on-enter "war/vey"
                 '(setf (dialog-value "war-confidant") "vey"))

(dialog-conversation "war/vey"
                     (dialog-left "Vey"
                                  "the third district is asking who moved their trains. i can give them an answer that is not your signature.")
                     (dialog-right "you"
                                   "in exchange for what?")
                     (dialog-left "Vey"
                                  "emergency powers, on the table this morning. signed in front of the cabinet, in your steadiest hand.")
                     :next "war/day2-bell")

(dialog-on-enter "war/sorel"
                 '(setf (dialog-value "war-confidant") "sorel"))

(dialog-conversation "war/sorel"
                     (dialog-left "Sorel"
                                  "four trains, chancellor. flour, fuel, winter coats, and one car that is not on any manifest at all.")
                     (dialog-right "you"
                                   "where did they go?")
                     (dialog-left "Sorel"
                                  "the order says the depot at kilometer nine. there is no depot at kilometer nine. there is a fence.")
                     :next "war/day2-bell")

(dialog-on-enter "war/olen"
                 '(setf (dialog-value "war-confidant") "olen"))

(dialog-conversation "war/olen"
                     (dialog-left "Olen"
                                  "i know this order. a courier woke me for it tuesday night. you dictated it through the door.")
                     (dialog-right "you"
                                   "you heard my voice?")
                     (dialog-left "Olen"
                                  "i heard a voice that knew the codes, chancellor. at two in the morning, through a door, that is the same thing.")
                     :next "war/day2-bell")

(dialog-text "war/day2-bell"
             "the eight o'clock bell rings once. under it, for a moment, the distant bells of the third district keep their own time."
             :next "war/session")


;;; The session: emergency powers, and kilometer nine.

(dialog-scene "war/session"
              "the cabinet room. eight o'clock."
              :next "war/decree")

(dialog-conversation "war/decree"
                     (dialog-left "Vey"
                                  "the decree consolidates rail, censorship, and the district police under this office until the all-clear.")
                     (dialog-left "Olen"
                                  "there has been no all-clear since tuesday. minister Vey is asking for them permanently.")
                     (dialog-right "you"
                                   "and if i do not sign?")
                     (dialog-left "Vey"
                                  "then the third district learns whose signature moved their winter coats.")
                     :next "war/decree-choice")

(dialog-pick "war/decree-choice"
             "the decree lies beside the rerouting order. the hands match."
             (dialog-option "sign it" "war/decree-signed")
             (dialog-option "refuse" "war/decree-refused")
             (dialog-option "put it to a vote" "war/decree-vote"))

(dialog-on-enter "war/decree-signed"
                 '(setf (dialog-value "war-decree") "signed"))

(dialog-text "war/decree-signed"
             "you sign. your hand shakes, and for once you are glad of it: this signature, at least, looks like yours."
             :next "war/km-nine")

(dialog-on-enter "war/decree-refused"
                 '(setf (dialog-value "war-decree") "refused"))

(dialog-text "war/decree-refused"
             "you refuse. Vey gathers his papers without hurry, the way people do when the next meeting is already arranged."
             :next "war/km-nine")

(dialog-on-enter "war/decree-vote"
                 '(setf (dialog-value "war-decree") "vote"))

(dialog-text "war/decree-vote"
             "you put it to the table. four hands for, three against, and Sorel abstaining with both hands on the ledger. the decree passes without your signature on it."
             :next "war/km-nine")

(dialog-pick "war/km-nine"
             "the manifests still say kilometer nine."
             (dialog-option "send Brandt out there" "war/km-brandt")
             (dialog-option "go yourself, after dark" "war/km-night")
             (dialog-option "leave it alone" "war/km-leave"))

(dialog-on-enter "war/km-brandt"
                 '(setf (dialog-value "war-km-nine") "brandt"))

(dialog-conversation "war/km-brandt"
                     (dialog-left "Brandt"
                                  "there is a fence and a gate and a siding. the unlisted car is there, sealed.")
                     (dialog-right "you"
                                   "and inside?")
                     (dialog-left "Brandt"
                                  "i was not cleared to open it. chancellor, the gate log already had my name in it. i have never been there.")
                     :next "war/night-office")

(dialog-on-enter "war/km-night"
                 '(setf (dialog-value "war-km-nine") "self"))

(dialog-text "war/km-night"
             "after dark you walk the rail cut to kilometer nine. there is a fence, a siding, and one sealed car with fresh chalk marks. the sentry does not turn around. he says good evening, chancellor, and opens the gate."
             :next "war/night-office")

(dialog-on-enter "war/km-leave"
                 '(setf (dialog-value "war-km-nine") "left"))

(dialog-text "war/km-leave"
             "you put the manifests in the bottom drawer. by morning the rerouting order is no longer attached to them, and no one says they removed it."
             :next "war/night-office")

(defun war-night-office-target ()
  (if (dialog-value "war-found-band")
      "war/night-numbers"
      "war/night-quiet"))

(dialog-scene "war/night-office"
              "the night office."
              :next #'war-night-office-target)

(dialog-text "war/night-numbers"
             "the radio is where you left it, tuned to the clear band. the numbers are still being read. tonight, for the first time, you write them down."
             :next "war/day-end")

(dialog-text "war/night-quiet"
             "the radio hisses on the shelf. you leave it be. the bells of the third district reach the window glass and stop there, in the tape."
             :next "war/day-end")

(dialog-text "war/day-end"
             "you sleep at the desk, over the folder, in your clothes."
             :next "base/awake")
