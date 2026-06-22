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
             "you go down into a city that has thinned, the way a held note thins. the gas lamps are the same number and in the wrong order. one shopfront is still lit: an armourer's, a suit of mail white in the window, a stair behind it going up to a light."
             :next "jrpg/wilde-street")


;;; THE REPAIRER OF REPUTATIONS — Hawberk's, and the room above it

(dialog-minigame "jrpg/wilde-street"
                 "arrows or wasd move. reach the lit armourer's shop."
                 :game :jrpg-overworld
                 :success "jrpg/hawberk"
                 :failure "jrpg/hawberk"
                 :config (list :gen-width 32
                               :gen-height 16
                               :finish-glyph #\!
                               :store-prefix "kiy-wilde"
                               :encounter-target "jrpg/thief-combat"
                               :encounter-rate 9
                               :start-message "the thinned streets. arrows or wasd move."
                               :legend "+ lamp   ! the armourer's   $ coin   block"
                               :tile-messages
                               '((#\! . "the armourer's lit window, the mail white in it.")
                                 (#\. . "thin cobbles, fewer than there were."))))

(dialog-minigame "jrpg/thief-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/wilde-street"
                 :failure "jrpg/thief-down"
                 :config (list :enemy-name "THIEF"
                               :enemy-kind "ruffian"
                               :enemy-hp 13
                               :enemy-attack-min 3
                               :enemy-attack-max 5
                               :victory-xp 4
                               :victory-gold 7
                               :message "a thin hand goes for the clasp in your coat before you see the rest of him."))

(dialog-on-enter "jrpg/thief-down"
                 '(jrpg-heal 5))

(dialog-text "jrpg/thief-down"
             "he gets a coin and not the clasp, and is gone down an alley. the armourer's window is still lit ahead."
             :next "jrpg/wilde-street")

(dialog-conversation "jrpg/hawberk"
                     (dialog-left "Constance"
                                  "father is riveting and will not look up. you want the stair. everyone who wants the stair has your look.")
                     (dialog-right "{player-name}"
                                   "what look is that?")
                     (dialog-left "Constance"
                                  "like you have read something you cannot put down. go up, then. Mr. Wilde is expecting you. he is always expecting everyone.")
                     :next "jrpg/wilde")

(dialog-text "jrpg/wilde"
             "up the stair, a low room: a small scarred man in a chair too high for him, a savage cat curled in his lap, a ledger open on his knee, a locked cabinet behind. he repairs reputations, he says, makes names and unmakes them, for a fee. he has been expecting you, which he says of everyone, and means."
             :next "jrpg/wilde-questions")

(dialog-interrogation "jrpg/wilde-questions"
                      "the cat opens one eye. Mr. Wilde keeps a finger in the ledger, at a page he would like you to ask about."
                      (:next "jrpg/castaigne")
                      (:continue-label "the cabinet, then")
                      ("ask about the ledger of names"
                       :id "register"
                       :speaker "Mr. Wilde"
                       "every name in it has taken the Yellow Sign, which no living soul dares disregard. yours is here. it is here twice. the second time is dated after today, in a hand i would call yours if you had got round to writing it.")
                      ("ask about the locked cabinet"
                       :id "crown"
                       :speaker "Mr. Wilde"
                       "a crown. the diadem of the Last King, who hid Yhtill forever under the tatters. you may try it on; they all do. woe to the one crowned with the crown of the King in Yellow — though that has stopped nobody yet.")
                      ("ask who the King is"
                       :id "king"
                       :speaker "Mr. Wilde"
                       "the son of Hastur, who keeps the black stars over Carcosa and the cloudy depths of Demhe and the Lake of Hali. he was a man, the manuscript holds, before he was the answer to a question no one should ask. you have been asking it for some pages now."))

(dialog-text "jrpg/castaigne"
             "a man rises from a dark corner you had not searched. he gives his name as Hildred and his title as Rex, says the crown is promised to him and a rival claimant must be exiled or die. he has read further than you. he comes for the Sign with a clean razor and a writ already signed."
             :next "jrpg/castaigne-combat")

(dialog-minigame "jrpg/castaigne-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/after-castaigne"
                 :failure "jrpg/castaigne-down"
                 :config (list :enemy-name "HILDRED-REX"
                               :enemy-kind "ruffian"
                               :enemy-hp 26
                               :enemy-attack-min 4
                               :enemy-attack-max 8
                               :victory-xp 12
                               :victory-gold 8
                               :message "Hildred-Rex advances, crowning himself with both empty hands as he comes."))

(dialog-text "jrpg/after-castaigne"
             "Hildred sits down hard, the title gone out of him, and weeps that the cat has got Mr. Wilde. the cat has: the small scarred man bleeds from the throat in his high chair, the ledger fallen open at your name, twice. you go before the noise brings anyone. the cabinet you leave shut, this time."
             :next "jrpg/church")

(dialog-on-enter "jrpg/castaigne-down"
                 '(jrpg-heal 6))

(dialog-text "jrpg/castaigne-down"
             "he has your collar and the razor at it when the cat, for its own reasons, takes Mr. Wilde's throat instead, and Hildred forgets you entirely for the man who promised him a crown. you leave them to it. the ledger lies open at your name, twice."
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
