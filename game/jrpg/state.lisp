(in-package #:immortal-coil)

(defparameter *jrpg-stat-defaults*
  '(("jrpg-hero-level" . 1)
    ("jrpg-hero-max-hp" . 18)
    ("jrpg-hero-hp" . 18)
    ("jrpg-hero-mp" . 4)
    ("jrpg-hero-attack" . 5)
    ("jrpg-hero-defense" . 2)
    ("jrpg-gold" . 12)
    ("jrpg-xp" . 0)
    ;; hours: the path's soul-currency - earned from foes, spent on gear and
    ;; levels, scattered on death (to jrpg-lost-hours) and reclaimed on the next
    ;; victory. The King is a time-god; the Sign-touched trade in time.
    ("jrpg-hours" . 8)
    ("jrpg-lost-hours" . 0)
    ("jrpg-potions" . 1)
    ("jrpg-slimes-defeated" . 0)
    ("jrpg-companion" . "Lena")
    ("jrpg-companion-role" . "childhood friend")
    ("jrpg-village-errand" . "none")
    ("jrpg-route" . "shore road")
    ;; Carcosa: composure is the will to keep your own face on. the King, the
    ;; masque, and the second act of the Play spend it; the lake and rest mend
    ;; it. the world's recoverable things live here too.
    ("jrpg-composure" . 10)
    ("jrpg-composure-max" . 10)
    ("jrpg-play-scraps" . 0)
    ("jrpg-second-act" . 0)
    ("jrpg-mask-shard" . 0)
    ("jrpg-yellow-sign" . nil)))

(defun jrpg-value (key &optional default)
  (dialog-value key default))

(defun (setf jrpg-value) (value key &optional default)
  (setf (dialog-value key default) value))

(defun jrpg-init-state ()
  (dolist (entry *jrpg-stat-defaults*)
    (unless (dialog-store-bound-p (first entry))
      (setf (jrpg-value (first entry)) (rest entry)))))

(defun jrpg-set-companion (name &optional (role "companion"))
  (jrpg-init-state)
  (setf (jrpg-value "jrpg-companion") name
        (jrpg-value "jrpg-companion-role") role))

(defun jrpg-number (key &optional (default 0))
  (let ((value (jrpg-value key default)))
    (if (numberp value)
        value
        default)))

(defun jrpg-set-number (key value)
  (setf (jrpg-value key) value))

(defun jrpg-adjust-number (key amount &optional (default 0))
  (jrpg-set-number key (+ (jrpg-number key default) amount)))

(defun jrpg-clamp-hp ()
  (jrpg-set-number "jrpg-hero-hp"
                   (max 0
                        (min (jrpg-number "jrpg-hero-hp")
                             (jrpg-number "jrpg-hero-max-hp" 18)))))

(defun jrpg-heal (amount)
  (jrpg-adjust-number "jrpg-hero-hp" amount)
  (jrpg-clamp-hp))

(defun jrpg-damage-hero (amount)
  (jrpg-adjust-number "jrpg-hero-hp" (- amount))
  (jrpg-clamp-hp))

(defun jrpg-hero-alive-p ()
  (plusp (jrpg-number "jrpg-hero-hp")))

(defun jrpg-use-potion ()
  (when (plusp (jrpg-number "jrpg-potions"))
    (jrpg-adjust-number "jrpg-potions" -1)
    (jrpg-heal 9)
    t))

;;; Carcosa: composure (the will to keep your own face on) and the world's
;;; recoverable things.

(defun jrpg-composure ()
  (jrpg-number "jrpg-composure" 10))

(defun jrpg-composure-max ()
  (jrpg-number "jrpg-composure-max" 10))

(defun jrpg-spend-composure (amount)
  "Lose composure; never below zero. Returns the remaining composure."
  (jrpg-set-number "jrpg-composure" (max 0 (- (jrpg-composure) amount)))
  (jrpg-composure))

(defun jrpg-restore-composure (amount)
  (jrpg-set-number "jrpg-composure"
                   (min (jrpg-composure-max) (+ (jrpg-composure) amount))))

(defun jrpg-composed-p ()
  "True while the player can still hold their own face - refuse the throne,
leave the masque, keep the mask on."
  (plusp (jrpg-composure)))

(defun jrpg-grant-item (key &optional (amount 1))
  "Recover something from the world (a scrap of the Play, a mask shard, a
flask of Hali-water). Stored so later scenes and mods can read the haul."
  (jrpg-adjust-number key amount))

(defun jrpg-mark-yellow-sign ()
  (setf (jrpg-value "jrpg-yellow-sign") t))

(defun jrpg-has-yellow-sign-p ()
  (and (jrpg-value "jrpg-yellow-sign") t))

(defun jrpg-xp-to-next (level)
  "Experience needed to clear the given level."
  (+ 8 (* (max 1 level) 6)))

(defun jrpg-level-up-check ()
  "Spend banked xp on levels. Returns the new level if any gained, else nil."
  (let ((leveled nil))
    (loop
      (let* ((level (jrpg-number "jrpg-hero-level" 1))
             (xp (jrpg-number "jrpg-xp" 0))
             (need (jrpg-xp-to-next level)))
        (if (>= xp need)
            (progn
              (jrpg-set-number "jrpg-xp" (- xp need))
              (jrpg-set-number "jrpg-hero-level" (1+ level))
              (jrpg-adjust-number "jrpg-hero-max-hp" 5)
              (jrpg-adjust-number "jrpg-hero-attack" 1)
              (when (evenp (1+ level))
                (jrpg-adjust-number "jrpg-hero-mp" 1))
              (jrpg-set-number "jrpg-hero-hp"
                               (jrpg-number "jrpg-hero-max-hp" 18))
              (setf leveled (1+ level)))
            (return))))
    leveled))

(defun jrpg-award-victory (&key (xp 3) (gold 5))
  "Victory pays HOURS (the soul-currency = the old xp + gold). Getting back up
after a fall also reclaims the hours you scattered. Leveling is now manual
(spend hours; see jrpg-level-up), so no automatic level here."
  (let ((gained (+ xp gold)))
    (jrpg-adjust-number "jrpg-hours" gained)
    (jrpg-adjust-number "jrpg-slimes-defeated" 1)
    (let ((lost (jrpg-number "jrpg-lost-hours" 0)))
      (when (plusp lost)
        (jrpg-adjust-number "jrpg-hours" lost)
        (jrpg-set-number "jrpg-lost-hours" 0)
        (incf gained lost)))
    (setf (jrpg-value "jrpg-last-battle") "victory"
          (jrpg-value "jrpg-just-gained") gained)))

(defun jrpg-record-defeat ()
  "Falling scatters half your carried hours into the dark; reclaim them by
winning your next fight. A second fall before then forfeits the old pool."
  (let* ((carried (jrpg-number "jrpg-hours" 0))
         (drop (floor carried 2)))
    (jrpg-set-number "jrpg-hours" (- carried drop))
    (jrpg-set-number "jrpg-lost-hours" drop))
  (setf (jrpg-value "jrpg-last-battle") "defeat"))

(defun jrpg-record-retreat ()
  (setf (jrpg-value "jrpg-last-battle") "retreat"))

(defun jrpg-companion ()
  (jrpg-value "jrpg-companion" "Lena"))

(defun jrpg-companion-role ()
  (jrpg-value "jrpg-companion-role" "childhood friend"))

(defun jrpg-hero-name ()
  (let ((name (jrpg-value "player-name" "HERO")))
    (if (and (stringp name)
             (plusp (length name)))
        name
        "HERO")))
