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

(defun jrpg-companion-road-target ()
  (let ((companion (jrpg-companion)))
    (cond
      ((string= companion "Nio")
       "jrpg/road-nio")
      ((string= companion "Bram")
       "jrpg/road-bram")
      (t
       "jrpg/road-lena"))))


;;; Opening quest

(dialog-on-enter "jrpg/inn"
                 '(jrpg-init-state))

(dialog-text "jrpg/inn"
             "the lantern steadies. you are in an inn room: checked blanket, wooden chest, wash basin, and a quest notice nailed above the basin."
             :next "jrpg/notice")

(dialog-text "jrpg/notice"
             " THE DEMON LORD WAITS IN THE NORTH TOWER. BREAKFAST INCLUDED."
             :next "jrpg/notice-number")

(dialog-text "jrpg/notice-number"
             "67"
             :next "jrpg/name")

(dialog-string "jrpg/name"
               "what name is written on the quest notice?"
               :response-key "player-name"
               :max-length 24
               :target "jrpg/keeper")

(dialog-conversation "jrpg/keeper"
                     (dialog-left "Mira"
                                  "you are late, {player-name}.")
                     (dialog-right "{player-name}"
                                   "the notice says breakfast included.")
                     (dialog-left "Mira"
                                  "after the tower. i already put your name in the ledger.")
                     :next "jrpg/common-room")

(dialog-text "jrpg/common-room"
             "downstairs, Mira writes in the ledger. Toma stacks bread by the stove. Oren stands by the door with a polished spear."
             :next "jrpg/party")

(dialog-pick "jrpg/party"
             "before the gate, what do you make time for?"
             (dialog-option "help Lena tie down the pack" "jrpg/friend")
             (dialog-option "return Nio's charm book" "jrpg/mage")
             (dialog-option "ask Bram about the road" "jrpg/knight"))

(dialog-on-enter "jrpg/friend"
                 '(jrpg-set-companion "Lena" "childhood friend"))
(dialog-on-enter "jrpg/mage"
                 '(jrpg-set-companion "Nio" "quiet mage"))
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
                     (dialog-left "Nio"
                                  "i memorized two spells and half of a weather charm.")
                     (dialog-right "{player-name}"
                                   "which half?")
                     (dialog-left "Nio"
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
             "Oakbarrow square has three stalls, a dry well, Mira's ledger table, and Oren's gate chain stretched between two posts."
             :next "jrpg/village-errand")

(dialog-pick "jrpg/village-errand"
             "who do you speak to before the north road?"
             (dialog-option "Mira at the ledger" "jrpg/errand-mira")
             (dialog-option "Toma at the oven" "jrpg/errand-toma")
             (dialog-option "Oren at the gate chain" "jrpg/errand-oren"))

(dialog-on-enter "jrpg/errand-mira"
                 '(setf (jrpg-value "jrpg-village-errand") "mira"))

(dialog-conversation "jrpg/errand-mira"
                     (dialog-left "Mira"
                                  "room four, one candle, one basin, one blanket. all on credit.")
                     (dialog-right "{player-name}"
                                   "for defeating Vane?")
                     (dialog-left "Mira"
                                  "for leaving before breakfast.")
                     :next "jrpg/gate")

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
                                  "north road to the bridge. bridge to the mile marker. mile marker to the tower.")
                     (dialog-right "{jrpg-companion}"
                                   "and slimes?")
                     (dialog-left "Oren"
                                  "six last week. i counted them on the toll board.")
                     :next "jrpg/gate")


;;; Village gate hooks

(dialog-pick "jrpg/gate"
             "at Oakbarrow's north gate, Oren holds the chain while {jrpg-companion} checks the pack."
             (dialog-option "cross the bridge" "jrpg/gate-leave")
             (dialog-option "buy Toma's travel loaf" "jrpg/gate-bread"
                            :unless '(string= (jrpg-value "jrpg-village-errand")
                                               "toma"))
             (dialog-option "ask Oren about slimes" "jrpg/gate-guard"))

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
             "Oren points at six chalk marks on the toll board. each mark is one slime from last week."
             :next "jrpg/overworld")


;;; Overworld and first battle

(dialog-minigame "jrpg/overworld"
                 "arrows or wasd move. cross the overworld road."
                 :game :jrpg-overworld
                 :success "jrpg/road-mile-marker"
                 :failure "jrpg/road-mile-marker")

(dialog-text "jrpg/road-mile-marker"
             "past the bridge, a mile marker reads OAKBARROW 1, NORTH TOWER 3. slime tracks shine in the ditch mud."
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
                     (dialog-left "Nio"
                                  "the weather charm says the mud is recent.")
                     (dialog-right "{player-name}"
                                   "the half that knows when it is raining?")
                     (dialog-left "Nio"
                                  "also the half that knows when it stopped.")
                     :next "jrpg/slime-arrives")

(dialog-conversation "jrpg/road-bram"
                     (dialog-left "Bram"
                                  "if the slime jumps, stand behind me.")
                     (dialog-right "{player-name}"
                                   "without the helmet?")
                     (dialog-left "Bram"
                                  "especially without the helmet. i can duck.")
                     :next "jrpg/slime-arrives")

(dialog-text "jrpg/slime-arrives"
             "the grass by the mile marker shakes. a round slime hops onto the road and blocks the tower path."
             :next "jrpg/slime-combat")

(dialog-minigame "jrpg/slime-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success #'jrpg-combat-result-target
                 :failure "jrpg/slime-defeat")

(dialog-text "jrpg/slime-retreat"
             "you return to the mile marker. OAKBARROW 1 is carved deeper than NORTH TOWER 3."
             :next "jrpg/tower-road")

(dialog-text "jrpg/slime-defeat"
             "you wake beside the ditch. {jrpg-companion} has one hand on your shoulder and mud on both knees."
             :next "jrpg/tower-road")

(dialog-conversation "jrpg/road-clear"
                     (dialog-left "{jrpg-companion}"
                                  "one slime. six coins. no bite marks.")
                     (dialog-right "{player-name}"
                                   "is that good?")
                     (dialog-left "{jrpg-companion}"
                                  "for a first mile, yes.")
                     :next "jrpg/tower-road")

(dialog-text "jrpg/tower-road"
             "by late afternoon, the North Tower rises from a bare hill. a small toll hut stands beside the front path."
             :next "jrpg/tower-steward")

(dialog-conversation "jrpg/tower-steward"
                     (dialog-left "Pell"
                                  "name and village.")
                     (dialog-right "{player-name}"
                                   "{player-name}, from Oakbarrow.")
                     (dialog-left "Pell"
                                  "front door is honest, side stair is faster, morning bell is safer.")
                     :next "jrpg/tower-choice")


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
             "inside, a long carpet leads to a large door. a rack beside it holds three visitor swords and one mop."
             :next "jrpg/demon-lord")

(dialog-conversation "jrpg/demon-lord"
                     (dialog-left "Vane"
                                  "{player-name} from Oakbarrow. Mira's handwriting has improved.")
                     (dialog-right "{player-name}"
                                   "you know Mira?")
                     (dialog-left "Vane"
                                  "everyone on the north road knows Mira.")
                     :next "jrpg/demon-choice")

(dialog-pick "jrpg/demon-choice"
             "what do you do?"
             (dialog-option "draw your sword" "jrpg/demon-fight")
             (dialog-option "ask about terms" "jrpg/demon-terms")
             (dialog-option "open the treasure chest" "jrpg/demon-chest"))

(dialog-on-enter "jrpg/demon-fight"
                 '(setf (jrpg-value "jrpg-demon-approach") "fight"))

(dialog-text "jrpg/demon-fight"
             "you draw your sword. {jrpg-companion} steps to your left and watches Vane's hands."
             :next "jrpg/chapter-end")

(dialog-on-enter "jrpg/demon-terms"
                 '(setf (jrpg-value "jrpg-demon-approach") "terms"))

(dialog-text "jrpg/demon-terms"
             "Vane names his terms: Oakbarrow stops posting notices, and he stops collecting broken swords from the hill."
             :next "jrpg/chapter-end")

(dialog-on-enter "jrpg/demon-chest"
                 '(setf (jrpg-value "jrpg-demon-approach") "chest"))

(dialog-text "jrpg/demon-chest"
             "the chest contains one tonic, three coins, and a folded receipt from Toma's oven."
             :next "jrpg/chapter-end")

(dialog-text "jrpg/chapter-end"
             "Pell's handbell rings below. Vane takes one visitor sword from the rack and sets it on the carpet between you."
             :next "jrpg/sword-choice")

(dialog-pick "jrpg/sword-choice"
             "the visitor sword lies on the carpet."
             (dialog-option "take it up" "jrpg/duel")
             (dialog-option "leave it where it lies" "jrpg/refuse")
             (dialog-option "ask about the broken swords" "jrpg/swords"))

(dialog-on-enter "jrpg/duel"
                 '(setf (jrpg-value "jrpg-vane-answer") "duel"))

(dialog-text "jrpg/duel"
             "you take it up. Vane sets his feet, and the first exchange knocks dust from the carpet. {jrpg-companion} counts the passes out loud."
             :next "jrpg/duel-end")

(dialog-conversation "jrpg/duel-end"
                     (dialog-left "Vane"
                                  "good. Oakbarrow sends better every year.")
                     (dialog-right "{player-name}"
                                   "is it over?")
                     (dialog-left "Vane"
                                  "for this year. take the sword. it counts as a receipt.")
                     :next "jrpg/inn-return")

(dialog-on-enter "jrpg/refuse"
                 '(setf (jrpg-value "jrpg-vane-answer") "terms"))

(dialog-conversation "jrpg/refuse"
                     (dialog-left "Vane"
                                  "then we talk. talking settles it too. it just takes longer than swords.")
                     (dialog-right "{player-name}"
                                   "Mira wants the notices to stop.")
                     (dialog-left "Vane"
                                  "and i want the hill to stop growing. tell her we are agreed.")
                     :next "jrpg/inn-return")

(dialog-on-enter "jrpg/swords"
                 '(setf (jrpg-value "jrpg-vane-answer") "asked"))

(dialog-conversation "jrpg/swords"
                     (dialog-left "Vane"
                                  "one for every visitor who took the sword up and lost. i mark the rack for each.")
                     (dialog-right "{player-name}"
                                   "how many marks?")
                     (dialog-left "Vane"
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
                 :config (list :start '(13 2)
                               :finish-glyphs '(#\B)
                               :store-prefix "jrpg-home-road"
                               :start-message "the tower is behind you. the bridge is west."
                               :legend "V Oakbarrow  = bridge  + sign  T tower  \" grass"
                               :tile-messages
                               '((#\T . "the tower is behind you.")
                                 (#\R . "the road sign points back to Oakbarrow.")
                                 (#\! . "the ditch grass shakes in the rain.")
                                 (#\B . "the bridge boards are slick.")
                                 (#\V . "Oakbarrow's gate lanterns burn ahead."))))

(dialog-text "jrpg/home-road-grass"
             "near the bridge, the ditch grass shakes again, and not with wind. {jrpg-companion} steps between you and the road sign."
             :next "jrpg/home-ambush")

(dialog-minigame "jrpg/home-ambush"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success "jrpg/home-clear"
                 :failure "jrpg/home-limp")

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
             "Toma's oven is still warm, and breakfast, one day late, is included. nobody asks about the tower at the table, which is how you know everyone wants to."
             :next #'jrpg-terms-target)

(dialog-conversation "jrpg/terms-duel"
                     (dialog-left "Mira"
                                  "a visitor sword. so it went to steel. and he gave it to you after, as a receipt.")
                     (dialog-right "{player-name}"
                                   "he said Oakbarrow sends better every year.")
                     (dialog-left "Mira"
                                  "we send what we have. i'll enter the sword under deposits. it goes back up the hill with the next one, like always.")
                     :next "jrpg/evening-table")

(dialog-conversation "jrpg/terms-terms"
                     (dialog-left "Mira"
                                  "no more notices, and his hill stops growing. say it back to me exactly. the ledger doesn't take approximately.")
                     (dialog-right "{player-name}"
                                   "Oakbarrow stops posting notices. he stops collecting broken swords.")
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
             "supper is barley and the travel loaf's cousin, eaten at the long table with the stove ticking down. Oren tells the slime count wrong on purpose so Toma can correct him, which is how Oakbarrow says it is glad you are back."
             :next "jrpg/ledger-line")

(dialog-text "jrpg/ledger-line"
             "Mira writes one line in the ledger and hands you the room four key. on the stair, {jrpg-companion} says good night the short way, which in Oakbarrow is a whole speech."
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
             "on the landing, the inn holds its evening sounds the way a pot holds heat: the ledger closing, the stove settling, Oren's chain going up for the night with its own small ceremony."
             :next "jrpg/room-four")

(defun jrpg-room-four-target ()
  (if (equal (jrpg-value "jrpg-vane-answer") "terms")
      "bellfall/asleep"
      "base/awake"))

(dialog-text "jrpg/room-four"
             "room four: one candle, one basin, one blanket, all on credit, all earned now. the quest notice is gone from above the basin, and the nail it hung on has been polished by years of notices. you are asleep before the candle is out."
             :next #'jrpg-room-four-target)
