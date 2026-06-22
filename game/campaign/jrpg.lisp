(dialog-particles "jrpg/inn" :rising :fade-seconds 2.0)
(dialog-music "jrpg/inn" "audio/jrpg-lyria-drone.mp3" :volume 0.24)
(dialog-sound "jrpg/keeper" "audio/jrpg/ledger.wav" :volume 0.24)
(dialog-sound "jrpg/errand-mira" "audio/jrpg/ledger.wav" :volume 0.28)
(dialog-sound "jrpg/errand-toma" "audio/jrpg/coin.wav" :volume 0.28)
(dialog-sound "jrpg/gate-leave" "audio/jrpg/gate-chain.wav" :volume 0.34)
(dialog-sound "jrpg/gate-bread" "audio/jrpg/tonic.wav" :volume 0.30)
(dialog-sound "jrpg/slime-arrives" "audio/jrpg/slime.wav" :volume 0.34)
(dialog-sound "jrpg/slime-retreat" "audio/jrpg/retreat.wav" :volume 0.28)
(dialog-sound "jrpg/tower-steward" "audio/jrpg/ledger.wav" :volume 0.22)
(dialog-sound "jrpg/tower-front" "audio/jrpg/gate-chain.wav" :volume 0.30)
(dialog-sound "jrpg/tower-wait" "audio/jrpg/bell.wav" :volume 0.30)
(dialog-sound "jrpg/demon-fight" "audio/jrpg/sword.wav" :volume 0.34)
(dialog-sound "jrpg/demon-chest" "audio/jrpg/coin.wav" :volume 0.28)
(dialog-sound "jrpg/chapter-end" "audio/jrpg/bell.wav" :volume 0.26)
(dialog-sound "jrpg/duel" "audio/jrpg/sword.wav" :volume 0.34)
(dialog-sound "jrpg/ledger-line" "audio/jrpg/ledger.wav" :volume 0.24)

(defun jrpg-combat-result-target ()
  (let ((result (jrpg-value "jrpg-last-battle" "victory")))
    (cond
      ((string= result "retreat")
       "jrpg/slime-retreat")
      (t
       "jrpg/road-clear"))))

(defun jrpg-shrine-combat-result-target ()
  (let ((result (jrpg-value "jrpg-last-battle" "victory")))
    (cond
      ((string= result "retreat")
       "jrpg/shrine-retreat")
      (t
       "jrpg/shrine-clear"))))

(defun jrpg-companion-road-target ()
  (let ((companion (jrpg-companion)))
    (cond
      ((string= companion "Niko")
       "jrpg/road-nio")
      ((string= companion "Bram")
       "jrpg/road-bram")
      (t
       "jrpg/road-lena"))))

(defun jrpg-shrine-companion-target ()
  (let ((companion (jrpg-companion)))
    (cond
      ((string= companion "Niko")
       "jrpg/shrine-nio")
      ((string= companion "Bram")
       "jrpg/shrine-bram")
      (t
       "jrpg/shrine-lena"))))


;;; Opening quest

(dialog-on-enter "jrpg/inn"
                 '(jrpg-init-state))

(dialog-text "jrpg/inn"
             "the lantern steadies. an inn room above the water: checked blanket, wooden chest, wash basin, and a summons nailed over the basin. outside, two suns go down behind the lake."
             :next "jrpg/notice")

(dialog-on-enter "jrpg/notice"
                 '(jrpg-mark-yellow-sign))

(dialog-text "jrpg/notice"
             " THE KING WAITS IN THE HIGH TOWER. END HIM, AND THE SONGS COME BACK. BREAKFAST INCLUDED. a small sign is inked in the corner, yellow, the only colour on the page."
             :next "jrpg/notice-number")

(dialog-text "jrpg/notice-number"
             "67"
             :next "jrpg/name")

(dialog-string "jrpg/name"
               "what name is written on the summons?"
               :response-key "player-name"
               :max-length 24
               :target "jrpg/keeper")

(dialog-conversation "jrpg/keeper"
                     (dialog-left "Mira"
                                  "you are late, {player-name}.")
                     (dialog-right "{player-name}"
                                   "the summons says breakfast included.")
                     (dialog-left "Mira"
                                  "after the tower. i already put your name in the ledger, under the others.")
                     :next "jrpg/common-room")

(dialog-text "jrpg/common-room"
             "downstairs, Mira writes in the ledger. Toma stacks bread by the cold stove. Oren stands by the door with a polished spear. the lake fog is at the sill."
             :next "jrpg/party")

(dialog-pick "jrpg/party"
             "before the gate, what do you make time for?"
             (dialog-option "help Lena tie down the pack" "jrpg/friend")
             (dialog-option "return Niko's charm book" "jrpg/mage")
             (dialog-option "ask Bram about the road" "jrpg/knight"))

(dialog-on-enter "jrpg/friend"
                 '(jrpg-set-companion "Lena" "childhood friend"))
(dialog-on-enter "jrpg/mage"
                 '(jrpg-set-companion "Niko" "quiet mage"))
(dialog-on-enter "jrpg/knight"
                 '(jrpg-set-companion "Bram" "knight"))

(dialog-conversation "jrpg/friend"
                     (dialog-left "Lena"
                                  "i packed rope, bread, and your second-best knife.")
                     (dialog-right "{player-name}"
                                   "what happened to the best knife?")
                     (dialog-left "Lena"
                                  "Toma used it to wedge the oven door.")
                     :next "jrpg/square")

(dialog-conversation "jrpg/mage"
                     (dialog-left "Niko"
                                  "i memorized two spells and half of a weather charm.")
                     (dialog-right "{player-name}"
                                   "which half?")
                     (dialog-left "Niko"
                                  "the half that knows when it is raining.")
                     :next "jrpg/square")

(dialog-conversation "jrpg/knight"
                     (dialog-left "Bram"
                                  "my helmet is still at the blacksmith.")
                     (dialog-right "{player-name}"
                                   "are you still a knight without it?")
                     (dialog-left "Bram"
                                  "yes. easier to hear orders.")
                     :next "jrpg/square")

(dialog-text "jrpg/square"
             "Demhe square has three stalls, a dry well, Mira's ledger table, and Oren's gate chain between two posts. the lake lies flat past the rooftops, under the low twin suns."
             :next "jrpg/village-errand")

(dialog-pick "jrpg/village-errand"
             "who do you speak to before the shore road?"
             (dialog-option "Mira at the ledger" "jrpg/errand-mira")
             (dialog-option "Toma at the oven" "jrpg/errand-toma")
             (dialog-option "Oren at the gate chain" "jrpg/errand-oren"))

(dialog-on-enter "jrpg/errand-mira"
                 '(setf (jrpg-value "jrpg-village-errand") "mira"))

(dialog-conversation "jrpg/errand-mira"
                     (dialog-left "Mira"
                                  "room four, one candle, one basin, one blanket. all on credit.")
                     (dialog-right "{player-name}"
                                   "for ending the King?")
                     (dialog-left "Mira"
                                  "for leaving before breakfast.")
                     :next "jrpg/mira-questions")

(dialog-interrogation "jrpg/mira-questions"
                      "Mira keeps the ledger open and the kettle near. there is time before the gate, if you want it."
                      (:next "jrpg/gate")
                      (:continue-label "head for the gate")
                      ("ask about the heroes who stayed here"
                       :id "heroes"
                       :speaker "Mira"
                       "they all order the same breakfast and leave before it comes. surprise me and eat it. nobody has, in a long run of mornings.")
                      ("ask what the tower is really like"
                       :id "tower"
                       :speaker "Mira"
                       "a desk, a lamp, and the King answering letters. he writes back, in yellow. that unsettles people more than a monster would.")
                      ("ask why the songs stopped"
                       :id "songs"
                       :speaker "Mira"
                       "since his sign started reaching the strand, nobody finishes a tune. it dies in the throat by the third line. you stop noticing, which is the part i mind."))

(dialog-on-enter "jrpg/errand-toma"
                 '(setf (jrpg-value "jrpg-village-errand") "toma"))

(dialog-on-enter "jrpg/errand-toma"
                 '(jrpg-adjust-number "jrpg-gold" -2))

(dialog-on-enter "jrpg/errand-toma"
                 '(jrpg-adjust-number "jrpg-potions" 1))

(dialog-conversation "jrpg/errand-toma"
                     (dialog-left "Toma"
                                  "two gold for the travel loaf. it comes with a corked tonic.")
                     (dialog-right "{player-name}"
                                   "that is expensive bread.")
                     (dialog-left "Toma"
                                  "it has to survive the bridge.")
                     :next "jrpg/gate")

(dialog-on-enter "jrpg/errand-oren"
                 '(setf (jrpg-value "jrpg-village-errand") "oren"))

(dialog-conversation "jrpg/errand-oren"
                     (dialog-left "Oren"
                                  "shore road to the bridge. bridge to the mile marker. mile marker to the tower.")
                     (dialog-right "{jrpg-companion}"
                                   "and tatters?")
                     (dialog-left "Oren"
                                  "six last week. i counted them on the toll board.")
                     :next "jrpg/gate")


;;; Village gate hooks

(dialog-pick "jrpg/gate"
             "at Demhe's lake gate, Oren holds the chain while {jrpg-companion} checks the pack."
             (dialog-option "cross the bridge" "jrpg/gate-leave")
             (dialog-option "buy Toma's travel loaf" "jrpg/gate-bread"
                            :unless '(string= (jrpg-value "jrpg-village-errand")
                                               "toma"))
             (dialog-option "ask Oren about tatters" "jrpg/gate-guard"))

(dialog-on-enter "jrpg/gate-leave"
                 '(setf (jrpg-value "jrpg-gate-choice") "leave"))

(dialog-text "jrpg/gate-leave"
             "Oren lifts the chain from the right post. the bridge boards are dry, patched, and narrow."
             :next "jrpg/overworld")

(dialog-on-enter "jrpg/gate-bread"
                 '(setf (jrpg-value "jrpg-gate-choice") "bread"))

(dialog-on-enter "jrpg/gate-bread"
                 '(jrpg-adjust-number "jrpg-gold" -2))

(dialog-on-enter "jrpg/gate-bread"
                 '(jrpg-adjust-number "jrpg-potions" 1))

(dialog-text "jrpg/gate-bread"
             "Toma wraps the travel loaf in wax paper and ties a corked tonic beside it."
             :next "jrpg/overworld")

(dialog-on-enter "jrpg/gate-guard"
                 '(setf (jrpg-value "jrpg-gate-choice") "guard"))

(dialog-text "jrpg/gate-guard"
             "Oren points at six chalk marks on the toll board. each mark is one tatter from last week."
             :next "jrpg/overworld")


;;; Overworld and first battle

(dialog-minigame "jrpg/overworld"
                 "arrows or wasd move. cross the overworld road."
                 :game :jrpg-overworld
                 :success "jrpg/road-mile-marker"
                 :failure "jrpg/road-mile-marker"
                 :config (list :gen-width 42
                               :gen-height 22
                               :finish-glyph #\!
                               :waypoints '(#\R #\T)
                               :store-prefix "jrpg-overworld"
                               :start-message "the country opens out past the bridge. arrows or wasd move."
                               :legend "+ sign  T tower  \" mile marker  $ coin  o tonic  ^~ block"
                               :tile-messages
                               '((#\R . "a road sign points the way to the high tower.")
                                 (#\T . "the high tower stands far off the road.")
                                 (#\! . "the mile marker reads DEMHE 1, HIGH TOWER 3.")
                                 (#\. . "the road runs bright and open."))))

(dialog-text "jrpg/road-mile-marker"
             "past the bridge, a mile marker reads DEMHE 1, HIGH TOWER 3. thread tracks shine in the ditch mud."
             :next #'jrpg-companion-road-target)

(dialog-conversation "jrpg/road-lena"
                     (dialog-left "Lena"
                                  "keep left of the ditch. you stepped in it every spring.")
                     (dialog-right "{player-name}"
                                   "i remember.")
                     (dialog-left "Lena"
                                  "you remember after i tell you.")
                     :next "jrpg/slime-arrives")

(dialog-conversation "jrpg/road-nio"
                     (dialog-left "Niko"
                                  "the weather charm says the mud is recent.")
                     (dialog-right "{player-name}"
                                   "the half that knows when it is raining?")
                     (dialog-left "Niko"
                                  "also the half that knows when it stopped.")
                     :next "jrpg/slime-arrives")

(dialog-conversation "jrpg/road-bram"
                     (dialog-left "Bram"
                                  "if the tatter springs, stand behind me.")
                     (dialog-right "{player-name}"
                                   "without the helmet?")
                     (dialog-left "Bram"
                                  "especially without the helmet. i can duck.")
                     :next "jrpg/slime-arrives")

(dialog-text "jrpg/slime-arrives"
             "the reeds by the lake-stone stir. a wad of yellow rag hauls itself onto the road, blind and blunt, and blocks the way up. a tatter, the town would say, scraped off the King's coat and gone feral."
             :next "jrpg/slime-combat")

(dialog-minigame "jrpg/slime-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success #'jrpg-combat-result-target
                 :failure "jrpg/slime-defeat"
                 :config (list :enemy-name "TATTER"
                               :enemy-kind "tatter"
                               :message "the tatter humps closer, trailing loose yellow thread."))

(dialog-text "jrpg/slime-retreat"
             "you return to the mile marker. DEMHE 1 is carved deeper than HIGH TOWER 3."
             :next "jrpg/road-rest")

(dialog-on-enter "jrpg/slime-defeat"
                 '(jrpg-heal 9))

(dialog-text "jrpg/slime-defeat"
             "you wake beside the ditch. {jrpg-companion} has one hand on your shoulder and mud on both knees."
             :next "jrpg/road-rest")

(dialog-on-enter "jrpg/road-clear"
                 '(jrpg-grant-item "jrpg-play-scraps"))

(dialog-conversation "jrpg/road-clear"
                     (dialog-left "{jrpg-companion}"
                                  "one tatter. six coins. and a scrap of yellow writing, caught in the thread.")
                     (dialog-right "{player-name}"
                                   "is that good?")
                     (dialog-left "{jrpg-companion}"
                                  "for a first mile, yes. keep the scrap. everyone up this road collects them.")
                     :next "jrpg/road-rest")

(dialog-text "jrpg/road-rest"
             "the shore road runs between low pines for another mile. a cart track breaks off toward a white roadside shrine, while the main road keeps climbing toward the tower hill."
             :next "jrpg/road-rest-choice")

(dialog-pick "jrpg/road-rest-choice"
             "at the cart-track fork, what do you do?"
             (dialog-option "check the roadside shrine" "jrpg/shrine-track")
             (dialog-option "split the travel loaf" "jrpg/shrine-lunch")
             (dialog-option "keep to the tower road" "jrpg/tower-road"))

(dialog-on-enter "jrpg/shrine-track"
                 '(setf (jrpg-value "jrpg-road-detour") "shrine"))

(dialog-text "jrpg/shrine-track"
             "the cart track is narrow but used: wheel ruts, pine needles, and a line of white stones set too regularly to be accidental."
             :next "jrpg/shrine-overworld")

(dialog-minigame "jrpg/shrine-overworld"
                 "arrows or wasd move. follow the cart track to the shrine."
                 :game :jrpg-overworld
                 :success "jrpg/shrine-arrival"
                 :failure "jrpg/shrine-arrival"
                 :config (list :gen-width 38
                               :gen-height 20
                               :finish-glyph #\S
                               :waypoints '(#\B #\R)
                               :store-prefix "jrpg-shrine-road"
                               :start-message "the cart track leaves the main road by the sign."
                               :legend "= bridge  + sign  S shrine  $ coin  o tonic  ^~ block"
                               :tile-messages
                               '((#\B . "the bridge is now a white line behind you.")
                                 (#\R . "the road sign has a small shrine mark cut into its post.")
                                 (#\S . "the shrine stones are cold even in sun.")
                                 (#\. . "the cart track crunches under your boots."))))

(dialog-text "jrpg/shrine-arrival"
             "the shrine is a square shelf of white stone under two pines. someone has left three copper bits, a cracked cup, and a strip of wax paper from Toma's oven."
             :next "jrpg/shrine-slime")

(dialog-text "jrpg/shrine-slime"
             "the wet grass beside the shelf gathers itself into a reed-dark thing. it has pine needles stuck all through it and one copper bit showing near the surface."
             :next "jrpg/shrine-slime-combat")

(dialog-minigame "jrpg/shrine-slime-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success #'jrpg-shrine-combat-result-target
                 :failure "jrpg/shrine-limp"
                 :config (list :enemy-name "REED-DROWNED"
                               :enemy-kind "drowned"
                               :enemy-hp 18
                               :enemy-attack-min 4
                               :enemy-attack-max 7
                               :victory-xp 5
                               :victory-gold 4
                               :message "the reed-thing slides from under the shrine shelf, dripping."))

(dialog-text "jrpg/shrine-clear"
             "the reed-thing comes apart into clean water, pine needles, and the copper bit. {jrpg-companion} rinses the coin in the cracked cup before giving it to the shelf."
             :next #'jrpg-shrine-companion-target)

(dialog-text "jrpg/shrine-retreat"
             "you back out to the cart track. the reed-thing stays by the shelf, slow and satisfied, as if the offering box is its proper work."
             :next #'jrpg-shrine-companion-target)

(dialog-on-enter "jrpg/shrine-limp"
                 '(jrpg-heal 7))

(dialog-text "jrpg/shrine-limp"
             "you wake sitting against one of the pines. the shrine shelf is damp, the copper bits are gone, and {jrpg-companion} has put the cracked cup upright again."
             :next #'jrpg-shrine-companion-target)

(dialog-on-enter "jrpg/shrine-lunch"
                 '(setf (jrpg-value "jrpg-road-detour") "lunch")
                 '(jrpg-heal 4))

(dialog-text "jrpg/shrine-lunch"
             "you sit on a warm stone by the fork and split the travel loaf. crumbs fall into the cart rut, and ants find them with a discipline that would shame soldiers."
             :next #'jrpg-shrine-companion-target)

(dialog-conversation "jrpg/shrine-lena"
                     (dialog-left "Lena"
                                  "we came this way once to cut pine boughs for midsummer.")
                     (dialog-right "{player-name}"
                                   "did we leave an offering?")
                     (dialog-left "Lena"
                                  "your best knife. not on purpose. Toma found it in a loaf pan two days later and blamed me for teaching you religion.")
                     :next "jrpg/tower-road")

(dialog-conversation "jrpg/shrine-nio"
                     (dialog-left "Niko"
                                  "the charm book calls this a wayside shelf. not a shrine. shrines have names.")
                     (dialog-right "{player-name}"
                                   "does that matter?")
                     (dialog-left "Niko"
                                  "to the book, yes. to the cup and copper, apparently no.")
                     :next "jrpg/tower-road")

(dialog-conversation "jrpg/shrine-bram"
                     (dialog-left "Bram"
                                  "my helmet was hung here last winter. i made an offering for courage and forgot what i offered.")
                     (dialog-right "{player-name}"
                                   "was the offering the helmet?")
                     (dialog-left "Bram"
                                  "that is what Oren says. Oren is not a priest, but he is often nearby when i am stupid.")
                     :next "jrpg/tower-road")

(dialog-text "jrpg/tower-road"
             "by late afternoon, the high tower rises from a bare hill. a small toll hut stands beside the front path."
             :next "jrpg/hill-overworld")

(dialog-minigame "jrpg/hill-overworld"
                 "arrows or wasd move. follow the hill road to the tower."
                 :game :jrpg-overworld
                 :success "jrpg/tower-hill-arrival"
                 :failure "jrpg/tower-hill-arrival"
                 :config (list :gen-width 40
                               :gen-height 24
                               :finish-glyph #\T
                               :waypoints '(#\R)
                               :store-prefix "jrpg-tower-hill"
                               :start-message "the bridge is behind you. the hill road bends upward."
                               :legend "+ road sign  T tower  $ coin  o tonic  ^~ block"
                               :tile-messages
                               '((#\R . "the road sign says HIGH TOWER, NO WAGONS.")
                                 (#\T . "the tower path ends at Pell's toll hut.")
                                 (#\! . "the rough grass twitches at your boots.")
                                 (#\. . "the hill road is pale with dust."))))

(dialog-text "jrpg/tower-hill-arrival"
             "the last switchback ends at the toll hut. the tower door is still higher up, behind Pell's barrel, ledger slate, and handbell."
             :next "jrpg/tower-steward")

(dialog-conversation "jrpg/tower-steward"
                     (dialog-left "Pell"
                                  "name and village.")
                     (dialog-right "{player-name}"
                                   "{player-name}, from Demhe.")
                     (dialog-left "Pell"
                                  "front door is honest, side stair is faster, morning bell is safer.")
                     :next "jrpg/pell-questions")

(dialog-interrogation "jrpg/pell-questions"
                      "Pell keeps the slate open while the hill wind moves dust across the path."
                      (:next "jrpg/tower-choice")
                      (:continue-label "choose an approach")
                      (:require-all t)
                      ("ask about the front door"
                       :id "front-door"
                       :speaker "Pell"
                       "front door means he sees you coming and you see him seeing you. some people prefer that. some people need it.")
                      ("ask about the side stair"
                       :id "side-stair"
                       :speaker "Pell"
                       "side stair is narrow, clean, and nobody writes songs about it. mind the loose fourth step from the top.")
                      ("ask about the morning bell"
                       :id "morning-bell"
                       :speaker "Pell"
                       "morning bell is for people who want a night's sleep before deciding they are brave. i ring it either way."))


;;; Tower approach

(dialog-pick "jrpg/tower-choice"
             "how do you approach the tower?"
             (dialog-option "sign Pell's slate" "jrpg/tower-front")
             (dialog-option "take the side stair" "jrpg/tower-side")
             (dialog-option "wait for morning bell" "jrpg/tower-wait"))

(dialog-on-enter "jrpg/tower-front"
                 '(setf (jrpg-value "jrpg-tower-approach") "front"))

(dialog-text "jrpg/tower-front"
             "Pell writes your name on a slate and unlocks the front door with an iron key."
             :next "jrpg/demon-hall")

(dialog-on-enter "jrpg/tower-side"
                 '(setf (jrpg-value "jrpg-tower-approach") "side"))

(dialog-text "jrpg/tower-side"
             "the side stair runs behind the toll hut, past stacked lantern oil and three cracked spear shafts."
             :next "jrpg/demon-hall")

(dialog-on-enter "jrpg/tower-wait"
                 '(setf (jrpg-value "jrpg-tower-approach") "wait"))

(dialog-text "jrpg/tower-wait"
             "you sleep on the toll hut floor. at dawn, Pell rings a handbell and opens the front door."
             :next "jrpg/demon-hall")

(dialog-text "jrpg/demon-hall"
             "inside, a long carpet runs to a tall door. a brass plate reads W. HALE, KEEPER, the letters worn soft. a rack beside it holds three visitor swords and one mop."
             :next "carcosa/court")

(dialog-conversation "jrpg/demon-lord"
                     (dialog-left "the King"
                                  "{player-name} from Demhe. Mira's handwriting has improved.")
                     (dialog-right "{player-name}"
                                   "you are the King.")
                     (dialog-left "the King"
                                  "i answer her letters in yellow and she calls it a crown. sit. the lake takes a while to get used to.")
                     :next "jrpg/vane-questions")

(dialog-interrogation "jrpg/vane-questions"
                      "the King waits by the sword rack in a yellow coat gone to tatters. he wears no mask."
                      (:next "jrpg/demon-choice")
                      (:continue-label "decide what to do")
                      (:require-all t)
                      ("ask about the yellow sign"
                       :id "sign"
                       :speaker "the King"
                       "i send it to the ones whose story i mean to end kindly. yours came on the summons. you have been ended kindly for a while now, {player-name}, and not noticed.")
                      ("ask about the drift of masks"
                       :id "masks"
                       :speaker "the King"
                       "every petitioner unmasks before the throne. under the mask they find nothing left to threaten, and they set it down, and they stay. you may keep yours.")
                      ("ask about the lake"
                       :id "lake"
                       :speaker "the King"
                       "Hali. it never gives anything back. i crossed it more mornings than there are mornings, and it never once let me land where i meant to. then it landed me here, and made me this."))

(dialog-pick "jrpg/demon-choice"
             "what do you do?"
             (dialog-option "draw your sword" "jrpg/demon-fight")
             (dialog-option "ask about terms" "jrpg/demon-terms")
             (dialog-option "open the treasure chest" "jrpg/demon-chest"))

(dialog-on-enter "jrpg/demon-fight"
                 '(setf (jrpg-value "jrpg-demon-approach") "fight"))

(dialog-text "jrpg/demon-fight"
             "you draw your sword. {jrpg-companion} steps to your left and watches the King's hands."
             :next "jrpg/chapter-end")

(dialog-on-enter "jrpg/demon-terms"
                 '(setf (jrpg-value "jrpg-demon-approach") "terms"))

(dialog-text "jrpg/demon-terms"
             "the King names his terms: Demhe stops posting notices, and he stops collecting broken swords from the hill."
             :next "jrpg/chapter-end")

(dialog-on-enter "jrpg/demon-chest"
                 '(setf (jrpg-value "jrpg-demon-approach") "chest"))

(dialog-text "jrpg/demon-chest"
             "the chest contains one tonic, three coins, and a folded receipt from Toma's oven."
             :next "jrpg/chapter-end")

(dialog-text "jrpg/chapter-end"
             "Pell's handbell rings below. the King takes one visitor sword from the rack and sets it on the carpet between you."
             :next "jrpg/sword-choice")

(dialog-pick "jrpg/sword-choice"
             "the visitor sword lies on the carpet."
             (dialog-option "take it up" "jrpg/duel")
             (dialog-option "leave it where it lies" "jrpg/refuse")
             (dialog-option "ask about the broken swords" "jrpg/swords")
             (dialog-option "ask him to take the crown off" "carcosa/unmask"))

(dialog-on-enter "jrpg/duel"
                 '(setf (jrpg-value "jrpg-vane-answer") "duel"))

(dialog-text "jrpg/duel"
             "you take it up. the King sets his feet, and the first exchange knocks dust from the carpet. {jrpg-companion} counts the passes out loud."
             :next "jrpg/duel-end")

(dialog-conversation "jrpg/duel-end"
                     (dialog-left "the King"
                                  "good. Demhe sends better every year.")
                     (dialog-right "{player-name}"
                                   "is it over?")
                     (dialog-left "the King"
                                  "for this year. take the sword. it counts as a receipt.")
                     :next "jrpg/inn-return")

(dialog-on-enter "jrpg/refuse"
                 '(setf (jrpg-value "jrpg-vane-answer") "terms"))

(dialog-conversation "jrpg/refuse"
                     (dialog-left "the King"
                                  "then we talk. talking settles it too. it just takes longer than swords.")
                     (dialog-right "{player-name}"
                                   "Mira wants the notices to stop.")
                     (dialog-left "the King"
                                  "and i want the hill to stop growing. tell her we are agreed.")
                     :next "jrpg/inn-return")

(dialog-on-enter "jrpg/swords"
                 '(setf (jrpg-value "jrpg-vane-answer") "asked"))

(dialog-conversation "jrpg/swords"
                     (dialog-left "the King"
                                  "one for every visitor who took the sword up and lost. i mark the rack for each.")
                     (dialog-right "{player-name}"
                                   "how many marks?")
                     (dialog-left "the King"
                                  "count them on your way out. bring the number to Mira. she keeps the other ledger.")
                     :next "jrpg/inn-return")

(dialog-text "jrpg/inn-return"
             "the tower door closes behind you with a sound like a ledger shutting. from the toll hut, Pell signs you out on the slate and points down the hill: weather coming, and the bridge before it."
             :next "jrpg/road-home")

(dialog-text "jrpg/road-home"
             "the walk back runs ahead of the rain. Pell's bell is quiet behind you before the tower drops below the ridge."
             :next "jrpg/home-overworld")

(dialog-minigame "jrpg/home-overworld"
                 "arrows or wasd move. reach the bridge before the rain."
                 :game :jrpg-overworld
                 :success "jrpg/home-road-grass"
                 :failure "jrpg/home-road-grass"
                 :config (list :gen-width 44
                               :gen-height 22
                               :finish-glyph #\B
                               :waypoints '(#\T #\R #\V)
                               :store-prefix "jrpg-home-road"
                               :start-message "the tower is behind you. the bridge waits at the far side, and the rain is close."
                               :legend "V Demhe  = bridge  + sign  T tower  $ coin  o tonic"
                               :tile-messages
                               '((#\T . "the tower is behind you.")
                                 (#\R . "the road sign points back to Demhe.")
                                 (#\B . "the bridge boards are slick.")
                                 (#\V . "Demhe's gate lanterns burn ahead."))))

(dialog-text "jrpg/home-road-grass"
             "near the bridge, the ditch grass shakes again, and not with wind. {jrpg-companion} steps between you and the road sign."
             :next "jrpg/home-ambush")

(dialog-minigame "jrpg/home-ambush"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/home-clear"
                 :failure "jrpg/home-limp"
                 :config (list :enemy-kind "byakhee"
                               :enemy-name "BYAKHEE"
                               :enemy-hp 24
                               :enemy-attack-min 4
                               :enemy-attack-max 8
                               :victory-xp 9
                               :victory-gold 10
                               :message "something with wide wings drops out of the low cloud."))

(dialog-conversation "jrpg/home-clear"
                     (dialog-left "{jrpg-companion}"
                                  "you fight differently than this morning. slower. like you're counting something.")
                     (dialog-right "{player-name}"
                                   "why did you come with me, really?")
                     (dialog-left "{jrpg-companion}"
                                  "because everyone who goes up that hill comes back changed or doesn't come back. i wanted you to come back to something.")
                     :next "jrpg/bridge-home")

(dialog-conversation "jrpg/home-limp"
                     (dialog-left "{jrpg-companion}"
                                  "lean on me. it's not far and i'm not telling anyone.")
                     (dialog-right "{player-name}"
                                   "you've done this before.")
                     (dialog-left "{jrpg-companion}"
                                  "my father went up the hill once. i carried him back from this same ditch. walk now, talk never.")
                     :next "jrpg/bridge-home")

(dialog-text "jrpg/bridge-home"
             "the rain starts on the bridge boards. Oren has the gate chain down before you ask, and the chalk marks on the toll board have been wiped clean for the new week."
             :next "jrpg/oven-warm")

(defun jrpg-terms-target ()
  (let ((answer (jrpg-value "jrpg-vane-answer" "asked")))
    (cond
      ((string= answer "duel") "jrpg/terms-duel")
      ((string= answer "terms") "jrpg/terms-terms")
      (t "jrpg/terms-asked"))))

(dialog-text "jrpg/oven-warm"
             "Toma's oven is still warm. breakfast, one day late, is included. nobody asks about the tower at the table. that is how you know everyone wants to."
             :next #'jrpg-terms-target)

(dialog-conversation "jrpg/terms-duel"
                     (dialog-left "Mira"
                                  "a visitor sword. so it went to steel. and he gave it to you after, as a receipt.")
                     (dialog-right "{player-name}"
                                   "he said Demhe sends better every year.")
                     (dialog-left "Mira"
                                  "we send what we have. i'll enter the sword under deposits. it goes back up the hill with the next one, like always.")
                     :next "jrpg/evening-table")

(dialog-conversation "jrpg/terms-terms"
                     (dialog-left "Mira"
                                  "no more notices, and his hill stops growing. say it back to me exactly. the ledger doesn't take approximately.")
                     (dialog-right "{player-name}"
                                   "Demhe stops posting notices. he stops collecting broken swords.")
                     (dialog-left "Mira"
                                  "then it's entered, and signed, and the first quiet winter in nine years can start tomorrow. you'll want the room either way.")
                     :next "jrpg/evening-table")

(dialog-conversation "jrpg/terms-asked"
                     (dialog-left "Mira"
                                  "you counted the rack. out with it.")
                     (dialog-right "{player-name}"
                                   "he said you keep the other ledger.")
                     (dialog-left "Mira"
                                  "i keep the names, the years, and who they left behind. someone has to, and the tower only keeps the swords. sit down. you can read it after breakfast.")
                     :next "ledger/breakfast")

(dialog-text "jrpg/evening-table"
             "supper is barley and the travel loaf's cousin, eaten at the long table with the stove ticking down. Oren tells the tatter count wrong on purpose so Toma can correct him, which is how Demhe says it is glad you are back."
             :next "jrpg/ledger-line")

(dialog-text "jrpg/ledger-line"
             "Mira writes one line in the ledger and hands you the room four key. on the stair, {jrpg-companion} says good night the short way, which in Demhe is a whole speech."
             :next "jrpg/fair-word")

(dialog-conversation "jrpg/fair-word"
                     (dialog-left "Mira"
                                  "one more thing. tomorrow is midsummer. the fair goes up at dawn, and the ledger takes its one holiday.")
                     (dialog-right "{player-name}"
                                   "a fair, the day after the tower?")
                     (dialog-left "Mira"
                                  "especially the day after the tower. that is when fairs work.")
                     :next "jrpg/fair-choice")

(dialog-pick "jrpg/fair-choice"
             "the room four key is warm in your hand."
             (dialog-option "stay for the fair" "festival/stay")
             (dialog-option "take the road at first light" "jrpg/room-four"))

(dialog-text "jrpg/stair-night"
             "on the landing the inn holds its evening sounds the way a pot holds heat. the ledger closing. the stove settling. Oren's chain going up for the night, with its own small ceremony."
             :next "jrpg/room-four")

(defun jrpg-room-four-target ()
  (if (equal (jrpg-value "jrpg-vane-answer") "terms")
      "bellfall/asleep"
      "sys/reboot"))

(dialog-text "jrpg/room-four"
             "room four: one candle, one basin, one blanket, all on credit, all earned now. the quest notice is gone from above the basin, and the nail it hung on has been polished by years of notices. you are asleep before the candle is out."
             :next #'jrpg-room-four-target)
