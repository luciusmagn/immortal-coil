;;; The quiet mutiny: the ship's second dark branch. The captain tells
;;; the truth once, and the crew responds with perfect, loving
;;; procedure. Every kindness is a cell. Entered from the galley
;;; question; exits through sleep.

(dialog-music "mutiny/told" "audio/ship-lyria-drone.mp3" :volume 0.18)

(dialog-text "mutiny/truth"
             "you set the cup down and tell her. the failed attempts. the alarm that is always still sounding. the counting. you keep your voice level the whole way through, which afterward you understand was the worst possible way to say it."
             :next "mutiny/told")

(dialog-text "mutiny/told"
             "Voss does not laugh and does not argue. she looks at the cup in your hands for a long moment, says thank you, captain, the way you thank someone for a casualty report, and washes her own cup twice."
             :next "mutiny/night")

(dialog-text "mutiny/night"
             "nothing happens that night. you lie in the bunk and feel the ship around you, warm, crewed, and somewhere in it one conversation you cannot hear, conducted in the low voices of people who love you."
             :next "mutiny/morning")

(dialog-scene "mutiny/morning"
              "the next morning."
              :next "mutiny/codes")

(dialog-text "mutiny/codes"
             "your command codes return AUTHENTICATING a half second longer than they used to. then they work. a half second is nothing. it is exactly the length of a second person's approval."
             :next "mutiny/dane")

(dialog-conversation "mutiny/dane"
                     (dialog-left "Dane"
                                  "routine crew physical, captain. you are due. you have been due for three rotations, so this one found you.")
                     (dialog-right "{player-name}"
                                   "did Voss send you?")
                     (dialog-left "Dane"
                                  "the schedule sent me. sit, please. this is the part where i listen to your heart and you look at the wall and we both pretend that is all i am listening to.")
                     :next "mutiny/physical")

(dialog-text "mutiny/physical"
             "Dane's hands are warm and the instruments are cold and the questions are very slightly wrong: how long have you felt the crossings repeat, captain, rather than do they. you answer the questions that were asked and not the ones that were meant, and Dane writes the same amount either way."
             :next "mutiny/bridge-day")

(dialog-text "mutiny/bridge-day"
             "on the bridge, the watch rotates around you with its usual quiet, except the helm is always crewed now, even in dock trim, and the jump seat has been swung out and locked open, facing the boards, comfortable, yours."
             :next "mutiny/imari-file")

(dialog-conversation "mutiny/imari-file"
                     (dialog-left "Imari"
                                  "captain. before this goes where it is going, you should see what i have, from me, not from the file.")
                     (dialog-right "{player-name}"
                                   "show me.")
                     (dialog-left "Imari"
                                  "forty-one crossings. no failed attempts. no aborts, no scrubs, no second passes. captain, i have served eleven years and nobody flies like that. i wrote it down because it is my job to write things down. i am sorry for what it adds up to.")
                     :next "mutiny/file")

(dialog-text "mutiny/file"
             "the file is thin and devastating. every perfect crossing, dated. every correct call, logged. the record you thought protected you, kept faithfully by the person who loves you most professionally, reading now as the chart of someone who cannot be what the record says, and so must be something else."
             :next "mutiny/meeting-call")

(dialog-text "mutiny/meeting-call"
             "the meeting is not called a meeting. it is called a scheduling review, mess hall, end of watch, and when you arrive the whole crew is there and nobody is eating and there are two cups set out, both for you, one water, one not."
             :next "mutiny/meeting")

(dialog-conversation "mutiny/meeting"
                     (dialog-left "Voss"
                                  "captain. nobody here doubts you. that is the problem. we have run out of ways to believe what we see.")
                     (dialog-left "Imari"
                                  "the record supports relief for rest. it is the gentlest sentence the regulations contain. i looked for a gentler one. there is not one.")
                     (dialog-right "{player-name}"
                                   "and if i refuse?")
                     (dialog-left "Dane"
                                  "then nothing happens today, and we have this meeting again in a week, with the same love and one more week of file.")
                     :next "mutiny/choice")

(dialog-pick "mutiny/choice"
             "the two cups sit in front of you. the crew waits, kind and arranged."
             (dialog-option "sign the relief yourself" "mutiny/sign")
             (dialog-option "refuse and stand on the record" "mutiny/refuse")
             (dialog-option "ask for one last crossing" "mutiny/last-crossing"))

(dialog-on-enter "mutiny/sign"
                 '(setf (dialog-value "mutiny-answer") "signed"))

(dialog-text "mutiny/sign"
             "you sign it yourself, in the small even hand slanted left at the line ends, and the relief is the first document in months that feels true going down. Imari countersigns without looking up, because looking up would be unkind, and Imari has thought about this."
             :next "mutiny/quarters")

(dialog-on-enter "mutiny/refuse"
                 '(setf (dialog-value "mutiny-answer") "refused"))

(dialog-text "mutiny/refuse"
             "you refuse. the crew accepts it the way a tide accepts a fence post. the meeting adjourns with warmth and apologies, and over the next three watches every duty you hold is rotated, for training purposes, into other hands, until the only thing left assigned to you is rest."
             :next "mutiny/quarters")

(dialog-on-enter "mutiny/last-crossing"
                 '(setf (dialog-value "mutiny-answer") "bargained"))

(dialog-text "mutiny/last-crossing"
             "one last crossing. they grant it the way families grant things at bedsides. Voss preflights the lane twice. Imari opens a log page headed with your name and rank, and adds, in brackets, the word final, and then erases it, and the erasure stays in the paper like a scar."
             :next "mutiny/crossing")

(dialog-minigame "mutiny/crossing"
                 "w/a/s/d or arrow keys steer. hold the ship in the open gates."
                 :game :wire-flight
                 :success "mutiny/crossing-clean"
                 :failure "mutiny/crossing-failed")

(dialog-text "mutiny/crossing-clean"
             "eighty seconds. cleanest of the record. you bring her through and the bridge is silent, and you understand the silence: you have just proven their case past appeal. perfection was the symptom. you flew the confession."
             :next "mutiny/quarters")

(dialog-text "mutiny/crossing-failed"
             "the lane closes early and you scrub the run, hands correct, voice level, abort textbook. it is the first imperfect thing the crew has ever watched you do, and from the helm you hear Voss exhale, and you understand that for them, the scrub was the most reassuring flying of your life. the relief signs itself after that."
             :next "mutiny/quarters")

(dialog-text "mutiny/quarters"
             "your quarters have been improved while you were elsewhere. a better blanket. your books returned from the wardroom. the desk cleared of lane tables and dressed with the photographs you never put up. the door closes with its old sound, and the new sound is the one it does not make after: the bolt is gone, swapped for a latch that opens from both sides, for your safety."
             :next "mutiny/days")

(dialog-scene "mutiny/days"
              "the days after."
              :next "mutiny/routine")

(dialog-text "mutiny/routine"
             "rest has a schedule. walks at change of watch, accompanied, conversational. meals brought warm and on time. Dane twice a day, listening to your heart and the wall. the crew greets you by rank, every time, with a gentleness that would be mockery from anyone who loved you less."
             :next "mutiny/observations")

(dialog-text "mutiny/observations"
             "you start noticing the ship the way passengers do. the hum has registers you never had time to hear. the corridor lights warm by two points at meal hours. it is a good ship. you commanded it for years and are only now aboard it."
             :next "mutiny/visit")

(dialog-conversation "mutiny/visit"
                     (dialog-left "Voss"
                                  "i brought the lane tables. not for work. some people like crosswords.")
                     (dialog-right "{player-name}"
                                   "is that a joke, commander?")
                     (dialog-left "Voss"
                                  "acting captain. and yes. it was a bad one. the next ones will be better. i have a file of them now. someone keeps files on this ship, it turns out.")
                     :next "mutiny/inspection")

(dialog-scene "mutiny/inspection"
              "the inspection."
              :next "mutiny/inspector-aboard")

(dialog-text "mutiny/inspector-aboard"
             "a sector inspector docks on the eleventh day, grey-tabbed and pleasant, with a list. command transfers attract lists. the crew meets her in dress order, and you are on the list, fourth item, after the reactor logs and before the water reclamation figures."
             :next "mutiny/inspector-talk")

(dialog-conversation "mutiny/inspector-talk"
                     (dialog-left "the inspector"
                                  "relief for rest, self-signed, countersigned, exemplary file. i have read it. now i would like the part that is not in it.")
                     (dialog-right "{player-name}"
                                   "the file is accurate.")
                     (dialog-left "the inspector"
                                  "files always are. that is what they are for. captain, i have done forty of these. the crews lie out of contempt or they lie out of love, and this crew has scrubbed the deck plates twice. blink if you want this ship turned over.")
                     :next "mutiny/inspector-choice")

(dialog-pick "mutiny/inspector-choice"
             "she waits with her stylus capped. through the open hatch, Imari is very carefully not listening."
             (dialog-option "tell her the relief was right" "mutiny/back-crew")
             (dialog-option "tell her everything you told Voss" "mutiny/tell-inspector")
             (dialog-option "say the file is complete" "mutiny/say-nothing"))

(dialog-on-enter "mutiny/back-crew"
                 '(setf (dialog-value "mutiny-inspector") "backed"))

(dialog-text "mutiny/back-crew"
             "you tell her the relief was right, in the level voice, with the reasons in order, and you watch yourself defend the cage from inside it because the people who built it are yours. she caps her list. exemplary, she says, and means the crew, and looks at you a half second too long while she says it."
             :next "mutiny/inspector-leaves")

(dialog-on-enter "mutiny/tell-inspector"
                 '(setf (dialog-value "mutiny-inspector") "told"))

(dialog-text "mutiny/tell-inspector"
             "you tell her everything. she listens the way Dane listens, to you and to the wall, and writes nothing, and when you finish she says, gently, that what you have described is in the file, captain, in the annex, in your own statement, dated the night you told your navigator. you ask to see the annex. your signature is on it. you keep your face still while the floor moves."
             :next "mutiny/inspector-leaves")

(dialog-on-enter "mutiny/say-nothing"
                 '(setf (dialog-value "mutiny-inspector") "silent"))

(dialog-text "mutiny/say-nothing"
             "the file is complete, you say, and she nods the way professionals nod at each other across a fact they have agreed not to lift, and caps the stylus, and the inspection moves on to water reclamation, where the figures are also exemplary."
             :next "mutiny/inspector-leaves")

(dialog-text "mutiny/inspector-leaves"
             "she undocks at end of watch. the crew exhales by sections. that night the corridor lights warm by two points an hour early, and there is cake from somewhere, real cake, and a slice arrives at your quarters on the good tray with two forks, in case you wanted company, the note says, and the note is in Voss's hand."
             :next "mutiny/wardroom")

(dialog-text "mutiny/wardroom"
             "you take the second fork to the wardroom. they make room the way crews do, a half shuffle outward around the table, and for one hour over cake the rank dissolves and you are just the person who has been aboard longest, telling the story of the bad refit at dock nine, and they laugh in the right places, and it is the finest hour of the month, and it costs them nothing, and you understand at last that it never did."
             :next "mutiny/night-bridge-choice")

(dialog-pick "mutiny/night-bridge-choice"
             "third watch. the corridor to the bridge is unlocked, because everything is unlocked to you now, which is how they keep you."
             (dialog-option "go up to the bridge" "mutiny/night-bridge")
             (dialog-option "stay and sleep" "mutiny/stay"))

(dialog-text "mutiny/stay"
             "you stay. through the bulkhead, at the top of the hour, the watch changes with its small ceremony, and you mouth the words of the handover from your bed, all of them, in order, and then you stop yourself, and that is the night's work."
             :next "mutiny/succession")

(dialog-text "mutiny/night-bridge"
             "they let you onto the bridge at night the way a family lets a grandfather into a workshop. the watch greets you by rank. someone fetches coffee. the jump seat is already out. nobody offers you the boards and nobody would stop you, and between those two facts there is a fence higher than any door."
             :next "mutiny/succession")

(dialog-text "mutiny/succession"
             "you are in the jump seat when the next crossing comes. Voss flies it. she is good, then better than good, and the board goes green deck by deck, and Imari says eighty-three seconds, cleanest of the quarter, and you watch the praise land on her face and find nothing there to hold onto. her eyes are already on the next lane. her hand stays curled around the cup long after it is empty."
             :next "mutiny/succession-after")

(dialog-text "mutiny/succession-after"
             "nobody else saw it. you saw it, because you have stood where she is standing, behind that exact stillness. you open your mouth to say something across the bridge, and close it, because there is nothing to say that the file would not absorb, and because she would say it back to you in a year, level-voiced, over a washed cup."
             :next "mutiny/letter")

(dialog-text "mutiny/letter"
             "in your quarters you write to Voss in the format no manual provides. four sentences. you do not send it. you put it under the blotter with the pencil flat on top, where a careful person tidying after you will someday find it and understand it was meant to be found."
             :next "mutiny/sleep")

(defun mutiny-sleep-target ()
  (let ((answer (dialog-value "mutiny-answer" "")))
    (cond
      ((string= answer "signed") "mutiny/sleep-signed")
      ((string= answer "refused") "mutiny/sleep-refused")
      (t "mutiny/sleep-bargained"))))

(dialog-text "mutiny/sleep"
             "Dane's evening round. the small cup with the smaller pill, offered, never insisted. you take it some nights. tonight you palm it, and Dane sees you palm it, and writes the same amount either way, and wishes you good night by rank."
             :next #'mutiny-sleep-target)

(dialog-text "mutiny/sleep-signed"
             "you lie down in a bed that has been made for you by other hands. your signature is on your own relief, the truest thing you ever signed, and sleep comes the way the tide comes in: scheduled, gentle, and not yours to refuse."
             :next "base/awake")

(dialog-text "mutiny/sleep-refused"
             "you lie down still captain by your own record, of nothing, beloved, attended, and kept. through the bulkhead the ship runs perfectly without you, which was always the cruelest thing it knew how to do, and you sleep inside its kindness like a coat that fits."
             :next "base/awake")

(dialog-text "mutiny/sleep-bargained"
             "you lie down with the last crossing still in your hands, the way a final cigarette stays in the lungs. whatever the log says of it, it was flying, and it was yours, and they gave it to you because they loved you, and they took everything else for the same reason, and you sleep."
             :next "base/awake")
