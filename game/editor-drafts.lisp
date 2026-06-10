;;; Editor overflow drafts.
;;;
;;; The in-game editor appends edits to the script file that owns the
;;; edited node (marked with ";; editor-generated:" comments for review
;;; and folding). Edits land here only when no source file is known for
;;; the node. Keep manual cleanup explicit.
