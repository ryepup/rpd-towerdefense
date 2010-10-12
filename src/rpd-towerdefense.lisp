;;; -*- mode: lisp; indent-tabs: nil -*-

(in-package :rpd-towerdefense)

(defun simulate (board turns)
  (iterate
   (for turn from 0 to turns)
   (collect
    (list turn
	  (iterate (for piece in (pieces board))
		   (when-let ((effects (act piece)))
		     (collect effects)))
	  (snapshot board)  ))
   )
  )

(defun render (simulation-results))