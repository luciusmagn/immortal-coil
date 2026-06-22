;;; The armistice: the war path's bright branch. The morning the eight
;;; o'clock bell does not ring, told as joy. The version with the
;;; all-clear in it, lived in for one morning. Entered from the fourth
;;; day; exits through waking.

(dialog-text "armistice/offer"
             "the dream has one more morning in it, sometimes. you can feel it past the day's edge, the way you feel a room past a door: lit, and quiet, and further on."
             :next "armistice/offer-choice")

(dialog-pick "armistice/offer-choice"
             "the bell will ring at eight, or it will not."
             (dialog-option "wake now" "sys/reboot")
             (dialog-option "stay for the morning it ends" "armistice/quiet"))

(dialog-scene "armistice/quiet"
              "the morning it ends."
              :next "armistice/no-bell")

(dialog-text "armistice/no-bell"
             "at eight o'clock the bell does not ring. that is the whole of it. no treaty read aloud, no flags. an absence of bell, and the building standing inside the absence, listening with its entire staff."
             :next "armistice/corridor")

(dialog-text "armistice/corridor"
             "the corridors fill with people who have stopped walking. clerks stand with folders against their chests, looking up, the way you look up at weather."
             :next "armistice/corridor-s2")

(dialog-text "armistice/corridor-s2"
             "somebody laughs once, high and frightened, and claps a hand over it. the silence goes on being silence. it holds."
             :next "armistice/second-minute")

(dialog-text "armistice/second-minute"
             "in the second minute, somewhere down the stairwell, a door opens that has been closed for four years, by sound alone: swollen wood, a shoulder, then daylight where daylight has not been."
             :next "armistice/second-minute-s2")

(dialog-text "armistice/second-minute-s2"
             "the building begins, room by room, to remember its windows."
             :next "armistice/tape")

(dialog-text "armistice/tape"
             "the tape comes off the glass in long ribbons."
             :next "armistice/tape-2")

(dialog-text "armistice/tape-2"
             "it leaves its crosses behind in gum and dust, pale Xs over every view, and the clerks polish at them with their sleeves, laughing now, properly, because the crosses come away and the city is behind them. it was behind them the whole time."
             :next "armistice/map-room")

(dialog-text "armistice/map-room"
             "in the map room, the tape line at the river has stopped. not advancing slower. stopped, with the morning's date pinned beside it in Sorel's hand."
             :next "armistice/map-room-2")

(dialog-text "armistice/map-room-2"
             "Olen stands at the map at attention, punctual to the last morning, and he is weeping, without noise, without moving, the way a wall sheds rain."
             :next "armistice/sorel-line")

(dialog-say "armistice/sorel-line"
            "Sorel"
            "i have ruled a line under the casualty column. there is nothing to enter after it. chancellor, i have kept books for thirty years and i have never once ruled a line that stayed ruled."
            :next "armistice/sorel-line-2")

(dialog-say "armistice/sorel-line-2"
            "you"
            "will this one stay?"
            :next "armistice/sorel-line-3")

(dialog-say "armistice/sorel-line-3"
            "Sorel"
            "the column is closed. let some other ledger worry about staying. today the figure is final, and the figure has stopped growing, and i am going to sit down for a moment on the good chair."
            :next "armistice/sorel-questions")

(dialog-interrogation "armistice/sorel-questions"
                      "Sorel has not sat down yet. he stands by the closed column with the pen still in his hand, willing to be kept a moment longer."
                      (:next "armistice/brandt")
                      (:continue-label "let him sit down")
                      ("ask what the final figure is"
                       :id "figure"
                       :speaker "Sorel"
                       "i will not say it aloud on the day it stopped growing. you signed for most of it. read it tonight, alone, once, and then let the line hold it for you.")
                      ("ask if he has closed a column like this before"
                       :id "before"
                       :speaker "Sorel"
                       "harvests, debts, one bank. never a war. a war does not close, chancellor. it is the first time i have ruled a line and dared it to mean what it says.")
                      ("ask how a person closes the war inside"
                       :id "inside"
                       :speaker "Sorel"
                       "i do not know. books are easier than men. but i am told you begin by sitting on the good chair, and i intend to test the method directly."))

(dialog-say "armistice/brandt"
            "Brandt"
            "chancellor. the all-clear version. the one i said someone else would live in."
            :next "armistice/brandt-2")

(dialog-say "armistice/brandt-2"
            "you"
            "you were wrong, Brandt."
            :next "armistice/brandt-3")

(dialog-say "armistice/brandt-3"
            "Brandt"
            "i was wrong. i have never been so happy to file an error in my life. i am going to be wrong about more things. i am going to take it up as a discipline."
            :next "armistice/brandt-laugh")

(dialog-text "armistice/brandt-laugh"
             "and Brandt laughs. you have never heard it."
             :next "armistice/brandt-laugh-2")

(dialog-text "armistice/brandt-laugh-2"
             "nine years in this building and you have never once heard it, and it is terrible, honking, entirely without administrative value, and the clerks in the corridor catch it and pass it on, and it goes down the stairwell ahead of him, opening doors."
             :next "armistice/radio")

(dialog-text "armistice/radio"
             "in the night office the radio is on, tuned to the clear band out of four years of habit. the numbers are being read, group after group, the exhausted voice keeping its protocol. then, mid-group, it stops."
             :next "armistice/dead-air")

(dialog-text "armistice/dead-air"
             "dead air. a minute of it. you stand with your hand on the shelf and let it run."
             :next "armistice/dead-air-s2")

(dialog-text "armistice/dead-air-s2"
             "then the voice comes back, off protocol, unprofessional, close to the microphone, and says: go home."
             :next "armistice/dead-air-s3")

(dialog-text "armistice/dead-air-s3"
             "and the clear band, for the first time in four years, goes clear."
             :next "armistice/olen-map")

(dialog-say "armistice/olen-map"
            "Olen"
            "chancellor. i have stood at this map for four years. i find i do not know where to stand in a room that does not have one."
            :next "armistice/olen-map-2")

(dialog-say "armistice/olen-map-2"
            "you"
            "by the window, Olen. it is the new map. everything on it is ours to lose slowly."
            :next "armistice/olen-map-3")

(dialog-say "armistice/olen-map-3"
            "Olen"
            "by the window. yes. i will require new habits. i am told the river is good to look at, now that it is only a river."
            :next "armistice/olen-questions")

(dialog-interrogation "armistice/olen-questions"
                      "Olen has not moved to the window yet. he stands where the map was, hands half-raised toward a thing that is no longer there."
                      (:next "armistice/vey")
                      (:continue-label "leave him to the window")
                      ("ask what it is like to leave the map"
                       :id "map"
                       :speaker "Olen"
                       "like setting down a weight you forgot was yours. my hands keep reaching for it. i am told that fades. i am told a great many things fade, starting today.")
                      ("ask whether the window feels like a weakness"
                       :id "window"
                       :speaker "Olen"
                       "for four years a window was where a shell came through. i must learn it as where light comes through. the river will help. it is patient about being only a river.")
                      ("ask what new habits he will need"
                       :id "habits"
                       :speaker "Olen"
                       "to stand without a map. to plan a week instead of a front. to call the river a river. small habits, chancellor. i was only ever good at the large terrible ones."))

(dialog-text "armistice/vey"
             "you pass Vey's office. he is at his desk, composing, in his even hand, a memorandum on the orderly administration of peacetime, dated today, addressed to whom it may concern."
             :next "armistice/vey-2")

(dialog-text "armistice/vey-2"
             "Vey turns with the wind, and the wind has changed. it is a comfort to watch."
             :next "armistice/coat")

(dialog-text "armistice/coat"
             "you walk out the front entrance without your coat, which you have not done in four years. the sentries have stopped being sentries."
             :next "armistice/coat-s2")

(dialog-text "armistice/coat-s2"
             "they are two young men standing in the sun in heavy boots. one of them has his helmet off and his face turned up to it."
             :next "armistice/sentry-cap")

(dialog-text "armistice/sentry-cap"
             "the older sentry, the one still helmeted, catches your eye and very slowly, with full ceremony, takes the helmet off, holds it out at arm's length, and drops it. it rolls. neither of you picks it up."
             :next "armistice/sentry-cap-2")

(dialog-text "armistice/sentry-cap-2"
             "it is the most insubordinate thing you have ever been glad to witness, and you return his salute, which he has not given."
             :next "armistice/street")

(dialog-text "armistice/street"
             "the street is full. nobody is going anywhere. everyone is handing everyone things: bread, news, babies, the same three facts over and over."
             :next "armistice/street-2")

(dialog-text "armistice/street-2"
             "a woman you have never met hands you a cup of something hot and keeps moving, supplying the crowd by instinct, the whole city one kitchen."
             :next "armistice/unrecognized")

(dialog-text "armistice/unrecognized"
             "nobody knows you without the coat. you stand in your own capital holding a borrowed cup, one face in the crowd. it feels like being forgiven. you know better than to trust that. you take it anyway, for the one morning. the column is closed."
             :next "armistice/bells-other")

(dialog-text "armistice/bread-queue"
             "outside the baker's, the queue has stopped being a queue and become a party that happens to be shaped like one."
             :next "armistice/bread-queue-2")

(dialog-text "armistice/bread-queue-2"
             "the baker is giving the morning's second batch away, loudly, over his wife's arithmetic, and his wife is letting him, doing the arithmetic anyway out of love, and laughing at the total."
             :next "armistice/cups")

(dialog-text "armistice/bells-other"
             "from the third district, across the canal, bells. not the slow count."
             :next "armistice/bells-other-2")

(dialog-text "armistice/bells-other-2"
             "struck fast, bright, in relays, and you can hear the relays changing: children, taking turns, lifted to the rope by grown hands, ringing nothing into the record at all."
             :next "armistice/bells-other-3")

(dialog-text "armistice/bells-other-3"
             "ringing because rope and bell make a noise, and the noise is allowed."
             :next "armistice/bread-queue")

(dialog-text "armistice/cups"
             "the borrowed cup, when you finally look at it, is good china, somebody's sunday best, brought out into the street with its eleven brothers and handed to strangers."
             :next "armistice/cups-2")

(dialog-text "armistice/cups-2"
             "all over the city the kept things are coming out. the good plates, the saved sugar, the bottle at the back of the cupboard that someone was saving for a day. nothing is being saved now. saving is over."
             :next "armistice/table")

(dialog-text "armistice/table"
             "in the cabinet room, at some point in the afternoon, the map is folded."
             :next "armistice/table-2")

(dialog-text "armistice/table-2"
             "it takes four people and it folds badly, the way maps do, and under it the table is just a table: wood, scarred, a century of pencil marks and cup rings, the ordinary furniture of an ordinary room, returned to service."
             :next "armistice/first-choice")

(dialog-pick "armistice/first-choice"
             "the afternoon stands open. there has not been an open afternoon in four years, and nobody alive remembers the procedure."
             (dialog-option "open every window in the building" "armistice/windows")
             (dialog-option "walk to the third district" "armistice/walk-district")
             (dialog-option "sleep, at last, in a bed" "armistice/bed"))

(dialog-on-enter "armistice/windows"
                 '(setf (dialog-value "armistice-first") "windows"))

(dialog-text "armistice/windows"
             "you go floor by floor with Brandt and a master key, opening windows. it takes hours."
             :next "armistice/windows-2")

(dialog-text "armistice/windows-2"
             "the building exhales four years of paper and blackout cloth and kept breath, and the drafts run the corridors like children, and by the top floor the two of you are racing, and he wins, and you contest the result, and lose the appeal."
             :next "armistice/evening")

(dialog-on-enter "armistice/walk-district"
                 '(setf (dialog-value "armistice-first") "district"))

(dialog-text "armistice/walk-district"
             "you walk to the third district in your shirtsleeves, across the canal, against the remembered grain of every night you did it in a borrowed coat. the lists are coming down off the doors."
             :next "armistice/walk-district-2")

(dialog-text "armistice/walk-district-2"
             "not torn: taken down, folded, kept, the way you keep a thing you intend to be done with on your own terms."
             :next "armistice/district-bell")

(dialog-text "armistice/district-bell"
             "at the parish hall they are still ringing, relay after relay, and the ringer with the fingerless gloves stands aside from the rope entirely, resting his arm forever, supervising joy."
             :next "armistice/district-bell-2")

(dialog-text "armistice/district-bell-2"
             "he does not know you without the coat. he hands you the rope anyway, because everyone gets a turn today, and you ring."
             :next "armistice/evening")

(dialog-on-enter "armistice/bed"
                 '(setf (dialog-value "armistice-first") "slept"))

(dialog-text "armistice/bed"
             "you go home, to the flat that has technically been yours all along, and sleep in a bed, in daylight, with the window open and the street noise coming in like surf."
             :next "armistice/bed-2")

(dialog-text "armistice/bed-2"
             "nobody wakes you. there is nothing that cannot wait. for four years there was always something that could not wait. today there is nothing."
             :next "armistice/evening")

(dialog-text "armistice/evening"
             "the evening comes on slow and gold, and the city lights itself early, every window, four years of saved light spent in one night. no bell rings at dusk. the bells are spent too, rung out, resting in their towers."
             :next "armistice/last")

(dialog-text "armistice/last"
             "you stand at an open window with the day ending and let yourself have it, all of it, the one morning, the version with the all-clear in it."
             :next "armistice/last-2")

(dialog-text "armistice/last-2"
             "somewhere below, faint, Brandt is still laughing about something, and the sound carries in the open air, because everything does now."
             :next "armistice/wake")

(dialog-text "armistice/wake"
             "sleep, when it comes, comes easy, the first easy sleep of the whole long dream, and it carries you up and out with the windows open the whole way."
             :next "sys/reboot")
