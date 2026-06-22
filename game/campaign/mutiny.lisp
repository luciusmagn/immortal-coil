;;; The quiet mutiny: the ship's second dark branch. The captain tells
;;; the truth once, and the crew responds with perfect, loving
;;; procedure. Every kindness is a cell. Entered from the galley
;;; question; exits through sleep.

(dialog-music "mutiny/told" "audio/ship-lyria-drone.mp3" :volume 0.18)

(dialog-text "mutiny/truth"
             "you set the cup down and tell her. the failed attempts. the alarm that never stops. the counting. you keep your voice level the whole way through. that was the wrong way to do it. you see that after."
             :next "mutiny/told")

(dialog-text "mutiny/told"
             "Voss does not laugh and does not argue. she looks at the cup in your hands a long moment. she says thank you, captain. she says it the way you thank a man for a casualty report. she washes her own cup twice."
             :next "mutiny/night")

(dialog-text "mutiny/night"
             "nothing happens that night. you lie in the bunk and feel the ship around you, warm and crewed. somewhere in it there is one conversation you cannot hear. it is held in low voices, by people who love you."
             :next "mutiny/morning")

(dialog-scene "mutiny/morning"
              "the next morning."
              :next "mutiny/codes")

(dialog-text "mutiny/codes"
             "your command codes come back AUTHENTICATING half a second longer than they used to. then they work. half a second is nothing. it is the length of a second person saying yes."
             :next "mutiny/dane")

(dialog-say "mutiny/dane" "Dane"
            "routine crew physical, captain. you are due. you have been due for three rotations, so this one found you."
            :next "mutiny/dane-2")

(dialog-say "mutiny/dane-2" "you"
            "did Voss send you?"
            :next "mutiny/dane-3")

(dialog-say "mutiny/dane-3" "Dane"
            "the schedule sent me. sit, please. this is the part where i listen to your heart and you look at the wall and we both pretend that is all i am listening to."
            :next "mutiny/physical")

(dialog-text "mutiny/physical"
             "Dane's hands are warm and the instruments are cold. the questions are a little wrong. how long have you felt the crossings repeat, captain. not whether they do."
             :next "mutiny/physical-answer")

(dialog-choice-path "mutiny/physical-answer"
                    "the stethoscope is cold and she is not really asking about your heart."
                    ("answer the question she meant"
                     :id "honest"
                     "you tell her how long. the pencil does not speed up or slow down. the steadiness is its own kind of mercy."
                     :next "mutiny/bridge-day")
                    ("answer only the question she asked"
                     :id "evade"
                     "you answer the questions she asked and not the ones she meant. Dane writes the same amount either way."
                     :next "mutiny/bridge-day")
                    ("ask what she has heard from Voss"
                     :id "voss"
                     "the crew talks, she says, and talk is not in her instruments, so she leaves it out. she writes your pulse instead. it has changed."
                     :next "mutiny/bridge-day"))

(dialog-text "mutiny/bridge-day"
             "on the bridge the watch runs with its usual quiet. the helm is always crewed now, even in dock trim. the jump seat has been swung out and locked open, facing the boards. it is comfortable. it is yours."
             :next "mutiny/imari-file")

(dialog-say "mutiny/imari-file" "Imari"
            "captain. before this goes where it is going, you should see what i have, from me, not from the file."
            :next "mutiny/imari-file-2")

(dialog-say "mutiny/imari-file-2" "you"
            "show me."
            :next "mutiny/imari-file-3")

(dialog-say "mutiny/imari-file-3" "Imari"
            "forty-one crossings. no failed attempts. no aborts, no scrubs, no second passes. captain, i have served eleven years and nobody flies like that. i wrote it down because it is my job to write things down. i am sorry for what it adds up to."
            :next "mutiny/file")

(dialog-text "mutiny/file"
             "the file is thin. every clean crossing, dated. every right call, logged."
             :next "mutiny/file-2")

(dialog-text "mutiny/file-2"
             "you thought the record was protecting you. Imari kept it well, out of love, in her way. now it reads as the chart of a man who cannot be what it says he is. so he must be something else."
             :next "mutiny/meeting-call")

(dialog-text "mutiny/meeting-call"
             "the meeting is not called a meeting. it is called a scheduling review. mess hall, end of watch. when you get there the whole crew is present and nobody is eating. two cups are set out, both for you. one water, one not."
             :next "mutiny/meeting")

(dialog-say "mutiny/meeting" "Voss"
            "captain. nobody here doubts you. that is the problem. we have run out of ways to believe what we see."
            :next "mutiny/meeting-2")

(dialog-say "mutiny/meeting-2" "Imari"
            "the record supports relief for rest. it is the gentlest sentence the regulations contain. i looked for a gentler one. there is not one."
            :next "mutiny/meeting-3")

(dialog-say "mutiny/meeting-3" "you"
            "and if i refuse?"
            :next "mutiny/meeting-4")

(dialog-say "mutiny/meeting-4" "Dane"
            "then nothing happens today, and we have this meeting again in a week, with the same love and one more week of file."
            :next "mutiny/choice")

(dialog-pick "mutiny/choice"
             "the two cups sit in front of you. the crew waits, kind and arranged."
             (dialog-option "sign the relief yourself" "mutiny/sign")
             (dialog-option "refuse and stand on the record" "mutiny/refuse")
             (dialog-option "ask for one last crossing" "mutiny/last-crossing"))

(dialog-on-enter "mutiny/sign"
                 '(setf (dialog-value "mutiny-answer") "signed"))

(dialog-text "mutiny/sign"
             "you sign it yourself, in the small even hand that slants left at the ends. it is the first thing you have signed in months that feels true. Imari countersigns without looking up. looking up would be unkind. she has thought about that."
             :next "mutiny/quarters")

(dialog-on-enter "mutiny/refuse"
                 '(setf (dialog-value "mutiny-answer") "refused"))

(dialog-text "mutiny/refuse"
             "you refuse. it changes nothing. the crew lets the refusal sit there, and goes around it."
             :next "mutiny/refuse-2")

(dialog-text "mutiny/refuse-2"
             "the meeting breaks up with warmth and apologies. over the next three watches every duty you hold is rotated into other hands, for training. at the end the only thing left assigned to you is rest."
             :next "mutiny/quarters")

(dialog-on-enter "mutiny/last-crossing"
                 '(setf (dialog-value "mutiny-answer") "bargained"))

(dialog-text "mutiny/last-crossing"
             "one last crossing. they give it to you the way a family gives in at a bedside. Voss preflights the lane twice."
             :next "mutiny/last-crossing-s2")

(dialog-text "mutiny/last-crossing-s2"
             "Imari opens a log page under your name and rank. she writes the word final in brackets, then rubs it out. the mark of it stays in the paper."
             :next "mutiny/crossing")

(dialog-minigame "mutiny/crossing"
                 "w/a/s/d or arrow keys steer. hold the ship in the open gates."
                 :game :wire-flight
                 :success "mutiny/crossing-clean"
                 :failure "mutiny/crossing-failed")

(dialog-text "mutiny/crossing-clean"
             "eighty seconds. cleanest on the record. you bring her through and the bridge goes quiet. you know what the quiet is. you have proven their case past appeal. the clean flying was the symptom. you flew the confession."
             :next "mutiny/quarters")

(dialog-text "mutiny/crossing-failed"
             "the lane closes early and you scrub the run, hands correct, voice level, abort textbook."
             :next "mutiny/crossing-failed-2")

(dialog-text "mutiny/crossing-failed-2"
             "it is the first thing the crew has ever watched you do badly. from the helm you hear Voss let out her breath. for them the scrub is the most reassuring flying of your life. the relief signs itself after that."
             :next "mutiny/quarters")

(dialog-text "mutiny/quarters"
             "your quarters have been improved while you were out. a better blanket. your books back from the wardroom. the desk cleared of lane tables and set with the photographs you never put up."
             :next "mutiny/quarters-2")

(dialog-text "mutiny/quarters-2"
             "the door closes with its old sound. then it does not make the next sound. the bolt is gone. there is a latch now that opens from both sides. for your safety."
             :next "mutiny/days")

(dialog-scene "mutiny/days"
              "the days after."
              :next "mutiny/routine")

(dialog-text "mutiny/routine"
             "rest has a schedule. walks at the change of watch, with company, easy talk. meals brought warm and on time. Dane twice a day, listening to your heart and to the wall."
             :next "mutiny/routine-2")

(dialog-text "mutiny/routine-2"
             "the crew greets you by rank every time. they are gentle about it. from anyone who loved you less it would be mockery."
             :next "mutiny/observations")

(dialog-text "mutiny/observations"
             "you start to notice the ship the way passengers do. the hum has notes in it you never had time to hear. the corridor lights warm two points at meal hours. it is a good ship. you commanded it for years. you are only now aboard it."
             :next "mutiny/visit")

(dialog-say "mutiny/visit" "Voss"
            "i brought the lane tables. not for work. some people like crosswords."
            :next "mutiny/visit-2")

(dialog-say "mutiny/visit-2" "you"
            "is that a joke, commander?"
            :next "mutiny/visit-3")

(dialog-say "mutiny/visit-3" "Voss"
            "acting captain. and yes. it was a bad one. the next ones will be better. i have a file of them now. someone keeps files on this ship, it turns out."
            :next "mutiny/inspection")

(dialog-scene "mutiny/inspection"
              "the inspection."
              :next "mutiny/inspector-aboard")

(dialog-text "mutiny/inspector-aboard"
             "a sector inspector docks on the eleventh day. grey-tabbed, pleasant, with a list. command transfers draw lists. the crew meets her in dress order. you are on the list, fourth item, after the reactor logs and before the water figures."
             :next "mutiny/inspector-talk")

(dialog-say "mutiny/inspector-talk" "the inspector"
            "relief for rest, self-signed, countersigned, exemplary file. i have read it. now i would like the part that is not in it."
            :next "mutiny/inspector-talk-2")

(dialog-say "mutiny/inspector-talk-2" "you"
            "the file is accurate."
            :next "mutiny/inspector-talk-3")

(dialog-say "mutiny/inspector-talk-3" "the inspector"
            "files always are. that is what they are for. captain, i have done forty of these. the crews lie out of contempt or they lie out of love, and this crew has scrubbed the deck plates twice. blink if you want this ship turned over."
            :next "mutiny/inspector-choice")

(dialog-pick "mutiny/inspector-choice"
             "she waits with her stylus capped. through the open hatch, Imari is very carefully not listening."
             (dialog-option "tell her the relief was right" "mutiny/back-crew")
             (dialog-option "tell her everything you told Voss" "mutiny/tell-inspector")
             (dialog-option "say the file is complete" "mutiny/say-nothing"))

(dialog-on-enter "mutiny/back-crew"
                 '(setf (dialog-value "mutiny-inspector") "backed"))

(dialog-text "mutiny/back-crew"
             "you tell her the relief was right. you say it in the level voice, with the reasons in order. you hear yourself defend the cage from the inside of it. the people who built it are yours. she caps her list."
             :next "mutiny/back-crew-2")

(dialog-text "mutiny/back-crew-2"
             "exemplary, she says. she means the crew. she looks at you half a second too long when she says it."
             :next "mutiny/inspector-leaves")

(dialog-on-enter "mutiny/tell-inspector"
                 '(setf (dialog-value "mutiny-inspector") "told"))

(dialog-text "mutiny/tell-inspector"
             "you tell her everything."
             :next "mutiny/tell-inspector-2")

(dialog-text "mutiny/tell-inspector-2"
             "she listens the way Dane listens, to you and to the wall. she writes nothing."
             :next "mutiny/tell-inspector-2-s2")

(dialog-text "mutiny/tell-inspector-2-s2"
             "when you finish she says, gently, that what you have described is in the file already. in the annex. in your own statement."
             :next "mutiny/tell-inspector-2-s3")

(dialog-text "mutiny/tell-inspector-2-s3"
             "dated the night you told your navigator."
             :next "mutiny/tell-inspector-3")

(dialog-text "mutiny/tell-inspector-3"
             "you ask to see the annex. your signature is on it. you keep your face still while the floor moves."
             :next "mutiny/inspector-leaves")

(dialog-on-enter "mutiny/say-nothing"
                 '(setf (dialog-value "mutiny-inspector") "silent"))

(dialog-text "mutiny/say-nothing"
             "the file is complete, you say. she nods. it is the nod two professionals give across a fact they have agreed not to lift. she caps the stylus. the inspection moves on to water reclamation. those figures are exemplary too."
             :next "mutiny/inspector-leaves")

(dialog-text "mutiny/inspector-leaves"
             "she undocks at end of watch. the crew exhales by sections."
             :next "mutiny/inspector-leaves-2")

(dialog-text "mutiny/inspector-leaves-2"
             "that night the corridor lights warm two points an hour early. there is cake from somewhere. real cake. a slice comes to your quarters on the good tray, with two forks. in case you wanted company, the note says. the note is in Voss's hand."
             :next "mutiny/wardroom")

(dialog-text "mutiny/wardroom"
             "you take the second fork to the wardroom."
             :next "mutiny/wardroom-2")

(dialog-text "mutiny/wardroom-2"
             "they make room the way crews do, a half shuffle out around the table. for one hour over cake the rank goes away and you are only the man who has been aboard longest."
             :next "mutiny/wardroom-3")

(dialog-text "mutiny/wardroom-3"
             "you tell the story of the bad refit at dock nine. they laugh in the right places. it is the best hour of the month. it costs them nothing. you understand at last that it never did."
             :next "mutiny/night-bridge-choice")

(dialog-pick "mutiny/night-bridge-choice"
             "third watch. the corridor to the bridge is unlocked. everything is unlocked to you now. that is how they keep you."
             (dialog-option "go up to the bridge" "mutiny/night-bridge")
             (dialog-option "stay and sleep" "mutiny/stay"))

(dialog-text "mutiny/stay"
             "you stay. through the bulkhead, at the top of the hour, the watch changes with its small ceremony. you mouth the words of the handover from your bed, all of them, in order. then you stop yourself. that is the night's work."
             :next "mutiny/succession")

(dialog-text "mutiny/night-bridge"
             "they let you onto the bridge at night the way a family lets a grandfather into a workshop. the watch greets you by rank. someone fetches coffee. the jump seat is already out."
             :next "mutiny/night-bridge-2")

(dialog-text "mutiny/night-bridge-2"
             "nobody offers you the boards. nobody would stop you if you took them. you do not take them. you sit in the jump seat. that is the whole of it."
             :next "mutiny/succession")

(dialog-text "mutiny/succession"
             "you are in the jump seat when the next crossing comes. Voss flies it."
             :next "mutiny/succession-2")

(dialog-text "mutiny/succession-2"
             "she is good, then better than good. the board goes green deck by deck. Imari says eighty-three seconds, cleanest of the quarter. you watch the praise land on her face. her face does not change."
             :next "mutiny/succession-3")

(dialog-text "mutiny/succession-3"
             "her eyes are already on the next lane. her hand stays curled around the cup long after it is empty."
             :next "mutiny/succession-after")

(dialog-text "mutiny/succession-after"
             "nobody else saw it. you saw it. you have stood where she is standing, behind that same stillness."
             :next "mutiny/succession-after-2")

(dialog-text "mutiny/succession-after-2"
             "you open your mouth to say something across the bridge. you close it. there is nothing to say that the file would not take in. and she would say it back to you in a year, level-voiced, over a washed cup."
             :next "mutiny/letter")

(dialog-text "mutiny/letter"
             "in your quarters you write to Voss in the format no manual gives you. four sentences. you do not send it."
             :next "mutiny/letter-s2")

(dialog-text "mutiny/letter-s2"
             "you put it under the blotter with the pencil flat on top. a careful person tidying after you will find it someday. they will know it was meant to be found."
             :next "mutiny/sleep")

(defun mutiny-sleep-target ()
  (let ((answer (dialog-value "mutiny-answer" "")))
    (cond
      ((string= answer "signed") "mutiny/sleep-signed")
      ((string= answer "refused") "mutiny/sleep-refused")
      (t "mutiny/sleep-bargained"))))

(dialog-text "mutiny/sleep"
             "Dane's evening round. the small cup with the smaller pill, offered, never pushed. you take it some nights. tonight you palm it. Dane sees you palm it and writes the same amount either way and wishes you good night by rank."
             :next #'mutiny-sleep-target)

(dialog-text "mutiny/sleep-signed"
             "you lie down in a bed other hands made for you. your name is on your own relief. it is the truest thing you ever signed. sleep comes scheduled and gentle. it is not yours to refuse."
             :next "mutiny/shore")

(dialog-text "mutiny/sleep-refused"
             "you lie down. you are still captain by your own record. captain of nothing. beloved, attended, kept."
             :next "mutiny/sleep-refused-s2")

(dialog-text "mutiny/sleep-refused-s2"
             "through the bulkhead the ship runs without you and runs well. that was always the cruelest thing it could do. you sleep inside the kindness of it."
             :next "mutiny/shore")

(dialog-text "mutiny/sleep-bargained"
             "you lie down. the last crossing is still in your hands. you can feel it there."
             :next "mutiny/sleep-bargained-2")

(dialog-text "mutiny/sleep-bargained-2"
             "whatever the log says of it, it was flying, and it was yours. they gave it to you because they loved you. they took everything else for the same reason. you sleep."
             :next "mutiny/shore")

;;; The loop breaks the wrong way. For once the dark does not set the captain
;;; back at the start; it sets him down somewhere else. Seeded gently here,
;;; paid off on another path where the King in Yellow turns out to be him.

(dialog-text "mutiny/shore"
             "sleep comes, but the alarm does not. for the first time the dark does not set you back at the start. it sets you down somewhere else: a flat lake, two suns going under it, the air gone still and a little yellow at the edges."
             :next "mutiny/shore-2")

(dialog-text "mutiny/shore-2"
             "there is a weight on your head, lighter than it should be. before they took the bridge, the crew left you the one thing a relieved captain keeps. you do not take it off. there is no one here to see it yet, and the lake is patient, and it has always been the same lake."
             :next "sys/reboot")
