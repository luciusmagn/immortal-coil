;;; Bellfall: the jrpg path's second dark branch. Nine quiet years of
;;; terms, then the midnight bell, the funeral on the hill, and the year
;;; the notices have to start again. Entered through room four on the
;;; terms answer; exits through the choice of what Demhe does next.

(dialog-text "bellfall/asleep"
             "the sleep is the good kind. the winter that starts tomorrow is the first quiet one in nine years. it keeps its word. so do the eight after it."
             :next "bellfall/years")

(dialog-scene "bellfall/years"
              "nine quiet years later."
              :next "bellfall/stayed")

(dialog-text "bellfall/stayed"
             "you stayed. it was never decided, the way the true things aren't. there was a winter, and then a roof that wanted mending before the next one, and then you were the one who mends the inn's roof."
             :next "bellfall/mornings")

(dialog-text "bellfall/mornings"
             "mornings you work the oven with Toma, whose shoulder has opinions now, and who has begun, without ceremony, teaching you the travel loaf."
             :next "bellfall/mornings-s2")

(dialog-text "bellfall/mornings-s2"
             "evenings you walk the chain with Oren, whose knee predicts weather better than Niko's half charm ever did."
             :next "bellfall/room-yours")

(dialog-text "bellfall/room-yours"
             "room four stopped being credit years ago. the nail above the basin has stayed empty nine years, polished brighter than the basin, and Mira dusts it like a trophy, because it is one."
             :next "bellfall/quiet-ledger")

(dialog-text "bellfall/quiet-ledger"
             "the other ledger has not opened for a new entry since sixty-seven. some evenings Mira takes it down, looks at the wrapped weight of it in her hands, and puts it back without untying the cloth."
             :next "bellfall/companion-years")

(dialog-conversation "bellfall/companion-years"
                     (dialog-left "{jrpg-companion}"
                                  "nine years. my father got two quiet ones in his whole life, and i got nine just by standing next to you.")
                     (dialog-right "{player-name}"
                                   "you did more than stand there.")
                     (dialog-left "{jrpg-companion}"
                                  "i know. i wanted to hear you say it. that took nine years too.")
                     :next "bellfall/autumn")

(dialog-text "bellfall/autumn"
             "it is a deep clear autumn, the barley in, the lanterns from midsummer still in some windows, when the bell rings."
             :next "bellfall/bell")

(dialog-text "bellfall/bell"
             "not the supper bell. not Pell's handbell. a bell from the north, deep enough to come through the ground as much as the air, one slow stroke, and then another, and Demhe has never heard it before and knows it at once."
             :next "bellfall/square-night")

(dialog-text "bellfall/square-night"
             "the village gathers in the square in nightshirts and boots, nobody sent for, everybody there. Oren counts the strokes under his breath, by habit, with nothing to mark them on."
             :next "bellfall/children")

(dialog-text "bellfall/children"
             "the children, who have never heard any bell but supper's, stand inside the adults' coats and learn the new sound the way children learn everything: from the faces around them, before anyone says a word."
             :next "bellfall/bell-night")

(dialog-text "bellfall/bell-night"
             "the bell rings all night, even and unhurried, the pace of a man walking a known road, and stops with first light, mid-stroke, the way a thing stops that has finished rather than tired."
             :next "bellfall/lanterns-relit")

(dialog-text "bellfall/lanterns-relit"
             "before dawn, unasked, the midsummer lanterns come out of cupboards all over the village and are lit in the windows, paper by paper, until the square is ringed with small warm lights facing north."
             :next "bellfall/lanterns-relit-s2")

(dialog-text "bellfall/lanterns-relit-s2"
             "grief reaches for whatever festival gear it can find."
             :next "bellfall/pell-comes")

(dialog-conversation "bellfall/pell-comes"
                     (dialog-left "Pell"
                                  "the tower door stands open. the rack of swords is out on the grass, set in rows, polished. and the bell rope is still moving, and there is nobody on it.")
                     (dialog-right "{player-name}"
                                   "the King.")
                     (dialog-left "Pell"
                                  "there is a grave dug. it was dug neat, and signed at the head, the way he did everything. it is waiting for him and he is laid beside it, waiting for us. he knew we would want to do the carrying.")
                     :next "bellfall/mira-page")

(dialog-text "bellfall/mira-page"
             "Mira takes down the other ledger and unties it for the first time in nine years, and turns to a page you have never been shown: entry fifty-nine. settled: by terms. she lays her hand flat over the name."
             :next "bellfall/fifty-nine")

(dialog-conversation "bellfall/fifty-nine"
                     (dialog-left "Mira"
                                  "fifty-nine went up like all of them. he came down once, to this table, and asked me what the terms were. then he went back up and the old lord came down to this grave-yard, and the notices changed hands.")
                     (dialog-right "{player-name}"
                                   "the King was a sixty-seven once.")
                     (dialog-left "Mira"
                                  "the King was a fifty-nine. the tower is not a monster's house, it is a post. it has always been held by someone's child who asked about terms. you asked about terms.")
                     :next "bellfall/terms-questions")

(dialog-interrogation "bellfall/terms-questions"
                      "the bell has not yet rung for the procession. Mira lets you keep the chair a little longer."
                      (:next "bellfall/funeral-prep")
                      (:continue-label "rise for the funeral")
                      ("ask what the terms actually are"
                       :id "terms"
                       :speaker "Mira"
                       "what the valley owes the hill, and what the hill agrees not to take. the words change with each post. the arithmetic under them never has.")
                      ("ask how the post changes hands"
                       :id "post"
                       :speaker "Mira"
                       "the one above comes down to the grave-yard. the one below goes up to the desk. nobody is forced. everybody is chosen. that has been enough to keep it turning.")
                      ("ask whether anyone has refused the post"
                       :id "refused"
                       :speaker "Mira"
                       "one did. the hill stopped being choosy that winter, and the valley spent a long time being findable to it. we do not say his name. we post more carefully now."))

(dialog-scene "bellfall/funeral-prep"
              "the morning of the funeral."
              :next "bellfall/set-aside")

(dialog-text "bellfall/set-aside"
             "Toma bakes through the night, and the loaf he sets at the head of the baskets is the set-aside loaf, the one his count has kept aside every day for years, unexplained, in case."
             :next "bellfall/set-aside-s2")

(dialog-text "bellfall/set-aside-s2"
             "this is the case. he knew it would come and not what it would be."
             :next "bellfall/procession")

(dialog-text "bellfall/procession"
             "Demhe walks the north road together, the whole village, the first time in anyone's memory. Oren carries the polished spear at the front, point down, finally with its use: spears are for carrying ahead of people, in the end."
             :next "bellfall/toll")

(dialog-text "bellfall/toll"
             "at the toll hut the slate reads CLOSED FOR MOURNING, and Pell stands beside it signing every villager through with a touch on the shoulder, keeping the count by heart, because some tolls are kept even when they are not charged."
             :next "bellfall/bridge-cross")

(dialog-text "bellfall/bridge-cross"
             "the bridge takes the village's weight in twos and threes. nobody jokes about it surviving. the travel loaf survives the bridge, you think, and the thought has Toma's voice, and you carry it the rest of the climb."
             :next "bellfall/tower-grass")

(dialog-text "bellfall/tower-grass"
             "the swords stand in the grass in their rows, every visitor who lost, polished for the occasion by a man getting his accounts right. between the rows to the grave, the grass is freshly scythed. he made a path for the village he kept."
             :next "bellfall/first-sword")

(dialog-text "bellfall/first-sword"
             "the oldest sword in the rows is pitted to lace, the blade more absence than iron."
             :next "bellfall/first-sword-2")

(dialog-text "bellfall/first-sword-2"
             "Oren reads the maker's mark with his thumb and says a name out of his grandmother's stories, quietly, and puts his hand back at his side. the post is older than the village. the village is the post's."
             :next "bellfall/grave")

(dialog-text "bellfall/grave"
             "the village buries the King of the high tower with bread, barley, and the silence it saves for its own. Mira reads entry fifty-nine aloud, name first, and enters the settled date at the graveside, in ink, on a book held flat by Pell."
             :next "bellfall/grave-words")

(dialog-conversation "bellfall/grave-words"
                     (dialog-left "Mira"
                                  "Walter the King. settled, today, by terms, having held the post thirty-one years and kept the valley a valley. left behind: the village of Demhe, in its entirety.")
                     (dialog-right "{player-name}"
                                   "the whole column?")
                     (dialog-left "Mira"
                                  "the whole column. there are entries you hope to write all your life. they cost the same as the others. more, possibly.")
                     :next "bellfall/grave-goods")

(dialog-text "bellfall/grave-goods"
             "the village leaves things, one at a time, nobody organizing it: the set-aside loaf, broken to share with the grave. a stick of Oren's chalk. a tin star."
             :next "bellfall/grave-goods-s2")

(dialog-text "bellfall/grave-goods-s2"
             "somebody's paper lantern, saved dry since midsummer, weighted with a pebble against the hill wind."
             :next "bellfall/walk-down")

(dialog-text "bellfall/walk-down"
             "the village walks down quieter than it walked up. at the mile marker, Oren stops, and measures the road with his eye, and says nothing, and his nothing carries: the marker has moved. the hill grew in the night. one marker's worth."
             :next "bellfall/no-bell")

(dialog-text "bellfall/no-bell"
             "that evening the supper bell does not ring. nobody decided it. the village eats with no bell, one night, for the man who rang one. everyone hears the hour anyway, by the stroke that does not come."
             :next "bellfall/ditch")

(dialog-text "bellfall/ditch"
             "by the bridge, the ditch grass is shaking, and not with wind. nine years since the last time. the village bunches behind Oren's spear, and you step out front, because your feet know the spot. it is the same spot."
             :next "bellfall/ambush")

(dialog-minigame "bellfall/ambush"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "bellfall/ambush-won"
                 :failure "bellfall/ambush-carried")

(dialog-text "bellfall/ambush-won"
             "you win slow, counting, with nine years of roof-mending in your arms, and when it is done the village exhales behind you, and Oren marks the toll board for the first time in nine years, one chalk stroke, very small."
             :next "bellfall/winter-comes")

(dialog-text "bellfall/ambush-carried"
             "your knee goes where Oren's would have, and it is sixty-six's child, your companion of the old road, who carries you up out of the ditch, the way they carried their father, the way this ditch has always been paid."
             :next "bellfall/ambush-carried-2")

(dialog-text "bellfall/ambush-carried-2"
             "walk now, talk never, they say, and their voice is not steady."
             :next "bellfall/winter-comes")

(dialog-scene "bellfall/winter-comes"
              "the first loud winter."
              :next "bellfall/counting")

(dialog-text "bellfall/counting"
             "the tatter count climbs all winter. the chain goes up earlier each week. by midwinter the toll board is half full and Pell has stopped going down to the fair-fund jar, because the jar is now the watch fund, by unspoken vote."
             :next "bellfall/roster")

(dialog-text "bellfall/roster"
             "a watch roster appears on the inn wall, the village's first, ruled in Mira's hand. your name is on it twice a week, entered before you volunteered, because the book has always known things about you a little ahead of you knowing them."
             :next "bellfall/table-debate")

(dialog-conversation "bellfall/table-debate"
                     (dialog-left "Toma"
                                  "post it. bread feeds whoever comes, and whoever comes buys the valley nine more years. that is not cold. that is the oven's whole arithmetic.")
                     (dialog-right "{player-name}"
                                   "Oren?")
                     (dialog-left "Oren"
                                  "chains are honest. notices are not. but my knee is honest too, and it says i hold that chain four more winters at the most. i will not vote for a plan that needs me in it.")
                     :next "bellfall/table-say")

(dialog-choice-path "bellfall/table-say"
                    "the table waits. Toma and Oren have said their piece, and now the quiet is yours to fill or leave."
                    ("side with Toma: the bread is mercy"
                     :id "toma"
                     "Toma nods like a man who already knew. Oren says nothing, which from Oren is a whole speech, and pours you the last of the cider anyway."
                     :next "bellfall/drawer")
                    ("side with Oren: the chain is honest"
                     :id "oren"
                     "Oren straightens, vindicated and unhappy about it. Toma only says that honesty does not rise, but he says it kindly, and cuts you more bread."
                     :next "bellfall/drawer")
                    ("say the valley should need neither"
                     :id "neither"
                     "the table goes quiet the way it does when someone says the true thing too early. Mira lets the quiet finish, then reaches for the drawer."
                     :next "bellfall/drawer"))

(dialog-text "bellfall/drawer"
             "one evening Mira sets the till drawer on the long table. the blank notices wait in their stack. the practice slate. the pen. she puts her hands flat on the table and looks at you. the whole inn goes quiet."
             :next "bellfall/choice")

(dialog-pick "bellfall/choice"
             "the stack of blank notices sits between you. the kind line is not written yet."
             (dialog-option "post notice sixty-eight" "bellfall/post")
             (dialog-option "go up and take the post yourself" "bellfall/take")
             (dialog-option "let the hill come. hold the valley" "bellfall/hold"))

(dialog-on-enter "bellfall/post"
                 '(setf (jrpg-value "bellfall-choice") "posted"))

(dialog-text "bellfall/post"
             "you write it yourself. Mira watches your spacing, corrects the weight of WAITS, and lets the kind line stand exactly as you set it: BREAKFAST INCLUDED."
             :next "bellfall/post-s2")

(dialog-text "bellfall/post-s2"
             "the notice goes south with the spring carts, two valleys over, where they do not know the hand."
             :next "bellfall/post-spring")

(dialog-text "bellfall/post-spring"
             "in late spring a traveler comes in off the south road, dust to the knee, your notice folded in one hand, and asks if the tower business is open, and whether the breakfast part is true."
             :next "bellfall/post-answer")

(dialog-text "bellfall/post-answer"
             "it is always true, you say, from behind the till, in the place where Mira used to stand, and you take their name for the register in a hand you have been practicing for months, and entry sixty-eight opens under your pen."
             :next "bellfall/post-companion")

(dialog-text "bellfall/post-companion"
             "{jrpg-companion} watches from the stair, and later, drying plates, says only: you have her hand now. and you do. it is the kindest thing anyone has said to you. it is also the worst. they say it over the plates and keep drying."
             :next "bellfall/end")

(dialog-on-enter "bellfall/take"
                 '(setf (jrpg-value "bellfall-choice") "took"))

(dialog-text "bellfall/take"
             "you pack the chest the way it was packed for you: rope, bread, the second-best knife. {jrpg-companion} watches you do it and does not argue, which is how you know it is right, and worse, how you know it is yours."
             :next "bellfall/take-toll")

(dialog-text "bellfall/take-toll"
             "Pell signs you through the toll without charge and without words, and writes on the slate, after you pass, a line you do not see until years later in a story: GONE UP. SETTLED. BY TERMS."
             :next "bellfall/take-door")

(dialog-text "bellfall/take-door"
             "the tower door closes behind you with a sound like a ledger shutting, and the post is yours: the bell rope, the rack, the terms, the metering of the hill. the work is simple and endless, like an oven, like a chain."
             :next "bellfall/take-years")

(dialog-text "bellfall/take-years"
             "years on, a young visitor from Demhe climbs the hill with a notice in their pocket and Toma's loaf in their pack."
             :next "bellfall/take-years-2")

(dialog-text "bellfall/take-years-2"
             "you take a visitor sword down from the rack, and set it on the carpet between you, and hope, the way the King must have hoped, that this one asks about terms."
             :next "bellfall/end")

(dialog-on-enter "bellfall/hold"
                 '(setf (jrpg-value "bellfall-choice") "held"))

(dialog-text "bellfall/hold"
             "no more notices, you say. no more sixty-sevens. the hill can come, and the valley will hold it the way valleys held things before the towers: with chains, counts, and everybody's hands."
             :next "bellfall/hold-years")

(dialog-text "bellfall/hold-years"
             "the village votes by staying. the chain goes up at dusk now, and the children learn to count strokes the way they once learned the pencil words two counties over, and the mile marker moves a little each season, and is watched."
             :next "bellfall/hold-cost")

(dialog-text "bellfall/hold-cost"
             "it costs what holding costs: the orchard hill is grazed bare for sightlines, the fair shrinks to one stall, and Oren dies on the chain at a great age, upright, mid-count, and is buried with the spear, which the village agrees he would call a fair exchange."
             :next "bellfall/end")

(dialog-text "bellfall/end"
             "whatever Demhe chose, the supper bell still rings, ordinary as weather, and sleep, when it takes you, takes you all at once, with the deep bell of the high tower somewhere under it, patient, keeping its own count."
             :next "sys/reboot")
