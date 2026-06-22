;;; The seam: the alice path's second dark branch. Following the white
;;; thread down under the long table, through the seam in the boards, to
;;; the compost of doors: where rooms go when nobody keeps them.
;;; Entered from the thread's fork; exits up through the garden.

(dialog-text "seam/under"
             "under the long table the cloth hangs to the floor. the floor under it is plain boards. between two boards, a seam. the second strand of thread runs down into it, taut, like a line let down a well."
             :next "seam/boards")

(dialog-text "seam/boards"
             "you press the seam and the boards part along it, not like wood, like cloth taking a hem out. there are stairs below. they are made of door sills, stacked, worn in the middle by one kind of traffic."
             :next "seam/descent")

(dialog-text "seam/descent"
             "the banister is a rail of door handles, every pattern, every age, each one polished where a hand falls and dull where it does not."
             :next "seam/descent-s2")

(dialog-text "seam/descent-s2"
             "you go down holding strangers' grips, one after another, and they fit, every one. handles are the most forgiving furniture."
             :next "seam/smell")

(dialog-text "seam/smell"
             "the smell arrives before the light: every room at once, faint. woodsmoke, wax, basin water, bread, ink, rain through a window open one finger. it is not a bad smell. it is the smell of after."
             :next "seam/compost")

(dialog-text "seam/compost"
             "the under-court opens out farther than the court above could cover it. drifts of doorframes going soft at the joints. numbers flaking off and turning in the air like leaves. hinges shed in the lanes like seeds, bright, then dull, then soil."
             :next "seam/compost-quiet")

(dialog-text "seam/compost-quiet"
             "nothing rots here, exactly. it loosens. a wardrobe drift settles as you watch, a hand's width in an hour. the only sound is the settling, and somewhere off among the lintels, a needle being threaded."
             :next "seam/lanes")

(dialog-text "seam/lanes"
             "the drifts have lanes between them, swept, and the lanes have a logic: wardrobes settle with wardrobes, sills with sills."
             :next "seam/lanes-s2")

(dialog-text "seam/lanes-s2"
             "one whole quarter is staircases, lying down at last, and you do not linger there. a staircase lying down is hard to look at."
             :next "seam/curtain-meadow")

(dialog-text "seam/curtain-meadow"
             "past the staircases, a meadow of curtains, laid flat, lifting all together at some breath the rest of the place does not feel. they are the only thing down here that still moves on its own."
             :next "seam/lullaby")

(dialog-text "seam/lullaby"
             "in the curtain meadow you hear it: the melody. the jury's deliberation tune, the lullaby with the intervals worn round."
             :next "seam/lullaby-s2")

(dialog-text "seam/lullaby-s2"
             "it circles the lanes low to the ground, going nowhere. its room was unpicked long ago and nobody rewound it."
             :next "seam/lullaby-2")

(dialog-text "seam/lullaby-2"
             "it was a nursery's, you understand, hearing it here. the jury did not write it. the jury only borrowed it, the way everything above borrows from below, and it resolves, as it always resolves, on the note you know, and goes around again."
             :next "seam/seamstress")

(dialog-text "seam/seamstress"
             "she works at a table made of tables, in light that comes from nowhere and lands like late afternoon. white thread, long stitches, a kitchen across her lap. she is taking it out."
             :next "seam/seamstress-2")

(dialog-text "seam/seamstress-2"
             "stitch by stitch, the kitchen shows its cloth-work: shelf grain as weave, window light as bright thread, the smell of the room wound close to a spool marked in chalk."
             :next "seam/watch-unpick")

(dialog-text "seam/watch-unpick"
             "she unpicks the window over the sink and the light in it goes out, slow, the way a held note ends. she unpicks the smell of the kitchen last, winding it close to the spool's heart, where it will keep."
             :next "seam/lesson")

(dialog-text "seam/lesson"
             "she beckons you to the kitchen on her lap and puts the needle in your hand, guiding it backward through one stitch. take it out slow, she says."
             :next "seam/lesson-stitch")

(dialog-text "seam/lesson-stitch"
             "you do, and the stitch gives with a small dry sound. under your fingers, a hand's width of pantry shelf reveals its weave."
             :next "seam/lesson-work")

(dialog-text "seam/lesson-work"
             "one is enough, she says, taking the needle back. now you know the weight of the work, and you will not tell anyone above that it is cruel, because you have felt it, and it is not cruel. it is exact."
             :next "seam/seamstress-talk")

(dialog-say "seam/seamstress-talk"
            "the seamstress"
            "you came down the thread. that is allowed and not advised."
            :next "seam/seamstress-talk-2")

(dialog-say "seam/seamstress-talk-2"
            "you"
            "what is this place?"
            :next "seam/seamstress-talk-3")

(dialog-say "seam/seamstress-talk-3"
            "the seamstress"
            "where rooms go when nobody keeps them. somebody has to take them apart kindly. the alternative is that they come apart unkindly, up there, around whoever is left in them."
            :next "seam/seamstress-questions")

(dialog-interrogation "seam/seamstress-questions"
                      "her needle does not stop moving while she talks. there is room to ask, between one stitch and the next."
                      (:next "seam/economy")
                      (:continue-label "hear the rest")
                      ("ask if many come down the thread"
                       :id "many"
                       :speaker "the seamstress"
                       "a few a year, always by accident, always sure they meant to. you are the first in a while to ask what the place is before asking how to leave it.")
                      ("ask what 'not advised' means"
                       :id "advised"
                       :speaker "the seamstress"
                       "that the coming down costs a little of the room you came from. you will not miss the thread until you are home and a wall fails to meet.")
                      ("ask how long she has worked here"
                       :id "long"
                       :speaker "the seamstress"
                       "longer than the rooms i unpick, shorter than the thread. time is measured in stitches here, and i have lost the count kindly, which is the only way to lose it."))

(dialog-say "seam/economy"
            "the seamstress"
            "the thread goes to the spools. the spools go to the gardener. he plants what i wind, and doors come up, and rooms are sewn from them for the next keepers. nothing here is lost. it is only no longer addressed."
            :next "seam/economy-2")

(dialog-say "seam/economy-2"
            "you"
            "the garden grows out of this?"
            :next "seam/economy-3")

(dialog-say "seam/economy-3"
            "the seamstress"
            "every garden grows out of something like this. the gardener and i do not socialize. compost and seed never do. the thread manages the relationship."
            :next "seam/number-tin")

(dialog-text "seam/number-tin"
             "by her elbow, a biscuit tin of flaked-off numbers, swept from the corners: threes gone soft, sevens curled like bark. the gardener paints his new doors from this tin, she says. numbers are reused."
             :next "seam/number-tin-2")

(dialog-text "seam/number-tin-2"
             "yours has been six doors' number already. it remembers none of them."
             :next "seam/spool-shelf")

(dialog-text "seam/spool-shelf"
             "behind her, the spool wall climbs out of the light: thousands, chalked one word each. STOVE. RAIN. FOUR. HUSH."
             :next "seam/spool-shelf-2")

(dialog-text "seam/spool-shelf-2"
             "the oldest spools, high up, predate the court, predate the garden, are wound in thread the color old linen goes, and their chalk has worn almost to nothing."
             :next "seam/glasses")

(dialog-text "seam/glasses"
             "along one wall, on a shelf that was a mantel, water glasses stand in rows, each full to its own line."
             :next "seam/glasses-s2")

(dialog-text "seam/glasses-s2"
             "the last glass of every unkept room, she says, carried down before the unpicking. nobody drinks them. she dusts them."
             :next "seam/glass-count")

(dialog-text "seam/glass-count"
             "you do not count the glasses. you have learned, in several worlds now, what counting does to you here, and the shelf is long, and the shelf is not the only shelf."
             :next "seam/her-glass")

(dialog-text "seam/her-glass"
             "there is one more glass, apart from the shelf, on the table of tables at her right hand: half empty, no line marked. hers."
             :next "seam/her-glass-kept")

(dialog-text "seam/her-glass-kept"
             "she drinks from it while she works. it is the only drinking glass in the under-court. she lives here, so somebody keeps her too."
             :next "seam/her-glass-question")

(dialog-text "seam/her-glass-question"
             "you do not ask who fills it. she would not answer, and you both know it."
             :next "seam/stray")

(dialog-text "seam/stray"
             "it is at the shelf that you notice the room following you. a small one, half unpicked, trailing its hem of floorboards: a child's room, wallpaper soft as flannel, one window unraveling at the corner."
             :next "seam/stray-2")

(dialog-text "seam/stray-2"
             "it stops when you stop. it pretends to be a drift. rooms are bad at pretending."
             :next "seam/stray-history")

(dialog-say "seam/stray-history"
            "the seamstress"
            "that one came down early. its keeper grew, which is not the keeper's fault and not the room's, and it will not lie flat for the needle. it has been following my visitors for years. ignore it and it will settle."
            :next "seam/stray-history-2")

(dialog-say "seam/stray-history-2"
            "you"
            "and if i don't ignore it?"
            :next "seam/stray-history-3")

(dialog-say "seam/stray-history-3"
            "the seamstress"
            "then you will be making a promise, and i sew promises, so i can tell you the thread they take. all of it. promises take all of it."
            :next "seam/stray-close")

(dialog-text "seam/stray-close"
             "the small room comes a board's width closer while you are not looking, and arranges its unraveled window to face you, the way a dog arranges its ears."
             :next "seam/stray-close-s2")

(dialog-text "seam/stray-close-s2"
             "through the gap in its corner you can see its lamp is still in it. unlit, but in it. it kept its lamp."
             :next "seam/spool-yours")

(dialog-text "seam/spool-yours"
             "on the spool wall, among the chalk marks, one spool sits apart with its thread run out, taut, rising into the dark overhead. the chalk says nothing."
             :next "seam/spool-yours-s2")

(dialog-text "seam/spool-yours-s2"
             "it does not need to. the white thread on your wrist runs to it, and hums very slightly, like a held breath."
             :next "seam/spool-truth")

(dialog-say "seam/spool-truth"
            "the seamstress"
            "yes. your room is sewn from here, like all of them. the court's thread was never the court's. keeping a room is what keeps the stitches in. that is all keeping has ever been."
            :next "seam/spool-truth-2")

(dialog-say "seam/spool-truth-2"
            "you"
            "and if i stop?"
            :next "seam/spool-truth-3")

(dialog-say "seam/spool-truth-3"
            "the seamstress"
            "then one day the thread goes slack, and i wind, and the spool fills, and the glass comes down to the shelf, full, at its line. i am not threatening you. i am telling you what i do for a living. somebody tells the keepers. it has come to be me."
            :next "seam/sit")

(dialog-text "seam/sit"
             "she pours you tea. it is not kindness so much as how the place runs. the cup she pours it into has a chip you recognize. you do not ask. the not-asking is in your voice when you thank her, and she nods. learned manners. the kind this place teaches."
             :next "seam/tea-warm")

(dialog-text "seam/tea-warm"
             "while you drink, the small room edges to the table's leeward side and warms your tea from a board's width away, the way it must once have warmed socks and small fevers."
             :next "seam/tea-warm-s2")

(dialog-text "seam/tea-warm-s2"
             "it has one trick. it does its trick. the seamstress looks elsewhere with great skill."
             :next "seam/stray-choice")

(dialog-pick "seam/stray-choice"
             "the small room waits at the lane's edge with its lamp in it. the seamstress threads her needle and does not hurry you."
             (dialog-option "take its thread. adopt the room" "seam/adopt")
             (dialog-option "ask her to finish it kindly" "seam/finish")
             (dialog-option "ask the gardener to plant it" "seam/plant"))

(dialog-on-enter "seam/adopt"
                 '(setf (dialog-value "seam-stray") "adopted"))

(dialog-text "seam/adopt"
             "she ties the small room's thread beside your own, two strands on one wrist, and the knot she uses has no name above ground."
             :next "seam/adopt-knot")

(dialog-text "seam/adopt-knot"
             "the room comes in against your side, boards to your boot, the way a thing comes in that has decided about you. promises take all of it, she says again, but gently, the way you bless someone."
             :next "seam/adopt-room")

(dialog-text "seam/adopt-room"
             "from now on, she says, your room has a small room in it, somewhere a wall used to be honest. keep them both watered. she means the glasses. you will stand two glasses now, each to its line, and the second one is lower, child height."
             :next "seam/parting")

(dialog-on-enter "seam/finish"
                 '(setf (dialog-value "seam-stray") "finished"))

(dialog-text "seam/finish"
             "you sit with the small room while she takes it out. it lies flat for her now, which it never has, because somebody is sitting with it, and that was the whole holdout, all these years."
             :next "seam/finish-lamp")

(dialog-text "seam/finish-lamp"
             "she unpicks the lamp last of all, lit for the first stitch and the last, and winds its evening light into the heart of the spool."
             :next "seam/finish-spool")

(dialog-text "seam/finish-spool"
             "the chalk she writes on the spool is one word long, and she lets you write it, and you write the word you would want on yours, and she reads it and nods once, and shelves it where the afternoon light lands longest."
             :next "seam/parting")

(dialog-on-enter "seam/plant"
                 '(setf (dialog-value "seam-stray") "planted"))

(dialog-text "seam/plant"
             "the gardener comes down for it himself, which the seamstress says has not happened in her tenure."
             :next "seam/plant-s2")

(dialog-text "seam/plant-s2"
             "he pots the small room entire, lamp and all, in turned black earth, and promises nothing, which from him is the highest grade of promise available."
             :next "seam/plant-2")

(dialog-text "seam/plant-2"
             "it will come up as a door, he says, carrying it up the sill stairs. they all do."
             :next "seam/plant-2-2")

(dialog-text "seam/plant-2-2"
             "but this one will come up with its lamp already lit, and some keeper, some year, will open a door with evening behind it, and that is the gardener's whole pension, moments like that, paid irregularly."
             :next "seam/parting")

(dialog-text "seam/parting"
             "before you go she reaches up to the spool wall without looking and takes down a short length of the old linen-colored thread, and ties off the end of your wrist thread with it, a finishing knot, so it cannot unravel from use."
             :next "seam/parting-2")

(dialog-text "seam/parting-2"
             "everything should end in older thread than itself, she says. that is the whole craft."
             :next "seam/way-up")

(dialog-text "seam/way-up"
             "when it is time, the seamstress sews you a way up: long basting stitches in the air of the stairwell, loose on purpose. follow the basting, she says."
             :next "seam/way-up-2")

(dialog-text "seam/way-up-2"
             "it will hold one passage and then i am taking it out. nothing down here is permanent. that is the kindness. tell the room i sew straight."
             :next "seam/stairs-up")

(dialog-text "seam/stairs-up"
             "you climb the sill stairs with the basting humming beside your hand, and the handles of the banister turn under your palm as you pass, each one, the way they did on the way down."
             :next "seam/underside")

(dialog-text "seam/underside"
             "near the top you pass beneath the long table itself and see its underside, which nobody above has ever seen: ring marks of every cup that ever stood on it, ghosted through the wood, and each one named in chalk, in her hand."
             :next "seam/garden-gate")

(dialog-text "seam/garden-gate"
             "you come up through a trapdoor of turned earth into the garden of doors at night, between a row of fives and the plot where the numbers dry."
             :next "seam/garden-gate-2")

(dialog-text "seam/garden-gate-2"
             "the gardener is waiting with his lantern down low, and he looks at the thread lint on your coat and asks nothing, knowing everything a gardener needs to."
             :next "seam/cloth-plot")

(dialog-text "seam/cloth-plot"
             "he walks you out past the new plot, where tomorrow's doors are still bolts of room-cloth, pinned to the turned earth with sill pegs, and under the pins the cloth rises and falls, very slightly, at the pace of the curtain meadow far below."
             :next "seam/cloth-plot-2")

(dialog-text "seam/cloth-plot-2"
             "the same breath. the whole garden breathes it."
             :next "seam/gate-out")

(dialog-say "seam/gate-out"
            "the gardener"
            "you have been to see her. the coat says so. the gate is still free. the toll for down there is paid in different coin, and you have paid it, by the look of you."
            :next "seam/gate-out-2")

(dialog-say "seam/gate-out-2"
            "you"
            "she says she sews straight."
            :next "seam/gate-out-3")

(dialog-say "seam/gate-out-3"
            "the gardener"
            "she does. tell nobody up here i agreed. compost and seed, you understand. the thread manages the relationship."
            :next "seam/gate-look-back")

(dialog-text "seam/gate-look-back"
             "at the gate you look back once, which is allowed from gates, and the garden at night is doing what it always does: rows of doors asleep on their feet."
             :next "seam/gate-look-back-2")

(dialog-text "seam/gate-look-back-2"
             "numbers drying, and under all of it, faint as a needle through cloth, the lullaby, going around, keeping the whole place company from below."
             :next "seam/thread-slack")

(dialog-text "seam/thread-slack"
             "at the gate the white thread goes slack, its work done twice over, and slips off your wrist on its own knot."
             :next "seam/thread-slack-2")

(dialog-text "seam/thread-slack-2"
             "you wind it twice around two fingers, the way thread is kept, and put it in your pocket, where the seam cannot wind it, and the court cannot enter it, and only you know its length."
             :next "seam/pocket-hum")

(dialog-text "seam/pocket-hum"
             "on the stairs up, the kept thread hums once in your pocket, low, the held-breath hum of the spool wall, settling. it knows where it has been. so do you."
             :next "seam/pocket-hum-2")

(dialog-text "seam/pocket-hum-2"
             "a souvenir comes loose. the thread is still attached at the far end, and always will be."
             :next "seam/sleep")

(dialog-text "seam/sleep"
             "sleep comes up the stairwell to meet you, at exactly the length it always was, and takes you on the top step, all at once, the deep kind, the kind that is sewn in long stitches, loose on purpose."
             :next "sys/reboot")
