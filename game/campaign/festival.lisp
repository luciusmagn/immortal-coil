;;; The midsummer fair: the jrpg path's bright branch. Game stalls,
;;; prizes, the lantern launch, and Vane down from the tower in a plain
;;; coat. Seeded: stall order, prizes, and several beats derive from
;;; festival-seed, rolled once into the store on entry, so a playthrough
;;; keeps its fair across save and load while the next one gets its own.

(defun festival-seed ()
  (dialog-value "festival-seed" 0))

(defun festival-roll (salt n)
  (let* ((x (+ (festival-seed) (* salt 374761393)))
         (x (mod (* (logxor x (ash x -15)) 2246822519) 4294967296))
         (x (mod (* (logxor x (ash x -13)) 3266489917) 4294967296))
         (x (logxor x (ash x -16))))
    (mod x n)))

(defparameter *festival-stalls*
  #(("ring" . "festival/ring")
    ("weight" . "festival/weight")
    ("cups" . "festival/cups")))

(defun festival-stall-order ()
  (aref #((0 1 2) (0 2 1) (1 0 2) (1 2 0) (2 0 1) (2 1 0))
        (festival-roll 1 6)))

(defun festival-next-stall ()
  (loop for idx in (festival-stall-order)
        for entry = (aref *festival-stalls* idx)
        unless (dialog-value (format nil "festival-done-~a" (car entry)))
          do (return (cdr entry))
        finally (return "festival/fortune-tent")))

(defun festival-ring-prize-target ()
  (aref #("festival/ring-duck" "festival/ring-star" "festival/ring-knife")
        (festival-roll 2 3)))

(defun festival-weight-target ()
  (if (zerop (festival-roll 5 2))
      "festival/weight-exact"
      "festival/weight-near"))

(defun festival-cups-target ()
  (aref #("festival/cups-won" "festival/cups-lost" "festival/cups-pell")
        (festival-roll 6 3)))

(defun festival-fortune-target ()
  (aref #("festival/fortune-road" "festival/fortune-bread"
          "festival/fortune-rain" "festival/fortune-key"
          "festival/fortune-late")
        (festival-roll 4 5)))

(defun festival-lantern-target ()
  (aref #("festival/lantern-mira" "festival/lantern-toma"
          "festival/lantern-oren" "festival/lantern-companion")
        (festival-roll 3 4)))

(dialog-music "festival/stay" "audio/jrpg-lyria-drone.mp3" :volume 0.26)

(dialog-on-enter "festival/stay"
                 '(unless (dialog-value "festival-seed")
                   (setf (dialog-value "festival-seed") (random 1000000))))

(dialog-text "festival/stay"
             "you tell Mira you will stay for the fair. she enters it in the ledger as room four, one day, weather permitting, and the weather, for once in nine years, looks like permitting."
             :next "festival/room-night")

(dialog-text "festival/room-night"
             "you sleep in room four with the window cracked, and half the night the square below murmurs with ladders, rope, and Toma arguing happily about where the long table goes."
             :next "festival/wake")

(dialog-scene "festival/wake"
              "midsummer morning."
              :next "festival/bunting")

(dialog-text "festival/bunting"
             "the square has grown bunting overnight, every color the village owns, which is four. the dry well has a plank over it and a pie on the plank. the gate chain is down and stays down."
             :next "festival/breakfast")

(dialog-conversation "festival/breakfast"
                     (dialog-left "Mira"
                                  "breakfast is included today for everyone, hero or not. the ledger takes a holiday. it is the only day i let it.")
                     (dialog-right "{player-name}"
                                   "what do you do without it?")
                     (dialog-left "Mira"
                                  "i remember things instead. it is less accurate and i recommend it.")
                     :next "festival/companion-morning")

(dialog-conversation "festival/companion-morning"
                     (dialog-left "{jrpg-companion}"
                                  "three stalls this year. Oren built a ring toss, Toma is doing the weight of the loaf, and Pell came down from the toll hut with the cup game.")
                     (dialog-right "{player-name}"
                                   "Pell left the toll hut?")
                     (dialog-left "{jrpg-companion}"
                                  "once a year. the slate says BACK FOR MIDSUMMER and the road forgives it.")
                     :next "festival/stall-walk")

(dialog-text "festival/stall-walk"
             "you walk into the fair the way you walked the north road, except everything on this road wants you to win."
             :next #'festival-next-stall)

;;; The ring toss

(dialog-on-enter "festival/ring"
                 '(setf (dialog-value "festival-done-ring") t))

(dialog-text "festival/ring"
             "Oren's ring toss is the gate chain's links, sawn and sanded, thrown at the old spear stuck point-down in a hay bale. he polishes each ring between players, out of habit."
             :next "festival/ring-try")

(dialog-conversation "festival/ring-try"
                     (dialog-left "Oren"
                                  "three rings, one copper. lean as much as you like. the spear has seen worse than leaning.")
                     (dialog-right "{player-name}"
                                   "what do i win?")
                     (dialog-left "Oren"
                                  "depends what the spear decides. it has been deciding all morning.")
                     :next "festival/ring-throw")

(dialog-text "festival/ring-throw"
             "the first ring goes wide. the second rings the spear and hops off, to a groan from the pie table. the third you throw the way you fought at the mile marker, slower, counting, and it settles on with a small wooden knock."
             :next #'festival-ring-prize-target)

(dialog-text "festival/ring-duck"
             "the spear decides on the wooden duck, carved by Oren over nine winters of gate duty. it has a chip on the beak he calls a beauty mark. {jrpg-companion} names it before you have left the stall, and the name is Sergeant."
             :next "festival/stall-next-1")

(dialog-text "festival/ring-star"
             "the spear decides on the tin star, cut from a tower notice's nail plate, polished to a shine. Oren pins it on you with two fingers and full ceremony, and for the rest of the day children salute you, and you salute back every time."
             :next "festival/stall-next-1")

(dialog-text "festival/ring-knife"
             "the spear decides on a knife, and you know it before Oren holds it out: your best knife, the one Toma used to wedge the oven door, rescued, reground, and rehandled in pale new wood. some prizes are returns. those are the good ones."
             :next "festival/stall-next-1")

(dialog-text "festival/stall-next-1"
             "Oren resets the rings for the next thrower and waves you on into the fair."
             :next #'festival-next-stall)

;;; The weight of the loaf

(dialog-on-enter "festival/weight"
                 '(setf (dialog-value "festival-done-weight") t))

(dialog-text "festival/weight"
             "Toma's stall is a single magnificent loaf on a scale hidden under a cloth, and a slate of guesses in village hands, some crossed out where marriages have produced second opinions."
             :next "festival/weight-guess")

(dialog-conversation "festival/weight-guess"
                     (dialog-left "Toma"
                                  "guess the weight, win the loaf. and before you ask: yes, it would survive the bridge. it would survive the tower.")
                     (dialog-right "{player-name}"
                                   "what did you put in it?")
                     (dialog-left "Toma"
                                  "everything the travel loaf taught me and three eggs i am not discussing.")
                     :next "festival/weight-answer")

(dialog-text "festival/weight-answer"
             "you heft the memory of every loaf this village has handed you, packs and gate stops and breakfasts included, and you write a number on the slate."
             :next #'festival-weight-target)

(dialog-text "festival/weight-exact"
             "exact. to the measure. Toma stares at the slate, then at you, then declares to the square that heroes are wasted on towers, and the loaf is yours, and it takes both arms."
             :next "festival/stall-next-2")

(dialog-text "festival/weight-near"
             "off by a hen's egg, which Toma rules the most honorable kind of wrong. the loaf goes to old Senna from the mill, who guessed it to the crumb, and Toma cuts you the heel anyway, for science, he says."
             :next "festival/stall-next-2")

(dialog-text "festival/stall-next-2"
             "the scale is reset, the cloth re-draped, and the next guesser is already arguing with their spouse."
             :next #'festival-next-stall)

;;; Pell's cup game

(dialog-on-enter "festival/cups"
                 '(setf (dialog-value "festival-done-cups") t))

(dialog-text "festival/cups"
             "Pell runs three cups and a barley grain on the toll hut's slate, laid flat across two barrels. the sign says ONE COPPER. HONEST GAME. the second line is doing a lot of work and everyone knows it."
             :next "festival/cups-watch")

(dialog-conversation "festival/cups-watch"
                     (dialog-left "Pell"
                                  "eyes on the middle cup. i am required by the fair committee to say that. i am the fair committee.")
                     (dialog-right "{player-name}"
                                   "is the grain even under there?")
                     (dialog-left "Pell"
                                  "that is the spirit. one copper.")
                     :next "festival/cups-play")

(dialog-text "festival/cups-play"
             "the cups go around the way the toll slate goes around: faster than they look, with one honest pause in the middle if you know to watch for it."
             :next #'festival-cups-target)

(dialog-text "festival/cups-won"
             "you call the left cup, and the grain is there, and Pell pays out a copper and a look of professional respect, which witnesses agree is the rarer coin."
             :next "festival/stall-next-3")

(dialog-text "festival/cups-lost"
             "you call the middle cup, and the grain is under the right, and Pell sweeps your copper into the fair fund jar with the solemnity of a toll being justly collected. worth it, says {jrpg-companion}, who called the middle too."
             :next "festival/stall-next-3")

(dialog-text "festival/cups-pell"
             "you call no cup. you call Pell's left sleeve."
             :next "festival/cups-pell-s2")

(dialog-text "festival/cups-pell-s2"
             "there is a silence, then Pell shakes the sleeve and the grain drops to the slate, and the whole square cheers, and Pell bows and pays double, beaming, like a man finally caught after years of honest signage."
             :next "festival/stall-next-3")

(dialog-text "festival/stall-next-3"
             "Pell racks the cups and calls the next mark, sorry, player, and the barrels do steady business all morning."
             :next #'festival-next-stall)

;;; The fortune tent and the quiet visitor

(dialog-text "festival/fortune-tent"
             "past the stalls stands a tent of borrowed quilts with a sign in Mira's hand: FORTUNES. ACCURACY NOT GUARANTEED ON HOLIDAYS."
             :next "festival/fortune-inside")

(dialog-text "festival/fortune-inside"
             "inside, it is Mira with a teapot and a deck of trade cards too worn to trade. she deals three face down, the way she rules a ledger line, and turns one."
             :next #'festival-fortune-target)

(dialog-text "festival/fortune-road"
             "the card is the road. you will go far, says Mira, and come back hungry. that is not fortune-telling, that is innkeeping, but the tea is good and the card looks like the north road in the right light."
             :next "festival/vane-arrives")

(dialog-text "festival/fortune-bread"
             "the card is the oven. warmth follows you, says Mira, which i could have told you for free, since you track flour everywhere when you have been at Toma's stall. drink your tea."
             :next "festival/vane-arrives")

(dialog-text "festival/fortune-rain"
             "the card is the rain. good for barley, bad for bunting, says Mira. when it comes, you will be under a roof you helped earn. she says it like an entry, and entries in this voice come true."
             :next "festival/vane-arrives")

(dialog-text "festival/fortune-key"
             "the card is the key. room four, says Mira, is yours as long as the nail above the basin stays empty, and i have decided the nail stays empty. that is the most binding fortune this tent does."
             :next "festival/vane-arrives")

(dialog-text "festival/fortune-late"
             "the card is the bell, upside down. you will be late, says Mira, to something that waits for you anyway. she taps the card twice and refuses to explain, on the grounds that it is a holiday."
             :next "festival/vane-arrives")

(dialog-text "festival/vane-arrives"
             "a little after noon, a tall man in a plain grey coat buys a travel loaf at Toma's stall, pays in old coins, and joins the ring toss line like anyone. it takes the square a moment. it is Vane."
             :next "festival/vane-toss")

(dialog-text "festival/vane-toss"
             "the demon lord of the north tower is terrible at ring toss. all three rings go wide, the last one into the pie. he pays for the pie. nobody makes a thing of it. that is Oakbarrow's whole genius. he stays for another round."
             :next "festival/vane-word")

(dialog-conversation "festival/vane-word"
                     (dialog-left "Vane"
                                  "your village is good at this. the tower does not have holidays. it has anniversaries. they are not the same thing.")
                     (dialog-right "{player-name}"
                                   "you could come down for the next one.")
                     (dialog-left "Vane"
                                  "i believe that is now in the terms. Mira entered it while i was losing to the pie.")
                     :next "festival/afternoon")

(dialog-text "festival/afternoon"
             "the afternoon goes long and golden: a barley-sack race Oren wins by regulation stride, a song Toma knows all nine verses of, and the pie, repaired, judged best in fair by a committee of Pell."
             :next "festival/lantern-prep")

;;; The lantern launch

(dialog-text "festival/lantern-prep"
             "at dusk the village writes wishes on paper lanterns. {jrpg-companion} guards yours from view with both hands, then admits to writing the same thing two years running."
             :next "festival/hedge-walk")

(dialog-text "festival/hedge-walk"
             "the launch is from the orchard hill, reached through the old hedge lanes, which the children have spent all week turning into a maze on purpose."
             :next "festival/hedge")

(dialog-minigame "festival/hedge"
                 "w/s or up/down move. a/d or left/right turn. find your way up through the hedge lanes."
                 :game :dream-maze
                 :success "festival/hedge-first"
                 :failure "festival/hedge-laughing")

(dialog-text "festival/hedge-first"
             "you come out at the top of the orchard with the first wave, breathless, in time to claim the good spot by the crooked oak before the rest of the village pours through."
             :next "festival/launch")

(dialog-text "festival/hedge-laughing"
             "you and {jrpg-companion} come out exactly where you went in, twice, to the open delight of the children who built it. the third try a small girl sells you the secret for a copper. it is money well spent."
             :next "festival/launch")

(dialog-text "festival/launch"
             "the lanterns go up together on a count Oren gives like a gate order. the whole sky over Oakbarrow fills with slow warm lights. nobody says anything for a while. there is nothing that needs improving."
             :next #'festival-lantern-target)

(dialog-text "festival/lantern-mira"
             "one lantern snags in the crooked oak, and it is Mira's, and she watches it burn safely out among the branches and declares it entered under fixed assets, and laughs at her own joke, which nobody has heard her do in nine years."
             :next "festival/embers")

(dialog-text "festival/lantern-toma"
             "one lantern snags in the crooked oak, and it is Toma's, and he claims loudly that he aimed for the tree, since wishes keep better in wood than in sky, and by the third telling the whole village agrees it was always done that way."
             :next "festival/embers")

(dialog-text "festival/lantern-oren"
             "one lantern snags in the crooked oak, and it is Oren's, and he stands at parade rest watching it like a sentry whose post just got smaller and warmer, and lets the children boost each other up to read his wish. it says NO SLIMES."
             :next "festival/embers")

(dialog-text "festival/lantern-companion"
             "one lantern snags in the crooked oak, and it is {jrpg-companion}'s. they go very quiet beside you. then they say, well. now you know where it lives. they do not explain. they take your arm for the walk down."
             :next "festival/embers")

(dialog-text "festival/embers"
             "the walk back down the hedge lanes is lit by lantern stubs and full of the slow traffic of people carrying sleeping children. Vane says good night at the gate, formally, to each person, and means every one."
             :next "festival/inn-night")

(dialog-text "festival/inn-night"
             "the inn's common room holds the day's last warmth: cider, the heel of the great loaf, Pell settling the fair fund jar with Mira, copper by copper, both of them rounding in the village's favor."
             :next "festival/room-end")

(dialog-text "festival/room-end"
             "room four. one candle, one basin, one blanket, and on the nail above the basin, where the notices used to hang, somebody has hung a small paper lantern, unlit, for next year. you are asleep before the candle is out."
             :next "base/awake")
