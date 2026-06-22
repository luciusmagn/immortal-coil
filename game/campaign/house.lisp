;;; Inside the house: the forest's first dark branch. Going down to the
;;; open door and through it. Rooms that match the bedroom, a second cot
;;; recently used, and the keeper's kindness, which is the trap stated
;;; plainly. Entered from the porch; exits through sleep.

(dialog-music "house/inside" "audio/forest-lyria-drone.mp3" :volume 0.22)

(dialog-text "house/inside"
             "the hall is lamplit and smells of woodsmoke and wax. the floor is swept. on a nail by the door hang paper tags, four of them, and a fifth nail below them, empty, polished by use."
             :next "house/pegs")

(dialog-text "house/pegs"
             "along the wall, coat pegs. five. four hold coats, work coats and a child's slicker. the fifth is empty. it sits at the height you hang a coat, and the wood of it is worn pale. one coat wore it that way, taken down and put up, for years."
             :next "house/clock")

(dialog-text "house/clock"
             "the hall clock is stopped at six. it was stopped at six when you came down the stairs the first night, you think, and then you correct yourself: when you came in the door just now."
             :next "house/clock-2")

(dialog-text "house/clock-2"
             "the keeper winds it every evening anyway, eight turns, so the winding gets done. the hands never move. nothing here needs them to."
             :next "house/kitchen")

(dialog-text "house/kitchen"
             "in the kitchen there is bread cooling on a rack, and someone humming low through a door, two notes, patient. you have been in this kitchen before."
             :next "house/kitchen-2")

(dialog-text "house/kitchen-2"
             "you were in it on the store bench, in one of the pieces of sleep, and you woke from it warm and frightened, and here is the warmth, keeping its side of the bargain."
             :next "house/keeper")

(dialog-say "house/keeper"
            "the keeper"
            "you found your way back. they mostly do, off the hill. sit. soup first. questions keep, soup doesn't."
            :next "house/keeper-2")

(dialog-say "house/keeper-2"
            "you"
            "you were the one on the trail. with the lantern."
            :next "house/keeper-3")

(dialog-say "house/keeper-3"
            "the keeper"
            "somebody has to walk the trail when one of ours is out in the dark. eat. you can hate me warm as easy as cold."
            :next "house/keeper-first-word")

(dialog-choice-path "house/keeper-first-word"
                    "the spoon is in your hand and the keeper waits, in no hurry, for whatever you mean to say first."
                    ("i'm not staying."
                     :id "leaving"
                     "nobody says that warm, the keeper says. say it again in spring, with the door open all winter and you still at this table. i'll believe whichever one you say then."
                     :next "house/soup")
                    ("you've done this before."
                     :id "before"
                     "more times than there are chairs, the keeper says, and fewer than there are plates. eat. the counting is mine to do, and it keeps me up enough already."
                     :next "house/soup")
                    ("thank you."
                     :id "thanks"
                     "don't thank me, the keeper says. thank the soup. i only carried it down the trail, and carrying is the part nobody should ever be thanked for."
                     :next "house/soup"))

(dialog-text "house/soup"
             "the soup is barley and carrot and exactly right, which you resent with your whole heart and eat anyway, because the body votes first."
             :next "house/soup-s2")

(dialog-text "house/soup-s2"
             "the keeper does not watch you eat. they wipe the counter and hum the two notes and leave the bread where your eyes keep going."
             :next "house/grace-fork")

(defun house-grace-target ()
  (if (equal (dialog-value "forest-letter") "read")
      "house/grace-known"
      "house/grace"))

(dialog-text "house/grace-fork"
             "when the bowl is empty the keeper refills it without asking and finally talks, to the stove more than to you, in the tone of someone reporting small news to family."
             :next #'house-grace-target)

(dialog-text "house/grace"
             "the garden came in, the keeper says. and the dog found her way home, in the end, thinner but unworried. you nod along to a stranger's news, and the nodding feels practiced, and you do not know where the practice came from."
             :next "house/upstairs")

(dialog-text "house/grace-known"
             "the garden came in, the keeper says. and the dog found her way home, in the end, thinner but unworried. word for word."
             :next "house/grace-known-2")

(dialog-text "house/grace-known-2"
             "the round patient hand, eleven years sealed in a mailbox, speaking out of a living mouth at the stove."
             :next "house/grace-known-3")

(dialog-text "house/grace-known-3"
             "either the letter was dictation, or the news in this house never changes. you cannot decide which is worse. you keep eating."
             :next "house/upstairs")

(dialog-text "house/upstairs"
             "you have been up these stairs. your hand finds the smooth place on the rail without looking. on the landing there are four doors. the keeper opens the second one and stands aside. they do not say which room it is. they do not need to."
             :next "house/room")

(dialog-text "house/room"
             "the room is your room. the bed under the window. the night stand, with a glass of water already poured. the desk, with its one drawer. you know what the drawer sounds like before it is opened."
             :next "house/room-2")

(dialog-text "house/room-2"
             "it is the room you wake up in, the one you always wake up in, rebuilt here out of plank and quilt, or the other way around, and the keeper says, supper's at the bell, and leaves you with it."
             :next "house/cot")

(dialog-text "house/cot"
             "against the far wall, where your room has nothing, this one has a cot. the blankets are thrown back in a hurry's shape. the pillow still holds the dent of a head."
             :next "house/cot-2")

(dialog-text "house/cot-2"
             "on the floor beside it, one boot lace, broken, and a wrist tag, chewed soft at the corner the way paper goes when it is worried at for months."
             :next "house/cot-tag")

(dialog-text "house/cot-tag"
             "the tag's ink has run, like yours. RETURN IF FOUND, and under it a name that is not {forest-tag-name}, in the same round patient hand, and under the name the same number, the one that answers calm as housework on the second ring."
             :next "house/night-choice")

(dialog-pick "house/night-choice"
             "downstairs, a bell rings once, softly, the way you ring a bell for someone you are sure will come."
             (dialog-option "go down and ask about the cot" "house/ask-cot")
             (dialog-option "say nothing. eat. sleep" "house/quiet-night")
             (dialog-option "wait, then search the house" "house/search"))

(dialog-on-enter "house/ask-cot"
                 '(setf (dialog-value "house-night") "asked"))

(dialog-say "house/ask-cot"
            "the keeper"
            "the cot. yes. that one is out on the hill tonight. second winter running. some of ours take longer to come back than others."
            :next "house/ask-cot-2")

(dialog-say "house/ask-cot-2"
            "you"
            "ours."
            :next "house/ask-cot-3")

(dialog-say "house/ask-cot-3"
            "the keeper"
            "you slept on that cot your first winter, before you earned the bed. you do not remember, and that is fine, and it is also why the tags. the hill is hard on remembering. eat your supper."
            :next "house/supper")

(dialog-on-enter "house/quiet-night"
                 '(setf (dialog-value "house-night") "quiet"))

(dialog-text "house/quiet-night"
             "you say nothing."
             :next "house/quiet-night-2")

(dialog-text "house/quiet-night-2"
             "supper is set for two, and the second place stays empty, and the keeper serves it anyway, a full plate, covered with a cloth at the end and set on the windowsill, where the cold will keep it."
             :next "house/quiet-night-3")

(dialog-text "house/quiet-night-3"
             "for the one on the hill, the keeper says, in case. you sleep in the bed because the bed is yours, and that is the fact you take down into sleep like a stone."
             :next "house/listening")

(dialog-text "house/listening"
             "you lie awake first, cataloguing, because cataloguing is what you have instead of a door that locks from your side: the stove ticking down, the wind keeping to the pines."
             :next "house/listening-2")

(dialog-text "house/listening-2"
             "the two notes move once through the rooms below, unhurried. then the house goes quiet. it is not an empty quiet. the stove has stopped ticking. the wind has stopped in the pines. everything that was making a sound has stopped at once."
             :next "house/morning")

(dialog-on-enter "house/search"
                 '(setf (dialog-value "house-night") "searched"))

(dialog-text "house/search"
             "you lie still until the house settles, then walk it in sock feet. the first door on the landing: a room that matches the bedroom. the third door: a room that matches the bedroom."
             :next "house/search-2")

(dialog-text "house/search-2"
             "four doors, one room, repeated patiently, each with its bed under its window and its glass poured, two of them slept-in tonight, and you stop counting cots."
             :next "house/under-stairs")

(dialog-text "house/under-stairs"
             "under the stairs there is a low door, half height, and you know it before your hand reaches it: plank for plank it is the root cellar door, the one in the woods, the one with the oiled hinges and the matches on the second step."
             :next "house/under-stairs-2")

(dialog-text "house/under-stairs-2"
             "it is here and it is out there, the same door in two places. you do not open it. you already know what is on the second step."
             :next "house/album")

(dialog-text "house/album"
             "downstairs, in the dresser the lamp keeps lit, a photograph album. the porch, summer and winter, decades of coats and haircuts, and the keeper in every photograph, unchanged, holding the broom."
             :next "house/album-2")

(dialog-text "house/album-2"
             "in the oldest one, cracked and brown, a thin figure stands at the porch rail, not looking at the camera, looking at the woods, and the figure has your way of standing in it, and under the photograph, in pencil: came back."
             :next "house/album-after")

(dialog-text "house/album-after"
             "you put the album back the way evidence goes back: exactly. on the stairs the third step takes your weight without a sound, because you stepped over the creak, because you knew where the creak was."
             :next "house/morning")

(dialog-say "house/supper"
            "the keeper"
            "you want to know how long. they all want how long, as if the number would do something for them."
            :next "house/supper-2")

(dialog-say "house/supper-2"
            "you"
            "how long?"
            :next "house/supper-3")

(dialog-say "house/supper-3"
            "the keeper"
            "long enough that the county stopped writing. long enough that the letters in the boxes went quiet. you are not kept here, understand. the door stands open. that is the whole of it. the door stands open and look how that has gone."
            :next "house/keeper-questions")

(dialog-interrogation "house/keeper-questions"
                      "the keeper lets the kettle tick and waits, the way someone waits who has answered all of this before and minded none of it."
                      (:next "house/washing")
                      (:continue-label "take up the dish-cloth")
                      ("ask about the names on the mailboxes"
                       :id "boxes"
                       :speaker "the keeper"
                       "every one came off the hill and stayed. the boxes outlived the letters. i keep them painted. it is a small honest job and i am short of those.")
                      ("ask what the letters said, before they stopped"
                       :id "letters"
                       :speaker "the keeper"
                       "come home. they all said come home, in the hands of people who meant it. then the county went quiet and the meaning stayed in the boxes with nowhere to go.")
                      ("ask how many have left and not come back"
                       :id "left"
                       :speaker "the keeper"
                       "two. i think of them the way you think of a window left open in a house you loved. glad for the air. worried about the rain."))

(dialog-text "house/washing"
             "after supper you dry while the keeper washes, because the cloth was put in your hand. the two of you stand at the basin in the lamplight, passing plates, like any kitchen anywhere."
             :next "house/washing-2")

(dialog-text "house/washing-2"
             "your dread does not go anywhere. it only goes quiet, and close, and stands at the basin with you, drying plates."
             :next "house/morning")

(dialog-scene "house/morning"
              "morning in the house."
              :next "house/round")

(dialog-text "house/round"
             "the keeper is up before the frost is off, making the morning round: stove, lamps, porch, sill. the covered plate on the windowsill is gone, cloth and all."
             :next "house/round-2")

(dialog-text "house/round-2"
             "where it went, the keeper does not check: taken, or weathered, or worse. not checking is the discipline that keeps the giving clean."
             :next "house/breakfast")

(dialog-text "house/breakfast"
             "morning is porridge with cream and the smell of the stove and frost going off the windows in lines. it is the best morning you can remember."
             :next "house/breakfast-s2")

(dialog-text "house/breakfast-s2"
             "you make yourself hold that thought still and look at it. the memory it sits on is shallow, and you know that. the porridge is warm anyway."
             :next "house/chores")

(dialog-say "house/chores"
            "the keeper"
            "the wood wants splitting. only if you like. the hill brings down weather early this year."
            :next "house/chores-2")

(dialog-say "house/chores-2"
            "you"
            "and if i don't like?"
            :next "house/chores-3")

(dialog-say "house/chores-3"
            "the keeper"
            "then the wood stays whole and you stay warm anyway. nobody pays their way here. that has never once been the arrangement. the arrangement is older and worse: you are looked after."
            :next "house/woodpile")

(dialog-text "house/woodpile"
             "you split wood until noon because your hands wanted it. the maul is the right weight. the rounds stand the right height."
             :next "house/woodpile-2")

(dialog-text "house/woodpile-2"
             "the work takes your thinking the way the soup took your hunger. clean, complete. that is the trap, and knowing it is a trap does not loosen it. nothing in this house lies. that is what makes it the hill's."
             :next "house/bread")

(dialog-text "house/bread"
             "at noon the keeper sets the sponge for tomorrow's bread and puts your hands in the bowl without asking, fold and quarter-turn, fold and quarter-turn, and your hands take the rhythm before your head consents to it."
             :next "house/bread-2")

(dialog-text "house/bread-2"
             "hands remember faster than heads, the keeper says, watching yours. and yours are quick. they have done this. you fold, and quarter-turn, and do not ask when."
             :next "house/far-field")

(dialog-text "house/far-field"
             "after noon the keeper shoulders a sack and goes up toward the far field, unhurried, leaving you the house, the open door, the road below, and the whole grey afternoon. it is not carelessness. it is the lesson, set out like a meal."
             :next "house/door-test")

(dialog-pick "house/door-test"
             "from the porch you can see the road going down and the trail going up. the broom leans on the rail where it always leans."
             (dialog-option "walk out. now. down the road" "house/leave")
             (dialog-option "stay the day. set the table" "house/stay")
             (dialog-option "go up the trail after the cot's owner" "house/follow"))

(dialog-on-enter "house/leave"
                 '(setf (dialog-value "house-day") "left"))

(dialog-text "house/leave"
             "you walk out the open door and down the road and nobody stops you, because nobody has ever needed to. you make the mailboxes by dusk."
             :next "house/leave-2")

(dialog-text "house/leave-2"
             "it is at the mailboxes, reaching for nothing, that your hand finds the house key in your coat pocket, the brass one, warm, and you do not remember taking it, and you stand there a long time learning what it weighs."
             :next "house/leave-count")

(dialog-text "house/leave-count"
             "five boxes on the rack. four names weathered off, one readable. four tags on the nail in the hall, and a fifth nail, empty, polished."
             :next "house/leave-count-2")

(dialog-text "house/leave-count-2"
             "four coats on the pegs, and a fifth peg, worn pale, at your height."
             :next "house/leave-count-3")

(dialog-text "house/leave-count-3"
             "you stand at the boxes doing the arithmetic the hill has been setting out for you in fives since the first night, and the answer is the same every way you run it: the set is complete when you are in it."
             :next "house/leave-night")

(dialog-text "house/leave-night"
             "you sleep that night in the tree line within sight of the boxes, and it can be told plainly: you sleep facing the hill."
             :next "house/leave-night-2")

(dialog-text "house/leave-night-2"
             "in the morning there is frost, and on the flat of the newest mailbox, the one with the readable name, someone has stood a covered plate, still faintly warm."
             :next "house/last-notes")

(dialog-on-enter "house/stay"
                 '(setf (dialog-value "house-day") "stayed"))

(dialog-text "house/stay"
             "you stay the day. you sweep the porch because the broom was there. at dusk you set the table, two plates, and cover one, and put it on the windowsill for the one on the hill."
             :next "house/stay-2")

(dialog-text "house/stay-2"
             "the keeper comes down from the far field and looks at the sill and then at you, and says nothing. the nothing is a welcome, and you eat your supper in the warm."
             :next "house/stay-bell")

(dialog-text "house/stay-bell"
             "it is only after the meal, drying plates, that you run the day backward and find the seam in it: the bell rang at dusk, one soft stroke, and you came in from the yard and washed your hands, and there was no moment of deciding to."
             :next "house/stay-bell-2")

(dialog-text "house/stay-bell-2"
             "the bell rang and you were already moving. you stand with the cloth in your hands until the keeper takes it from you, gently, and finishes the plate."
             :next "house/stay-night")

(dialog-text "house/stay-night"
             "in the night the two notes move through the house below you, room to room."
             :next "house/stay-night-s2")

(dialog-text "house/stay-night-s2"
             "it is the sound a house makes when it is being checked on, when its people are being counted. the count includes you."
             :next "house/stay-night-s3")

(dialog-text "house/stay-night-s3"
             "you lie in your bed under your window and let it."
             :next "house/last-notes")

(dialog-on-enter "house/follow"
                 '(setf (dialog-value "house-day") "followed"))

(dialog-text "house/follow"
             "you take the trail up, past the far field, into the pines, walking the way the keeper walks, unhurried, and it works."
             :next "house/follow-2")

(dialog-text "house/follow-2"
             "where the creek cuts under the roots you find him: the cot's owner, grey-faced, tag on his wrist, pressed into the dark under the boughs exactly where you pressed yourself two nights ago."
             :next "house/mirror")

(dialog-say "house/mirror"
            "the man from the cot"
            "stay back. stay where you are."
            :next "house/mirror-2")

(dialog-say "house/mirror-2"
            "you"
            "i'm not with the house. i ran too. two nights ago i was under these same trees."
            :next "house/mirror-3")

(dialog-say "house/mirror-3"
            "the man from the cot"
            "look at your hands. they're scrubbed. there's a key on your belt and bread on your breath, and you walked up here the way they walk. two nights. it took you two nights."
            :next "house/mirror-after")

(dialog-text "house/mirror-after"
             "he goes off through the pines, quiet and practiced, and does not look back, and you stand by the creek with your scrubbed hands out from your sides like things you are carrying for someone else."
             :next "house/mirror-after-2")

(dialog-text "house/mirror-after-2"
             "the worst of it is the relief you feel when the cold starts working into you. the cold is honest, at least. the cold is on nobody's side."
             :next "house/mirror-walk")

(dialog-text "house/mirror-walk"
             "you walk back down at dusk because down is where the warm is, and you say it to yourself that flatly on purpose, to feel the size of it."
             :next "house/mirror-walk-2")

(dialog-text "house/mirror-walk-2"
             "at the porch the keeper has left the lamp lit, the door open, your plate covered, and has gone to bed. it is the kindest argument anyone has ever made to you. it is also the worst."
             :next "house/last-notes")

(dialog-text "house/last-notes"
             "last of all, wherever the day has put you, bed or needles or tree line, the two notes come, faint, from the house or from your own keeping of them, you can no longer say which."
             :next "house/last-notes-2")

(dialog-text "house/last-notes-2"
             "they find the level of your breathing and settle there, patient, the way a thing settles that has nowhere else it needs to be."
             :next "house/end")

(dialog-text "house/end"
             "sleep, when it takes you, takes you all at once, the deep kind, the kind the house keeps on the shelf for its own."
             :next "sys/reboot")
