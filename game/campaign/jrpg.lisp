;;; The King in Yellow path, Act I — the ordinary city.
;;;
;;; Rebuilt from Chambers, no JRPG skeleton kept. The player begins ALONE with
;;; the banned Play and the Yellow Sign already half on them, and walks the
;;; night city of the stories: the painter Scott and his model Tessie of THE
;;; YELLOW SIGN, the churchyard watchman, and the pursuing organist of IN THE
;;; COURT OF THE DRAGON, which is the crossing into Carcosa. JRPG mechanics are
;;; kept (overworld travel, turn battles against the human menace of the city,
;;; stats, items, composure); the village, the quest, and the demon lord are
;;; gone. Companions, if any, are picked up later and only if they fit.

(dialog-particles "jrpg/inn" :ash :fade-seconds 2.0)
(dialog-music "jrpg/inn" "audio/jrpg-lyria-drone.mp3" :volume 0.22)
(dialog-sound "jrpg/the-book" "audio/jrpg/ledger.wav" :volume 0.22)
(dialog-sound "jrpg/clasp" "audio/jrpg/coin.wav" :volume 0.26)
(dialog-sound "jrpg/watchman-combat" "audio/jrpg/sword.wav" :volume 0.32)

(dialog-on-enter "jrpg/inn"
                 '(jrpg-init-state))

(dialog-text "jrpg/inn"
             "a rented room you do not remember taking: one lamp, one window on a courtyard, one chair with your coat over it. on the table, a slim book bound in pale cloth. you are alone, and have been a while."
             :next "jrpg/the-book")

(dialog-on-enter "jrpg/the-book"
                 '(jrpg-mark-yellow-sign)
                 '(jrpg-grant-item "jrpg-play-scraps"))

(dialog-text "jrpg/the-book"
             "the book is THE KING IN YELLOW. you have read the first act, which is why it is still bright in you, and not the second, which waits like a held breath. inside the cover a small sign is stamped in yellow, the one colour in the room."
             :next "jrpg/name")

(dialog-string "jrpg/name"
               "a name is written on the flyleaf, in your own hand. what is it?"
               :response-key "player-name"
               :max-length 24
               :target "jrpg/window")

(dialog-text "jrpg/window"
             "{player-name}. you put the book in your coat. across the courtyard a studio skylight is lit; a man paints late and someone poses for him. in the churchyard below them a figure stands very still, its face turned up."
             :next "jrpg/street")


;;; The night city — travel and the ordinary menace of it (overworld + battle)

(dialog-text "jrpg/street"
             "the street is the ordinary kind of dangerous after dark. gas lamps far apart, a man asleep or dead in a doorway, footsteps that keep your pace and then do not."
             :next "jrpg/street-walk")

(dialog-minigame "jrpg/street-walk"
                 "arrows or wasd move. cross the square to the lit studio."
                 :game :jrpg-overworld
                 :success "jrpg/studio-door"
                 :failure "jrpg/studio-door"
                 :config (list :gen-width 34
                               :gen-height 18
                               :finish-glyph #\!
                               :waypoints '(#\R)
                               :store-prefix "kiy-street"
                               :encounter-target "jrpg/ruffian-combat"
                               :encounter-rate 8
                               :start-message "the square at night. arrows or wasd move."
                               :legend "+ lamp   ! studio stair   $ coin   block"
                               :tile-messages
                               '((#\R . "a gas lamp, guttering low.")
                                 (#\! . "the studio's stair door stands ajar.")
                                 (#\. . "wet cobbles, and your own echo."))))

(dialog-minigame "jrpg/ruffian-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/street-walk"
                 :failure "jrpg/ruffian-down"
                 :config (list :enemy-name "RUFFIAN"
                               :enemy-kind "ruffian"
                               :enemy-hp 15
                               :enemy-attack-min 3
                               :enemy-attack-max 6
                               :victory-xp 4
                               :victory-gold 6
                               :message "a man comes out of a doorway with his hands low and open."))

(dialog-on-enter "jrpg/ruffian-down"
                 '(jrpg-heal 6))

(dialog-text "jrpg/ruffian-down"
             "you come to against a wall with your pockets lighter and your head ringing. the studio light is still on across the square. you go on."
             :next "jrpg/street-walk")


;;; THE YELLOW SIGN — the studio

(dialog-particles "jrpg/studio" :motes :fade-seconds 3.0)

(dialog-text "jrpg/studio-door"
             "the stair smells of turpentine and cold stone. at the top, a studio: a man at an easel, a woman in a robe on the model stand, a stove gone out. the man is scraping at his own canvas with a knife."
             :next "jrpg/studio")

(dialog-conversation "jrpg/studio"
                     (dialog-left "the painter"
                                  "i can't hold the flesh tones. they go to mud the moment i look away. you are the third person tonight to come up that stair i did not hear.")
                     (dialog-right "{player-name}"
                                   "who were the other two?")
                     (dialog-left "the painter"
                                  "i don't know. that is the trouble. Scott, by the way. the model is Tessie. sit, if the chair is real.")
                     :next "jrpg/studio-questions")

(dialog-interrogation "jrpg/studio-questions"
                      "Scott wipes the knife. Tessie watches the window, not the churchyard, on purpose."
                      (:next "jrpg/clasp")
                      (:continue-label "let it lie")
                      ("ask about the canvas"
                       :id "canvas"
                       :speaker "Scott"
                       "it rots while i paint it. sound flesh into gangrene, in an afternoon. it began the day that watchman came to the churchyard and turned his face up at my window.")
                      ("ask Tessie about the watchman"
                       :id "watchman"
                       :speaker "Tessie"
                       "i dreamed a hearse went by slow, and he was driving it, soft and white like a grave-worm, and he turned and said: have you found the Yellow Sign. i found it in the street the next morning.")
                      ("ask about the book on the shelf"
                       :id "play"
                       :speaker "Scott"
                       "we read the first act last night, the three of us, and laughed. none of us opened the second. nobody who opens the second comes down to say what is in it."))

(dialog-on-enter "jrpg/clasp"
                 '(jrpg-grant-item "jrpg-mask-shard"))

(dialog-text "jrpg/clasp"
             "Tessie unpins an ornament from her robe and presses it on you: an onyx clasp, the gold worked into the Yellow Sign. it is colder than metal should be. she wants it out of the room. she does not say off her."
             :next "jrpg/read-choice")

(dialog-pick "jrpg/read-choice"
             "Scott's copy of the Play lies open at the end of the first act. the second waits."
             (dialog-option "read on into the second act" "jrpg/read-second")
             (dialog-option "close the book" "jrpg/watchman-comes"))

(dialog-on-enter "jrpg/read-second"
                 '(jrpg-spend-composure 3)
                 '(jrpg-grant-item "jrpg-second-act"))

(dialog-text "jrpg/read-second"
             "you read three lines of the second act before Scott takes the book from your hands, too late for you, in time for him. the room is the same room. it is not the same room. somewhere a tune you know stops in its third line."
             :next "jrpg/watchman-comes")

(dialog-text "jrpg/watchman-comes"
             "a step on the stair. then another, wet and heavy and in no hurry. the door, which Scott bolted, is opening. the smell that comes up is churchyard. Tessie does not scream; she used up screaming on the dream."
             :next "jrpg/watchman-combat")

(dialog-minigame "jrpg/watchman-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/after-watchman"
                 :failure "jrpg/watchman-takes"
                 :config (list :enemy-name "THE WATCHMAN"
                               :enemy-kind "watchman"
                               :enemy-hp 30
                               :enemy-attack-min 4
                               :enemy-attack-max 8
                               :victory-xp 12
                               :victory-gold 0
                               :message "the watchman comes in soft and white, one hand out for the clasp: have you found the Yellow Sign."))

(dialog-text "jrpg/after-watchman"
             "it comes apart like a thing long drowned and badly kept, and what is left on the boards is a coat and a smell. Scott is down with the Play shut under his hand. Tessie holds your sleeve and will not say what she has decided. you keep the clasp; you did not mean to."
             :next "jrpg/leave-studio")

(dialog-text "jrpg/watchman-takes"
             "it is stronger than a dead thing should be. when you can stand, the watchman is gone, and so is Tessie, and Scott will only say she went to find the Yellow Sign, in the voice of a man reading a line he did not write. you still have the clasp. it is warm now."
             :next "jrpg/leave-studio")

(dialog-text "jrpg/leave-studio"
             "you go down into a city that has thinned, the way a held note thins. the gas lamps are the same number and in the wrong order. ahead, where there was no church, a church stands with its door open and an organ going inside."
             :next "jrpg/church")


;;; IN THE COURT OF THE DRAGON — the pursuit and the crossing

(dialog-text "jrpg/church"
             "inside, the organ plays badly and on purpose. the organist watches you in a small mirror set over the keys, and keeps watching while his hands hold the wrong time. when you leave, he leaves. when you stop, the music stops, nearer."
             :next "jrpg/flight")

(dialog-minigame "jrpg/flight"
                 "arrows or wasd move. lose the organist in the streets."
                 :game :jrpg-overworld
                 :success "jrpg/threshold"
                 :failure "jrpg/threshold"
                 :config (list :gen-width 38
                               :gen-height 20
                               :finish-glyph #\!
                               :store-prefix "kiy-flight"
                               :start-message "the streets fold back on themselves. arrows or wasd move."
                               :legend "+ lamp   ! the way out   block"
                               :tile-messages
                               '((#\R . "the same corner you turned from.")
                                 (#\! . "an arch you did not walk toward, and are under.")
                                 (#\. . "your steps, and a half-step more."))))

(dialog-text "jrpg/threshold"
             "the streets run out. the organ is gone, or it is everywhere. above the last roofs the stars are wrong, black ones, and two suns are going down that never finish, and a lake you can smell from here. you have read enough of the second act to be expected."
             :next "carcosa/cross")
