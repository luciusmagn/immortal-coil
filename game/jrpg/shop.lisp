(in-package #:immortal-coil)

;;; A vendor screen. There are several across the path - a city pawnbroker, a
;;; pallid stall in Carcosa - so the stock and the title come from the node's
;;; :config (:title "..." :stock '((item-key cost) ...)); with no config it
;;; falls back to the city pawnbroker's default stock. up/down select, enter
;;; buys if affordable, esc leaves.

(defun jrpg-shop-stock (node)
  (let ((v (minigame-config-value node :stock)))
    (if (and (listp v) v) v *jrpg-shop-stock*)))

(defun jrpg-shop-title (node)
  (let ((v (minigame-config-value node :title)))
    (if (stringp v) v "THE PAWNBROKER OF HOURS")))

(defclass jrpg-shop-session (minigame-session)
  ((selected :initform 0  :accessor jrpg-shop-selected)
   (message  :initform "what'll it be?" :accessor jrpg-shop-message)))

(defmethod minigame-session-update ((s jrpg-shop-session) node dt)
  (declare (ignore dt))
  (let* ((stock (jrpg-shop-stock node)) (n (length stock)))
    (cond
      ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-backspace+))
       (finish-minigame-node node (node-success-target node)))
      ((plusp n)
       (cond
         ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
          (setf (jrpg-shop-selected s) (mod (1+ (jrpg-shop-selected s)) n))
          (play-choice-switch))
         ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
          (setf (jrpg-shop-selected s) (mod (1- (jrpg-shop-selected s)) n))
          (play-choice-switch)))
       (when (confirm-pressed-p)
         (let ((entry (nth (min (jrpg-shop-selected s) (1- n)) stock)))
           (setf (jrpg-shop-message s) (jrpg-shop-buy (first entry) (second entry)))
           (play-jrpg-sound "coin" :volume 0.3)))))))

(defmethod minigame-session-draw ((s jrpg-shop-session) node color)
  (declare (ignore color))
  (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                             (claylib::c-ptr (make-color 0 0 0 236)))
  (let ((stock (jrpg-shop-stock node)))
    (draw-jrpg-box 300 110 680 500 235)
    (draw-jrpg-line (jrpg-shop-title node) 332 132 22)
    (jrpg-draw-rule 332 162 616 90)
    (draw-text-at (format nil "you carry ~d Hours" (jrpg-hours)) 332 172 17
                  (yellow-sign-color 230))
    (loop with y = 224
          for entry in stock
          for i from 0
          for key = (first entry)
          for cost = (second entry)
          for sel = (= i (jrpg-shop-selected s))
          for owned = (and (not (jrpg-item-consumable-p key)) (jrpg-has-item-p key))
          for afford = (>= (jrpg-hours) cost)
          do (when sel (jrpg-draw-select-bar 320 y 640 30))
             (draw-jrpg-line (format nil "~a~a~a" (if sel "> " "  ") (jrpg-shop-label key)
                                     (if owned "  (owned)" ""))
                             332 y 18 (cond (owned 130) ((not afford) 120) (sel 235) (t 185)))
             (draw-jrpg-line (format nil "~d Hr" cost) 858 y 18 (if afford 205 120))
             (incf y 36))
    (jrpg-draw-rule 332 486 616 70)
    (let* ((entry (nth (min (jrpg-shop-selected s) (max 0 (1- (length stock)))) stock))
           (key (first entry))
           (desc (if (eq key :tonic)
                     "a corked tonic; restores 9 hp when drunk in battle."
                     (jrpg-item-desc key))))
      (draw-jrpg-line desc 332 498 14 185))
    (draw-jrpg-line (jrpg-shop-message s) 332 536 16 210)
    (draw-jrpg-line "up/down select   enter buy   esc leave" 332 572 13 150)))

(register-minigame-session-kind :jrpg-shop 'jrpg-shop-session)

(dialog-minigame "jrpg/shop"
                 ""
                 :game :jrpg-shop
                 :success "jrpg/city-hub"
                 :failure "jrpg/city-hub")
