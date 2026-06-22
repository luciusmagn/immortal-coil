;;; The King in Yellow path, Act II - Carcosa, unstuck in time.
;;;
;;; Entered from jrpg/threshold via carcosa/cross. The King is the ship-captain
;;; (the captain path) gone cosmically, irretrievably insane, his power over
;;; time swollen out of suffering into authority over moment and repetition.
;;; Time will not hold still near him; the throne room keeps re-happening; the
;;; captain-truth surfaces only in shards through the raving. The Yellow Sign on
;;; the player means he may be claimed. Dreadful, never cozy.

(dialog-particles "carcosa/cross" :motes :fade-seconds 5.0)
(dialog-particles "carcosa/causeway-intro" :motes :fade-seconds 3.0)
(dialog-particles "carcosa/court" :tatters :fade-seconds 3.0)
(dialog-particles "carcosa/king-hall" :tatters :fade-seconds 4.0)
(dialog-particles "carcosa/throne-choice" :tatters :fade-seconds 2.0)
(dialog-sound "carcosa/courtier-combat" "audio/jrpg/sword.wav" :volume 0.32)
(dialog-sound "carcosa/king-loop" "audio/jrpg/bell.wav" :volume 0.24)

;; Lyria's Carcosa drone bed, the lake of Hali, the crown's shimmer.
(dialog-music "carcosa/cross" "audio/jrpg-carcosa.mp3" :volume 0.20)
(dialog-sound "carcosa/causeway-intro" "audio/jrpg/lake.wav" :volume 0.30)
(dialog-sound "carcosa/take-crown" "audio/jrpg/crown.wav" :volume 0.40)

(dialog-minigame "carcosa/title"
                 ""
                 :game :title-card
                 :success "carcosa/cross"
                 :failure "carcosa/cross"
                 :config (list :title "CARCOSA"
                               :subtitle "where the black stars hang"
                               :seconds 2.8
                               :accent :crown))

(dialog-on-enter "carcosa/cross"
                 '(jrpg-complete-quest :cross)
                 '(jrpg-start-quest :king)
                 '(jrpg-add-item :hali-water)
                 '(jrpg-refresh-class))

(dialog-text "carcosa/cross"
             "you cross without a step in between. the night city is behind you. a still lake, two suns caught half under it, a smell of wet and old paper. the Yellow Sign in your coat is warm against you."
             :next "carcosa/causeway-intro")

(dialog-text "carcosa/causeway-intro"
             "a causeway runs from the shore into the mist, toward towers that do not agree on how far off they are. this is Hali. you are alone on the stone, which is more than the lake usually allows."
             :next "carcosa/causeway")

(dialog-minigame "carcosa/causeway"
                 "w/s or up/down move. a/d or left/right turn. cross the causeway through the mist."
                 :game :dream-maze
                 :success "carcosa/causeway-cross"
                 :failure "carcosa/causeway-cross"
                 :config (list :doors '(("=" "carcosa/causeway-cross"))
                               :size 1.0)
                 :outcomes (list "carcosa/causeway-cross"))

(dialog-text "carcosa/causeway-cross"
             "halfway over, a figure stands in the mist: a pale robe, a mask, both wet. one of the kept. it does not move aside, and it has the look of having stood here a long time."
             :next "carcosa/courtier-combat")

(dialog-minigame "carcosa/courtier-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "carcosa/court"
                 :failure "carcosa/courtier-limp"
                 :config (list :enemy-name "PALLID COURTIER"
                               :enemy-kind "courtier"
                               :enemy-hp 24
                               :enemy-attack-min 4
                               :enemy-attack-max 7
                               :victory-xp 10
                               :victory-gold 0
                               :message "the courtier lifts a hand to its mask, as if to offer it to you."))

(dialog-on-enter "carcosa/courtier-limp"
                 '(jrpg-heal 7))

(dialog-text "carcosa/courtier-limp"
             "you go down on the wet stone. when you rise, the courtier is gone, and its mask lies pale and empty where it stood. you step over it to the far shore."
             :next "carcosa/court")


;;; The court - Cassilda and Camilla, overheard, then asked

(dialog-text "carcosa/court"
             "before the high doors, two women keep a court of their own: one at a cold harp, one at a window on the lake, both dressed for a masque, though no music plays and no one has come."
             :next "carcosa/cassilda-song-1")

;; Cassilda's Song, verbatim from Chambers (public domain), sung at the harp.
(dialog-particles "carcosa/cassilda-song-1" :tatters :fade-seconds 3.0)
(dialog-particles "carcosa/cassilda-song-2" :tatters :fade-seconds 3.0)

(dialog-say "carcosa/cassilda-song-1"
            "Cassilda"
            "Along the shore the cloud waves break, the twin suns sink behind the lake, the shadows lengthen in Carcosa. Strange is the night where black stars rise, and strange moons circle through the skies, but stranger still is lost Carcosa."
            :next "carcosa/cassilda-song-2")

(dialog-say "carcosa/cassilda-song-2"
            "Cassilda"
            "Songs that the Hyades shall sing, where flap the tatters of the King, must die unheard in dim Carcosa. Song of my soul, my voice is dead; die thou, unsung, as tears unshed shall dry and die in lost Carcosa."
            :next "carcosa/court-overheard")

(dialog-on-enter "carcosa/court-overheard" '(jrpg-lean-class :mourner 1))

(dialog-conversation "carcosa/court-overheard"
                     (dialog-left "Cassilda"
                                  "you, sir, should unmask. we have all laid aside disguise but him.")
                     (dialog-right "Camilla"
                                   "i told him so, once. 'i wear no mask,' he said - and i saw that it was true. i have not been warm since.")
                     (dialog-left "Cassilda"
                                  "and still we dress for the masque. someone must, or it is only a lake and a man who will not stop talking.")
                     :next "carcosa/court-questions")

(dialog-interrogation "carcosa/court-questions"
                      "Cassilda sets the harp aside. Camilla does not turn from the lake."
                      (:next "carcosa/cloister")
                      (:continue-label "go to the high doors")
                      ("ask what the King was"
                       :id "before"
                       :speaker "Cassilda"
                       "a man, we think, once. he came across the lake with the crown already on him and no memory of the hand that set it there. now there is too much of him, spread through too much time, to be a man.")
                      ("ask why the room repeats"
                       :id "repeat"
                       :speaker "Camilla"
                       "he cannot stop arriving. the room near him forgets which moment is now. mind your own while you still have it.")
                      ("ask about the songs"
                       :id "songs"
                       :speaker "Cassilda"
                       "they die in the third line, everywhere his Sign reaches. it reached your city before you left it."))


;;; The keeper of kept things - a pallid vendor at the cloister, on the way in

(dialog-text "carcosa/cloister"
             "before the high doors a stall is kept: a pallid figure with kept things laid out - a flask of the lake, a mask with no face, a shred of the King's own yellow. he takes Hours, like everyone here."
             :next "carcosa/vendor")

(dialog-minigame "carcosa/vendor"
                 ""
                 :game :jrpg-shop
                 :success "carcosa/king-hall"
                 :failure "carcosa/king-hall"
                 :config (list :title "THE KEEPER OF KEPT THINGS"
                               :stock '((:hali-water 16)
                                        (:pallid-mask 70)
                                        (:tatter-shroud 92))))


;;; The King - insane, time-shattered; the captain-truth only in shards

(dialog-text "carcosa/king-hall"
             "the throne room keeps happening. you enter it more than once, from doors you did not use. on the throne, in tatters the colour of the Sign, the King. he wears no mask, or the mask is his face; your eyes will not decide which. he is talking, and has been, to no one, longer than the room has existed."
             :next "carcosa/king-1")

(dialog-say "carcosa/king-1"
            "the KING"
            "again. good. you always come in again. i kept the crossing this time, did you see, clean, the whole bridge, every man, watch --"
            :next "carcosa/king-2")

(dialog-say "carcosa/king-2"
            "the KING"
            "-- and again, and the count is wrong, the count is always wrong by everyone, and they thanked me, with the good chair and the soft pill and their hands, and the dark put me HERE, here is not the ship, HERE --"
            :next "carcosa/king-loop")

(dialog-text "carcosa/king-loop"
             "the room slips back a half second. he says the same three words. the two suns un-set and set. for a moment you are at the door again, entering. the Sign in your coat is very warm."
             :next "carcosa/king-named")

(dialog-on-enter "carcosa/king-named" '(jrpg-refresh-class))
(dialog-say "carcosa/king-named"
            "the KING"
            "i know what you are. {jrpg-class-title}. you have always been it; every choice only told you so. it will not save you here."
            :next "carcosa/king-3")

(dialog-on-enter "carcosa/king-3" '(jrpg-complete-quest :sign))
(dialog-say "carcosa/king-3"
            "the KING"
            "you have the Sign. i sent it. i keep the ones i send it to. sit in the good chair, the relieved chair, and i will show you the crossing, and you will keep it for me, and i will rest, i have not --"
            :next "carcosa/throne-choice")

(dialog-on-enter "carcosa/throne-choice" '(jrpg-complete-quest :king))

(dialog-pick "carcosa/throne-choice"
             "the crown sits on the throne beside him, yellow, the one colour. the room is about to reset again."
             ;; the one action only your inferred class can take
             (dialog-option "unmake his name, as you have unmade others" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :repairer)))
             (dialog-option "set down his true face, as you set down the rot" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :painter)))
             (dialog-option "read him the last line of his own Play" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :reader)))
             (dialog-option "put him down, the way you put down the watchman" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :watchman)))
             (dialog-option "stay with him, since someone must mourn" "carcosa/class-end"
                            :unless '(not (eq (jrpg-value "jrpg-class") :mourner)))
             (dialog-option "take the crown" "carcosa/take-crown")
             (dialog-option "refuse, and keep your own face" "carcosa/refuse-crown"
                            :unless '(not (jrpg-composed-p)))
             (dialog-option "ask him the year, to break the loop" "carcosa/ask-year"))

(dialog-on-enter "carcosa/class-end"
                 '(setf (jrpg-value "jrpg-vane-answer") "class"))

(dialog-text "carcosa/class-end"
             "you meet him the only way a {jrpg-class-title} can - and it is a thing the loop kept no line for. the suns hang. the room does not reset this time; it only lets you out, the Sign in your coat gone quiet at last."
             :next "carcosa/out")

(dialog-on-enter "carcosa/take-crown"
                 '(setf (jrpg-value "jrpg-vane-answer") "crown")
                 '(jrpg-add-item :crown))

(dialog-text "carcosa/take-crown"
             "you take it up. it weighs nothing, the way the tatters weigh nothing. the King stops mid-word, for the first time in longer than he could count, steps down, and is one of the pale kept, eased. the crossing is yours now. the count will be wrong. you will keep it anyway."
             :next "carcosa/king-end")

(dialog-text "carcosa/king-end"
             "the room stops resetting. far down the shore one tune gets past its third line and into a fourth, once, while you hold the thing that was stopping it."
             :next "sys/reboot")

(dialog-on-enter "carcosa/refuse-crown"
                 '(setf (jrpg-value "jrpg-vane-answer") "refused"))

(dialog-text "carcosa/refuse-crown"
             "you keep your own face and back to the door. nothing crowned stops anything leaving. the room resets and you are not in it; you come out somewhere with one sun and a straight street, changed, the Sign in your coat gone cold at last."
             :next "carcosa/out")

(dialog-on-enter "carcosa/ask-year"
                 '(jrpg-spend-composure 2)
                 '(setf (jrpg-value "jrpg-vane-answer") "year"))

(dialog-text "carcosa/ask-year"
             "you ask him the year. it is the one question the loop keeps no line for. he stops. the suns hang. for one held second the tatters are a coat, the throne is a chair, and the face under the mask is a tired man's, appalled - who says a number, and a name that is not the King's, before the room resets and takes it back. you keep it. you will not forget it."
             :next "carcosa/out")

(dialog-text "carcosa/out"
             "you wake. the book is shut, the lamp out, the courtyard grey. on the flyleaf, under your name, a second line has been added today in your own hand, which you do not remember writing. it reads only: again."
             :next "sys/reboot")
