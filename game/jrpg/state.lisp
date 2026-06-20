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
    ("jrpg-companion" . "Lena")
    ("jrpg-companion-role" . "childhood friend")
    ("jrpg-village-errand" . "none")
    ("jrpg-route" . "north road")))

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
  (jrpg-adjust-number "jrpg-xp" xp)
  (jrpg-adjust-number "jrpg-gold" gold)
  (jrpg-adjust-number "jrpg-slimes-defeated" 1)
  (setf (jrpg-value "jrpg-last-battle") "victory"
        (jrpg-value "jrpg-just-leveled") (jrpg-level-up-check)))

(defun jrpg-record-defeat ()
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
