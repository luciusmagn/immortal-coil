(in-package #:immortal-coil)

;;; The character screen: your class, stats, worn gear, what you carry, and your
;;; quests. Reached from the night-city hub (door S) and returns to it. up/down
;;; select a carried item; enter equips/unequips gear or uses a consumable; esc
;;; leaves. Equipping reapplies the item's modifiers to the stats combat reads.

(defclass jrpg-character-session (minigame-session)
  ((selected  :initform 0   :accessor jrpg-char-selected)
   (message   :initform ""  :accessor jrpg-char-message)
   (leveling  :initform nil :accessor jrpg-char-leveling)
   (level-sel :initform 0   :accessor jrpg-char-level-sel)))

(defun jrpg-character-items ()
  "Carried items, de-duplicated for the list (consumables show a count)."
  (remove-duplicates (jrpg-inventory) :from-end t))

(defun jrpg-char-equipped-p (id)
  (let ((slot (jrpg-item-slot id)))
    (and slot (eq (jrpg-equipped-in slot) id))))

(defun jrpg-char-activate (s id)
  (cond
    ((jrpg-item-consumable-p id)
     (setf (jrpg-char-message s) (or (jrpg-use-consumable id) "nothing happens.")))
    ((jrpg-item-slot id)
     (if (jrpg-char-equipped-p id)
         (progn (jrpg-unequip (jrpg-item-slot id))
                (setf (jrpg-char-message s)
                      (format nil "you put away the ~a." (jrpg-item-name id))))
         (progn (jrpg-equip id)
                (setf (jrpg-char-message s)
                      (format nil "you take up the ~a." (jrpg-item-name id))))))
    (t (setf (jrpg-char-message s) "you turn it over and put it back."))))

(defmethod minigame-session-update ((s jrpg-character-session) node dt)
  (declare (ignore dt))
  (let* ((items (jrpg-character-items)) (n (length items)))
    (cond
      ;; choosing which stat to raise this level
      ((jrpg-char-leveling s)
       (let ((m (length *jrpg-level-stats*)))
         (cond
           ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-backspace+))
            (setf (jrpg-char-leveling s) nil
                  (jrpg-char-message s) "you hold off, for now."))
           ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
            (setf (jrpg-char-level-sel s) (mod (1+ (jrpg-char-level-sel s)) m))
            (play-choice-switch))
           ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
            (setf (jrpg-char-level-sel s) (mod (1- (jrpg-char-level-sel s)) m))
            (play-choice-switch))
           ((confirm-pressed-p)
            (let* ((stat (first (nth (jrpg-char-level-sel s) *jrpg-level-stats*)))
                   (cost (jrpg-level-cost))
                   (lv (jrpg-level-up stat)))
              (setf (jrpg-char-leveling s) nil
                    (jrpg-char-message s)
                    (if lv (format nil "you give up ~d Hours and grow - level ~d." cost lv)
                        "you cannot afford it after all.")))))))
      ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-backspace+))
       ;; return to wherever it was opened from (an overworld via C, or the hub)
       (let ((target (or (jrpg-value "jrpg-char-return") (node-success-target node))))
         (setf (jrpg-value "jrpg-char-return") nil)
         (finish-minigame-node node target)))
      ((is-key-pressed-p +key-l+)
       (if (>= (jrpg-hours) (jrpg-level-cost))
           (setf (jrpg-char-leveling s) t (jrpg-char-level-sel s) 0)
           (setf (jrpg-char-message s)
                 (format nil "growing costs ~d Hours; you have ~d."
                         (jrpg-level-cost) (jrpg-hours)))))
      ((plusp n)
       (cond
         ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
          (setf (jrpg-char-selected s) (mod (1+ (jrpg-char-selected s)) n))
          (play-choice-switch))
         ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
          (setf (jrpg-char-selected s) (mod (1- (jrpg-char-selected s)) n))
          (play-choice-switch)))
       (when (confirm-pressed-p)
         (jrpg-char-activate s (nth (min (jrpg-char-selected s) (1- n)) items)))))))

(defun jrpg-char-quest-tag (state)
  (case state (:active "(active)") (:done "(done)") (t "")))

(defmethod minigame-session-draw ((s jrpg-character-session) node color)
  (declare (ignore node color))
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 238)))
  (draw-jrpg-box 170 80 940 580 235)
  (let ((lx 202) (rx 624))
    ;; header band (full width): name, class, the class line wrapped, a rule
    (draw-jrpg-line "YOURSELF" lx 100 24)
    (draw-text-at (format nil "you are ~a" (jrpg-class-name)) lx 134 18
                  (yellow-sign-color 235))
    (loop with y = 160
          for line in (let ((ls (wrap-text-lines (jrpg-class-desc) 14 870)))
                        (if (> (length ls) 2) (subseq ls 0 2) ls))
          do (draw-jrpg-line line lx y 14 185) (incf y 18))
    (jrpg-draw-rule lx 202 876)
    ;; left column: stats, then quests
    (draw-jrpg-line "STATS" lx 222 16 205)
    (draw-jrpg-line (format nil "HP ~d/~d     MP ~d"
                            (jrpg-number "jrpg-hero-hp") (jrpg-number "jrpg-hero-max-hp" 18)
                            (jrpg-number "jrpg-hero-mp"))
                    lx 248 17)
    (draw-jrpg-line (format nil "ATK ~d     DEF ~d     WILL ~d/~d"
                            (jrpg-number "jrpg-hero-attack" 5) (jrpg-number "jrpg-hero-defense" 2)
                            (jrpg-composure) (jrpg-composure-max))
                    lx 272 17)
    (draw-jrpg-line (format nil "LV ~d     ~d Hours"
                            (jrpg-number "jrpg-hero-level" 1) (jrpg-hours))
                    lx 296 17)
    (draw-jrpg-line (format nil "press L to grow  (~d Hours)" (jrpg-level-cost))
                    lx 320 13 165)
    (draw-jrpg-line "QUESTS" lx 358 16 205)
    (loop with y = 384
          for entry in *jrpg-quests*
          for id = (first entry)
          for state = (jrpg-quest-state id)
          unless (eq state :inactive)
            do (draw-jrpg-line (format nil "~a ~a" (jrpg-quest-title id)
                                       (jrpg-char-quest-tag state))
                               lx y 15 (if (eq state :done) 150 215))
               (incf y 24))
    ;; right column: worn, then carried
    (draw-jrpg-line "WORN" rx 222 16 205)
    (loop with y = 248
          for slot in *jrpg-equip-slots*
          for id = (jrpg-equipped-in slot)
          do (draw-jrpg-line (format nil "~7a ~a" (string-downcase (symbol-name slot))
                                     (if id (jrpg-item-name id) "(none)"))
                             rx y 16 (if id 225 145))
             (incf y 24))
    (draw-jrpg-line "CARRIED" rx 332 16 205)
    (let ((items (jrpg-character-items)))
      (if (null items)
          (draw-jrpg-line "(nothing yet)" rx 358 15 150)
          (loop with y = 358
                for id in items
                for i from 0
                for sel = (= i (jrpg-char-selected s))
                for count = (jrpg-item-count id)
                do (when sel (jrpg-draw-select-bar (- rx 10) y 420 22))
                   (draw-jrpg-line
                    (format nil "~a~a~a"
                            (if sel "> " "  ")
                            (jrpg-item-name id)
                            (cond ((jrpg-char-equipped-p id) "  [worn]")
                                  ((> count 1) (format nil "  x~d" count))
                                  (t "")))
                    rx y 16 (if sel 235 175))
                   (incf y 23)))
      ;; footer: selected item description, feedback, controls
      (jrpg-draw-rule lx 580 876)
      (when items
        (let ((id (nth (min (jrpg-char-selected s) (1- (length items))) items)))
          (draw-jrpg-line (jrpg-item-desc id) lx 592 14 185)))
      (draw-jrpg-line (jrpg-char-message s) lx 616 15 210)
      (draw-jrpg-line "up/down: select   enter: equip/use   L: grow   esc: back"
                      rx 618 12 150)
      (when (jrpg-char-leveling s)
        (draw-jrpg-box 360 296 360 250 244)
        (draw-jrpg-line "RAISE WHICH?" 384 316 18)
        (draw-jrpg-line (format nil "this level: ~d Hours" (jrpg-level-cost)) 384 340 13 175)
        (loop with y = 370
              for entry in *jrpg-level-stats*
              for i from 0
              for sel = (= i (jrpg-char-level-sel s))
              do (when sel (jrpg-draw-select-bar 372 y 336 24))
                 (draw-jrpg-line (format nil "~a~a" (if sel "> " "  ") (second entry))
                                 384 y 16 (if sel 235 180))
                 (incf y 28))
        (draw-jrpg-line "enter: choose    esc: cancel" 384 524 12 150)))))

(register-minigame-session-kind :jrpg-character 'jrpg-character-session)

(dialog-minigame "jrpg/character"
                 ""
                 :game :jrpg-character
                 :success "jrpg/city-hub"
                 :failure "jrpg/city-hub")
