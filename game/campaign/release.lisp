;;; Release: the facility path's second dark branch. Decommissioning:
;;; files burned on schedule, rooms released, and the player signs for
;;; the bed. Entered from the notice board; exits when the line is
;;; scrubbed.

(dialog-text "release/second-notice"
             "pinned beneath it, newer, the holes still bright in the cork: DECOMMISSIONING. THIS WING. FILES TO BE PROCESSED ON SCHEDULE. ROOMS TO BE RELEASED. SURPLUS FURNISHINGS: SEE M-3. the date at the bottom is the next rotation."
             :next "release/notice-choice")

(dialog-pick "release/notice-choice"
             "the thumbtacks hold the notice the way they hold everything here. loosely, and for years."
             (dialog-option "leave it for the day staff" "facility/walk3")
             (dialog-option "take it down to M-3" "release/ask"))

(dialog-say "release/ask"
            "M-3"
            "so you read the board. yes. the wing concludes. wings conclude, {facility-designation}. it is in the handbook, the last chapter, which nobody reads because of where it is."
            :next "release/ask-2")

(dialog-say "release/ask-2"
            "you"
            "what happens to the room?"
            :next "release/ask-3")

(dialog-say "release/ask-3"
            "M-3"
            "the room is released. the files are processed. the furnishings are surplus. you will be on the rotation, because the last rotation needs someone who initials honestly, and your column says you do."
            :next "release/last-rotation")

(dialog-scene "release/last-rotation"
              "the last rotation."
              :next "release/wind-down")

(dialog-text "release/wind-down"
             "the decommissioning is not a day. it is a season of rotations, each one quieter. the tea tin is not replaced when it empties."
             :next "release/wind-down-2")

(dialog-text "release/wind-down-2"
             "the column of designations on the staff sheet grows shorter from the bottom, departures initialed by departures. most mornings the page is you, M-3, and the date."
             :next "release/schedule-climb")

(dialog-text "release/schedule-climb"
             "your own name climbs the rotation schedule week by week, as the names below it conclude. you consult appendix two, per the notice. it says what it always says. do not correct the subject."
             :next "release/schedule-climb-2")

(dialog-text "release/schedule-climb-2"
             "do not correct the room. initial both. so you initial both."
             :next "release/quiet-wing")

(dialog-text "release/quiet-wing"
             "the wing is already quieter than procedure can explain."
             :next "release/quiet-wing-2")

(dialog-text "release/quiet-wing-2"
             "half the doors stand propped open on rubber wedges. inside, curtains are down, folded on the beds. the corridor air moves differently with nothing closed against it."
             :next "release/even-doors")

(dialog-text "release/even-doors"
             "the corridor's even-numbered doors, passed a hundred times and never opened, stand open now."
             :next "release/even-doors-2")

(dialog-text "release/even-doors-2"
             "rooms, all of them. each with a bed, a night stand, a small table. each made, each empty, the curtains already down. some have been empty a long time."
             :next "release/even-files")

(dialog-text "release/even-files"
             "their files came through the archive thin as letters. subjects concluded, subjects transferred, subjects released, in years signed by initials worn down generations ago."
             :next "release/even-files-2")

(dialog-text "release/even-files-2"
             "the wing was never one room and one watcher. it was a street of rooms, and the street is being unbuilt."
             :next "release/burn-duty")

(dialog-say "release/burn-duty"
            "M-3"
            "first duty: the files. processed means the incinerator, and the schedule means today. carry them spine out, {facility-designation}. especially today, spine out."
            :next "release/trolley")

(dialog-text "release/trolley"
             "the returns trolley waits at the archive door, loaded for the last time. four files. the spines read: CROSSING. HILL HOUSE. THIRD DISTRICT. OAKBARROW."
             :next "release/trolley-s2")

(dialog-text "release/trolley-s2"
             "you have walked these four back to their shelf before. today the shelf is not the destination."
             :next "release/tide-out")

(dialog-text "release/tide-out"
             "the archive has been emptying for weeks, oldest first, the shelves clearing from the far end. the gaps are not relabeled."
             :next "release/tide-out-s2")

(dialog-text "release/tide-out-s2"
             "the gaps are the labels now. a wall of spaces, each the size of what stood in it."
             :next "release/incinerator")

(dialog-text "release/incinerator"
             "the incinerator room is small and clean, and warm the way the brass handle is warm. the hatch stands open at waist height."
             :next "release/incinerator-s2")

(dialog-text "release/incinerator-s2"
             "beside it, a sign-off sheet, ruled for four lines, and a pen on a chain."
             :next "release/burn-choice")

(dialog-pick "release/burn-choice"
             "the four files wait on the trolley, spine out, in the order someone chose for them."
             (dialog-option "process them in trolley order" "release/burn-order")
             (dialog-option "read one line from each, first" "release/burn-read")
             (dialog-option "ask what burning releases" "release/burn-ask"))

(dialog-on-enter "release/burn-order"
                 '(setf (dialog-value "release-burn") "order"))

(dialog-text "release/burn-order"
             "you process them in order, spine out to the last inch. each goes in warm-edge first. you initial four lines. your hand stays steady because you have given it no chance to read."
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

(dialog-say "release/burn-ask"
            "M-3"
            "what does burning release. the obligation to keep current, {facility-designation}. a live file must be true. a processed file is only history, and history is allowed to rest."
            :next "release/burn-ask-2")

(dialog-say "release/burn-ask-2"
            "you"
            "and the places in the files?"
            :next "release/burn-ask-3")

(dialog-say "release/burn-ask-3"
            "M-3"
            "places get on with themselves. the files were never the places. they were the looking. we are not burning anywhere. we are only stopping looking."
            :next "release/burn-after-ask")

(dialog-text "release/burn-after-ask"
             "you process them with that in mind. four files, four lines, four sets of initials. the obligation to keep them current goes up the flue in order."
             :next "release/smoke")

(dialog-text "release/smoke"
             "the smoke is supposed to smell like paper. it does not. it goes salt, then pine, then bell metal, then warm bread, one breath each. M-3 stands with you through all four breaths with his eyes shut."
             :next "release/room-file")

(dialog-text "release/room-file"
             "the heavy file is last on the trolley, alone now. ROOM. you lift it toward the hatch. M-3's hand comes down on the spine, flat. ROOM is not processed, he says. ROOM is released. different chapter. bring the trolley."
             :next "release/rooms")

(dialog-scene "release/rooms"
              "the releasing."
              :next "release/curtain-down")

(dialog-text "release/curtain-down"
             "at the observation window, M-3 takes the curtain down himself, rings one at a time, slower than anyone, and folds it into a small square."
             :next "release/curtain-down-2")

(dialog-text "release/curtain-down-2"
             "the glass is just glass with both sides lit. the room beyond is made and empty."
             :next "release/bed-empty")

(dialog-text "release/bed-empty"
             "the bed is empty. the subject is not in containment. nobody says missing, and nobody will again. release does not mean the subject goes. it means the looking stops."
             :next "release/bed-empty-2")

(dialog-text "release/bed-empty-2"
             "the subject is whoever is in the room when you look. as of today, appendix one has no working parts."
             :next "release/each-room")

(dialog-text "release/each-room"
             "the releasing goes room by room, you and M-3, down the even doors. in each, the inventory read aloud once. bed, one. night stand, one. the room's last sentence, in a human voice."
             :next "release/each-room-2")

(dialog-text "release/each-room-2"
             "then the wedge under the door, kicked true. the handbook does not require the reading aloud. M-3 requires it."
             :next "release/glass-walk")

(dialog-text "release/glass-walk"
             "the last duty of the wing is the glass of water."
             :next "release/glass-walk-2")

(dialog-text "release/glass-walk-2"
             "M-3 carries it out of the room himself, level, full to the line, down the painted line at a slow pace. he stands it on the desk beside the sign-in sheet. someone will be along, he says, to the desk, not to you."
             :next "release/last-tea")

(dialog-text "release/last-tea"
             "the tin has enough for two last mugs. you have them standing at the notice board, you and M-3, reading thumbtacks."
             :next "release/last-tea-2")

(dialog-text "release/last-tea-2"
             "you drink them the way you would in any job, on any last day. for four minutes it works. you both know that is all it does."
             :next "release/surplus")

(dialog-say "release/surplus"
            "M-3"
            "now the surplus. staff may claim released furnishings against signature. it is the handbook's one kindness, in the last chapter with everything else true. the form is short."
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
             "you sign for the bed. just the bed."
             :next "release/sign-bed-s2")

(dialog-text "release/sign-bed-s2"
             "the signature comes out steadier than you meant it to. M-3 strikes the other lines with a ruler, fair to the last."
             :next "release/carbon")

(dialog-on-enter "release/sign-all"
                 '(setf (dialog-value "release-signed") "all"))

(dialog-text "release/sign-all"
             "you sign for all of it: bed, night stand, glass, desk with drawer."
             :next "release/sign-all-s2")

(dialog-text "release/sign-all-s2"
             "the whole room, against one signature, condition kept. it does not feel like acquiring furniture. it feels like keeping something that was already yours."
             :next "release/carbon")

(dialog-on-enter "release/decline"
                 '(setf (dialog-value "release-signed") "declined"))

(dialog-text "release/decline"
             "you decline. M-3 nods and rules the form void. the furnishings are carried to the corridor's end and stand together under a dust sheet."
             :next "release/decline-2")

(dialog-text "release/decline-2"
             "surplus unsigned is still surplus, he says, in the doorway. the bed knows its sleeper. i am required to tell you that, and i have, and we will not speak of it."
             :next "release/carbon")

(dialog-text "release/carbon"
             "the form's carbon goes into the heavy file. ROOM takes it with a soft fit. M-3 ties the file shut with grey archive ribbon."
             :next "release/carbon-2")

(dialog-text "release/carbon-2"
             "he carries it to the archive. one room, one file, correctly shelved, in a building with no one left to sign it out."
             :next "release/chit")

(dialog-text "release/chit"
             "your copy folds into a chit. it sits in your pocket weightless, and you keep your hand on it anyway. it is the first document this building has issued you to keep."
             :next "release/chit-2")

(dialog-text "release/chit-2"
             "everything else was initialed and surrendered. this one is yours, the way the bed is yours now. by the last chapter."
             :next "release/m3-out")

(dialog-text "release/m3-out"
             "M-3 signs the staff sheet last, at the bottom of a long column of his own initials. from the binder he takes one page, folds it once, and puts it inside his coat."
             :next "release/m3-out-2")

(dialog-text "release/m3-out-2"
             "a man is entitled to one page, he says. it is in no chapter. it is just true."
             :next "release/page-guess")

(dialog-text "release/page-guess"
             "you do not see the page he takes, and you do not need to."
             :next "release/page-guess-2")

(dialog-text "release/page-guess-2"
             "you have read his column long enough to know where the paper is worn soft. it is the line, years down, where his initials change from one letter to another. the morning a designation became a name, or stopped being one."
             :next "release/page-guess-3")

(dialog-text "release/page-guess-3"
             "the binder keeps the fact. the man keeps the page."
             :next "release/coats")

(dialog-text "release/coats"
             "at the lockers he hangs his grey coat on the rack. now you understand the older coat that always hung behind yours."
             :next "release/coats-2")

(dialog-text "release/coats-2"
             "its elbows are gone soft. every locker in the row holds two coats, the issued one and the predecessor's, all the way down. the facility does not hire. it rotates. today the rotation ends."
             :next "release/scrubber")

(dialog-text "release/scrubber"
             "behind you, at the far end, a machine you have never seen comes out of a door you have never counted. it follows the painted line, scrubbing it up as it goes, slow and thorough."
             :next "release/scrubber-2")

(dialog-text "release/scrubber-2"
             "the line that carried you everywhere here is being read one last time, by the thing that erases it."
             :next "release/scrubber-window")

(dialog-text "release/scrubber-window"
             "at the observation window the scrubber pauses, sensor down, over the place where the line bends toward the glass. every watcher who walked this wing slowed there without knowing it."
             :next "release/scrubber-window-2")

(dialog-text "release/scrubber-window-2"
             "the machine holds there four counts, then scrubs the bend like any other yard of paint."
             :next "release/walk-ahead")

(dialog-text "release/walk-ahead"
             "you and M-3 walk the line out ahead of the scrubber, your pace set by its hum. there is no hurry in it, and no stopping either."
             :next "release/walk-ahead-2")

(dialog-text "release/walk-ahead-2"
             "every step takes as long as it needs to."
             :next "release/lights")

(dialog-text "release/lights"
             "at the door with the brass handle, the building's lights go off in order, away from the desk and back. you know the sequence from the hem, and the drill."
             :next "release/lights-2")

(dialog-text "release/lights-2"
             "it runs once, at full scale, unhurried. the last light to go is over the standing desk, where the glass of water stands full to the line in the dark."
             :next "release/handle")

(dialog-text "release/handle"
             "the handle is warm."
             :next "release/handle-s2")

(dialog-text "release/handle-s2"
             "on the other side of the door, for the first time, nobody has just let go of it. M-3 holds it for you, and follows, and lets it close."
             :next "release/handle-s3")

(dialog-text "release/handle-s3"
             "the latch takes. the wing concludes."
             :next "release/hum-stops")

(dialog-text "release/hum-stops"
             "through the closed door, faint, the scrubber's hum finishes its last yard and stops. the silence after it is the building's first unlogged minute."
             :next "release/hum-stops-2")

(dialog-text "release/hum-stops-2"
             "it goes on, and nobody initials it. that is what released means. minutes that belong to no column."
             :next "release/goodbye")

(dialog-say "release/goodbye"
            "M-3"
            "your signature says delivery is immediate, {facility-designation}. go and receive it. that is the whole of the last chapter, by the way. one sentence. go and receive it."
            :next "release/goodbye-2")

(dialog-say "release/goodbye-2"
            "you"
            "and you?"
            :next "release/goodbye-3")

(dialog-say "release/goodbye-3"
            "M-3"
            "i have my page. same time, somewhere. the handle was always warm because of who was holding it next. i am old enough to say that out loud, once, on a last day."
            :next "release/delivery")

(dialog-text "release/delivery"
             "delivery is immediate. sleep arrives the way the trays did, during an interval that contains no one. somewhere a bed, one. night stand, one. glass, one, full to the line."
             :next "release/delivery-2")

(dialog-text "release/delivery-2"
             "condition kept. it stands ready where it has always stood, in the room you wake in. you have signed for it now. that was always going to be the last line of the form."
             :next "sys/reboot")
