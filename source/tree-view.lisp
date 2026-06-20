(in-package #:immortal-coil)

;;; The story tree: a pannable overlay (T) that visualizes the sprawling
;;; shape of the graph. It grows from the start node as you play. Nodes
;;; you have actually entered are bright beads; the immediate static
;;; branches just ahead of them are dim. Targets that are computed at
;;; runtime (function next-targets) are not shown until you take one and
;;; the real node is recorded, so dynamic subtrees only appear once you
;;; reach them. Beads are joined by dotted threads, and the tree grows
;;; upward from a single root.

(defvar *tree-open-p* nil)
(defvar *tree-pan-x* 0.0)
(defvar *tree-pan-y* 0.0)
(defvar *tree-model* nil)

(defconstant +tree-x-gap+ 44.0)
(defconstant +tree-y-gap+ 52.0)
(defconstant +tree-base-x+ 140.0)
(defconstant +tree-base-y+ 632.0)
(defconstant +tree-pan-step+ 13.0)
(defconstant +tree-lookahead+ 8)
(defconstant +tree-max-nodes+ 1400)
(defconstant +tree-bead-visited-radius+ 5.0)
(defconstant +tree-bead-frontier-radius+ 3.5)
(defconstant +tree-bead-current-radius+ 7.0)


;;; Model

(defstruct tree-model
  (root     nil)
  (ids      nil :type list)
  (children (make-hash-table :test #'equal))
  (parent   (make-hash-table :test #'equal))
  (depth    (make-hash-table :test #'equal))
  (x        (make-hash-table :test #'equal))
  (visited  (make-hash-table :test #'equal)))

(defun tree-node-static-children (id)
  "The static (string) outgoing targets of node ID that exist as nodes.
Function-valued targets are deliberately omitted: their subtree only
appears once it is actually taken and recorded as visited."
  (let ((node (gethash id *nodes*)))
    (when node
      (remove-duplicates
       (loop for target in (append (list (node-next node)
                                         (node-target node)
                                         (node-success-target node)
                                         (node-failure-target node))
                                   (node-minigame-outcomes node)
                                   (map 'list #'choice-target
                                        (node-choices node)))
             when (and (stringp target) (node-exists-p target))
               collect target)
       :test #'equal :from-end t))))

(defun tree-visited-pairs ()
  "Visited (node-id . parent-id) pairs in first-visit order, with a
fallback so old saves and fresh states still render a root."
  (let ((pairs (reverse (and *state* (play-state-visited *state*)))))
    (or pairs
        (let ((id (and *state* (play-state-current-id *state*))))
          (when id (list (cons id nil)))))))

(defun tree-compute-depths (model)
  "BFS from the root over the trunk (visited) children to set the depth
of every visited node."
  (let ((root (tree-model-root model))
        (depth (tree-model-depth model))
        (children (tree-model-children model)))
    (when root
      (setf (gethash root depth) 0)
      (let ((queue (list root)))
        (loop while queue
              for id = (pop queue)
              do (dolist (child (gethash id children))
                   (unless (gethash child depth)
                     (setf (gethash child depth) (1+ (gethash id depth)))
                     (setf queue (nconc queue (list child))))))))))

(defun tree-grow-frontier (model)
  "Expand static (string) descendants of visited nodes, breadth-first,
out to a look-ahead horizon past the deepest node reached. This reveals
levels down branches you took and branches you did not. Dynamic targets
are never followed, so their subtrees stay hidden until actually
entered, and the horizon advances as you reach deeper nodes."
  (let* ((placed (tree-model-visited model))
         (parent (tree-model-parent model))
         (depth (tree-model-depth model))
         (children (tree-model-children model))
         (seen (make-hash-table :test #'equal))
         (count (hash-table-count placed))
         (horizon (+ (loop for id being the hash-keys of placed
                           maximize (gethash id depth 0))
                     +tree-lookahead+))
         (queue (loop for id being the hash-keys of placed collect id)))
    (loop while queue
          for id = (pop queue)
          for d = (gethash id depth 0)
          when (< d horizon)
            do (dolist (child (tree-node-static-children id))
                 (when (and (< count +tree-max-nodes+)
                            (not (gethash child placed))
                            (not (gethash child seen)))
                   (setf (gethash child seen) t
                         (gethash child parent) id
                         (gethash child depth) (1+ d))
                   (push child (gethash id children))
                   (incf count)
                   (setf queue (nconc queue (list child))))))))

(defun tree-layout-x (model id counter)
  "Assign each node an x-slot (leaves take sequential slots, parents
centre over their children) and collect ids. Depth is precomputed."
  (push id (tree-model-ids model))
  (let ((kids (gethash id (tree-model-children model))))
    (if (null kids)
        (progn
          (setf (gethash id (tree-model-x model)) (car counter))
          (incf (car counter)))
        (progn
          (dolist (child kids)
            (tree-layout-x model child counter))
          (setf (gethash id (tree-model-x model))
                (/ (loop for child in kids
                         sum (gethash child (tree-model-x model)))
                   (length kids)))))))

(defun build-tree-model ()
  (let* ((model (make-tree-model))
         (pairs (tree-visited-pairs))
         (placed (tree-model-visited model))
         (children (tree-model-children model))
         (parent (tree-model-parent model)))
    ;; trunk: the nodes you actually entered, parented to where you came from
    (loop for (id . par) in pairs
          do (setf (gethash id placed) t
                   (gethash id parent) par)
             (when (and par (gethash par placed))
               (push id (gethash par children))))
    (setf (tree-model-root model)
          (or (loop for (id . par) in pairs when (null par) return id)
              (caar pairs)
              *story-start-node*))
    (tree-compute-depths model)
    (tree-grow-frontier model)
    (maphash (lambda (id kids) (setf (gethash id children) (reverse kids)))
             children)
    (let ((root (tree-model-root model)))
      (when root
        (tree-layout-x model root (list 0.0))))
    model))


;;; Geometry

(defun tree-node-x (model id)
  (+ +tree-base-x+ (* (gethash id (tree-model-x model) 0.0) +tree-x-gap+)))

(defun tree-node-y (model id)
  (- +tree-base-y+ (* (gethash id (tree-model-depth model) 0) +tree-y-gap+)))

(defun tree-on-screen-p (x y)
  (and (<= -60.0 x (+ +virtual-width+ 60.0))
       (<= -60.0 y (+ +virtual-height+ 60.0))))

(defun center-tree-on-current (model)
  (let ((id (and *state* (play-state-current-id *state*))))
    (if (and id (gethash id (tree-model-x model)))
        (setf *tree-pan-x* (- +virtual-center-x+ (tree-node-x model id))
              *tree-pan-y* (- +virtual-center-y+ (tree-node-y model id)))
        (setf *tree-pan-x* 0.0 *tree-pan-y* 0.0))))


;;; Input

(defun tree-toggle-pressed-p ()
  (and (is-key-pressed-p +key-t+)
       (not (input-node-capturing-text-p))
       (not (journal-open-p))))

(defun open-tree ()
  (setf *tree-open-p* t
        *tree-model* (build-tree-model))
  (center-tree-on-current *tree-model*)
  (play-choice-switch)
  t)

(defun close-tree ()
  (setf *tree-open-p* nil
        *tree-model* nil)
  (play-choice-switch)
  t)

(defun tree-pan ()
  (when (or (is-key-down-p +key-left+) (is-key-down-p +key-a+))
    (incf *tree-pan-x* +tree-pan-step+))
  (when (or (is-key-down-p +key-right+) (is-key-down-p +key-d+))
    (decf *tree-pan-x* +tree-pan-step+))
  (when (or (is-key-down-p +key-up+) (is-key-down-p +key-w+))
    (incf *tree-pan-y* +tree-pan-step+))
  (when (or (is-key-down-p +key-down+) (is-key-down-p +key-s+))
    (decf *tree-pan-y* +tree-pan-step+)))

(defun update-tree-controls ()
  (cond
    (*tree-open-p*
     (cond
       ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-t+))
        (close-tree))
       (t (tree-pan)))
     t)
    ((tree-toggle-pressed-p)
     (open-tree)
     t)
    (t nil)))


;;; Rendering

(defun tree-draw-dotted (x1 y1 x2 y2 alpha)
  (let* ((dx (- x2 x1))
         (dy (- y2 y1))
         (dist (max 1.0 (sqrt (+ (* dx dx) (* dy dy)))))
         (steps (max 1 (floor dist 9.0)))
         (color (make-color 255 255 255 alpha)))
    (loop for i from 1 below steps
          for frac = (/ i (float steps))
          do (claylib/ll:draw-circle (round (+ x1 (* dx frac)))
                                     (round (+ y1 (* dy frac)))
                                     1.5
                                     (claylib::c-ptr color)))))

(defun tree-draw-connectors (model)
  (dolist (id (tree-model-ids model))
    (let ((par (gethash id (tree-model-parent model))))
      (when (and par (gethash par (tree-model-x model)))
        (let ((cx (+ (tree-node-x model id) *tree-pan-x*))
              (cy (+ (tree-node-y model id) *tree-pan-y*))
              (px (+ (tree-node-x model par) *tree-pan-x*))
              (py (+ (tree-node-y model par) *tree-pan-y*)))
          (when (or (tree-on-screen-p cx cy) (tree-on-screen-p px py))
            (tree-draw-dotted px py cx cy
                              (if (gethash id (tree-model-visited model))
                                  150
                                  60))))))))

(defun tree-draw-beads (model)
  (let ((current (and *state* (play-state-current-id *state*))))
    (dolist (id (tree-model-ids model))
      (let ((sx (+ (tree-node-x model id) *tree-pan-x*))
            (sy (+ (tree-node-y model id) *tree-pan-y*)))
        (when (tree-on-screen-p sx sy)
          (let* ((visited-p (gethash id (tree-model-visited model)))
                 (current-p (equal id current))
                 (radius (cond (current-p +tree-bead-current-radius+)
                               (visited-p +tree-bead-visited-radius+)
                               (t +tree-bead-frontier-radius+)))
                 (alpha (if visited-p 255 70)))
            (claylib/ll:draw-circle (round sx) (round sy) radius
                                    (claylib::c-ptr
                                     (make-color 255 255 255 alpha)))
            (when current-p
              (claylib/ll:draw-circle-lines (round sx) (round sy) 11.0
                                            (claylib::c-ptr
                                             (make-color 255 255 255 235))))))))))

(defun draw-tree-overlay ()
  (when *tree-open-p*
    (let ((model (or *tree-model* (build-tree-model))))
      (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                                 (claylib::c-ptr (make-color 0 0 0 234)))
      (tree-draw-connectors model)
      (tree-draw-beads model)
      (draw-centered-text "THE STORY SO FAR"
                          +virtual-center-x+
                          34.0
                          22
                          (make-color 255 255 255 235))
      (draw-text-at "T/ESC CLOSE    WASD/ARROWS PAN    BRIGHT: TAKEN    DIM: AHEAD"
                    40.0
                    (- +virtual-height+ 34.0)
                    14
                    (make-color 255 255 255 170)))))
