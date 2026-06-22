(in-package #:immortal-coil)

;;; Gear, inventory, equipment, classes, and quests for the King in Yellow path.
;;; Base stats live in state.lisp. Equipping an item APPLIES its modifiers to the
;;; stored stats (and reverts on unequip), so combat needs no special-casing - it
;;; already reads jrpg-hero-attack/defense/composure-max. The CLASS is never
;;; chosen: it is inferred from how the player moves through the stories (leans
;;; tallied at choices), so "you have always been it." A light quest log too.


;;; --- items ---

(defparameter *jrpg-items*
  ;; id -> (:name n :slot s :mods (stat amt ...) :desc d :consumable bool)
  '((:palette-knife :name "palette knife" :slot :weapon :mods (:attack 3)
     :desc "a painter's knife, kept sharp. it cuts more than canvas.")
    (:sign-clasp :name "Yellow Sign clasp" :slot :charm :mods (:defense 1 :composure-max 2)
     :desc "onyx and gold, the Sign worked in; colder than metal should be.")
    (:dys-glove :name "warm glove" :slot :charm :mods (:composure-max 1)
     :desc "a woman's glove, still warm, five centuries cold.")
    (:crown :name "the pallid crown" :slot :relic :mods (:attack 4 :defense 4 :composure-max -4)
     :desc "the diadem of the Last King. it weighs nothing, and everything.")
    (:marble-phial :name "phial of marble-fluid" :consumable t
     :desc "the fluid that turns the living to marble; a kinder way to stop.")
    (:hali-water :name "flask of Hali-water" :consumable t
     :desc "lake-water that keeps what it touches. it steadies the will.")
    (:watchman-club :name "watchman's club" :slot :weapon :mods (:attack 5)
     :desc "worn smooth by a hand that did not tire. heavier than the knife.")
    (:mourners-locket :name "mourner's locket" :slot :charm :mods (:composure-max 3)
     :desc "someone's hair coiled inside; it keeps your face yours a little longer.")
    (:pallid-mask :name "pallid mask" :slot :charm :mods (:defense 2 :composure-max 2)
     :desc "a featureless mask; what is under it is your own business now.")
    (:tatter-shroud :name "tatter-shroud" :slot :relic :mods (:defense 3 :composure-max 1)
     :desc "a shred of the King's own mantle, still warm with someone's last hour.")))

(defun jrpg-item (id) (cdr (assoc id *jrpg-items*)))
(defun jrpg-item-name (id) (or (getf (jrpg-item id) :name) (string-downcase (symbol-name id))))
(defun jrpg-item-slot (id) (getf (jrpg-item id) :slot))
(defun jrpg-item-mods (id) (getf (jrpg-item id) :mods))
(defun jrpg-item-desc (id) (or (getf (jrpg-item id) :desc) ""))
(defun jrpg-item-consumable-p (id) (getf (jrpg-item id) :consumable))


;;; --- inventory (store: a list of item-id keywords; consumables may stack) ---

(defun jrpg-inventory () (jrpg-value "jrpg-inventory" nil))
(defun jrpg-has-item-p (id) (and (member id (jrpg-inventory)) t))
(defun jrpg-item-count (id) (count id (jrpg-inventory)))

;;; --- equipment: applying mods to the stored stats ---

(defparameter *jrpg-equip-slots* '(:weapon :charm :relic))

(defun jrpg-equip-key (slot) (format nil "jrpg-equip-~a" (string-downcase (symbol-name slot))))
(defun jrpg-equipped-in (slot) (jrpg-value (jrpg-equip-key slot)))
(defun jrpg-equipped-items ()
  (loop for s in *jrpg-equip-slots* for id = (jrpg-equipped-in s) when id collect id))

(defun jrpg-stat-key (stat)
  (ecase stat
    (:attack "jrpg-hero-attack")
    (:defense "jrpg-hero-defense")
    (:composure-max "jrpg-composure-max")
    (:max-hp "jrpg-hero-max-hp")))

(defun jrpg-apply-item-mods (id sign)
  (loop for (stat amt) on (jrpg-item-mods id) by #'cddr
        do (jrpg-adjust-number (jrpg-stat-key stat) (* sign amt))))

(defun jrpg-clamp-after-gear ()
  (jrpg-clamp-hp)
  (jrpg-set-number "jrpg-composure"
                   (max 0 (min (jrpg-composure) (jrpg-composure-max)))))

(defun jrpg-equip (id)
  "Equip ID into its slot (reverting whatever was there). Returns t on change."
  (jrpg-init-state)
  (let ((slot (jrpg-item-slot id)))
    (when (and slot (jrpg-has-item-p id) (not (eq (jrpg-equipped-in slot) id)))
      (let ((current (jrpg-equipped-in slot)))
        (when current (jrpg-apply-item-mods current -1)))
      (jrpg-apply-item-mods id 1)
      (setf (jrpg-value (jrpg-equip-key slot)) id)
      (jrpg-clamp-after-gear)
      t)))

(defun jrpg-unequip (slot)
  (let ((current (jrpg-equipped-in slot)))
    (when current
      (jrpg-apply-item-mods current -1)
      (setf (jrpg-value (jrpg-equip-key slot)) nil)
      (jrpg-clamp-after-gear)
      t)))

(defun jrpg-add-item (id)
  (jrpg-init-state)
  (when (or (jrpg-item-consumable-p id) (not (jrpg-has-item-p id)))
    (setf (jrpg-value "jrpg-inventory") (append (jrpg-inventory) (list id))))
  ;; auto-equip gear into an empty slot, so a pickup helps without a menu trip
  (let ((slot (jrpg-item-slot id)))
    (when (and slot (null (jrpg-equipped-in slot)))
      (jrpg-equip id)))
  id)

(defun jrpg-remove-item (id)
  (setf (jrpg-value "jrpg-inventory") (remove id (jrpg-inventory) :count 1)))

(defun jrpg-use-consumable (id)
  "Use a held consumable. Returns a short message, or nil if none/not usable."
  (when (and (jrpg-item-consumable-p id) (jrpg-has-item-p id))
    (prog1
        (case id
          (:hali-water (jrpg-restore-composure 4) "the lake-water steadies your will. +4.")
          (:marble-phial "you turn the phial in your hand. not yet.")
          (t "nothing happens."))
      (when (eq id :hali-water) (jrpg-remove-item id)))))


;;; --- classes: never chosen, inferred from leans tallied at choices ---

(defparameter *jrpg-classes*
  '((:repairer "REPAIRER OF REPUTATIONS"
     "you trade in names - making them, unmaking them, knowing the worst of them.")
    (:painter  "THE PALLID PAINTER"
     "you see the rot under the skin and the marble in the living, and set it down.")
    (:reader   "THE FAITHFUL READER"
     "the Play has your ear; you have begun to speak its lines back to it.")
    (:watchman "THE LAST WATCHMAN"
     "you stand your ground and put down whatever climbs the stair.")
    (:mourner  "THE MOURNER"
     "you love what time has already taken, and you follow it down.")))

;; tie-break order; :reader leads because everyone here has read the Play
(defparameter *jrpg-class-order* '(:reader :repairer :painter :watchman :mourner))

(defun jrpg-class-lean-key (id) (format nil "jrpg-lean-~a" (string-downcase (symbol-name id))))
(defun jrpg-class-lean (id) (jrpg-number (jrpg-class-lean-key id) 0))

(defun jrpg-resolved-class ()
  "The class with the most lean; ties go to the earlier of *jrpg-class-order*."
  (let ((best :reader) (best-n -1))
    (dolist (id *jrpg-class-order* best)
      (when (> (jrpg-class-lean id) best-n)
        (setf best id best-n (jrpg-class-lean id))))))

(defun jrpg-class-name (&optional (id (jrpg-resolved-class))) (second (assoc id *jrpg-classes*)))
(defun jrpg-class-desc (&optional (id (jrpg-resolved-class))) (third (assoc id *jrpg-classes*)))

(defun jrpg-refresh-class ()
  "Cache the resolved class so {jrpg-class-title} and :unless gates can read it."
  (jrpg-init-state)
  (setf (jrpg-value "jrpg-class") (jrpg-resolved-class)
        (jrpg-value "jrpg-class-title") (jrpg-class-name)))

(defun jrpg-lean-class (id &optional (n 1))
  (jrpg-init-state)
  (jrpg-set-number (jrpg-class-lean-key id) (+ (jrpg-class-lean id) n))
  (jrpg-refresh-class))


;;; --- quests (light: a few objectives that flip inactive -> active -> done) ---

(defparameter *jrpg-quests*
  '((:sign  "the Yellow Sign"   "find what marks you - and who sent it.")
    (:cross "the way to Carcosa" "follow the Sign's spread to the lake of Hali.")
    (:king  "the King unmasked"  "learn what the King in Yellow was, before the crown.")))

(defun jrpg-quest-key (id) (format nil "jrpg-quest-~a" (string-downcase (symbol-name id))))
(defun jrpg-quest-state (id) (or (jrpg-value (jrpg-quest-key id)) :inactive))
(defun jrpg-quest-title (id) (second (assoc id *jrpg-quests*)))
(defun jrpg-quest-desc (id) (third (assoc id *jrpg-quests*)))

(defun jrpg-start-quest (id)
  (jrpg-init-state)
  (when (eq (jrpg-quest-state id) :inactive)
    (setf (jrpg-value (jrpg-quest-key id)) :active)))

(defun jrpg-complete-quest (id)
  (jrpg-init-state)
  (setf (jrpg-value (jrpg-quest-key id)) :done))


;;; --- Hours: the soul-currency (the noun is capitalised in UI text so it does
;;; not read as a span of time). Earned/lost in state.lisp; spent here. ---

(defun jrpg-hours () (jrpg-number "jrpg-hours" 0))

(defun jrpg-add-hours (n) (jrpg-adjust-number "jrpg-hours" n))

(defun jrpg-spend-hours (n)
  "Spend N Hours if affordable; returns t on success."
  (when (>= (jrpg-hours) n)
    (jrpg-adjust-number "jrpg-hours" (- n))
    t))


;;; --- leveling: buy a level with Hours, on a rising curve ---

(defun jrpg-level-cost (&optional (level (jrpg-number "jrpg-hero-level" 1)))
  "Hours to buy the next level - a curve that climbs with the level you hold."
  (+ 20 (* 14 level) (* 5 level level)))

(defparameter *jrpg-level-stats*
  '((:hp      "VITALITY  +7 max hp")
    (:attack  "MIGHT     +2 attack")
    (:defense "GUARD     +2 defense")
    (:mp      "FOCUS     +2 mp")
    (:will    "WILL      +2 max will")))

(defun jrpg-level-up (stat)
  "Spend Hours (the curve) to gain a level, raising the chosen STAT. Returns the
new level, or nil if unaffordable. A level always mends you fully too."
  (jrpg-init-state)
  (when (jrpg-spend-hours (jrpg-level-cost))
    (let ((level (1+ (jrpg-number "jrpg-hero-level" 1))))
      (jrpg-set-number "jrpg-hero-level" level)
      (ecase stat
        (:hp      (jrpg-adjust-number "jrpg-hero-max-hp" 7))
        (:attack  (jrpg-adjust-number "jrpg-hero-attack" 2))
        (:defense (jrpg-adjust-number "jrpg-hero-defense" 2))
        (:mp      (jrpg-adjust-number "jrpg-hero-mp" 2))
        (:will    (jrpg-adjust-number "jrpg-composure-max" 2)))
      (jrpg-set-number "jrpg-hero-hp" (jrpg-number "jrpg-hero-max-hp" 18))
      (jrpg-restore-composure (jrpg-composure-max))
      level)))


;;; --- the shop: what the Sign-touched will sell for Hours ---

(defparameter *jrpg-shop-stock*
  '((:tonic 14) (:hali-water 18) (:watchman-club 64) (:mourners-locket 58)))

(defun jrpg-shop-label (key)
  (case key
    (:tonic "tonic (+9 hp, in battle)")
    (t (jrpg-item-name key))))

(defun jrpg-shop-buy (key cost)
  "Buy KEY for COST Hours if affordable; returns a short message. Generic over
any item id (gear is one-per-customer; tonics and consumables restock freely)."
  (cond
    ((< (jrpg-hours) cost) (format nil "you cannot spare ~d Hours." cost))
    ((and (not (jrpg-item-consumable-p key)) (jrpg-has-item-p key)) "you already carry that.")
    (t (jrpg-spend-hours cost)
       (cond
         ((eq key :tonic) (jrpg-adjust-number "jrpg-potions" 1)
          "a tonic, corked and waiting. bought.")
         ((jrpg-item key) (jrpg-add-item key)
          (format nil "~a - bought." (jrpg-item-name key)))
         (t "bought.")))))
