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
    ("jrpg-potions" . 1)
    ("jrpg-slimes-defeated" . 0)
    ("jrpg-route" . "north road")))

(defun jrpg-value (key &optional default)
  (dialog-value key default))

(defun (setf jrpg-value) (value key &optional default)
  (setf (dialog-value key default) value))

(defun jrpg-init-state ()
  (dolist (entry *jrpg-stat-defaults*)
    (unless (dialog-store-bound-p (first entry))
      (setf (jrpg-value (first entry)) (rest entry)))))

(defun jrpg-set-companion (name)
  (jrpg-init-state)
  (setf (jrpg-value "jrpg-companion") name))

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

(defun jrpg-award-victory (&key (xp 3) (gold 5))
  (jrpg-adjust-number "jrpg-xp" xp)
  (jrpg-adjust-number "jrpg-gold" gold)
  (jrpg-adjust-number "jrpg-slimes-defeated" 1)
  (setf (jrpg-value "jrpg-last-battle") "victory"))

(defun jrpg-record-defeat ()
  (setf (jrpg-value "jrpg-last-battle") "defeat"))

(defun jrpg-record-retreat ()
  (setf (jrpg-value "jrpg-last-battle") "retreat"))

(defun jrpg-companion ()
  (jrpg-value "jrpg-companion" "the childhood friend"))

(defun jrpg-hero-name ()
  (let ((name (jrpg-value "player-name" "HERO")))
    (if (and (stringp name)
             (plusp (length name)))
        name
        "HERO")))
