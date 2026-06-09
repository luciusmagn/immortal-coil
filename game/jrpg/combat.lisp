(in-package #:immortal-coil)

(defconstant +jrpg-combat-left+ 210)
(defconstant +jrpg-combat-top+ 168)
(defconstant +jrpg-combat-width+ 860)
(defconstant +jrpg-combat-height+ 404)

(defparameter *jrpg-combat-commands*
  #("ATTACK" "MAGIC" "ITEM" "RUN"))

(defvar *jrpg-combat* nil)

(defstruct jrpg-combat
  (node-id       *runtime-fallback-node-id*)
  (enemy-name    "SLIME")
  (enemy-hp      14)
  (enemy-max-hp  14)
  (selected      0)
  (message       "a slime draws near.")
  (finish-target nil)
  (finish-delay  0.0))

(defun make-fresh-jrpg-combat (node)
  (jrpg-init-state)
  (make-jrpg-combat :node-id (node-id node)
                    :enemy-name "SLIME"
                    :enemy-hp 14
                    :enemy-max-hp 14
                    :selected 0
                    :message "a slime draws near."
                    :finish-target nil
                    :finish-delay 0.0))

(defun ensure-jrpg-combat (node)
  (unless (and *jrpg-combat*
               (equal (jrpg-combat-node-id *jrpg-combat*)
                      (node-id node)))
    (setf *jrpg-combat* (make-fresh-jrpg-combat node)))
  *jrpg-combat*)

(defun jrpg-combat-command-count ()
  (length *jrpg-combat-commands*))

(defun jrpg-combat-horizontal-input-p ()
  (or (is-key-pressed-p +key-left+)
      (is-key-pressed-p +key-a+)
      (is-key-pressed-p +key-right+)
      (is-key-pressed-p +key-d+)))

(defun jrpg-combat-vertical-input-p ()
  (or (is-key-pressed-p +key-down+)
      (is-key-pressed-p +key-s+)
      (is-key-pressed-p +key-up+)
      (is-key-pressed-p +key-w+)))

(defun jrpg-combat-selection-target (selected)
  (cond
    ((jrpg-combat-horizontal-input-p)
     (if (< selected 2)
         (+ selected 2)
         (- selected 2)))
    ((jrpg-combat-vertical-input-p)
     (if (evenp selected)
         (1+ selected)
         (1- selected)))))

(defun jrpg-combat-move-selection (game)
  (let ((target (jrpg-combat-selection-target
                 (jrpg-combat-selected game))))
    (when target
      (setf (jrpg-combat-selected game) target)
      (play-choice-switch))))

(defun jrpg-combat-finish (game target)
  (setf (jrpg-combat-finish-target game) target
        (jrpg-combat-finish-delay game) 0.9))

(defun jrpg-combat-hero-attack ()
  (+ (jrpg-number "jrpg-hero-attack" 5)
     (get-random-value 0 2)))

(defun jrpg-combat-enemy-attack ()
  (max 1 (- (get-random-value 3 6)
            (jrpg-number "jrpg-hero-defense" 2))))

(defun jrpg-combat-enemy-alive-p (game)
  (plusp (jrpg-combat-enemy-hp game)))

(defun jrpg-combat-damage-enemy (game amount)
  (setf (jrpg-combat-enemy-hp game)
        (max 0 (- (jrpg-combat-enemy-hp game) amount))))

(defun jrpg-combat-victory (node game)
  (jrpg-award-victory :xp 4 :gold 6)
  (setf (jrpg-combat-message game)
        "the slime is defeated.")
  (jrpg-combat-finish game (node-success-target node)))

(defun jrpg-combat-defeat (node game)
  (jrpg-record-defeat)
  (setf (jrpg-combat-message game)
        "you fall down in the road.")
  (jrpg-combat-finish game (node-failure-target node)))

(defun jrpg-combat-enemy-turn (node game)
  (let ((damage (jrpg-combat-enemy-attack)))
    (jrpg-damage-hero damage)
    (if (jrpg-hero-alive-p)
        (setf (jrpg-combat-message game)
              (format nil "the slime hits you for ~d." damage))
        (jrpg-combat-defeat node game))))

(defun jrpg-combat-attack-command (node game)
  (let ((damage (jrpg-combat-hero-attack)))
    (jrpg-combat-damage-enemy game damage)
    (if (jrpg-combat-enemy-alive-p game)
        (progn
          (setf (jrpg-combat-message game)
                (format nil "you hit the slime for ~d." damage))
          (jrpg-combat-enemy-turn node game))
        (jrpg-combat-victory node game))))

(defun jrpg-combat-magic-command (node game)
  (if (plusp (jrpg-number "jrpg-hero-mp"))
      (let ((damage (+ 7 (get-random-value 0 3))))
        (jrpg-adjust-number "jrpg-hero-mp" -1)
        (jrpg-combat-damage-enemy game damage)
        (if (jrpg-combat-enemy-alive-p game)
            (progn
              (setf (jrpg-combat-message game)
                    (format nil "the spell deals ~d." damage))
              (jrpg-combat-enemy-turn node game))
            (jrpg-combat-victory node game)))
      (setf (jrpg-combat-message game)
            "nothing happens. you have no mp.")))

(defun jrpg-combat-item-command (node game)
  (if (jrpg-use-potion)
      (progn
        (setf (jrpg-combat-message game)
              "you drink a potion.")
        (jrpg-combat-enemy-turn node game))
      (setf (jrpg-combat-message game)
            "the bag is empty.")))

(defun jrpg-combat-run-command (node game)
  (jrpg-record-retreat)
  (setf (jrpg-combat-message game)
        "you run back to the road sign.")
  (jrpg-combat-finish game (node-success-target node)))

(defun jrpg-combat-confirm-command (node game)
  (play-start-confirm)
  (case (jrpg-combat-selected game)
    (0 (jrpg-combat-attack-command node game))
    (1 (jrpg-combat-magic-command node game))
    (2 (jrpg-combat-item-command node game))
    (3 (jrpg-combat-run-command node game))))

(defun update-jrpg-combat-minigame (node dt)
  (let ((game (ensure-jrpg-combat node)))
    (cond
      ((jrpg-combat-finish-target game)
       (decf (jrpg-combat-finish-delay game) dt)
       (when (<= (jrpg-combat-finish-delay game) 0.0)
         (let ((target (jrpg-combat-finish-target game)))
           (setf *jrpg-combat* nil)
           (jump-to-dialog-target target))))
      (t
       (jrpg-combat-move-selection game)
       (when (confirm-pressed-p)
         (jrpg-combat-confirm-command node game))))))

(defun draw-jrpg-box (left top width height &optional (alpha 235))
  (claylib/ll:draw-rectangle (round left)
                             (round top)
                             (round width)
                             (round height)
                             (claylib::c-ptr
                              (make-color 0 0 0 alpha)))
  (draw-rectangle-outline left
                          top
                          width
                          height
                          (make-color 255 255 255 230)
                          :thickness 2))

(defun draw-jrpg-line (text x y &optional (size 18) (alpha 230))
  (draw-text-at text
                x
                y
                size
                (make-color 255 255 255 alpha)))

(defun draw-jrpg-combat-enemy (game)
  (let ((x (+ +jrpg-combat-left+ 570))
        (y (+ +jrpg-combat-top+ 72)))
    (draw-centered-text (jrpg-combat-enemy-name game)
                        x
                        (- y 42)
                        20
                        (make-color 255 255 255 232))
    (draw-centered-text "o"
                        x
                        y
                        72
                        (make-color 255 255 255 220))
    (draw-centered-text "/|\\"
                        x
                        (+ y 52)
                        30
                        (make-color 255 255 255 210))
    (draw-centered-text
     (format nil "HP ~d/~d"
             (jrpg-combat-enemy-hp game)
             (jrpg-combat-enemy-max-hp game))
     x
     (+ y 112)
     16
     (make-color 255 255 255 210))))

(defun draw-jrpg-combat-stats ()
  (draw-jrpg-box 228 428 284 118)
  (draw-jrpg-line (string-upcase (jrpg-hero-name))
                  250
                  448
                  18)
  (draw-jrpg-line (format nil "HP ~d/~d"
                          (jrpg-number "jrpg-hero-hp")
                          (jrpg-number "jrpg-hero-max-hp" 18))
                  250 474 18)
  (draw-jrpg-line (format nil "MP ~d" (jrpg-number "jrpg-hero-mp"))
                  250 500 18)
  (draw-jrpg-line (format nil "G ~d" (jrpg-number "jrpg-gold"))
                  382 500 18))

(defun draw-jrpg-combat-commands (game)
  (draw-jrpg-box 530 428 240 118)
  (loop for i from 0 below (jrpg-combat-command-count)
        for label = (aref *jrpg-combat-commands* i)
        for x = (if (< i 2) 560 660)
        for y = (+ 452 (* (mod i 2) 34))
        do (draw-jrpg-line (if (= i (jrpg-combat-selected game))
                               (format nil "> ~a" label)
                               (format nil "  ~a" label))
                           x
                           y
                           18)))

(defun draw-jrpg-combat-message (game)
  (draw-jrpg-box 228 574 842 54)
  (draw-jrpg-line (jrpg-combat-message game) 250 591 18))

(defun draw-jrpg-combat-minigame (node color)
  (declare (ignore color))
  (let ((game (ensure-jrpg-combat node)))
    (draw-jrpg-box +jrpg-combat-left+
                   +jrpg-combat-top+
                   +jrpg-combat-width+
                   +jrpg-combat-height+
                   208)
    (draw-jrpg-combat-enemy game)
    (draw-jrpg-combat-stats)
    (draw-jrpg-combat-commands game)
    (draw-jrpg-combat-message game)))

(dialog-minigame-kind :jrpg-combat
                      :update #'update-jrpg-combat-minigame
                      :draw #'draw-jrpg-combat-minigame)
