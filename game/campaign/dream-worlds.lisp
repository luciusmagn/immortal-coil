(dialog-particles "alice/fall" :rising :fade-seconds 3.0)
(dialog-music "alice/fall" "audio/alice-glass-drone.mp3" :volume 0.25)

(dialog-text "alice/fall"
             "the left exit descends as a stairwell pretending to be a rabbit hole."
             :next "alice/table")

(dialog-text "alice/table"
             "at the bottom waits a table set for too many people. every cup is turned upside down except yours."
             :next "alice/choice")

(dialog-pick "alice/choice"
             "which impossible courtesy do you accept?"
             (dialog-option "drink from the right cup" "alice/cup")
             (dialog-option "answer the empty chair" "alice/chair")
             (dialog-option "follow the white thread" "alice/thread"))

(dialog-text "alice/cup"
             "the tea tastes like rainwater collected from a ceiling crack you remember."
             :next "alice/court")

(dialog-text "alice/chair"
             "the empty chair asks whether you are awake. it sounds offended by either answer."
             :next "alice/court")

(dialog-text "alice/thread"
             "the white thread runs under every plate and up your sleeve."
             :next "alice/court")

(dialog-say "alice/court"
            "the card judge"
            "state your name, your crime, and the size of the room you came from."
            :next "alice/unfinished")

(dialog-text "alice/unfinished"
             "the jury writes down the room before you describe it."
             :next "base/awake")


(dialog-particles "rogue/entrance" :rising :fade-seconds 2.5)
(dialog-music "rogue/entrance" "audio/rogue-cavern-drone.mp3" :volume 0.27)

(dialog-text "rogue/entrance"
             "the upper exit opens onto a dungeon floor drawn in hard white lines."
             :next "rogue/inventory")

(dialog-text "rogue/inventory"
             "you have a ration, a ring you cannot identify, and a memory of stairs going the wrong way."
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
             "the altar offers you a blessing in exchange for your map. it already knows you will accept later."
             :next "rogue/loot")

(dialog-pick "rogue/loot"
             "on the floor:"
             (dialog-option "read the scroll" "rogue/scroll")
             (dialog-option "wear the ring" "rogue/ring")
             (dialog-option "eat the ration" "rogue/ration"))

(dialog-text "rogue/scroll"
             "the scroll identifies itself as a scroll of identification. it refuses to elaborate."
             :next "rogue/unfinished")

(dialog-text "rogue/ring"
             "the ring makes the room forget you for one breath."
             :next "rogue/unfinished")

(dialog-text "rogue/ration"
             "the ration tastes like the breakfast you did not eat at the inn."
             :next "rogue/unfinished")

(dialog-text "rogue/unfinished"
             "somewhere below, a staircase waits with your name carved into the first step."
             :next "base/awake")
