;;; War leader path, grafted from the hall-sound leaves. The sounds keep
;;; their first reading; the building answers them with a knock.

(dialog-set-next "base/listen/static" "war/static")
(dialog-set-next "base/listen/bells" "war/bells")
(dialog-set-next "base/listen/glass" "war/glass")

(dialog-particles "war/static" :ash :fade-seconds 4.0)
(dialog-particles "war/bells" :ash :fade-seconds 4.0)
(dialog-particles "war/glass" :ash :fade-seconds 4.0)

(defun war-knock-target ()
  (if (dialog-value "war-first-order")
      "war/knock-again"
      "war/knock"))

(dialog-text "war/static"
             "the voice finishes its numbers and starts the same list over. closer than the radio, someone in the hall shifts their weight."
             :next #'war-knock-target)

(dialog-text "war/bells"
             "the bells ring on. footsteps pass your door at a walk, unhurried. whoever it is has heard them for days."
             :next #'war-knock-target)

(dialog-text "war/glass"
             "the thuds keep their slow count. the window glass is taped in a wide X. you do not remember taping it."
             :next #'war-knock-target)

(dialog-text "war/knock"
             "two knocks, a pause, one knock. the door opens before you answer."
             :next "war/aide")

(dialog-text "war/knock-again"
             "two knocks, a pause, one knock. you are awake before the second knock, and dressed."
             :next "war/aide")

(dialog-say "war/aide"
            "Brandt"
            "you slept four hours, chancellor. the eastern line held."
            :next "war/aide-2")

(dialog-say "war/aide-2"
            "you"
            "and the city?"
            :next "war/aide-3")

(dialog-say "war/aide-3"
            "Brandt"
            "the third district is still ringing. the cabinet is waiting."
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
             "you asked for an hour. the folder splits the night between both positions. neither held. the word pending appears eleven times."
             :next "war/figures-after")

(dialog-say "war/figures-after"
            "Brandt"
            "the cabinet convenes at eight. minister Vey asked for you beforehand. alone."
            :next "war/figures-after-2")

(dialog-say "war/figures-after-2"
            "you"
            "and the thick folder?"
            :next "war/figures-after-3")

(dialog-say "war/figures-after-3"
            "Brandt"
            "supply manifests. Sorel flagged them. i would read them first, chancellor."
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

(dialog-say "war/vey"
            "Vey"
            "the third district is asking who moved their trains. i can give them an answer that is not your signature."
            :next "war/vey-2")

(dialog-say "war/vey-2"
            "you"
            "in exchange for what?"
            :next "war/vey-3")

(dialog-say "war/vey-3"
            "Vey"
            "emergency powers, on the table this morning. signed in front of the cabinet, in your steadiest hand."
            :next "war/day2-bell")

(dialog-on-enter "war/sorel"
                 '(setf (dialog-value "war-confidant") "sorel"))

(dialog-say "war/sorel"
            "Sorel"
            "four trains, chancellor. flour, fuel, winter coats, and one car that is not on any manifest at all."
            :next "war/sorel-2")

(dialog-say "war/sorel-2"
            "you"
            "where did they go?"
            :next "war/sorel-3")

(dialog-say "war/sorel-3"
            "Sorel"
            "the order says the depot at kilometer nine. there is no depot at kilometer nine. there is a fence."
            :next "war/day2-bell")

(dialog-on-enter "war/olen"
                 '(setf (dialog-value "war-confidant") "olen"))

(dialog-say "war/olen"
            "Olen"
            "i know this order. a courier woke me for it tuesday night. you dictated it through the door."
            :next "war/olen-2")

(dialog-say "war/olen-2"
            "you"
            "you heard my voice?"
            :next "war/olen-3")

(dialog-say "war/olen-3"
            "Olen"
            "i heard a voice that knew the codes, chancellor. at two in the morning, through a door, that is the same thing."
            :next "war/day2-bell")

(dialog-text "war/day2-bell"
             "the eight o'clock bell rings once. under it, for a moment, the distant bells of the third district keep their own time."
             :next "war/session")


;;; The session: emergency powers, and kilometer nine.

(dialog-scene "war/session"
              "the cabinet room. eight o'clock."
              :next "war/decree")

(dialog-say "war/decree"
            "Vey"
            "the decree consolidates rail, censorship, and the district police under this office until the all-clear."
            :next "war/decree-2")

(dialog-say "war/decree-2"
            "Olen"
            "there has been no all-clear since tuesday. minister Vey is asking for them permanently."
            :next "war/decree-3")

(dialog-say "war/decree-3"
            "you"
            "and if i do not sign?"
            :next "war/decree-4")

(dialog-say "war/decree-4"
            "Vey"
            "then the third district learns whose signature moved their winter coats."
            :next "war/decree-choice")

(dialog-pick "war/decree-choice"
             "the decree lies beside the rerouting order. the hands match."
             (dialog-option "sign it" "war/decree-signed")
             (dialog-option "refuse" "war/decree-refused")
             (dialog-option "put it to a vote" "war/decree-vote"))

(dialog-on-enter "war/decree-signed"
                 '(setf (dialog-value "war-decree") "signed"))

(dialog-text "war/decree-signed"
             "you sign. your hand shakes. for once you are glad of it. this signature at least looks like yours."
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

(dialog-say "war/km-brandt"
            "Brandt"
            "there is a fence and a gate and a siding. the unlisted car is there, sealed."
            :next "war/km-brandt-2")

(dialog-say "war/km-brandt-2"
            "you"
            "and inside?"
            :next "war/km-brandt-3")

(dialog-say "war/km-brandt-3"
            "Brandt"
            "i was not cleared to open it. chancellor, the gate log already had my name in it. i have never been there."
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
             :next "war/day3")


;;; Day three: what the decree bought, and what the numbers count.

(defun war-day3-decree-target ()
  (let ((decree (dialog-value "war-decree" "vote")))
    (cond
      ((string= decree "signed") "war/decree-cost-signed")
      ((string= decree "refused") "war/decree-cost-refused")
      (t "war/decree-cost-vote"))))

(defun war-numbers-target ()
  (if (dialog-value "war-found-band")
      "war/numbers-yours"
      "war/numbers-sorel"))

(dialog-scene "war/day3"
              "the third morning."
              :next #'war-day3-decree-target)

(dialog-text "war/decree-cost-signed"
             "the district police wear new armbands by eight. your morning mail arrives opened and re-gummed, with a slip that reads INSPECTED FOR YOUR SAFETY. the slip is signed by no one."
             :next "war/day3-brandt")

(dialog-text "war/decree-cost-refused"
             "the decree returns countersigned by four ministers. a clerk asks, politely, on whose authority Brandt enters this wing. Brandt has worked here for nine years."
             :next "war/day3-brandt")

(dialog-text "war/decree-cost-vote"
             "the table that passed the decree met again last night, without you. the minutes list you as absent with apologies. you sent no apologies."
             :next "war/day3-brandt")

(dialog-say "war/day3-brandt"
            "Brandt"
            "Sorel is waiting in the map room. she has been there since five."
            :next "war/day3-brandt-2")

(dialog-say "war/day3-brandt-2"
            "you"
            "with the ledger?"
            :next "war/day3-brandt-3")

(dialog-say "war/day3-brandt-3"
            "Brandt"
            "with the ledger, and with yesterday's broadcast log. chancellor, she found what the numbers are."
            :next #'war-numbers-target)

(dialog-text "war/numbers-yours"
             "you bring the page you wrote at the night office. Sorel sets it beside the kilometer nine manifest, and the columns agree: car weights, head counts, departure times. the station has been reading inventory."
             :next "war/numbers-after")

(dialog-text "war/numbers-sorel"
             "Sorel transcribed last night's broadcast herself. set against the kilometer nine manifest, the columns agree: car weights, head counts, departure times. the station has been reading inventory."
             :next "war/numbers-after")

(dialog-say "war/numbers-after"
            "Sorel"
            "head counts, chancellor. the cars are not carrying coats."
            :next "war/numbers-after-2")

(dialog-say "war/numbers-after-2"
            "you"
            "whose counts?"
            :next "war/numbers-after-3")

(dialog-say "war/numbers-after-3"
            "Sorel"
            "the third district's. the bells have been ringing exactly as long as the broadcasts. i checked twice."
            :next "war/day3-choice")

(dialog-pick "war/day3-choice"
             "Sorel closes the ledger and waits. the map room has one door."
             (dialog-option "put it to Vey at the table" "war/accuse")
             (dialog-option "have Olen seal kilometer nine" "war/seal")
             (dialog-option "say nothing yet" "war/wait-move")
             (dialog-option "go to the third district tonight" "district/advice"))

(dialog-on-enter "war/accuse"
                 '(setf (dialog-value "war-day3") "accused"))

(dialog-say "war/accuse"
            "Vey"
            "an inventory broadcast. yes. continuity of government requires knowing what the districts hold."
            :next "war/accuse-2")

(dialog-say "war/accuse-2"
            "you"
            "the cars hold people."
            :next "war/accuse-3")

(dialog-say "war/accuse-3"
            "Vey"
            "the cars hold the district's contribution, chancellor, ordered over your signature. shall i read it to the table?"
            :next "war/day3-close")

(dialog-on-enter "war/seal"
                 '(setf (dialog-value "war-day3") "sealed"))

(dialog-say "war/seal"
            "Olen"
            "i can put a company on the siding by noon. they will need a written order."
            :next "war/seal-2")

(dialog-say "war/seal-2"
            "you"
            "you will have it in my hand."
            :next "war/seal-3")

(dialog-say "war/seal-3"
            "Olen"
            "in your hand, chancellor. watch it being written, and so will i."
            :next "war/day3-close")

(dialog-on-enter "war/wait-move"
                 '(setf (dialog-value "war-day3") "waited"))

(dialog-text "war/wait-move"
             "you say nothing yet. Sorel copies the matched columns into her own ledger, in pencil, and gives you the original. some evidence keeps better when it looks lost."
             :next "war/day3-close")

(dialog-text "war/day3-close"
             "the eight o'clock bell rings. the cabinet takes its seats around the map. whatever else is true, the war is still there. the most anyone can do is lose it slowly."
             :next "war/day3-night")

(defun war-day3-night-target ()
  (let ((day3 (dialog-value "war-day3" "waited")))
    (cond
      ((string= day3 "accused") "war/night-accused")
      ((string= day3 "sealed") "war/night-sealed")
      (t "war/night-waited"))))

(dialog-scene "war/day3-night"
              "the fourth night."
              :next #'war-day3-night-target)

(dialog-text "war/night-accused"
             "no one mentions the morning again. at dusk a clerk you have never seen replaces the lock on your office door, for your safety, and hands you the new key with a bow."
             :next "war/arc-end")

(dialog-text "war/night-sealed"
             "Olen's company reports the siding empty. fence, gate, chalk marks, no car. the gate log's last page has been torn out, and the sentry remembers nobody."
             :next "war/arc-end")

(dialog-text "war/night-waited"
             "the broadcast resumes at midnight. you take down the new numbers beside the old. the head counts are smaller tonight. you are learning to read it. you wish you were not."
             :next "war/arc-end")

(dialog-text "war/arc-end"
             "you sleep badly, in your clothes, with the pencil copy under the blotter."
             :next "war/day4")

(dialog-scene "war/day4"
              "the fourth morning."
              :next "war/brandt-last")

(dialog-say "war/brandt-last"
            "Brandt"
            "the pencil copy is filed, chancellor. filed where things are found again, which is not the same cabinet as filed."
            :next "war/brandt-last-2")

(dialog-say "war/brandt-last-2"
            "you"
            "Brandt. when this is over. what will it have been for?"
            :next "war/brandt-last-3")

(dialog-say "war/brandt-last-3"
            "Brandt"
            "for the ones who get the version with the all-clear in it. someone has to live in that version. it will not be us."
            :next "war/day4-close")

(dialog-text "war/day4-close"
             "the eight o'clock bell rings. you put on yesterday's coat, take the new key, and go down to the cabinet room."
             :next "war/day4-table")

(dialog-text "war/day4-table"
             "at the table, Vey is courteous, Olen is punctual, and Sorel has a new ledger with the first page already ruled. the map has moved again overnight, one tape line, toward the river."
             :next "war/day4-sorel")

(dialog-on-enter "war/day4-sorel"
                 '(setf (dialog-value "war-pencil-note") t))

(dialog-text "war/day4-sorel"
             "Sorel slides you the morning supply sheet to initial. at the bottom, in pencil, small enough to be a stray mark: K9 EMPTY. CAR NOT EMPTY WHEN IT LEFT. you initial the sheet and keep the pencil."
             :next "war/pencil-choice")

(dialog-pick "war/pencil-choice"
             "the pencil sits in your breast pocket through the morning session. the war will write its own version of these years. the question is whether anyone keeps yours."
             (dialog-option "let the building keep the records" "war/day4-end")
             (dialog-option "keep your own record, against the day" "tribunal/keep"))

(dialog-text "war/day4-end"
             "you take your seat. whatever the third district is counting tonight, the war is still there in front of everyone. the most anyone can do is lose it slowly. you are the one they ask to do it."
             :next "armistice/offer")
