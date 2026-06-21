;;; Nightshift: the facility path's first dark branch. Reassigned to
;;; the room side of the glass: the log read from inside, and the
;;; predecessor's notes in the night stand. Entered by initialing
;;; tomorrow's line; exits through the succession.

(dialog-text "nightshift/initialed"
             "you initial tomorrow's line as well, under your own handwriting. two sets of initials sit together on the page. a signature and its countersignature."
             :next "nightshift/m3-still")

(dialog-text "nightshift/m3-still"
             "M-3 is behind you. he is always behind you when the procedure needs a witness."
             :next "nightshift/m3-still-s2")

(dialog-text "nightshift/m3-still-s2"
             "he looks at the sheet for a long time. then he says one word. reassignment."
             :next "nightshift/briefing")

(dialog-say "nightshift/briefing"
            "M-3"
            "fourth rotation, {facility-designation}. the room side. you will want the duties. there are none. that is the hard part. the room side has conditions instead, and the conditions keep themselves."
            :next "nightshift/walk-in")

(dialog-text "nightshift/walk-in"
             "he walks you down the line to the door with the brass handle. he initials a sheet you have never seen. he holds the door. he does not say good luck."
             :next "nightshift/inside")

(dialog-text "nightshift/inside"
             "the door clicks shut behind you. bed under the window, night stand, glass full to the line, small table by the door. the room is made and waiting."
             :next "nightshift/glass-inside")

(dialog-text "nightshift/glass-inside"
             "from this side, the observation window is a curtain, drawn."
             :next "nightshift/glass-inside-s2")

(dialog-text "nightshift/glass-inside-s2"
             "when the corridor is lit, light shows along the hem of the curtain. that is how the room tells time. hem-light for rotations, dark for the long hours. the long hours are most of them."
             :next "nightshift/drawer")

(dialog-text "nightshift/drawer"
             "the night stand has one drawer. the inventory says it holds nothing. inside is a school notebook, soft with handling. on the cover, in pencil, in a hand you know: NOTES. FOR THE NEXT ONE."
             :next "nightshift/notes-1")

(dialog-text "nightshift/notes-1"
             "the notes are practical. drink before 0603. they log the drinking and worry if it is late. the worry goes upward, in reports."
             :next "nightshift/notes-1-2")

(dialog-text "nightshift/notes-1-2"
             "spare them the reports. the water is good. it is the one thing here with no second purpose."
             :next "nightshift/notes-2")

(dialog-text "nightshift/notes-2"
             "count the doors when you need to. it upsets the new watchers. count anyway. your figure will be disputed. let it be disputed. appendix two is their problem."
             :next "nightshift/notes-3")

(dialog-text "nightshift/notes-3"
             "the last page of notes is later than the rest, the pencil pressed harder."
             :next "nightshift/notes-3-2")

(dialog-text "nightshift/notes-3-2"
             "when you hear the binder's pages through the wall, the log is being read. you are the subject of the sentence. you can sleep through it. it took me years. start tonight."
             :next "nightshift/palimpsest")

(dialog-text "nightshift/palimpsest"
             "the notebook is older than its cover."
             :next "nightshift/palimpsest-layers")

(dialog-text "nightshift/palimpsest-layers"
             "under M-3's pencil, where the eraser wore the paper soft, an earlier hand shows through. under that, another. the layers go down a long way."
             :next "nightshift/palimpsest-drill")

(dialog-text "nightshift/palimpsest-drill"
             "the earliest legible layer is just numbers: in for four. hold for four. out for four."
             :next "nightshift/palimpsest-relay")

(dialog-text "nightshift/palimpsest-relay"
             "the notes are a relay, passed room-keeper to room-keeper, down years nobody counts. each one erases enough to make room, and never enough to lose the drill."
             :next "nightshift/palimpsest-relay-s2")

(dialog-text "nightshift/palimpsest-relay-s2"
             "you are not the next one. you are the latest one."
             :next "nightshift/first-watch")

(dialog-scene "nightshift/first-watch"
              "the first watch, from inside."
              :next "nightshift/hem-light")

(dialog-text "nightshift/hem-light"
             "the hem of the curtain lights. a rotation has begun on the far side. you lie in the bed, arm over the blanket, and listen to the watch happen to you. the rings sliding back. the held breath at the glass. the pencil."
             :next "nightshift/being-read")

(dialog-text "nightshift/being-read"
             "through the wall, the binder's pages turn. someone is reading your 0552, your 0603, your eleven minutes."
             :next "nightshift/being-read-s2")

(dialog-text "nightshift/being-read-s2"
             "you lie still. there is nothing to do under it but be reported accurately."
             :next "nightshift/hem-shadows")

(dialog-text "nightshift/hem-shadows"
             "you learn the watchers by their shadows along the hem. M-3's stands still. the day shift rocks heel to toe at the hour's end."
             :next "nightshift/hem-shadows-2")

(dialog-text "nightshift/hem-shadows-2"
             "the new ones lean in too close and jerk back when the glass fogs. you have opinions about all of them. you keep them to yourself."
             :next "nightshift/perform")

(dialog-text "nightshift/perform"
             "you drink before 0603, per the notes. through a wall and a curtain, you feel the watch relax."
             :next "nightshift/perform-s2")

(dialog-text "nightshift/perform-s2"
             "somewhere a grey coat initials a calm line, spared a report. the calm line is your doing."
             :next "nightshift/meals")

(dialog-text "nightshift/meals"
             "meals arrive during intervals that contain no one. you look away at the lawful moment. then the small table has a tray on it, and the tray is warm. the notes cover this too."
             :next "nightshift/meals-2")

(dialog-text "nightshift/meals-2"
             "do not try to catch the tray. the trying is logged. it works once, and you will wish it had not."
             :next "nightshift/eleven")

(dialog-text "nightshift/eleven"
             "the eleven minutes are the morning's whole craft."
             :next "nightshift/eleven-2")

(dialog-text "nightshift/eleven-2"
             "wake at 0552, rise at 0603, the notes say. fewer minutes reads as distress, more as decline. eleven is the figure the far side can initial without a report."
             :next "nightshift/eleven-3")

(dialog-text "nightshift/eleven-3"
             "you lie still for those eleven minutes each morning. it keeps the far side calm."
             :next "nightshift/count")

(dialog-text "nightshift/count"
             "in the long hours you count the doors."
             :next "nightshift/count-2")

(dialog-text "nightshift/count-2"
             "the figure comes out wrong by one. it is supposed to. this room has counted wrong by one since before your handwriting."
             :next "nightshift/count-3")

(dialog-text "nightshift/count-3"
             "you log it in the notebook, in pencil, under the predecessor's last entry. figure disputed. all well."
             :next "nightshift/watchers-note")

(dialog-text "nightshift/watchers-note"
             "deep in the notebook, one page is set apart, written calmer than the rest. about the watchers. they are more frightened than you. you have the room. they have the corridor."
             :next "nightshift/watchers-note-2")

(dialog-text "nightshift/watchers-note-2"
             "be watchable. it is the only kindness that goes in that direction."
             :next "nightshift/new-watcher")

(dialog-scene "nightshift/new-watcher"
              "some rotations later."
              :next "nightshift/new-voice")

(dialog-text "nightshift/new-voice"
             "a new watcher comes to the glass. you can tell. the rings drawn back too fast, the breathing unschooled, picking up the drill late."
             :next "nightshift/new-voice-s2")

(dialog-text "nightshift/new-voice-s2"
             "someone's first rotation. somewhere out there M-3 stands away from the glass, teaching by not helping."
             :next "nightshift/gift")

(dialog-text "nightshift/gift"
             "you stir, and do not wake, and take the next breath the familiar way, on purpose, the way it was once taken at you."
             :next "nightshift/gift-2")

(dialog-text "nightshift/gift-2"
             "on the far side, a held breath answers. you are the subject of someone's first line now. you have made it a kind one."
             :next "nightshift/spelling")

(dialog-text "nightshift/spelling"
             "the new watcher's pencil is slow through the wall, stopping at the hard words. you hear the handbook consulted, page against page."
             :next "nightshift/spelling-2")

(dialog-text "nightshift/spelling-2"
             "you breathe slower on those nights, giving them time to get you down right. you would like to be a fair copy."
             :next "nightshift/audit")

(dialog-text "nightshift/audit"
             "once a year, two grey coats inventory the room around you while you lie still in the bed. bed, one. night stand, one. glass, one, full."
             :next "nightshift/audit-2")

(dialog-text "nightshift/audit-2"
             "doors. here the two of them count separately, compare, and write down the dispute with visible relief. figure disputed, all well, initials, initials. the wrong figure passes inspection again."
             :next "nightshift/recurrence")

(dialog-scene "nightshift/recurrence"
              "recurrence, from inside."
              :next "nightshift/lights-dim")

(dialog-text "nightshift/lights-dim"
             "the corridor lights dim once, in order, away from the desk and back. you know the sequence from the hem."
             :next "nightshift/lights-dim-s2")

(dialog-text "nightshift/lights-dim-s2"
             "then the room's far wall has a door in it. the inventory disputes the door. it stands open. the dark behind it is not the corridor's."
             :next "nightshift/card-inside")

(dialog-text "nightshift/card-inside"
             "the card is in the drawer where you put it. you hold it in the dark. IN THE EVENT OF RECURRENCE, REMAIN WHERE YOU ARE. from this side of the glass it reads differently."
             :next "nightshift/card-inside-2")

(dialog-text "nightshift/card-inside-2"
             "it is not a restriction. it is a promise the room makes. that remaining is possible. that where you are will hold still enough to stay in."
             :next "nightshift/remain-inside")

(dialog-text "nightshift/remain-inside"
             "you remain where you are. the room goes somewhere, with you in it. whatever passes outside the disputed door passes quietly."
             :next "nightshift/remain-inside-2")

(dialog-text "nightshift/remain-inside-2"
             "it takes its time. you breathe the drill, in for four, hold for four, out for four, until the wall is a wall again."
             :next "nightshift/morning-after")

(dialog-text "nightshift/morning-after"
             "in the morning the glass is full to the line, refilled during an interval you would swear held no one. through the wall, the log reads one line longer than the night you remember."
             :next "nightshift/morning-after-2")

(dialog-text "nightshift/morning-after-2"
             "you initial the notebook instead. both records are kept. only one of them is yours."
             :next "nightshift/souvenirs")

(dialog-text "nightshift/souvenirs"
             "some mornings after recurrence the room comes back carrying things. a pine needle on the sill. flour dust in the blanket."
             :next "nightshift/souvenirs-ticket")

(dialog-text "nightshift/souvenirs-ticket"
             "once, pressed flat under the glass of water, a tram ticket, punched, from a city the inventory will not name. the room travels. you keep what it brings back."
             :next "nightshift/souvenirs-drawer")

(dialog-text "nightshift/souvenirs-drawer"
             "you keep them in the drawer with the notebook. needle, dust folded in paper, ticket. the inventory never objects."
             :next "nightshift/souvenirs-labels")

(dialog-text "nightshift/souvenirs-labels"
             "somewhere in the archive a file gets one line longer each time. you could write the spine labels yourself now. CROSSING. HILL HOUSE. THIRD DISTRICT. OAKBARROW."
             :next "nightshift/mug")

(dialog-text "nightshift/mug"
             "one tray arrives with a mug on it. grey, a designation stenciled on it, yours, from the locker row you will never stand in again. nobody initials a reason."
             :next "nightshift/mug-paperwork")

(dialog-text "nightshift/mug-paperwork"
             "somebody on the far side decided the room side should have its own mug. they fought the paperwork, and lost, and sent it anyway."
             :next "nightshift/mug-tea")

(dialog-text "nightshift/mug-tea"
             "you drink the acceptable tea from your own mug at the lawful hour. through the wall the binder's pages turn. the line being written about you is calm."
             :next "nightshift/m3-glass")

(dialog-scene "nightshift/m3-glass"
              "the long acquaintance."
              :next "nightshift/m3-watch")

(dialog-text "nightshift/m3-watch"
             "M-3 takes the watch himself some rotations. you learn his rings on the rail, slower than anyone's. and his breathing. the drill worn so smooth it is just breath now."
             :next "nightshift/m3-watch-2")

(dialog-text "nightshift/m3-watch-2"
             "he was on the room side once. nobody breathes like that from reading a handbook. the drill is what you take with you when they let you out."
             :next "nightshift/wall-talk")

(dialog-say "nightshift/wall-talk"
            "M-3, through the glass"
            "the curtain stays shut, {facility-designation}, per procedure. procedure does not mention the wall. the wall carries sound. i am old enough to stand near it. how is the room."
            :next "nightshift/wall-talk-2")

(dialog-say "nightshift/wall-talk-2"
            "you"
            "breathing. the figure is still disputed."
            :next "nightshift/wall-talk-3")

(dialog-say "nightshift/wall-talk-3"
            "M-3, through the glass"
            "good. when the figure settles, that is when we worry. the notes in the drawer. they were mine. i never knew who got them. file that wherever you file things now."
            :next "nightshift/bad-nights")

(dialog-text "nightshift/bad-nights"
             "on the bad nights, and the room side has them, M-3 stands at the wall after hours and reads you the day's log line, low, against every procedure he has initialed. subject slept."
             :next "nightshift/bad-nights-2")

(dialog-text "nightshift/bad-nights-2"
             "figure disputed. classification unchanged. in his voice, through the wall, it is not a report."
             :next "nightshift/succession")

(dialog-text "nightshift/succession"
             "the cycle shows you its whole shape. subject, then handler, then the long years of standing near walls. the second coat in the locker, elbows gone soft."
             :next "nightshift/succession-2")

(dialog-text "nightshift/succession-2"
             "the column of initials that become yours, the higher you read. the facility does not hire. it rotates."
             :next "nightshift/offer")

(dialog-say "nightshift/offer"
            "M-3, through the glass"
            "my rotation is ending, {facility-designation}. not the shift. the tenure."
            :next "nightshift/offer-s2")

(dialog-say "nightshift/offer-s2"
            "M-3, through the glass"
            "the desk will want someone who has read the log from both sides. the room will want someone it has already kept. you may have either chair."
            :next "nightshift/offer-s3")

(dialog-say "nightshift/offer-s3"
            "M-3, through the glass"
            "the facility asks you not to want both."
            :next "nightshift/choice")

(dialog-pick "nightshift/choice"
             "through the wall, the binder. through the curtain, the bed. both are yours, by initialed hours."
             (dialog-option "stay the subject. keep the room" "nightshift/stay-room")
             (dialog-option "take the grey coat. become M-3" "nightshift/take-coat")
             (dialog-option "walk the painted line out" "nightshift/walk-out"))

(dialog-on-enter "nightshift/stay-room"
                 '(setf (dialog-value "nightshift-end") "room"))

(dialog-text "nightshift/stay-room"
             "you keep the room. the notebook gets a new first page, in your hand. NOTES. FOR THE NEXT ONE."
             :next "nightshift/stay-room-2")

(dialog-text "nightshift/stay-room-2"
             "through the wall, a new pencil takes up the log, unschooled, careful. you drink before 0603. you spare them the report. the figure stays disputed around you."
             :next "nightshift/end-glass")

(dialog-on-enter "nightshift/take-coat"
                 '(setf (dialog-value "nightshift-end") "coat"))

(dialog-text "nightshift/take-coat"
             "the coat fits. the older coat in the locker always said it would."
             :next "nightshift/take-coat-watch")

(dialog-text "nightshift/take-coat-watch"
             "on your first watch from the corridor side you draw the curtain back slowly, rings one at a time, and stand away from the glass. the sleeper inside stirs and takes the next breath the familiar way. you hold yours, per the drill. the drill holds."
             :next "nightshift/take-coat-date")

(dialog-text "nightshift/take-coat-date"
             "you initial the line M-3 initialed for years. under it, for the first time, you write the date in full. you understand the date now, writing it."
             :next "nightshift/end-glass")

(dialog-on-enter "nightshift/walk-out"
                 '(setf (dialog-value "nightshift-end") "out"))

(dialog-text "nightshift/walk-out"
             "you walk the line out, past the desk, past the sheet with its column of your initials. the line carries you to a door you have never been shown. the handle is warm."
             :next "nightshift/walk-out-2")

(dialog-text "nightshift/walk-out-2"
             "on the other side of the door someone has just let go of it, the way someone always has. you go through anyway. the facility never files this. it cannot see past its own doors."
             :next "nightshift/end-glass")

(dialog-text "nightshift/end-glass"
             "wherever the choice has put you, there is a glass of water, full to the line. you stand it where it goes, to the millimeter. the keeping of it was never the facility's."
             :next "nightshift/end-glass-2")

(dialog-text "nightshift/end-glass-2"
             "it was always the room's, and the room's people's. you are one of them now, whichever side of the glass you kept."
             :next "nightshift/end")

(dialog-text "nightshift/end"
             "every rotation ends the same way. a bed, a night stand, a glass of water full to the line. sleep arrives per schedule, during an interval that contains no one, to refill you."
             :next "sys/reboot")
