(in-package #:immortal-coil)

(defconstant +jrpg-combat-left+ 210)
(defconstant +jrpg-combat-top+ 168)
(defconstant +jrpg-combat-width+ 860)
(defconstant +jrpg-combat-height+ 404)

(defparameter *jrpg-combat-sfx-volume* 0.42)

(defparameter *jrpg-slime-sprite*
  #(".......######......."
    ".....##########....."
    "...##############..."
    "..####********####.."
    ".####**######**####."
    ".###*##########*###."
    "#####...####...#####"
    "######..####..######"
    "####################"
    "####+##########+####"
    ".####++######++####."
    "..####++++++++####.."
    "...#####++++#####..."
    ".....##########....."
    "......########......"
    ".......##..##......."))

(defparameter *jrpg-bat-sprite*
  #("..#..............#.."
    ".###....####....###."
    "####..########..####"
    "#####.##****##.#####"
    "#.####.######.####.#"
    "...####.####.####..."
    ".....##.####.##....."
    "......#.####.#......"
    "........####........"
    ".......#+##+#......."
    "......##++++##......"
    ".......#+##+#......."
    "........#..#........"
    ".......#....#......."))

(defparameter *jrpg-goblin-sprite*
  #(".......####........."
    "......######........"
    ".....##****##......."
    ".....#*#**#*#......."
    "......######........"
    ".......####........."
    "....#..####..#......"
    "...##.######.##....."
    "..###.######.###...."
    "..#..########..#...."
    ".....##++++##......."
    ".....##.##.##......."
    "....##...#..##......"
    "...##....#...##....."))

(defparameter *jrpg-wolf-sprite*
  #("..................#."
    ".###.............###"
    "####............####"
    "#####..........#####"
    "############.#######"
    "##############****#."
    "###############*##.."
    "##################.."
    ".################..."
    ".##.####.####.##...."
    ".#...##...##...#...."
    ".#...##...##...#...."))

;;; Carcosan creatures - the King in Yellow's world. The tatter is a feral
;;; shred of the King's yellow mantle; the drowned is a thing the Lake of Hali
;;; kept; the byakhee is a winged servant out of the Hyades; the courtier is a
;;; masked dead petitioner; the phantom is the play's Phantom of Truth.

(defparameter *jrpg-tatter-sprite*
  #("...#...#...#..#....."
    "..###.###.###.##...."
    ".#####.#####.####..."
    "####*#####*#######.."
    ".################+.."
    "..#############++..."
    ".###.########.##...."
    "..#...######..#....."
    "...#.#.####.#.#....."
    "....#.#.##.#.#......"
    ".....#.#..#.#......."
    "......#.+.#........."
    ".......#+#.+........"
    "........#.#........."))

(defparameter *jrpg-drowned-sprite*
  #("....~..~...~..~....."
    "...#####.######....."
    "..###*#####*####...."
    ".################..."
    ".####+########+###.."
    ".##################."
    ".##++##########++##."
    "..################.."
    "...~############~..."
    "....~##########~...."
    ".....~~######~~....."
    "..~...~~####~~..~..."
    ".~.~....~~~~....~.~."
    "..~......~~......~.."))

(defparameter *jrpg-byakhee-sprite*
  #("#..................#"
    "##................##"
    "###....######....###"
    "####.##******##.####"
    ".####.########.####."
    "..####.######.####.."
    "...###.######.###..."
    "....#..######..#...."
    ".......#+##+#........"
    "......##++++##......."
    ".......#+##+#........"
    "........####........"
    ".......#.##.#........"
    "......#..#..#......."))

(defparameter *jrpg-courtier-sprite*
  #(".......#####........"
    "......#######......."
    ".....#*#*#*#*#......"
    ".....#########......"
    "......#######......."
    ".......#####........"
    "....#.########.#...."
    "...##.########.##..."
    "..###.########.###.."
    "..#...########...#.."
    "......########......"
    "......###..###......"
    ".....###....###....."
    "....###......###...."))

(defparameter *jrpg-phantom-sprite*
  #("........###........."
    ".......#####........"
    "......##*#*##......."
    "......#######......."
    ".....#.#####.#......"
    "....##.#####.##....."
    "...###.#####.###...."
    "..####.#####.####..."
    "..###..#####..###..."
    "..#...#######...#..."
    ".....#########......"
    "....###.###.###....."
    "...##....#....##...."
    "..#.....#.#.....#..."))

;;; Ordinary human menace of the night city (Act I), before anything from
;;; Carcosa: a street ruffian, and the churchyard watchman of THE YELLOW SIGN,
;;; the plump white grave-worm in a man's shape.

(defparameter *jrpg-ruffian-sprite*
  #("........####........"
    ".......######......."
    ".......#*##*#......."
    ".......######......."
    "........####........"
    "......########......"
    ".#...##########...#."
    "##...##########...##"
    ".#...##########...#."
    "......###..###......"
    "......##....##......"
    ".....##......##....."
    "....##........##...."
    "...##..........##..."))

(defparameter *jrpg-watchman-sprite*
  #(".....########......."
    "...############....."
    "..####++++++####...."
    "..###*##++##*###...."
    "..####++++++####...."
    "..#####+##+#####...."
    "..##############...."
    "...############....."
    "....##########......"
    "...#+#+#+#+#+#+#....."
    "..##++++++++++##...."
    "...#++++++++++#....."
    "....##+++++##......."
    "......######........"))

(defparameter *jrpg-enemy-sprites*
  (list (cons "slime" *jrpg-slime-sprite*)
        (cons "bat" *jrpg-bat-sprite*)
        (cons "goblin" *jrpg-goblin-sprite*)
        (cons "wolf" *jrpg-wolf-sprite*)
        (cons "ruffian" *jrpg-ruffian-sprite*)
        (cons "watchman" *jrpg-watchman-sprite*)
        (cons "tatter" *jrpg-tatter-sprite*)
        (cons "drowned" *jrpg-drowned-sprite*)
        (cons "byakhee" *jrpg-byakhee-sprite*)
        (cons "courtier" *jrpg-courtier-sprite*)
        (cons "phantom" *jrpg-phantom-sprite*)))

(defun jrpg-enemy-sprite (kind)
  (or (cdr (assoc (string-downcase (or kind "slime"))
                  *jrpg-enemy-sprites*
                  :test #'string=))
      *jrpg-slime-sprite*))

;;; Carcosan foes spend the player's composure, not only their blood.
(defparameter *jrpg-carcosan-kinds*
  '("tatter" "drowned" "byakhee" "courtier" "phantom"))

;;; --- the player's choices: five commands, and a small list of skills ---

(defparameter *jrpg-combat-commands*
  #((:key :attack :label "ATTACK")
    (:key :skill  :label "SKILL")
    (:key :guard  :label "GUARD")
    (:key :item   :label "ITEM")
    (:key :flee   :label "FLEE")))

(defun jrpg-combat-command-count ()
  (length *jrpg-combat-commands*))

(defun jrpg-combat-skill-list ()
  "Skills the hero can reach now. The focus strike and mend are always known;
reciting the King's lines unlocks once a scrap of the Play is on you, and it
spends will, not focus - the words wound the speaker too."
  (let ((skills (list (list :key :focus :label "focus strike"
                            :cost-mp 1 :note "MP1  a sure, staggering blow")
                      (list :key :mend :label "mend"
                            :cost-mp 1 :note "MP1  close your wounds"))))
    (when (plusp (jrpg-number "jrpg-play-scraps"))
      (setf skills
            (append skills
                    (list (list :key :recite :label "recite the play"
                                :cost-composure 2 :note "WILL2  the lines cut deep")))))
    skills))

(defun jrpg-combat-item-list ()
  "The consumables usable in battle right now: a tonic (if any potions remain),
and any held Hali-water or marble-phial."
  (let ((items nil))
    (when (plusp (jrpg-number "jrpg-potions"))
      (push (list :key :tonic :label "tonic" :note "+9 hp") items))
    (when (jrpg-has-item-p :hali-water)
      (push (list :key :hali-water :label "Hali-water" :note "+4 will") items))
    (when (jrpg-has-item-p :marble-phial)
      (push (list :key :marble-phial :label "marble-phial" :note "turn the foe to marble") items))
    (nreverse items)))

;;; --- one action's small animation: lunge out, land at impact, recover ---

(defparameter +jrpg-act-impact+  0.17)
(defparameter +jrpg-act-recover+ 0.46)
(defparameter +jrpg-act-done+    0.64)

(defstruct jrpg-act
  actor             ; :hero or :enemy
  kind              ; :attack :skill :guard :item :hit :reel
  (skill nil)       ; skill key when kind is :skill
  (item nil)        ; item key when kind is :item
  (clock 0.0)
  (fired nil))      ; impact already applied this action?

(defun jrpg-act-lunge (clock peak)
  "How far the acting combatant has leaned into the blow at CLOCK seconds:
out toward the foe near impact, then back to rest by the recover time."
  (* peak (sin (* pi (min 1.0 (/ clock +jrpg-act-recover+))))))

(defvar *jrpg-combat* nil)

(defstruct jrpg-combat
  (node-id          *runtime-fallback-node-id*)
  (enemy-name       "SLIME")
  (enemy-kind       "slime")
  (enemy-hp         14)
  (enemy-max-hp     14)
  (enemy-attack-min 3)
  (enemy-attack-max 6)
  (victory-xp       4)
  (victory-gold     6)
  (carcosan         nil)
  (selected         0)
  (submenu          nil)
  (skill-index      0)
  (message          "a slime draws near.")
  (elapsed          0.0)
  (phase            :menu)             ; :menu :anim :over
  (action           nil)
  (guarding         nil)
  (enemy-winding    nil)
  (enemy-stagger    nil)
  (shake            0.0)
  (flash-hero       0.0)
  (flash-enemy      0.0)
  (hero-recoil      0.0)
  (enemy-recoil     0.0)
  (floaters         nil)
  (sparks           nil)
  (enemy-hp-shown   14.0)
  (hero-hp-shown    18.0)
  (finish-target    nil)
  (finish-delay     0.0))

(defun jrpg-combat-config-number (node key default)
  (let ((value (minigame-config-value node key default)))
    (if (numberp value) value default)))

(defun jrpg-combat-config-string (node key default)
  (let ((value (minigame-config-value node key default)))
    (if (stringp value) value default)))

;;; Enemy variety: a node can carry an :enemy-pool (a keyword naming a pool
;;; below, or a literal list of specs); each encounter then draws a random foe
;;; instead of always the same one. The night city is more than ruffians.

(defparameter *jrpg-enemy-pools*
  '((:city
     ((:name "RUFFIAN"    :kind "ruffian" :hp 15 :attack-min 3 :attack-max 6 :hours 10
       :message "a man steps out of a doorway, hands low and open.")
      (:name "CUTPURSE"   :kind "ruffian" :hp 11 :attack-min 2 :attack-max 5 :hours 12
       :message "a thin hand goes for your coat before you see the rest of him.")
      (:name "A DRUNK"    :kind "ruffian" :hp 10 :attack-min 2 :attack-max 4 :hours 6
       :message "a drunk swings at someone who is not there. you will do.")
      (:name "STRAY CUR"  :kind "wolf"    :hp 13 :attack-min 3 :attack-max 6 :hours 7
       :message "a stray dog, all ribs and teeth, decides the street is its own.")
      (:name "NIGHT BATS" :kind "bat"     :hp 9  :attack-min 2 :attack-max 4 :hours 5
       :message "the dark over the gutter comes apart into wings.")
      (:name "A MADMAN"   :kind "ruffian" :hp 18 :attack-min 4 :attack-max 7 :hours 14 :drains t
       :message "a man who has read too far grins and comes at you, reciting.")))))

(defun jrpg-enemy-pool (key) (second (assoc key *jrpg-enemy-pools*)))

(defun jrpg-pick-enemy-spec (node)
  "Resolve the node's :enemy-pool (a pool keyword or a literal spec list) and
choose one spec at random; nil when the node has no pool."
  (let* ((raw (minigame-config-value node :enemy-pool))
         (pool (cond ((keywordp raw) (jrpg-enemy-pool raw))
                     ((and (listp raw) raw) raw)
                     (t nil))))
    (when pool
      (nth (get-random-value 0 (1- (length pool))) pool))))

(defun make-fresh-jrpg-combat (node)
  (jrpg-init-state)
  (let* ((spec (jrpg-pick-enemy-spec node))
         (kind (or (and spec (getf spec :kind))
                   (jrpg-combat-config-string node :enemy-kind "slime")))
         (enemy-hp (or (and spec (getf spec :hp))
                       (jrpg-combat-config-number node :enemy-hp 14)))
         (hours (and spec (getf spec :hours))))
    (make-jrpg-combat
     :node-id (node-id node)
     :enemy-name (or (and spec (getf spec :name))
                     (jrpg-combat-config-string node :enemy-name "SLIME"))
     :enemy-kind kind
     :enemy-hp enemy-hp
     :enemy-max-hp enemy-hp
     :enemy-attack-min (or (and spec (getf spec :attack-min))
                           (jrpg-combat-config-number node :enemy-attack-min 3))
     :enemy-attack-max (or (and spec (getf spec :attack-max))
                           (jrpg-combat-config-number node :enemy-attack-max 6))
     :victory-xp (or hours (jrpg-combat-config-number node :victory-xp 4))
     :victory-gold (if spec 0 (jrpg-combat-config-number node :victory-gold 6))
     :carcosan (or (and spec (getf spec :drains) t)
                   (and (member (string-downcase kind) *jrpg-carcosan-kinds*
                                :test #'string=)
                        t))
     :message (or (and spec (getf spec :message))
                  (jrpg-combat-config-string node :message "a slime draws near."))
     :enemy-hp-shown (float enemy-hp)
     :hero-hp-shown (float (jrpg-number "jrpg-hero-hp" 18)))))

(defun ensure-jrpg-combat (node)
  (unless (and *jrpg-combat*
               (equal (jrpg-combat-node-id *jrpg-combat*)
                      (node-id node)))
    (setf *jrpg-combat* (make-fresh-jrpg-combat node)))
  *jrpg-combat*)

(defun jrpg-sound-path (name)
  (format nil "assets/audio/jrpg/~a.wav" name))

(defun play-jrpg-sound (name &key (volume *jrpg-combat-sfx-volume*))
  (handler-case
      (play-story-sound (jrpg-sound-path name) :volume volume)
    (error (condition)
      (runtime-warn "Could not play JRPG sound ~a: ~a" name condition))))

(defun jrpg-enemy-word (game)
  (string-downcase (jrpg-combat-enemy-name game)))

;;; Where the two combatants stand. Both draw and the impact effects read
;;; these, so sparks and damage numbers land where the bodies are.

(defun jrpg-enemy-anchor ()
  (values (+ +jrpg-combat-left+ 568) (+ +jrpg-combat-top+ 150)))

(defun jrpg-hero-anchor ()
  (values (+ +jrpg-combat-left+ 150) (+ +jrpg-combat-top+ 168)))

;;; --- feedback: floating numbers and hit sparks ---

(defun jrpg-spawn-floater (game text x y &key crit yellow)
  (push (list :text text :x (float x) :y (float y) :age 0.0
              :ttl (if crit 1.1 0.9) :crit crit :yellow yellow)
        (jrpg-combat-floaters game)))

(defun jrpg-spawn-sparks (game x y count &key (speed 150.0) yellow)
  (dotimes (i count)
    (let* ((ang (* (/ (float (get-random-value 0 359)) 360.0) 2.0 pi))
           (spd (* speed (+ 0.45 (* 0.55 (/ (float (get-random-value 0 100)) 100.0))))))
      (push (list :x (float x) :y (float y)
                  :vx (* spd (cos ang))
                  :vy (- (* spd (sin ang)) 40.0)
                  :age 0.0
                  :ttl (+ 0.3 (* 0.004 (get-random-value 0 70)))
                  :size (+ 2 (get-random-value 0 2))
                  :yellow yellow)
            (jrpg-combat-sparks game)))))

(defun jrpg-update-floaters (game dt)
  (setf (jrpg-combat-floaters game)
        (loop for f in (jrpg-combat-floaters game)
              do (incf (getf f :age) dt)
                 (decf (getf f :y) (* 46.0 dt))
              when (< (getf f :age) (getf f :ttl)) collect f)))

(defun jrpg-update-sparks (game dt)
  (setf (jrpg-combat-sparks game)
        (loop for s in (jrpg-combat-sparks game)
              do (incf (getf s :age) dt)
                 (incf (getf s :x) (* (getf s :vx) dt))
                 (incf (getf s :y) (* (getf s :vy) dt))
                 (incf (getf s :vy) (* 240.0 dt))
              when (< (getf s :age) (getf s :ttl)) collect s)))

(defun jrpg-decay (value dt rate)
  "Ease VALUE toward zero, snapping once it is small."
  (let ((v (- value (* value (min 1.0 (* dt rate))))))
    (if (< (abs v) 0.05) 0.0 v)))

(defun jrpg-lerp-toward (shown actual dt)
  "Ease a displayed bar value SHOWN toward its true value ACTUAL."
  (let ((v (+ shown (* (- actual shown) (min 1.0 (* dt 7.0))))))
    (if (< (abs (- v actual)) 0.05) (float actual) v)))

;;; --- combat numbers ---

(defun jrpg-combat-enemy-alive-p (game)
  (plusp (jrpg-combat-enemy-hp game)))

(defun jrpg-combat-damage-enemy (game amount)
  (setf (jrpg-combat-enemy-hp game)
        (max 0 (- (jrpg-combat-enemy-hp game) amount))))

(defun jrpg-combat-hero-attack ()
  "Returns (values damage crit-p); about one swing in six lands clean."
  (let ((base (+ (jrpg-number "jrpg-hero-attack" 5) (get-random-value 0 2)))
        (crit (zerop (get-random-value 0 5))))
    (values (if crit (* 2 base) base) crit)))

;;; --- impact effects (called once, at the moment a blow lands) ---

(defun jrpg-combat-hit-enemy-fx (game damage &key crit yellow)
  (multiple-value-bind (ex ey) (jrpg-enemy-anchor)
    (setf (jrpg-combat-enemy-recoil game) (if crit 30.0 20.0)
          (jrpg-combat-flash-enemy game) 0.2
          (jrpg-combat-shake game) (max (jrpg-combat-shake game)
                                        (if crit 12.0 6.0)))
    (jrpg-spawn-sparks game ex ey (if crit 16 9)
                       :speed (if crit 200.0 150.0) :yellow yellow)
    (jrpg-spawn-floater game (format nil "~d" damage) ex (- ey 30)
                        :crit crit :yellow yellow)))

(defun jrpg-combat-hit-hero-fx (game damage &key heavy)
  (multiple-value-bind (hx hy) (jrpg-hero-anchor)
    (setf (jrpg-combat-hero-recoil game) (if heavy -30.0 -20.0)
          (jrpg-combat-flash-hero game) 0.22
          (jrpg-combat-shake game) (max (jrpg-combat-shake game)
                                        (if heavy 14.0 7.0)))
    (jrpg-spawn-sparks game hx hy (if heavy 14 8)
                       :speed (if heavy 190.0 140.0))
    (jrpg-spawn-floater game (format nil "~d" damage) hx (- hy 26) :crit heavy)))

(defun jrpg-combat-heal-hero-fx (game amount)
  (multiple-value-bind (hx hy) (jrpg-hero-anchor)
    (setf (jrpg-combat-flash-hero game) 0.18)
    (jrpg-spawn-floater game (format nil "+~d" amount) hx (- hy 24))
    (jrpg-spawn-sparks game hx hy 6 :speed 70.0)))

;;; --- ending the battle ---

(defun jrpg-combat-finish (game target)
  (setf (jrpg-combat-finish-target game) target
        (jrpg-combat-finish-delay game) 1.0
        (jrpg-combat-phase game) :over))

(defun jrpg-combat-victory (node game)
  (jrpg-award-victory :xp (jrpg-combat-victory-xp game)
                      :gold (jrpg-combat-victory-gold game))
  (multiple-value-bind (ex ey) (jrpg-enemy-anchor)
    (jrpg-spawn-sparks game ex ey 20 :speed 210.0))
  (play-jrpg-sound "coin" :volume 0.34)
  (setf (jrpg-combat-message game)
        (format nil "the ~a is defeated. +~d Hours."
                (jrpg-enemy-word game) (jrpg-value "jrpg-just-gained" 0)))
  (jrpg-combat-finish game (node-success-target node)))

(defun jrpg-combat-defeat (node game)
  (jrpg-record-defeat)
  (setf (jrpg-combat-message game)
        "you fall, and half your Hours scatter into the dark.")
  (jrpg-combat-finish game (node-failure-target node)))

;;; --- the hero's actions (resolved at impact) ---

(defun jrpg-combat-hero-strike (node game)
  (multiple-value-bind (damage crit) (jrpg-combat-hero-attack)
    (play-jrpg-sound "sword" :volume (if crit 0.52 0.42))
    (jrpg-combat-damage-enemy game damage)
    (jrpg-combat-hit-enemy-fx game damage :crit crit)
    (when crit (setf (jrpg-combat-enemy-stagger game) t))
    (setf (jrpg-combat-message game)
          (cond ((not (jrpg-combat-enemy-alive-p game))
                 (format nil "the ~a reels from the blow." (jrpg-enemy-word game)))
                (crit (format nil "a clean strike - ~d!" damage))
                (t (format nil "you hit the ~a for ~d." (jrpg-enemy-word game) damage))))
    (unless (jrpg-combat-enemy-alive-p game)
      (jrpg-combat-victory node game))))

(defun jrpg-combat-hero-skill (node game key)
  (case key
    (:focus
     (jrpg-adjust-number "jrpg-hero-mp" -1)
     (let ((dmg (+ (round (* (jrpg-number "jrpg-hero-attack" 5) 1.6))
                   (get-random-value 0 3))))
       (play-jrpg-sound "sword" :volume 0.5)
       (jrpg-combat-damage-enemy game dmg)
       (setf (jrpg-combat-enemy-stagger game) t)
       (jrpg-combat-hit-enemy-fx game dmg :crit t)
       (setf (jrpg-combat-message game)
             (if (jrpg-combat-enemy-alive-p game)
                 (format nil "a focused strike staggers the ~a - ~d!"
                         (jrpg-enemy-word game) dmg)
                 (format nil "the ~a folds." (jrpg-enemy-word game))))
       (unless (jrpg-combat-enemy-alive-p game)
         (jrpg-combat-victory node game))))
    (:mend
     (jrpg-adjust-number "jrpg-hero-mp" -1)
     (let ((amount (+ 9 (* 2 (jrpg-number "jrpg-hero-level" 1)))))
       (jrpg-heal amount)
       (play-jrpg-sound "tonic" :volume 0.4)
       (jrpg-combat-heal-hero-fx game amount)
       (setf (jrpg-combat-message game)
             (format nil "you knit the wounds. +~d." amount))))
    (:recite
     (jrpg-spend-composure 2)
     (let ((dmg (+ 12 (* 2 (jrpg-number "jrpg-hero-level" 1)) (get-random-value 0 5))))
       (play-jrpg-sound "magic" :volume 0.42)
       (jrpg-combat-damage-enemy game dmg)
       (jrpg-combat-hit-enemy-fx game dmg :crit t :yellow t)
       (setf (jrpg-combat-message game)
             (if (jrpg-combat-enemy-alive-p game)
                 (format nil "you speak the king's lines; the ~a shudders - ~d."
                         (jrpg-enemy-word game) dmg)
                 (format nil "the lines undo the ~a." (jrpg-enemy-word game))))
       (unless (jrpg-combat-enemy-alive-p game)
         (jrpg-combat-victory node game))))))

(defun jrpg-combat-hero-guard (game)
  (setf (jrpg-combat-guarding game) t)
  (jrpg-adjust-number "jrpg-hero-mp" 1)
  (jrpg-restore-composure 1)
  (play-jrpg-sound "retreat" :volume 0.3)
  (multiple-value-bind (hx hy) (jrpg-hero-anchor)
    (jrpg-spawn-floater game "GUARD" hx (- hy 24)))
  (setf (jrpg-combat-message game) "you set your feet and brace."))

(defun jrpg-combat-hero-item (node game key)
  (case key
    (:tonic
     (if (jrpg-use-potion)
         (progn (play-jrpg-sound "tonic" :volume 0.4)
                (jrpg-combat-heal-hero-fx game 9)
                (setf (jrpg-combat-message game) "you drink a tonic. +9."))
         (setf (jrpg-combat-message game) "the bag is empty.")))
    (:hali-water
     (jrpg-use-consumable :hali-water)        ; restores will, removes the flask
     (play-jrpg-sound "tonic" :volume 0.38)
     (multiple-value-bind (hx hy) (jrpg-hero-anchor)
       (setf (jrpg-combat-flash-hero game) 0.18)
       (jrpg-spawn-floater game "+will" hx (- hy 24) :yellow t))
     (setf (jrpg-combat-message game) "you drink the lake-water; your will steadies."))
    (:marble-phial
     (jrpg-remove-item :marble-phial)
     (let ((dmg (max 1 (round (* (jrpg-combat-enemy-max-hp game) 0.9)))))
       (play-jrpg-sound "chime" :volume 0.42)
       (jrpg-combat-damage-enemy game dmg)
       (jrpg-combat-hit-enemy-fx game dmg :crit t)
       (setf (jrpg-combat-message game)
             (format nil "you dash the phial; the ~a turns to marble - ~d."
                     (jrpg-enemy-word game) dmg))
       (unless (jrpg-combat-enemy-alive-p game)
         (jrpg-combat-victory node game))))
    (t (setf (jrpg-combat-message game) "nothing happens."))))

;;; --- the enemy's turn (resolved at impact) ---

(defun jrpg-combat-enemy-hit (node game)
  (let* ((heavy (or (jrpg-combat-enemy-winding game)
                    (zerop (get-random-value 0 4))))
         (base (get-random-value (jrpg-combat-enemy-attack-min game)
                                 (jrpg-combat-enemy-attack-max game)))
         (raw (if heavy (round (* base 1.8)) base))
         (defended (max 1 (- raw (jrpg-number "jrpg-hero-defense" 2))))
         (guarded (jrpg-combat-guarding game))
         (after-guard (if guarded (max 1 (ceiling defended 2)) defended))
         (unmasked (not (jrpg-composed-p)))
         (damage (if unmasked (round (* after-guard 1.33)) after-guard)))
    (setf (jrpg-combat-enemy-winding game) nil
          (jrpg-combat-guarding game) nil)
    (jrpg-damage-hero damage)
    (when (jrpg-combat-carcosan game)
      (jrpg-spend-composure (if heavy 2 1)))
    (jrpg-combat-hit-hero-fx game damage :heavy heavy)
    (play-jrpg-sound (if heavy "slime" "hit") :volume (if heavy 0.46 0.34))
    (setf (jrpg-combat-message game)
          (cond ((not (jrpg-hero-alive-p)) "you go down in the dark.")
                (guarded (format nil "you take it on your guard - ~d." damage))
                (heavy (format nil "the ~a strikes hard! ~d." (jrpg-enemy-word game) damage))
                (unmasked (format nil "unmasked, you take ~d." damage))
                (t (format nil "the ~a hits you for ~d." (jrpg-enemy-word game) damage))))
    (if (jrpg-hero-alive-p)
        (when (and (not (jrpg-combat-enemy-winding game))
                   (zerop (get-random-value 0 2)))
          (setf (jrpg-combat-enemy-winding game) t)
          (setf (jrpg-combat-message game)
                (format nil "the ~a draws itself up for a heavier blow."
                        (jrpg-enemy-word game))))
        (jrpg-combat-defeat node game))))

(defun jrpg-combat-enemy-reel (game)
  (setf (jrpg-combat-enemy-stagger game) nil)
  (multiple-value-bind (ex ey) (jrpg-enemy-anchor)
    (jrpg-spawn-floater game "REELING" ex (- ey 30) :yellow t))
  (setf (jrpg-combat-message game)
        (format nil "the ~a is too off-balance to strike." (jrpg-enemy-word game))))

;;; --- the turn machine ---

(defun jrpg-combat-begin-hero-action (game act)
  (setf (jrpg-combat-action game) act
        (jrpg-combat-phase game) :anim))

(defun jrpg-combat-flee (node game)
  (jrpg-record-retreat)
  (play-jrpg-sound "retreat" :volume 0.36)
  (setf (jrpg-combat-message game) "you slip back the way you came.")
  (jrpg-combat-finish game (node-success-target node)))

(defun jrpg-combat-resolve-impact (node game act)
  (ecase (jrpg-act-actor act)
    (:hero (case (jrpg-act-kind act)
             (:attack (jrpg-combat-hero-strike node game))
             (:skill  (jrpg-combat-hero-skill node game (jrpg-act-skill act)))
             (:guard  (jrpg-combat-hero-guard game))
             (:item   (jrpg-combat-hero-item node game (jrpg-act-item act)))))
    (:enemy (case (jrpg-act-kind act)
              (:hit  (jrpg-combat-enemy-hit node game))
              (:reel (jrpg-combat-enemy-reel game))))))

(defun jrpg-combat-finish-action (node game act)
  (declare (ignore node))
  (setf (jrpg-combat-action game) nil)
  (cond
    ;; the foe just acted → control returns to the player
    ((eq (jrpg-act-actor act) :enemy)
     (setf (jrpg-combat-phase game) :menu))
    ;; the hero acted and the foe still stands → the foe answers, unless a
    ;; stagger has it reeling
    ((jrpg-combat-enemy-alive-p game)
     (setf (jrpg-combat-action game)
           (if (jrpg-combat-enemy-stagger game)
               (make-jrpg-act :actor :enemy :kind :reel)
               (make-jrpg-act :actor :enemy :kind :hit))
           (jrpg-combat-phase game) :anim))
    (t (setf (jrpg-combat-phase game) :menu))))

(defun jrpg-combat-advance-action (node game dt)
  (let ((act (jrpg-combat-action game)))
    (when act
      (incf (jrpg-act-clock act) dt)
      (when (and (not (jrpg-act-fired act))
                 (>= (jrpg-act-clock act) +jrpg-act-impact+))
        (setf (jrpg-act-fired act) t)
        (jrpg-combat-resolve-impact node game act))
      ;; victory or defeat at impact moves us to :over; only keep going if the
      ;; battle is still live
      (when (and (eq (jrpg-combat-phase game) :anim)
                 (>= (jrpg-act-clock act) +jrpg-act-done+))
        (jrpg-combat-finish-action node game act)))))

;;; --- input ---

(defun jrpg-combat-vert-step ()
  "Returns +1 (down/next), -1 (up/prev), or 0."
  (cond ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+)
             (is-key-pressed-p +key-right+) (is-key-pressed-p +key-d+))
         1)
        ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+)
             (is-key-pressed-p +key-left+) (is-key-pressed-p +key-a+))
         -1)
        (t 0)))

(defun jrpg-combat-choose-command (node game key)
  (case key
    (:attack (jrpg-combat-begin-hero-action
              game (make-jrpg-act :actor :hero :kind :attack)))
    (:skill  (setf (jrpg-combat-submenu game) :skill
                   (jrpg-combat-skill-index game) 0)
             (play-choice-switch))
    (:guard  (jrpg-combat-begin-hero-action
              game (make-jrpg-act :actor :hero :kind :guard)))
    (:item   (if (jrpg-combat-item-list)
                 (progn (setf (jrpg-combat-submenu game) :item
                              (jrpg-combat-skill-index game) 0)
                        (play-choice-switch))
                 (setf (jrpg-combat-message game) "the bag is empty.")))
    (:flee   (jrpg-combat-flee node game))))

(defun jrpg-combat-handle-command-menu (node game)
  (let ((step (jrpg-combat-vert-step))
        (n (jrpg-combat-command-count)))
    (unless (zerop step)
      (setf (jrpg-combat-selected game)
            (mod (+ (jrpg-combat-selected game) step) n))
      (play-choice-switch))
    (when (confirm-pressed-p)
      (jrpg-combat-choose-command
       node game
       (getf (aref *jrpg-combat-commands* (jrpg-combat-selected game)) :key)))))

(defun jrpg-combat-handle-skill-menu (node game)
  (declare (ignore node))
  (let* ((skills (jrpg-combat-skill-list))
         (n (length skills))
         (step (jrpg-combat-vert-step)))
    (cond
      ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-backspace+))
       (setf (jrpg-combat-submenu game) nil)
       (play-choice-switch))
      (t
       (unless (zerop step)
         (setf (jrpg-combat-skill-index game)
               (mod (+ (jrpg-combat-skill-index game) step) n))
         (play-choice-switch))
       (when (confirm-pressed-p)
         (let* ((skill (nth (min (jrpg-combat-skill-index game) (1- n)) skills))
                (key (getf skill :key)))
           (cond
             ((and (getf skill :cost-mp)
                   (< (jrpg-number "jrpg-hero-mp") (getf skill :cost-mp)))
              (setf (jrpg-combat-message game) "you cannot focus - no mp."))
             ((and (getf skill :cost-composure)
                   (< (jrpg-composure) (getf skill :cost-composure)))
              (setf (jrpg-combat-message game)
                    "you cannot bear to speak the lines."))
             (t
              (setf (jrpg-combat-submenu game) nil)
              (jrpg-combat-begin-hero-action
               game (make-jrpg-act :actor :hero :kind :skill :skill key))))))))))

(defun jrpg-combat-handle-item-menu (node game)
  (declare (ignore node))
  (let* ((items (jrpg-combat-item-list))
         (n (length items))
         (step (jrpg-combat-vert-step)))
    (cond
      ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-backspace+))
       (setf (jrpg-combat-submenu game) nil)
       (play-choice-switch))
      ((zerop n)
       (setf (jrpg-combat-submenu game) nil))
      (t
       (unless (zerop step)
         (setf (jrpg-combat-skill-index game)
               (mod (+ (jrpg-combat-skill-index game) step) n))
         (play-choice-switch))
       (when (confirm-pressed-p)
         (let* ((item (nth (min (jrpg-combat-skill-index game) (1- n)) items))
                (key (getf item :key)))
           (setf (jrpg-combat-submenu game) nil)
           (jrpg-combat-begin-hero-action
            game (make-jrpg-act :actor :hero :kind :item :item key))))))))

(defun jrpg-combat-handle-menu (node game)
  (case (jrpg-combat-submenu game)
    (:skill (jrpg-combat-handle-skill-menu node game))
    (:item  (jrpg-combat-handle-item-menu node game))
    (t      (jrpg-combat-handle-command-menu node game))))

(defun update-jrpg-combat-minigame (node dt)
  (let ((game (ensure-jrpg-combat node)))
    (incf (jrpg-combat-elapsed game) dt)
    (jrpg-update-floaters game dt)
    (jrpg-update-sparks game dt)
    (setf (jrpg-combat-shake game) (jrpg-decay (jrpg-combat-shake game) dt 6.0)
          (jrpg-combat-flash-hero game) (max 0.0 (- (jrpg-combat-flash-hero game) dt))
          (jrpg-combat-flash-enemy game) (max 0.0 (- (jrpg-combat-flash-enemy game) dt))
          (jrpg-combat-hero-recoil game) (jrpg-decay (jrpg-combat-hero-recoil game) dt 9.0)
          (jrpg-combat-enemy-recoil game) (jrpg-decay (jrpg-combat-enemy-recoil game) dt 9.0)
          (jrpg-combat-enemy-hp-shown game)
          (jrpg-lerp-toward (jrpg-combat-enemy-hp-shown game)
                            (jrpg-combat-enemy-hp game) dt)
          (jrpg-combat-hero-hp-shown game)
          (jrpg-lerp-toward (jrpg-combat-hero-hp-shown game)
                            (jrpg-number "jrpg-hero-hp" 0) dt))
    (case (jrpg-combat-phase game)
      (:over (decf (jrpg-combat-finish-delay game) dt)
             (when (<= (jrpg-combat-finish-delay game) 0.0)
               (let ((target (jrpg-combat-finish-target game)))
                 (setf *jrpg-combat* nil)
                 (jump-to-dialog-target target))))
      (:anim (jrpg-combat-advance-action node game dt))
      (t (jrpg-combat-handle-menu node game)))))

;;; --- drawing ---

(defun jrpg-fill-rect (x y w h color)
  (claylib/ll:draw-rectangle (round x) (round y)
                             (max 1 (round w)) (max 1 (round h))
                             (claylib::c-ptr color)))

(defun draw-jrpg-box (left top width height &optional (alpha 235))
  (claylib/ll:draw-rectangle (round left) (round top)
                             (round width) (round height)
                             (claylib::c-ptr (make-color 0 0 0 alpha)))
  (draw-rectangle-outline left top width height
                          (make-color 255 255 255 230) :thickness 2))

(defun draw-jrpg-line (text x y &optional (size 18) (alpha 230))
  (draw-text-at text x y size (make-color 255 255 255 alpha)))

(defun jrpg-draw-select-bar (x y w &optional (h 24))
  "A faint highlight behind a selected menu row."
  (claylib/ll:draw-rectangle (round x) (round (- y 3)) (round w) h
                             (claylib::c-ptr (make-color 255 255 255 34))))

(defun jrpg-draw-rule (x y w &optional (alpha 70))
  "A thin divider rule."
  (claylib/ll:draw-rectangle (round x) (round y) (round w) 1
                             (claylib::c-ptr (make-color 255 255 255 alpha))))

(defun draw-jrpg-bar (x y w h frac trail-frac &key yellow)
  "A meter: faint track, a dim trailing chunk for the value still draining
away, then the solid fill. Yellow tints the will meter."
  (let ((frac (max 0.0 (min 1.0 frac)))
        (trail (max 0.0 (min 1.0 trail-frac))))
    (jrpg-fill-rect x y w h (make-color 255 255 255 38))
    (when (> trail frac)
      (jrpg-fill-rect (+ x (* w frac)) y (* w (- trail frac)) h
                      (make-color 255 255 255 120)))
    (jrpg-fill-rect x y (* w frac) h
                    (if yellow (yellow-sign-color 235) (make-color 255 255 255 230)))
    (draw-rectangle-outline x y w h (make-color 255 255 255 150) :thickness 1)))

(defun jrpg-slime-pixel-alpha (cell)
  "A grey ramp for the sprite glyphs, brightest to faint. '.' / space are
transparent. Sprites can shade their edges with the mid tones for depth."
  (case cell
    ((#\@ #\*) 255) ; specular highlight, eyes
    (#\# 220)   ; lit body
    (#\% 186)   ; upper mid
    (#\= 150)   ; mid
    (#\+ 116)   ; shadow
    (#\: 82)    ; deep shadow
    ((#\, #\~) 56) ; faintest: mist, water, drips
    (t nil)))

(defun jrpg-slime-row-offset (row elapsed)
  (round (* 2.0 (sin (+ (* elapsed 2.4) (* row 0.52))))))

(defun draw-jrpg-slime-shadow (center-x y elapsed)
  (let* ((pulse (+ 1.0 (* 0.08 (sin (* elapsed 3.0)))))
         (width (* 132 pulse))
         (height 12)
         (left (- center-x (/ width 2))))
    (loop for offset from 0 below height by 4
          do (claylib/ll:draw-rectangle
              (round (+ left (* offset 1.6)))
              (round (+ y offset))
              (round (- width (* offset 3.2)))
              3
              (claylib::c-ptr (make-color 255 255 255 (- 54 (* offset 4))))))))

(defun draw-jrpg-enemy-sprite (sprite center-x top scale elapsed)
  (loop with sprite-width = (length (aref sprite 0))
        with left = (- center-x (/ (* sprite-width scale) 2))
        with bounce = (round (* 4.0 (sin (* elapsed 3.0))))
        for row across sprite
        for y from 0
        for row-offset = (jrpg-slime-row-offset y elapsed)
        do (loop for cell across row
                 for x from 0
                 for alpha = (jrpg-slime-pixel-alpha cell)
                 when alpha
                   do (claylib/ll:draw-rectangle
                       (round (+ left row-offset (* x scale)))
                       (round (+ top bounce (* y scale)))
                       scale scale
                       (claylib::c-ptr (make-color 255 255 255 alpha))))))

(defun draw-jrpg-windup (cx cy reach elapsed)
  "Corner brackets that pulse around a foe winding up a heavy blow - the
player's cue to GUARD."
  (let* ((pulse (+ 0.5 (* 0.5 (sin (* elapsed 9.0)))))
         (a (round (* 190 pulse)))
         (r (+ (/ reach 2) 12))
         (col (make-color 255 255 255 a)))
    (jrpg-fill-rect (- cx r) (- cy r) 16 3 col)
    (jrpg-fill-rect (- cx r) (- cy r) 3 16 col)
    (jrpg-fill-rect (- (+ cx r) 16) (- cy r) 16 3 col)
    (jrpg-fill-rect (- (+ cx r) 3) (- cy r) 3 16 col)
    (jrpg-fill-rect (- cx r) (- (+ cy r) 3) 16 3 col)
    (jrpg-fill-rect (- cx r) (- (+ cy r) 16) 3 16 col)
    (jrpg-fill-rect (- (+ cx r) 16) (- (+ cy r) 3) 16 3 col)
    (jrpg-fill-rect (- (+ cx r) 3) (- (+ cy r) 16) 3 16 col)))

(defun jrpg-draw-combat-figure (cx cy hit guard)
  "The traveller, larger than the overworld figure and facing the foe; an arm
comes up when guarding, and the whole body flares white on a hit."
  (let* ((s 5)
         (col (make-color 255 255 255 (if hit 255 230))))
    (flet ((rect (dx dy w h)
             (jrpg-fill-rect (+ cx (* dx s)) (+ cy (* dy s))
                             (* w s) (* h s) col)))
      (rect -1.5 -8 3 3)        ; head
      (rect -2.0 -5 4 5)        ; torso
      (rect -2.0  0 1.6 4)      ; left leg
      (rect  0.4  0 1.6 4)      ; right leg
      (if guard
          (rect 1.8 -4 2.2 1.4) ; arm braced forward
          (rect 2.0 -4 1.4 1.4))) ; arm
    (when hit
      (jrpg-fill-rect (- cx (* 3 s)) (- cy (* 9 s)) (* 7 s) (* 14 s)
                      (make-color 255 255 255 120)))))

(defun draw-jrpg-combat-enemy (game ox oy)
  (multiple-value-bind (ax ay) (jrpg-enemy-anchor)
    (let* ((act (jrpg-combat-action game))
           (acting (and (eq (jrpg-combat-phase game) :anim) act
                        (eq (jrpg-act-actor act) :enemy)))
           (lunge (if acting (- (jrpg-act-lunge (jrpg-act-clock act) 56.0)) 0.0))
           (x (+ ax ox lunge (jrpg-combat-enemy-recoil game)))
           (y (+ ay oy))
           (e (jrpg-combat-elapsed game))
           (scale 7)
           (sprite (jrpg-enemy-sprite (jrpg-combat-enemy-kind game)))
           (rows (length sprite))
           (cols (length (aref sprite 0)))
           (sw (* cols scale))
           (sh (* rows scale))
           (top (- y (/ sh 2))))
      (draw-centered-text (jrpg-combat-enemy-name game) x (- y (/ sh 2) 18) 20
                          (make-color 255 255 255 232))
      (when (jrpg-combat-enemy-winding game)
        (draw-jrpg-windup x y sw e))
      (draw-jrpg-slime-shadow x (+ y (/ sh 2) 6) e)
      (draw-jrpg-enemy-sprite sprite x top scale e)
      (when (plusp (jrpg-combat-flash-enemy game))
        (jrpg-fill-rect (- x (/ sw 2)) top sw sh
                        (make-color 255 255 255
                                    (round (* 200 (/ (jrpg-combat-flash-enemy game) 0.2))))))
      (draw-jrpg-bar (- x 70) (+ y (/ sh 2) 18) 140 10
                     (/ (jrpg-combat-enemy-hp game)
                        (max 1 (jrpg-combat-enemy-max-hp game)))
                     (/ (jrpg-combat-enemy-hp-shown game)
                        (max 1 (jrpg-combat-enemy-max-hp game))))
      (draw-centered-text (format nil "~d/~d"
                                  (jrpg-combat-enemy-hp game)
                                  (jrpg-combat-enemy-max-hp game))
                          x (+ y (/ sh 2) 38) 15 (make-color 255 255 255 200)))))

(defun draw-jrpg-combat-hero (game ox oy)
  (multiple-value-bind (ax ay) (jrpg-hero-anchor)
    (let* ((act (jrpg-combat-action game))
           (acting (and (eq (jrpg-combat-phase game) :anim) act
                        (eq (jrpg-act-actor act) :hero)
                        (member (jrpg-act-kind act) '(:attack :skill))))
           (lunge (if acting (jrpg-act-lunge (jrpg-act-clock act) 54.0) 0.0))
           (x (+ ax ox lunge (jrpg-combat-hero-recoil game)))
           (y (+ ay oy)))
      (jrpg-draw-combat-figure x y
                               (plusp (jrpg-combat-flash-hero game))
                               (jrpg-combat-guarding game))
      (draw-centered-text (string-upcase (jrpg-hero-name)) x (- y 58) 17
                          (make-color 255 255 255 220)))))

(defun draw-jrpg-combat-stats (game ox oy)
  (let ((bx (+ 228 ox)) (by (+ 428 oy))
        (max-hp (jrpg-number "jrpg-hero-max-hp" 18)))
    (draw-jrpg-box bx by 300 118)
    (draw-jrpg-line (string-upcase (jrpg-hero-name)) (+ bx 18) (+ by 12) 18)
    (draw-jrpg-line "HP" (+ bx 18) (+ by 38) 15 200)
    (draw-jrpg-bar (+ bx 66) (+ by 39) 132 12
                   (/ (jrpg-number "jrpg-hero-hp") (max 1 max-hp))
                   (/ (jrpg-combat-hero-hp-shown game) (max 1 max-hp)))
    (draw-jrpg-line (format nil "~d/~d" (jrpg-number "jrpg-hero-hp") max-hp)
                    (+ bx 206) (+ by 37) 14 200)
    (draw-jrpg-line "WILL" (+ bx 18) (+ by 62) 15 200)
    (draw-jrpg-bar (+ bx 66) (+ by 63) 132 12
                   (/ (jrpg-composure) (max 1 (jrpg-composure-max)))
                   (/ (jrpg-composure) (max 1 (jrpg-composure-max)))
                   :yellow t)
    (unless (jrpg-composed-p)
      (draw-jrpg-line "UNMASKED" (+ bx 206) (+ by 61) 13 220))
    (draw-jrpg-line (format nil "MP ~d" (jrpg-number "jrpg-hero-mp")) (+ bx 18) (+ by 88) 16)
    (draw-jrpg-line (format nil "~d Hr" (jrpg-hours)) (+ bx 116) (+ by 88) 16)
    (draw-jrpg-line (format nil "Lv ~d" (jrpg-number "jrpg-hero-level" 1)) (+ bx 214) (+ by 88) 16)))

(defun draw-jrpg-combat-commands (game ox oy)
  (let ((bx (+ 540 ox)) (by (+ 428 oy)))
    (draw-jrpg-box bx by 232 118)
    (loop for i from 0 below (jrpg-combat-command-count)
          for label = (getf (aref *jrpg-combat-commands* i) :label)
          for sel = (= i (jrpg-combat-selected game))
          do (draw-jrpg-line (if sel (format nil "> ~a" label) (format nil "  ~a" label))
                             (+ bx 18) (+ by 10 (* i 20)) 16 (if sel 235 165)))))

(defun draw-jrpg-combat-skills (game ox oy)
  (let* ((bx (+ 540 ox)) (by (+ 428 oy))
         (skills (jrpg-combat-skill-list))
         (n (length skills))
         (idx (min (jrpg-combat-skill-index game) (1- n))))
    (draw-jrpg-box bx by 232 118)
    (loop for i from 0 below n
          for sk = (nth i skills)
          for sel = (= i idx)
          do (draw-jrpg-line (if sel (format nil "> ~a" (getf sk :label))
                                 (format nil "  ~a" (getf sk :label)))
                             (+ bx 14) (+ by 8 (* i 22)) 15 (if sel 235 160)))
    (draw-jrpg-line (or (getf (nth idx skills) :note) "") (+ bx 14) (+ by 80) 12 150)
    (draw-jrpg-line "esc: back" (+ bx 14) (+ by 98) 12 130)))

(defun draw-jrpg-combat-items (game ox oy)
  (let* ((bx (+ 540 ox)) (by (+ 428 oy))
         (items (jrpg-combat-item-list))
         (idx (min (jrpg-combat-skill-index game) (max 0 (1- (length items))))))
    (draw-jrpg-box bx by 232 118)
    (if (null items)
        (draw-jrpg-line "  (nothing to use)" (+ bx 14) (+ by 8) 14 150)
        (loop for i from 0 below (length items)
              for it = (nth i items)
              for sel = (= i idx)
              do (draw-jrpg-line (if sel (format nil "> ~a" (getf it :label))
                                     (format nil "  ~a" (getf it :label)))
                                 (+ bx 14) (+ by 8 (* i 22)) 15 (if sel 235 160))))
    (draw-jrpg-line (or (and items (getf (nth idx items) :note)) "") (+ bx 14) (+ by 80) 12 150)
    (draw-jrpg-line "esc: back" (+ bx 14) (+ by 98) 12 130)))

(defun draw-jrpg-combat-message (game ox oy)
  (let* ((bx (+ 228 ox)) (by (+ 574 oy))
         (all (wrap-text-lines (jrpg-combat-message game) 18 796))
         (lines (if (> (length all) 2) (subseq all 0 2) all))
         (n (max 1 (length lines)))
         (top (+ by (max 0 (floor (- 58 (* n 22)) 2)) 2)))
    (draw-jrpg-box bx by 842 58)
    (loop for line in lines
          for i from 0
          do (draw-jrpg-line line (+ bx 22) (+ top (* i 22)) 18))))

(defun jrpg-draw-sparks (game ox oy)
  (dolist (s (jrpg-combat-sparks game))
    (let* ((age (getf s :age)) (ttl (getf s :ttl))
           (alpha (round (* 255 (max 0.0 (- 1.0 (/ age ttl))))))
           (col (if (getf s :yellow) (yellow-sign-color alpha)
                    (make-color 255 255 255 alpha))))
      (jrpg-fill-rect (+ (getf s :x) ox) (+ (getf s :y) oy)
                      (getf s :size) (getf s :size) col))))

(defun jrpg-draw-floaters (game ox oy)
  (dolist (f (jrpg-combat-floaters game))
    (let* ((age (getf f :age)) (ttl (getf f :ttl))
           (frac (/ age ttl))
           (alpha (round (* 255 (if (> frac 0.6) (max 0.0 (- 1.0 (/ (- frac 0.6) 0.4))) 1.0))))
           (size (if (getf f :crit) 30 21))
           (col (if (getf f :yellow) (yellow-sign-color alpha)
                    (make-color 255 255 255 alpha))))
      (draw-centered-text (getf f :text) (+ (getf f :x) ox) (+ (getf f :y) oy) size col))))

(defun draw-jrpg-combat-minigame (node color)
  (declare (ignore color))
  (let* ((game (ensure-jrpg-combat node))
         (sh (jrpg-combat-shake game))
         (e (jrpg-combat-elapsed game))
         (ox (if (> sh 0.4) (* sh (sin (* e 47.0))) 0.0))
         (oy (if (> sh 0.4) (* sh 0.55 (sin (* e 59.0))) 0.0)))
    (draw-jrpg-box (+ +jrpg-combat-left+ ox) (+ +jrpg-combat-top+ oy)
                   +jrpg-combat-width+ +jrpg-combat-height+ 208)
    (draw-centered-text (jrpg-class-name) +virtual-center-x+ 152 14
                        (make-color 255 255 255 120))
    (draw-jrpg-combat-enemy game ox oy)
    (draw-jrpg-combat-hero game ox oy)
    (draw-jrpg-combat-stats game ox oy)
    (case (jrpg-combat-submenu game)
      (:skill (draw-jrpg-combat-skills game ox oy))
      (:item  (draw-jrpg-combat-items game ox oy))
      (t      (draw-jrpg-combat-commands game ox oy)))
    (draw-jrpg-combat-message game ox oy)
    (jrpg-draw-sparks game ox oy)
    (jrpg-draw-floaters game ox oy)))

;;; A compact, read-only summary card - class, stats, Hours, worn gear. Shared:
;;; the overworld pulls it up with C; other screens can reuse it.

(defun jrpg-draw-stat-card (left top)
  (draw-jrpg-box left top 380 286 240)
  (draw-jrpg-line (string-upcase (jrpg-hero-name)) (+ left 20) (+ top 16) 20)
  (draw-text-at (jrpg-class-name) (+ left 20) (+ top 44) 15 (yellow-sign-color 230))
  (draw-jrpg-line (format nil "HP ~d/~d    MP ~d"
                          (jrpg-number "jrpg-hero-hp") (jrpg-number "jrpg-hero-max-hp" 18)
                          (jrpg-number "jrpg-hero-mp"))
                  (+ left 20) (+ top 74) 16)
  (draw-jrpg-line (format nil "ATK ~d    DEF ~d    WILL ~d/~d"
                          (jrpg-number "jrpg-hero-attack" 5) (jrpg-number "jrpg-hero-defense" 2)
                          (jrpg-composure) (jrpg-composure-max))
                  (+ left 20) (+ top 98) 16)
  (draw-jrpg-line (format nil "LV ~d    ~d Hours"
                          (jrpg-number "jrpg-hero-level" 1) (jrpg-hours))
                  (+ left 20) (+ top 122) 16)
  (draw-jrpg-line "WORN" (+ left 20) (+ top 154) 15 200)
  (loop with y = (+ top 178)
        for slot in *jrpg-equip-slots*
        for id = (jrpg-equipped-in slot)
        do (draw-jrpg-line (format nil "~6a ~a" (string-downcase (symbol-name slot))
                                   (if id (jrpg-item-name id) "-"))
                           (+ left 20) y 15 (if id 215 150))
           (incf y 22))
  (draw-jrpg-line "C or esc: close" (+ left 20) (+ top 256) 13 150))

(dialog-minigame-kind :jrpg-combat
                      :update #'update-jrpg-combat-minigame
                      :draw #'draw-jrpg-combat-minigame)
