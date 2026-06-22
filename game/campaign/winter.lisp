;;; Wintering at the crossroads: the forest's second dark branch.
;;; Letting the bus go and staying. The store closes for the season,
;;; food appears on stumps, and the hill keeps its own. Entered from
;;; the bench at six in the morning; exits through the thaw.

(dialog-music "winter/doors" "audio/forest-lyria-drone.mp3" :volume 0.20)
(dialog-particles "winter/doors" :snow :fade-seconds 5.0)

(dialog-text "winter/doors"
             "you do not stand up. the bench holds you, and you hold the bench, and the idling engine counts off the seconds of the only decision out here that nobody will make for you."
             :next "winter/doors-2")

(dialog-text "winter/doors-2"
             "the driver looks at you in the long mirror, not unkindly, for the length of a breath you recognize. then the doors fold shut and the bus pulls out. the sound of it goes down the valley and is gone. the morning is very large."
             :next "winter/bench-after")

(dialog-text "winter/bench-after"
             "you sit on the bench in the porch light until the light clicks off on its own at full day. the difference between missing a bus and letting one go is nothing anyone can see from outside. you sit inside the difference and keep it."
             :next "winter/clerk-morning")

(dialog-say "winter/clerk-morning"
            "the clerk"
            "missed it, or let it go? there's a difference, and i can tell it at this range."
            :next "winter/clerk-morning-2")

(dialog-say "winter/clerk-morning-2"
            "you"
            "let it go."
            :next "winter/clerk-morning-3")

(dialog-say "winter/clerk-morning-3"
            "the clerk"
            "thought so. the ones who miss it pace. you sat like a man keeping an appointment. there's coffee, and the winter delivery wants stacking, and i don't pay wages, i pay lunch."
            :next "winter/stacking")

(dialog-text "winter/stacking"
             "you stack the winter delivery: flour in paper, salt in sacks, lamp oil, matches by the gross."
             :next "winter/stacking-2")

(dialog-text "winter/stacking-2"
             "the work is plain and your hands like it. you stop twice, both times for the same thought. your hands have liked work all over this county now. you have stopped asking them why."
             :next "winter/weeks")

(dialog-scene "winter/weeks"
              "the last weeks of the season."
              :next "winter/routine")

(dialog-text "winter/routine"
             "the days take a shape: sweep, stack, mind the counter when the clerk runs the post. you learn the regulars by their trucks. the valley people buy on account and talk weather."
             :next "winter/routine-2")

(dialog-text "winter/routine-2"
             "all of them know where you slept the first night, and none of them ask a second question, which out here is not incuriosity. it is custom, observed around something."
             :next "winter/salt")

(dialog-text "winter/salt"
             "one afternoon a man comes down off the hill for salt and nails."
             :next "winter/salt-2")

(dialog-text "winter/salt-2"
             "you know him for hill folk before the door finishes ringing: the coat, the unhurry, the way the room arranges itself around him without anyone moving."
             :next "winter/salt-3")

(dialog-text "winter/salt-3"
             "he pays in coins older than the till, and at the door he nods to you, only to you, the small private nod you give across a room of strangers to your own."
             :next "winter/salt-after")

(dialog-text "winter/salt-after"
             "the clerk watches the truck-less man walk back up the lane and then looks at you for a while, openly, doing arithmetic she does not share."
             :next "winter/salt-after-2")

(dialog-text "winter/salt-after-2"
             "that evening she counts the till twice and leaves the radio on past close, tuned to nothing in particular, the way you leave a light on in a house where something has been noticed."
             :next "winter/notice")

(dialog-text "winter/notice"
             "the notice goes up in the window the first week of real frost, hand-lettered, the letters worn from yearly use: CLOSED FOR THE SEASON. SPRING, MOST DAYS."
             :next "winter/notice-2")

(dialog-text "winter/notice-2"
             "the clerk winters with her sister in the valley, she tells you, always has, since the store was her father's. the plows stop thursday. after thursday the road is the hill's."
             :next "winter/offer")

(dialog-say "winter/offer"
            "the clerk"
            "so. thursday. you have three ways out of this crossroads and i have told all three of them to people standing where you're standing."
            :next "winter/offer-2")

(dialog-say "winter/offer-2"
            "you"
            "how many took them?"
            :next "winter/offer-3")

(dialog-say "winter/offer-3"
            "the clerk"
            "all of them took one. that's not the question you asked, and i noticed, and you noticed. sister's has a spare room. the last bus runs thursday noon. or somebody keeps my pipes from freezing, and i'd sooner it was somebody the hill already nods at."
            :next "winter/clerk-questions")

(dialog-interrogation "winter/clerk-questions"
                      "the clerk refills both cups without asking and lets the offer sit on the counter between you."
                      (:next "winter/thursday")
                      (:continue-label "let thursday come")
                      ("ask where the ones who left ended up"
                       :id "left"
                       :speaker "the clerk"
                       "the bus ones write the first winter and not the second. the sister ones i hear about at funerals, fondly. i don't grade the choices. i just keep the list.")
                      ("ask who else she has made this offer to"
                       :id "offer"
                       :speaker "the clerk"
                       "everyone the hill nodded at, and you'd be surprised who that is. some stayed a season, some a life. the pipes have never once cared which.")
                      ("ask what staying is really for"
                       :id "staying"
                       :speaker "the clerk"
                       "for the pipes, officially. for not being the only one who knows the store's quiet at four in the morning, honestly. i'm old, and the quiet got loud."))

(dialog-pick "winter/thursday"
             "thursday comes with the sky lowered to the treetops."
             (dialog-option "ride with her to the sister's" "winter/sister")
             (dialog-option "take the last bus out alone" "winter/last-bus")
             (dialog-option "stay and keep the store" "winter/keep-store"))

(dialog-on-enter "winter/sister"
                 '(setf (dialog-value "winter-thursday") "sister"))

(dialog-text "winter/sister"
             "your bag is in the truck bed by eight."
             :next "winter/sister-2")

(dialog-text "winter/sister-2"
             "at half past, the truck will not start, and the clerk works the choke twice and then goes still, listening to the engine the way you listen to a hall, and gets out, and lifts the hood. the points are packed with pine needles. packed."
             :next "winter/sister-3")

(dialog-text "winter/sister-3"
             "she stands looking at them with her breath going up white, and then she takes your bag out of the bed, gently, and sets it on the porch, and says, the hill answered. i'll send the bus by for you in spring."
             :next "winter/sister-4")

(dialog-text "winter/sister-4"
             "and she walks to the crossroads to flag the noon bus herself, because people with names the county still writes can leave, and you watch her go from the porch of the store that is now yours to keep."
             :next "winter/first-snow")

(dialog-on-enter "winter/last-bus"
                 '(setf (dialog-value "winter-thursday") "bus"))

(dialog-text "winter/last-bus"
             "the noon bus takes you up out of the valley toward the pass, and the snow starts at the second switchback, fat and businesslike."
             :next "winter/last-bus-2")

(dialog-text "winter/last-bus-2"
             "at the third switchback the driver stops, looks at the white coming down the cut, and turns the route around without a word, because the word would have been one you already know. he lets you down at the crossroads at four."
             :next "winter/last-bus-3")

(dialog-text "winter/last-bus-3"
             "road's closed, he says. you're winter folk now. he says it the way you read a list."
             :next "winter/first-snow")

(dialog-on-enter "winter/keep-store"
                 '(setf (dialog-value "winter-thursday") "kept"))

(dialog-text "winter/keep-store"
             "you say you will keep the store, and the clerk nods once, all business, and walks you through it: the stove's moods, the pump that wants priming, the ledger for anyone who comes needing on account."
             :next "winter/keep-store-2")

(dialog-text "winter/keep-store-2"
             "nobody will come, she says, and then, putting on her coat, in the voice of a woman leaving a fact where you will find it later: nobody with a truck."
             :next "winter/first-snow")

(dialog-scene "winter/first-snow"
              "first snow."
              :next "winter/store-alone")

(dialog-text "winter/store-alone"
             "the snow takes the valley in one night, roofs first, then roads, then the difference between them."
             :next "winter/store-alone-2")

(dialog-text "winter/store-alone-2"
             "the store holds its warmth in the back room where the stove is, and you move your living into that one room the way the books say lost men should, and the phone by the cooler gives you the dial tone for two more days and then gives you the winter."
             :next "winter/lines-down")

(dialog-text "winter/lines-down"
             "you try the operator once before the lines go, to say where you are to someone whose job is hearing it."
             :next "winter/lines-down-2")

(dialog-text "winter/lines-down-2"
             "she takes the store's name and your name, and reads them back, and says, lines come down every winter up there, hon. they go up in spring."
             :next "winter/lines-down-3")

(dialog-text "winter/lines-down-3"
             "it is the county's whole philosophy in one sentence, and after the click you stand holding the receiver, which smells of other people's hands, none of them recent."
             :next "winter/rationing")

(dialog-text "winter/rationing"
             "you keep the ledger out of habit, your own account on its own page: flour drawn, oil drawn, matches. the arithmetic is honest and gets quietly worse."
             :next "winter/rationing-2")

(dialog-text "winter/rationing-2"
             "the delivery was sized for a closed store, not a kept one, and by the fourth week you are eating once a day and writing it down, because writing it down is the difference between rationing and starving, according to you, at night, to the stove."
             :next "winter/first-plate")

(dialog-text "winter/first-plate"
             "the morning after the first day you eat nothing, there is a covered plate on the chopping stump in the yard."
             :next "winter/first-plate-2")

(dialog-text "winter/first-plate-2"
             "cloth over it, snow brushed off the stump first, the plate still warm enough to hold heat in its middle. boot prints lead away toward the tree line. bare footprints lead toward the stump."
             :next "winter/first-plate-3")

(dialog-text "winter/first-plate-3"
             "you stand in the doorway doing the older arithmetic, the one in fives, and then you are too hungry for arithmetic."
             :next "winter/plate-choice")

(dialog-pick "winter/plate-choice"
             "the plate sits on the stump. the yard is white and quiet."
             (dialog-option "eat what the hill sends" "winter/eat")
             (dialog-option "refuse it. leave it there" "winter/refuse")
             (dialog-option "eat, and leave something back" "winter/trade"))

(dialog-on-enter "winter/eat"
                 '(setf (dialog-value "winter-plates") "ate"))

(dialog-text "winter/eat"
             "you eat it on the back step, fast, with your fingers, and it is barley and carrot and exactly right, and you know the cooking, you knew it before the cloth was off."
             :next "winter/eat-2")

(dialog-text "winter/eat-2"
             "you eat all of it anyway and stand the plate back on the stump, washed, because your hands insisted on the washing, and your hands are keeping customs now that you have not agreed to."
             :next "winter/plates-on")

(dialog-on-enter "winter/refuse"
                 '(setf (dialog-value "winter-plates") "refused"))

(dialog-text "winter/refuse"
             "you leave the plate where it stands. it is there at noon, and at dusk, and gone in the morning, replaced, the new one warm."
             :next "winter/refuse-2")

(dialog-text "winter/refuse-2"
             "you last four days on flour and stubbornness while the plates come patient as weather, and on the fifth morning you eat, on the back step, fast, with your fingers. it is a kind of signing, and the hill does not gloat."
             :next "winter/refuse-2-s2")

(dialog-text "winter/refuse-2-s2"
             "the next plate is just a plate."
             :next "winter/plates-on")

(dialog-on-enter "winter/trade"
                 '(setf (dialog-value "winter-plates") "traded"))

(dialog-text "winter/trade"
             "you eat, and you leave the clerk's spare coffee tin on the stump, full, with the lid worked down tight against the damp."
             :next "winter/trade-2")

(dialog-text "winter/trade-2"
             "in the morning the tin is gone and the plate is doubled, two days' worth under one cloth, and you understand that you have not paid a debt, you have opened an account, and that out here an account is the most binding thing two parties can hold."
             :next "winter/plates-on")

(dialog-text "winter/plates-on"
             "the plates come every second day after that, steady as a route."
             :next "winter/plates-on-2")

(dialog-text "winter/plates-on-2"
             "you split wood for the stove and the work takes your thinking cleanly, and some evenings you catch yourself at the window with the lamp out, watching the stump the way you once watched a door. you are keeping it."
             :next "winter/midwinter")

(dialog-scene "winter/midwinter"
              "midwinter."
              :next "winter/lantern-night")

(dialog-text "winter/lantern-night"
             "in the deep of the season there is a night when the wind stops and the cold rings like struck iron."
             :next "winter/lantern-night-2")

(dialog-text "winter/lantern-night-2"
             "a lantern comes down out of the tree line, unhurried, and crosses the yard, and begins to go around the store, slowly, the way you walk around a thing you are minding."
             :next "winter/lantern-night-3")

(dialog-text "winter/lantern-night-3"
             "you put the lamp out and stand away from the windows with your back to the shelves."
             :next "winter/hold-still")

(dialog-minigame "winter/hold-still"
                 "space, w, or up arrow lets a breath out. stay quiet until the light moves on."
                 :game :forest-hide
                 :success "winter/lantern-passes"
                 :failure "winter/lantern-window"
                 :config '(:duration 8.0 :breath-rise 0.10))

(dialog-text "winter/lantern-passes"
             "the light makes its circuit twice and goes back up into the trees, and you breathe."
             :next "winter/lantern-passes-2")

(dialog-text "winter/lantern-passes-2"
             "in the morning the only prints in the yard go around the store in a clean ring, at exactly the distance a person keeps when they are checking on a building they care for."
             :next "winter/tag-post")

(dialog-text "winter/lantern-window"
             "halfway through its second circuit the light stops at the back window, your window, and stands there through eleven breaths, the long kind, while you hold the shelf edge and your chest burns."
             :next "winter/lantern-window-2")

(dialog-text "winter/lantern-window-2"
             "then it moves on, satisfied, the way you leave a room when you know where everything is, and you hear, very small through the glass, two notes, hummed low, going away."
             :next "winter/tag-post")

(dialog-text "winter/tag-post"
             "in the morning a paper tag is tied to the porch post, the string doubled against the wind. RETURN IF FOUND, and under it, in the round patient hand: {forest-tag-name}."
             :next "winter/tag-post-2")

(dialog-text "winter/tag-post-2"
             "and under the name, where the number should be, nothing. no number. there is no one to call about you anymore. the tag is not a request. it is a record being kept current."
             :next "winter/thaw")

(dialog-scene "winter/thaw"
              "thaw."
              :next "winter/melt")

(dialog-text "winter/melt"
             "the thaw comes loud, all dripping and small floods, the creek finding its old argument with the culvert. the road shows itself in black stripes."
             :next "winter/melt-2")

(dialog-text "winter/melt-2"
             "the plates stop with the snow, exactly with the snow, the way a thing ends when it is no longer needed."
             :next "winter/melt-2-s2")

(dialog-text "winter/melt-2-s2"
             "one morning you stand in the yard and the stump is just a stump. you miss it. you make yourself stand there until you have admitted that."
             :next "winter/clerk-back")

(dialog-say "winter/clerk-back"
            "the clerk"
            "pipes held. stove's going. ledger's kept. and you wintered."
            :next "winter/clerk-back-2")

(dialog-say "winter/clerk-back-2"
            "you"
            "i wintered."
            :next "winter/clerk-back-3")

(dialog-say "winter/clerk-back-3"
            "the clerk"
            "up here that's not a word for a season, you understand. it's a word for a person. there's maybe six of you in the county and the rest of them were born to it. sit down. i'll make the coffee. mine's better than yours, i can smell yours from here."
            :next "winter/spring-bus")

(dialog-text "winter/spring-bus"
             "the first bus of spring comes through on a tuesday."
             :next "winter/spring-bus-2")

(dialog-text "winter/spring-bus-2"
             "you are on the bench with your coffee when it slows for the stop, and you watch the driver read you through the glass, you, the bench, the kept store behind you, and the bus does not stop."
             :next "winter/spring-bus-3")

(dialog-text "winter/spring-bus-3"
             "it picks up and goes on down the valley. the doors did not even fold open. he has decided about you, the way he decides, and what he has decided is that you are not a passenger. you are a fixture of the route."
             :next "winter/spring-choice")

(dialog-pick "winter/spring-choice"
             "the clerk watches you watch the bus go, and says, gently, that there will be another one thursday. most days."
             (dialog-option "flag the thursday bus and go" "winter/go-out")
             (dialog-option "stay. the store, the valley, the year" "winter/stay-on")
             (dialog-option "walk up the hill road" "winter/walk-up"))

(dialog-on-enter "winter/go-out"
                 '(setf (dialog-value "winter-spring") "left"))

(dialog-text "winter/go-out"
             "thursday you stand in the road so there can be no deciding, and the bus stops, and the driver nods as if conceding a point in a long game. county line's free going out."
             :next "winter/go-out-2")

(dialog-text "winter/go-out-2"
             "you ride it standing your bag between your feet, and you step down at the pole in the wire-fence country, and the bus pulls away, and the relief you waited all winter to feel does not arrive."
             :next "winter/go-out-3")

(dialog-text "winter/go-out-3"
             "what arrives, at dusk, with the yard lights coming on one farm at a time, is the knowledge of exactly what the pines smell like after snow, carried somewhere you cannot return it."
             :next "winter/end")

(dialog-on-enter "winter/stay-on"
                 '(setf (dialog-value "winter-spring") "stayed"))

(dialog-text "winter/stay-on"
             "you stay. it is not a decision with a moment in it."
             :next "winter/stay-on-2")

(dialog-text "winter/stay-on-2"
             "the thursday bus comes and goes while you are priming the pump, and the one after while you are on the roof with the stove flashing, and by june the regulars have stopped being careful around you, which is the county's citizenship, granted without ceremony."
             :next "winter/stay-on-3")

(dialog-text "winter/stay-on-3"
             "some evenings, off the hill, very faint, two notes. you keep the lamp lit a while when you hear them. an account is open. you are good for it."
             :next "winter/end")

(dialog-on-enter "winter/walk-up"
                 '(setf (dialog-value "winter-spring") "hill"))

(dialog-text "winter/walk-up"
             "you go up the hill road in the early afternoon with the last plate's cloth washed, dried, and folded in your pocket, because an account is open and you mean to stand in the doorway of it."
             :next "winter/walk-up-2")

(dialog-text "winter/walk-up-2"
             "the pines close over the road the way a door closes, without hurry."
             :next "winter/walk-up-3")

(dialog-text "winter/walk-up-3"
             "by dusk you are above the house, and someone is on the porch, sweeping, and they stop, and shade their eyes toward your stretch of road, and wave, unhurried, the way you wave at family, and you lift your hand, and the cloth is in it."
             :next "winter/end")

(dialog-text "winter/end"
             "that night sleep takes you all at once, the deep kind, wherever you have laid yourself down. the last thing through is the sound of meltwater finding the culvert. that is the hill's country, talking in its sleep."
             :next "sys/reboot")
