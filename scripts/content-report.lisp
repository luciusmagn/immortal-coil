;;; Content-minutes report for the bundled story graph.
;;;
;;; Buckets nodes by id prefix (path family) and estimates how much
;;; play time each family holds. Two paces are reported: the typewriter
;;; pace the game intends (11 cps) and a fast pace where the player
;;; skips each node after reading (about 18 cps). Minigames use flat
;;; per-kind estimates including a retry.
;;;
;;; Run headless:
;;;   sbcl --eval '(require :asdf)' \
;;;        --eval '(asdf:load-system :immortal-coil)' \
;;;        --load scripts/content-report.lisp

(in-package #:immortal-coil)

(defparameter *report-read-cps* 18.0)
(defparameter *report-confirm-seconds* 2.0)
(defparameter *report-choice-seconds* 8.0)
(defparameter *report-input-seconds* 10.0)

(defparameter *report-minigame-seconds*
  '((:wire-flight . 120)
    (:dream-maze . 90)
    (:jrpg-overworld . 60)
    (:jrpg-combat . 120)
    (:war-radio . 40)
    (:forest-hide . 25)
    (:one-pace/brace . 30)
    (:rogue-delve . 240)))

(defun report-path-prefix (id)
  (let ((slash (position #\/ id)))
    (if slash
        (subseq id 0 slash)
        id)))

(defun report-text-seconds (text cps)
  (if (and text (plusp (length text)))
      (+ (/ (length text) cps) *report-confirm-seconds*)
      0.0))

(defun report-node-seconds (node cps)
  (let ((base (report-text-seconds (node-text node) cps)))
    (typecase node
      (conversation-node
       (+ base
          (loop for entry across (node-conversation node)
                sum (report-text-seconds (conversation-entry-text entry)
                                         cps))))
      (choice-node
       (+ base
          *report-choice-seconds*
          (loop for choice across (node-choices node)
                sum (/ (length (choice-label choice)) *report-read-cps*))))
      (input-node
       (+ base *report-input-seconds*))
      (minigame-node
       (+ base
          (or (rest (assoc (node-minigame node) *report-minigame-seconds*))
              45)))
      (t base))))

(defun report-content-minutes ()
  (let ((buckets (make-hash-table :test #'equal)))
    (maphash
     (lambda (id node)
       (let* ((prefix (report-path-prefix id))
              (entry (or (gethash prefix buckets)
                         (setf (gethash prefix buckets)
                               (list 0 0.0 0.0)))))
         (incf (first entry))
         (incf (second entry)
               (report-node-seconds node *characters-per-second*))
         (incf (third entry)
               (report-node-seconds node *report-read-cps*))))
     *nodes*)
    (let ((rows nil))
      (maphash (lambda (prefix entry)
                 (push (cons prefix entry) rows))
               buckets)
      (setf rows (sort rows #'> :key (lambda (row) (third row))))
      (format t "~&~12a ~6a ~12a ~10a~%" "PATH" "NODES" "TYPED MIN" "SKIM MIN")
      (dolist (row rows)
        (destructuring-bind (prefix count typed skim) row
          (format t "~12a ~6d ~12,1f ~10,1f~%"
                  prefix
                  count
                  (/ typed 60.0)
                  (/ skim 60.0))))
      rows)))

(load-dialog-graph)
(report-content-minutes)
