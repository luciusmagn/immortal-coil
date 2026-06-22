(in-package #:immortal-coil)

;;; The character screen: your class, stats, worn gear, what you carry, and your
;;; quests. Reached from the night-city hub (door S) and returns to it. up/down
;;; select a carried item; enter equips/unequips gear or uses a consumable; esc
;;; leaves. Equipping reapplies the item's modifiers to the stats combat reads.

(defclass jrpg-character-session (minigame-session)
  ((selected :initform 0  :accessor jrpg-char-selected)
   (message  :initform "" :accessor jrpg-char-message)))

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
      ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-backspace+))
       (finish-minigame-node node (node-success-target node)))
      ((is-key-pressed-p +key-l+)
       (let ((cost (jrpg-level-cost)))
         (if (jrpg-level-up)
             (setf (jrpg-char-message s)
                   (format nil "you give up ~d Hours and grow — level ~d."
                           cost (jrpg-number "jrpg-hero-level" 1)))
             (setf (jrpg-char-message s)
                   (format nil "growing costs ~d Hours; you have ~d." cost (jrpg-hours))))))
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
                             (claylib::c-ptr (make-color 0 0 0 236)))
  (draw-jrpg-box 170 80 940 580 235)
  (draw-jrpg-line "YOURSELF" 200 100 24)
  ;; class — the one line in the Sign's yellow
  (draw-text-at (format nil "you are ~a" (jrpg-class-name)) 200 140 19 (yellow-sign-color 235))
  (draw-jrpg-line (jrpg-class-desc) 200 166 14 195)
  (jrpg-draw-rule 200 196 880)
  ;; stats
  (draw-jrpg-line "STATS" 200 208 16 200)
  (draw-jrpg-line (format nil "HP ~d/~d    MP ~d"
                          (jrpg-number "jrpg-hero-hp") (jrpg-number "jrpg-hero-max-hp" 18)
                          (jrpg-number "jrpg-hero-mp"))
                  200 232 16)
  (draw-jrpg-line (format nil "ATK ~d    DEF ~d    WILL ~d/~d"
                          (jrpg-number "jrpg-hero-attack" 5) (jrpg-number "jrpg-hero-defense" 2)
                          (jrpg-composure) (jrpg-composure-max))
                  200 256 16)
  (draw-jrpg-line (format nil "LV ~d    ~d Hours"
                          (jrpg-number "jrpg-hero-level" 1) (jrpg-hours))
                  200 280 16)
  (draw-jrpg-line (format nil "press L: grow for ~d Hours" (jrpg-level-cost))
                  200 302 14 190)
  ;; quests (skip the ones not yet begun)
  (draw-jrpg-line "QUESTS" 200 322 16 200)
  (loop with y = 346
        for entry in *jrpg-quests*
        for id = (first entry)
        for state = (jrpg-quest-state id)
        unless (eq state :inactive)
          do (draw-jrpg-line (format nil "~a ~a" (jrpg-quest-title id) (jrpg-char-quest-tag state))
                             200 y 15 (if (eq state :done) 150 215))
             (incf y 24))
  ;; equipment
  (draw-jrpg-line "WORN" 640 140 16 200)
  (loop with y = 164
        for slot in *jrpg-equip-slots*
        for id = (jrpg-equipped-in slot)
        do (draw-jrpg-line (format nil "~6a ~a" (string-downcase (symbol-name slot))
                                   (if id (jrpg-item-name id) "—"))
                           640 y 16 (if id 225 150))
           (incf y 24))
  ;; carried
  (draw-jrpg-line "CARRIED" 640 248 16 200)
  (let ((items (jrpg-character-items)))
    (if (null items)
        (draw-jrpg-line "(nothing yet)" 640 272 15 150)
        (loop with y = 272
              for id in items
              for i from 0
              for sel = (= i (jrpg-char-selected s))
              for count = (jrpg-item-count id)
              do (when sel (jrpg-draw-select-bar 632 y 384 22))
                 (draw-jrpg-line
                  (format nil "~a~a~a"
                          (if sel "> " "  ")
                          (jrpg-item-name id)
                          (cond ((jrpg-char-equipped-p id) "  [worn]")
                                ((> count 1) (format nil "  x~d" count))
                                (t "")))
                  640 y 16 (if sel 235 175))
                 (incf y 23)))
    ;; description of the selected item + feedback + controls
    (when items
      (let ((id (nth (min (jrpg-char-selected s) (1- (length items))) items)))
        (draw-jrpg-line (jrpg-item-desc id) 200 590 14 185)))
    (draw-jrpg-line (jrpg-char-message s) 200 614 15 205)
    (draw-jrpg-line "up/down select   enter equip/use   L grow   esc back" 640 614 13 150)))

(register-minigame-session-kind :jrpg-character 'jrpg-character-session)

(dialog-minigame "jrpg/character"
                 ""
                 :game :jrpg-character
                 :success "jrpg/city-hub"
                 :failure "jrpg/city-hub")
