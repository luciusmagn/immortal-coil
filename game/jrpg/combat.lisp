(in-package #:immortal-coil)

(defconstant +jrpg-combat-left+ 210)
(defconstant +jrpg-combat-top+ 168)
(defconstant +jrpg-combat-width+ 860)
(defconstant +jrpg-combat-height+ 404)

(defparameter *jrpg-combat-commands*
  #("ATTACK" "MAGIC" "ITEM" "RUN"))

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

(defparameter *jrpg-enemy-sprites*
  (list (cons "slime" *jrpg-slime-sprite*)
        (cons "bat" *jrpg-bat-sprite*)
        (cons "goblin" *jrpg-goblin-sprite*)
        (cons "wolf" *jrpg-wolf-sprite*)))

(defun jrpg-enemy-sprite (kind)
  (or (cdr (assoc (string-downcase (or kind "slime"))
                  *jrpg-enemy-sprites*
                  :test #'string=))
      *jrpg-slime-sprite*))

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
  (selected         0)
  (message          "a slime draws near.")
  (elapsed          0.0)
  (finish-target    nil)
  (finish-delay     0.0))

(defun jrpg-combat-config-number (node key default)
  (let ((value (minigame-config-value node key default)))
    (if (numberp value)
        value
        default)))

(defun jrpg-combat-config-string (node key default)
  (let ((value (minigame-config-value node key default)))
    (if (stringp value)
        value
        default)))

(defun make-fresh-jrpg-combat (node)
  (jrpg-init-state)
  (let ((enemy-hp (jrpg-combat-config-number node :enemy-hp 14)))
    (make-jrpg-combat :node-id (node-id node)
                      :enemy-name (jrpg-combat-config-string node
                                                             :enemy-name
                                                             "SLIME")
                      :enemy-kind (jrpg-combat-config-string node
                                                             :enemy-kind
                                                             "slime")
                      :enemy-hp enemy-hp
                      :enemy-max-hp enemy-hp
                      :enemy-attack-min (jrpg-combat-config-number
                                         node
                                         :enemy-attack-min
                                         3)
                      :enemy-attack-max (jrpg-combat-config-number
                                         node
                                         :enemy-attack-max
                                         6)
                      :victory-xp (jrpg-combat-config-number node
                                                             :victory-xp
                                                             4)
                      :victory-gold (jrpg-combat-config-number node
                                                               :victory-gold
                                                               6)
                      :selected 0
                      :message (jrpg-combat-config-string
                                node
                                :message
                                "a slime draws near.")
                      :elapsed 0.0
                      :finish-target nil
                      :finish-delay 0.0)))

(defun ensure-jrpg-combat (node)
  (unless (and *jrpg-combat*
               (equal (jrpg-combat-node-id *jrpg-combat*)
                      (node-id node)))
    (setf *jrpg-combat* (make-fresh-jrpg-combat node)))
  *jrpg-combat*)

(defun jrpg-combat-command-count ()
  (length *jrpg-combat-commands*))

(defun jrpg-sound-path (name)
  (format nil "assets/audio/jrpg/~a.wav" name))

(defun play-jrpg-sound (name &key (volume *jrpg-combat-sfx-volume*))
  (handler-case
      (play-story-sound (jrpg-sound-path name) :volume volume)
    (error (condition)
      (runtime-warn "Could not play JRPG sound ~a: ~a"
                    name
                    condition))))

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
  "Returns (values damage crit-p); about one swing in six lands clean."
  (let ((base (+ (jrpg-number "jrpg-hero-attack" 5)
                 (get-random-value 0 2)))
        (crit (zerop (get-random-value 0 5))))
    (values (if crit (* 2 base) base) crit)))

(defun jrpg-combat-enemy-attack (game)
  "Returns (values damage heavy-p); about one blow in five comes hard."
  (let* ((heavy (zerop (get-random-value 0 4)))
         (raw (get-random-value (jrpg-combat-enemy-attack-min game)
                                (jrpg-combat-enemy-attack-max game)))
         (raw (if heavy (round (* raw 1.7)) raw)))
    (values (max 1 (- raw (jrpg-number "jrpg-hero-defense" 2)))
            heavy)))

(defun jrpg-combat-enemy-alive-p (game)
  (plusp (jrpg-combat-enemy-hp game)))

(defun jrpg-combat-damage-enemy (game amount)
  (setf (jrpg-combat-enemy-hp game)
        (max 0 (- (jrpg-combat-enemy-hp game) amount))))

(defun jrpg-combat-victory (node game)
  (jrpg-award-victory :xp (jrpg-combat-victory-xp game)
                      :gold (jrpg-combat-victory-gold game))
  (let ((leveled (jrpg-value "jrpg-just-leveled"))
        (name (string-downcase (jrpg-combat-enemy-name game))))
    (if leveled
        (progn
          (play-jrpg-sound "bell" :volume 0.4)
          (setf (jrpg-combat-message game)
                (format nil "the ~a falls. you reach level ~d." name leveled)))
        (progn
          (play-jrpg-sound "coin" :volume 0.34)
          (setf (jrpg-combat-message game)
                (format nil "the ~a is defeated." name)))))
  (jrpg-combat-finish game (node-success-target node)))

(defun jrpg-combat-defeat (node game)
  (jrpg-record-defeat)
  (setf (jrpg-combat-message game)
        "you fall down in the road.")
  (jrpg-combat-finish game (node-failure-target node)))

(defun jrpg-combat-enemy-turn (node game)
  (multiple-value-bind (damage heavy) (jrpg-combat-enemy-attack game)
    (jrpg-damage-hero damage)
    (play-jrpg-sound (if heavy "slime" "hit") :volume (if heavy 0.44 0.34))
    (if (jrpg-hero-alive-p)
        (setf (jrpg-combat-message game)
              (if heavy
                  (format nil "the ~a lunges hard! ~d damage."
                          (string-downcase (jrpg-combat-enemy-name game))
                          damage)
                  (format nil "the ~a hits you for ~d."
                          (string-downcase (jrpg-combat-enemy-name game))
                          damage)))
        (jrpg-combat-defeat node game))))

(defun jrpg-combat-attack-command (node game)
  (multiple-value-bind (damage crit) (jrpg-combat-hero-attack)
    (play-jrpg-sound "sword" :volume (if crit 0.52 0.42))
    (jrpg-combat-damage-enemy game damage)
    (if (jrpg-combat-enemy-alive-p game)
        (progn
          (setf (jrpg-combat-message game)
                (if crit
                    (format nil "a clean strike! ~d damage." damage)
                    (format nil "you hit the ~a for ~d."
                            (string-downcase (jrpg-combat-enemy-name game))
                            damage)))
          (jrpg-combat-enemy-turn node game))
        (jrpg-combat-victory node game))))

(defun jrpg-combat-magic-command (node game)
  (if (plusp (jrpg-number "jrpg-hero-mp"))
      (let ((damage (+ 6 (jrpg-number "jrpg-hero-level" 1)
                       (get-random-value 0 3))))
        (play-jrpg-sound "magic" :volume 0.38)
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
        (play-jrpg-sound "tonic" :volume 0.38)
        (setf (jrpg-combat-message game)
              "you drink a potion.")
        (jrpg-combat-enemy-turn node game))
      (setf (jrpg-combat-message game)
            "the bag is empty.")))

(defun jrpg-combat-run-command (node game)
  (jrpg-record-retreat)
  (play-jrpg-sound "retreat" :volume 0.36)
  (setf (jrpg-combat-message game)
        "you run back to the road sign.")
  (jrpg-combat-finish game (node-success-target node)))

(defun jrpg-combat-confirm-command (node game)
  (case (jrpg-combat-selected game)
    (0 (jrpg-combat-attack-command node game))
    (1 (jrpg-combat-magic-command node game))
    (2 (jrpg-combat-item-command node game))
    (3 (jrpg-combat-run-command node game))))

(defun update-jrpg-combat-minigame (node dt)
  (let ((game (ensure-jrpg-combat node)))
    (incf (jrpg-combat-elapsed game) dt)
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

(defun jrpg-slime-pixel-alpha (cell)
  (case cell
    (#\* 255)
    (#\# 224)
    (#\+ 124)
    (t nil)))

(defun jrpg-slime-row-offset (row elapsed)
  (round (* 2.0
            (sin (+ (* elapsed 2.4)
                    (* row 0.52))))))

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
              (claylib::c-ptr
               (make-color 255 255 255 (- 54 (* offset 4))))))))

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
                       scale
                       scale
                       (claylib::c-ptr
                        (make-color 255 255 255 alpha))))))

(defun draw-jrpg-combat-enemy (game)
  (let ((x (+ +jrpg-combat-left+ 570))
        (y (+ +jrpg-combat-top+ 72)))
    (draw-centered-text (jrpg-combat-enemy-name game)
                        x
                        (- y 42)
                        20
                        (make-color 255 255 255 232))
    (draw-jrpg-slime-shadow x (+ y 112) (jrpg-combat-elapsed game))
    (draw-jrpg-enemy-sprite (jrpg-enemy-sprite (jrpg-combat-enemy-kind game))
                            x (- y 8) 7 (jrpg-combat-elapsed game))
    (draw-centered-text
     (format nil "HP ~d/~d"
             (jrpg-combat-enemy-hp game)
             (jrpg-combat-enemy-max-hp game))
     x
     (+ y 134)
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
