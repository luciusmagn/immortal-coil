(dialog-particles "alice/fall" :rising :fade-seconds 3.0)
(dialog-music "alice/fall" "audio/alice-lyria-drone.mp3" :volume 0.24)

(dialog-text "alice/fall"
             "the left exit descends as a stairwell."
             :next "alice/table")

(dialog-text "alice/table"
             "at the bottom waits a table set for many people. every cup is turned upside down except one."
             :next "alice/choice")

(dialog-pick "alice/choice"
             "which courtesy do you accept?"
             (dialog-option "drink from the cup" "alice/cup")
             (dialog-option "answer the chair" "alice/chair")
             (dialog-option "follow the white thread" "alice/thread"))

(dialog-text "alice/cup"
             "the tea tastes like rainwater collected from a ceiling crack you remember."
             :next "alice/court")

(dialog-text "alice/chair"
             "the empty chair asks whether you are awake. it does not wait for your answer."
             :next "alice/court")

(dialog-text "alice/thread"
             "the white thread runs under every plate and up your sleeve."
             :next "alice/court")

(dialog-say "alice/court"
            "the card judge"
            "state your name, your crime, and the size of the room you came from."
            :next "alice/unfinished")

(dialog-text "alice/unfinished"
             "the jury writes down the room before you finish describing it."
             :next "base/awake")


(dialog-particles "rogue/entrance" :rising :fade-seconds 2.5)
(dialog-music "rogue/entrance" "audio/rogue-lyria-drone.mp3" :volume 0.26)

(dialog-text "rogue/entrance"
             "the upper exit opens onto a dungeon floor drawn in hard white lines."
             :next "rogue/inventory")

(dialog-text "rogue/inventory"
             "you have a ration, a ring you cannot identify, and no memory of which stairs brought you to this floor."
             :next "rogue/door")

(dialog-list "rogue/door"
             "choose a door."
             (dialog-option "north: damp stone" "rogue/north")
             (dialog-option "east: old bones" "rogue/east")
             (dialog-option "west: quiet altar" "rogue/west"))

(dialog-text "rogue/north"
             "the corridor smells of iron and wet rope. something invisible misses you by one square."
             :next "rogue/loot")

(dialog-text "rogue/east"
             "the bones are neatly stacked. someone has been sorting adventurers by height."
             :next "rogue/loot")

(dialog-text "rogue/west"
             "the altar offers a blessing in exchange for your map. older maps are already nailed beneath the candles."
             :next "rogue/loot")

(dialog-pick "rogue/loot"
             "on the floor:"
             (dialog-option "read the scroll" "rogue/scroll")
             (dialog-option "wear the ring" "rogue/ring")
             (dialog-option "eat the ration" "rogue/ration"))

(dialog-text "rogue/scroll"
             "the scroll is a scroll of identification. it names the ring: silver, old, and cursed."
             :next "rogue/unfinished")

(dialog-text "rogue/ring"
             "the ring fits. your hands fade from view, fingers first."
             :next "rogue/unfinished")

(dialog-text "rogue/ration"
             "the ration tastes like the breakfast you did not eat at the inn."
             :next "rogue/unfinished")

(dialog-text "rogue/unfinished"
             "at the corridor's end, a staircase leads down. your name is carved into the first step."
             :next "base/awake")
