;;; Release: the facility path's second dark branch. Decommissioning:
;;; files burned on schedule, rooms released, and the player signs for
;;; the bed. Entered from the notice board; exits when the line is
;;; scrubbed.

(dialog-text "release/second-notice"
             "pinned beneath it, newer, the holes still bright in the cork: DECOMMISSIONING. THIS WING. FILES TO BE PROCESSED ON SCHEDULE. ROOMS TO BE RELEASED. SURPLUS FURNISHINGS: SEE M-3. the date at the bottom is the next rotation."
             :next "release/notice-choice")

(dialog-pick "release/notice-choice"
             "the thumbtacks hold the notice the way thumbtacks hold everything here: provisionally, forever."
             (dialog-option "leave it for the day staff" "facility/walk3")
             (dialog-option "take it down to M-3" "release/ask"))

(dialog-conversation "release/ask"
                     (dialog-left "M-3"
                                  "so you read the board. yes. the wing concludes. wings conclude, {facility-designation}. it is in the handbook, the last chapter, which nobody reads because of where it is.")
                     (dialog-right "you"
                                   "what happens to the room?")
                     (dialog-left "M-3"
                                  "the room is released. the files are processed. the furnishings are surplus. you will be on the rotation, because the last rotation needs someone who initials honestly, and your column says you do.")
                     :next "release/last-rotation")

(dialog-scene "release/last-rotation"
              "the last rotation."
              :next "release/wind-down")

(dialog-text "release/wind-down"
             "the decommissioning is not a day. it is a season of rotations, each quieter. the kettle's tea tin is not replaced when it empties."
             :next "release/wind-down-2")

(dialog-text "release/wind-down-2"
             "the staff sheet's column of designations grows shorter from the bottom, departures initialed by departures, until most mornings the page is you, M-3, and the date."
             :next "release/schedule-climb")

(dialog-text "release/schedule-climb"
             "you find your own name climbing the rotation schedule week by week as the names below it conclude, and you consult appendix two about it, per the notice, and appendix two says what it has always said: do not correct the subject."
             :next "release/schedule-climb-2")

(dialog-text "release/schedule-climb-2"
             "do not correct the room. initial both. so you initial both."
             :next "release/quiet-wing")

(dialog-text "release/quiet-wing"
             "the wing is already quieter than procedure can explain."
             :next "release/quiet-wing-2")

(dialog-text "release/quiet-wing-2"
             "half the doors stand propped open on rubber wedges, rooms with their curtains down folded on the beds, and the corridor's air moves differently with nothing closed against it. buildings go loose at the end, like handwriting."
             :next "release/even-doors")

(dialog-text "release/even-doors"
             "the corridor's even-numbered doors, passed a hundred times and never opened, stand open now."
             :next "release/even-doors-2")

(dialog-text "release/even-doors-2"
             "rooms, all of them, each with its bed and night stand and small table, each made, each empty, their curtains already down. some have been empty so long the air inside has its own weather."
             :next "release/even-files")

(dialog-text "release/even-files"
             "their files came through the archive thin as letters: subjects concluded, subjects transferred, subjects released in years signed by initials that stopped being letters generations of staff ago."
             :next "release/even-files-2")

(dialog-text "release/even-files-2"
             "the wing was never one room and one watcher. it was a street of rooms, and the street is being unbuilt."
             :next "release/burn-duty")

(dialog-say "release/burn-duty"
            "M-3"
            "first duty: the files. processed means the incinerator, and the schedule means today. carry them spine out, {facility-designation}. especially today, spine out."
            :next "release/trolley")

(dialog-text "release/trolley"
             "the returns trolley waits at the archive door, loaded for the last time. four files. the spines read: CROSSING. HILL HOUSE. THIRD DISTRICT. OAKBARROW. you have walked these four back to their shelf before. today the shelf is not the destination."
             :next "release/tide-out")

(dialog-text "release/tide-out"
             "the archive has been emptying for weeks, oldest first, the shelves clearing from the far end like a tide going out. the gaps are not relabeled. the gaps are the labels now: a wall of spaces in the rerouting hand, each exactly the size of what stood in it."
             :next "release/incinerator")

(dialog-text "release/incinerator"
             "the incinerator room is small, clean, and warm the way the brass handle is warm. the hatch stands open at waist height. beside it, a sign-off sheet, ruled for four lines, and a pen on a chain that has never had to reach this far down the corridor before."
             :next "release/burn-choice")

(dialog-pick "release/burn-choice"
             "the four files wait on the trolley, spine out, in the order someone chose for them."
             (dialog-option "process them in trolley order" "release/burn-order")
             (dialog-option "read one line from each, first" "release/burn-read")
             (dialog-option "ask what burning releases" "release/burn-ask"))

(dialog-on-enter "release/burn-order"
                 '(setf (dialog-value "release-burn") "order"))

(dialog-text "release/burn-order"
             "you process them in order, spine out to the last inch, each one going in warm-edge-first the way files go that have been read recently, or that are always warm, and you initial four lines in a hand that stays steady because you have given it no chance to read."
             :next "release/smoke")

(dialog-on-enter "release/burn-read"
                 '(setf (dialog-value "release-burn") "read"))

(dialog-text "release/burn-read"
             "one line each, against the instruction, at the hatch. CROSSING: subject counts the gates, all crossings nominal. HILL HOUSE: subject is expected for supper."
             :next "release/burn-read-2")

(dialog-text "release/burn-read-2"
             "THIRD DISTRICT: subject initials the morning sheet. OAKBARROW: subject sleeps well here, recommend no change. then in, one by one, recommendation and all."
             :next "release/smoke")

(dialog-on-enter "release/burn-ask"
                 '(setf (dialog-value "release-burn") "asked"))

(dialog-conversation "release/burn-ask"
                     (dialog-left "M-3"
                                  "what does burning release. the obligation to keep current, {facility-designation}. a live file must be true. a processed file is only history, and history is allowed to rest.")
                     (dialog-right "you"
                                   "and the places in the files?")
                     (dialog-left "M-3"
                                  "places get on with themselves. the files were never the places. they were the looking. we are not burning anywhere. we are closing our eyes politely.")
                     :next "release/burn-after-ask")

(dialog-text "release/burn-after-ask"
             "you process them with that held in both hands like the trolley bar. four files, four lines, four sets of initials, and the obligation to keep current going up the flue in order."
             :next "release/smoke")

(dialog-text "release/smoke"
             "the smoke is supposed to smell like paper. it does not. it goes salt, then pine, then bell metal, then warm bread, in order, one breath each, and M-3 stands with you through all four breaths with his eyes shut, which for M-3 is a wake."
             :next "release/room-file")

(dialog-text "release/room-file"
             "the heavy file is last on the trolley, alone now. ROOM. you lift it toward the hatch and M-3's hand arrives on the spine, flat, final. ROOM is not processed, he says. ROOM is released. different chapter. bring the trolley."
             :next "release/rooms")

(dialog-scene "release/rooms"
              "the releasing."
              :next "release/curtain-down")

(dialog-text "release/curtain-down"
             "at the observation window, M-3 takes the curtain down himself, rings one at a time, slower than anyone, and folds it into a square that gets smaller than cloth should fold."
             :next "release/curtain-down-2")

(dialog-text "release/curtain-down-2"
             "the glass is just glass with both sides lit. the room beyond is made, empty, and waiting the way furniture waits."
             :next "release/bed-empty")

(dialog-text "release/bed-empty"
             "the bed is empty and the subject is not in containment and nobody says missing, and nobody ever will again, because release means this: not that the subject goes, but that the looking stops."
             :next "release/bed-empty-2")

(dialog-text "release/bed-empty-2"
             "the subject is whoever is in the room when you look. as of today, appendix one has no working parts."
             :next "release/each-room")

(dialog-text "release/each-room"
             "the releasing goes room by room, M-3 and you, down the even doors. in each: the inventory read aloud once, bed one, night stand one, the room's last sentence spoken into it by a human voice."
             :next "release/each-room-2")

(dialog-text "release/each-room-2"
             "then the wedge under the door, kicked true. a room is released the way a colleague is seen off. the handbook does not require the reading aloud. M-3 requires it."
             :next "release/glass-walk")

(dialog-text "release/glass-walk"
             "the last duty of the wing is the glass of water."
             :next "release/glass-walk-2")

(dialog-text "release/glass-walk-2"
             "M-3 carries it out of the room himself, level, full to the line, down the painted line at a procession's pace, and stands it on the standing desk beside the sign-in sheet. someone will be along, he says, to the desk, not to you."
             :next "release/last-tea")

(dialog-text "release/last-tea"
             "the kettle has enough in the tin for two last mugs, and you have them standing up at the notice board, you and M-3, reading thumbtacks."
             :next "release/last-tea-2")

(dialog-text "release/last-tea-2"
             "exactly the way you would in any job, on any last day, and for four minutes it works, which you both know is the tea's full operating range."
             :next "release/surplus")

(dialog-say "release/surplus"
            "M-3"
            "now the surplus. staff may claim released furnishings against signature. it is the handbook's one kindness and it is in the last chapter with everything else true. the form is short."
            :next "release/form")

(dialog-text "release/form"
             "the form is short. SURPLUS, RELEASED, THIS WING: BED, ONE. NIGHT STAND, ONE. GLASS, ONE. DESK WITH DRAWER, ONE. CONDITION: KEPT. DELIVERY: IMMEDIATE. there is one signature line, and the pen on its chain reaches it exactly."
             :next "release/sign-choice")

(dialog-pick "release/sign-choice"
             "M-3 holds the clipboard steady. the corridor lights hum at day strength, for the last day."
             (dialog-option "sign for the bed" "release/sign-bed")
             (dialog-option "sign for all of it" "release/sign-all")
             (dialog-option "decline the surplus" "release/decline"))

(dialog-on-enter "release/sign-bed"
                 '(setf (dialog-value "release-signed") "bed"))

(dialog-text "release/sign-bed"
             "you sign for the bed. just the bed. the signature comes out steadier than you meant it to, the way it did at the court of the long table, the way it does everywhere they hand you your own effects, and M-3 strikes the other lines with a ruler, fair to the last."
             :next "release/carbon")

(dialog-on-enter "release/sign-all"
                 '(setf (dialog-value "release-signed") "all"))

(dialog-text "release/sign-all"
             "you sign for all of it: bed, night stand, glass, desk with drawer. the whole room, against one signature, condition kept, and signing it feels less like acquiring furniture than like adopting a dog that has already been sleeping at your door for years."
             :next "release/carbon")

(dialog-on-enter "release/decline"
                 '(setf (dialog-value "release-signed") "declined"))

(dialog-text "release/decline"
             "you decline. M-3 nods, rules the form void, and the furnishings are carried to the corridor's end, where they stand together under a dust sheet like a held breath."
             :next "release/decline-2")

(dialog-text "release/decline-2"
             "surplus unsigned is still surplus, he says, in the doorway. the bed knows its sleeper. i am required to tell you that, and i have, and we will not speak of it."
             :next "release/carbon")

(dialog-text "release/carbon"
             "the form's carbon goes into the heavy file. ROOM takes it the way the shelf used to take returns, with a soft fit, and M-3 ties the file shut with archive ribbon, grey."
             :next "release/carbon-2")

(dialog-text "release/carbon-2"
             "he carries it to the archive, which is now one room long and holds exactly one file, correctly shelved, in a building with no one left to sign it out."
             :next "release/chit")

(dialog-text "release/chit"
             "your copy of the form folds into a chit that sits in your pocket with no weight at all, and you keep your hand on it anyway. it is the first document this building has ever issued you to keep."
             :next "release/chit-2")

(dialog-text "release/chit-2"
             "everything else was initialed and surrendered. this one is yours, the way the bed is now yours: by the last chapter."
             :next "release/m3-out")

(dialog-text "release/m3-out"
             "M-3 signs the staff sheet last, all the way down at the bottom of a column of his own initials going back further than the paper should hold, and from the binder he takes one page, folds it once, and puts it inside his coat."
             :next "release/m3-out-2")

(dialog-text "release/m3-out-2"
             "a man is entitled to one page, he says. it is in no chapter. it is just true."
             :next "release/page-guess")

(dialog-text "release/page-guess"
             "you do not see the page he takes, and you do not need to."
             :next "release/page-guess-2")

(dialog-text "release/page-guess-2"
             "you have read his column long enough to know where the paper has been touched soft: it is the line, years down, where his initials change from one letter to another, the morning a designation became a name to somebody, or stopped being one."
             :next "release/page-guess-3")

(dialog-text "release/page-guess-3"
             "the binder keeps the fact. the man keeps the page."
             :next "release/coats")

(dialog-text "release/coats"
             "at the lockers he hangs his grey coat on the rack, and you understand the older coat that has always hung behind yours."
             :next "release/coats-2")

(dialog-text "release/coats-2"
             "elbows gone soft: every locker in this row holds two coats, the issued one and the predecessor's, all the way down the row, all the way down the years. the facility does not hire. it rotates. today the rotation ends."
             :next "release/scrubber")

(dialog-text "release/scrubber"
             "behind you, at the wing's far end, a machine you have never seen comes out of a door you have never counted and begins to follow the painted line, scrubbing it up as it goes, slow, thorough, at procession pace."
             :next "release/scrubber-2")

(dialog-text "release/scrubber-2"
             "the line that carried you everywhere here is being read one last time, by the thing that erases it."
             :next "release/scrubber-window")

(dialog-text "release/scrubber-window"
             "at the observation window the scrubber pauses, sensor down, over the place where the line bends toward the glass, where every watcher who ever walked this wing slowed without knowing it."
             :next "release/scrubber-window-2")

(dialog-text "release/scrubber-window-2"
             "the machine holds there the length of a held breath, four counts, then scrubs the bend like any other yard of paint, which is the difference, in the end, between procedure and the people who keep it."
             :next "release/walk-ahead")

(dialog-text "release/walk-ahead"
             "you and M-3 walk the line out ahead of the scrubber, your pace set by its hum, and there is no hurry in it and no stopping either."
             :next "release/walk-ahead-2")

(dialog-text "release/walk-ahead-2"
             "every step you take exists for exactly as long as you need it to, which is a fair description, you think, of every corridor you have ever walked."
             :next "release/lights")

(dialog-text "release/lights"
             "at the door with the brass handle, the building's lights go off in order, away from the desk and back, the dimming you know from the hem and the drill."
             :next "release/lights-2")

(dialog-text "release/lights-2"
             "performed once at full scale, unhurried, and the last light to go is the one over the standing desk, where the glass of water stands full to the line in the dark."
             :next "release/handle")

(dialog-text "release/handle"
             "the handle is warm. on the other side of the door, nobody has just let go of it, for the first time, because the other side of the door is now where everything else is, and M-3 holds it for you, and follows, and lets it close. the latch takes. the wing concludes."
             :next "release/hum-stops")

(dialog-text "release/hum-stops"
             "through the closed door, faint, the scrubber's hum finishes its last yard and stops, and the silence after it is the building's first unlogged minute in living procedure."
             :next "release/hum-stops-2")

(dialog-text "release/hum-stops-2"
             "it goes on, and nobody initials it, and that is what released means, finally: minutes that belong to no column."
             :next "release/goodbye")

(dialog-conversation "release/goodbye"
                     (dialog-left "M-3"
                                  "your signature says delivery is immediate, {facility-designation}. go and receive it. that is the whole of the last chapter, by the way. one sentence. go and receive it.")
                     (dialog-right "you"
                                   "and you?")
                     (dialog-left "M-3"
                                  "i have my page. same time, somewhere. the handle was always warm because of who was holding it next. i am old enough to say that out loud, once, on a last day.")
                     :next "release/delivery")

(dialog-text "release/delivery"
             "delivery is immediate. sleep arrives the way the trays arrived, during an interval that contains no one, and somewhere a bed, one, night stand, one, glass, one, full to the line."
             :next "release/delivery-2")

(dialog-text "release/delivery-2"
             "condition kept. it stands ready where it has always stood, in the room you wake in, which you have signed for now, which was always going to be the last line of the form."
             :next "base/awake")
