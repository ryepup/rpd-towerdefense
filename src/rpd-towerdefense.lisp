;;; -*- mode: lisp; indent-tabs: nil -*-

(in-package :rpd-towerdefense)

(defclass game-state ()
  ((mass :accessor mass :initarg :mass
	 :initform (make-level :onchange (alexandria:curry #'draw-level "  Mass" 1)
			       :capacity 20000))
   (energy :accessor energy :initarg :energy
	   :initform (make-level :onchange (alexandria:curry #'draw-level "Energy" 2)
				 :capacity 20000))
   (simulation :accessor simulation :initarg :simulation)
   (board :reader board :initarg :board)
   (screen :reader screen :initarg :screen)
   (font :accessor font :initarg :font )
   (surfaces :reader surfaces :initform (make-hash-table)))
  )

(defun ensure-surface (key width height &rest args &key (game-state *game-state*) &allow-other-keys)
  (assert (not (null game-state)))
  (let ((args (copy-list args)))
    (dolist (arg '(:game-state)) (remf args arg))
    (alexandria:ensure-gethash key (surfaces game-state)
			       (apply #'sdl:create-surface width height args))))

(defun surface (key &key (game-state *game-state*))
  (assert (not (null game-state)))
  (gethash key (surfaces game-state)))

(defun draw-level (text y-start old-amt new-amt)
  (let* ((width (* (max (length (format nil "~a: ~a" text old-amt))
			(length (format nil "~a: ~a" text new-amt)))
		   (sdl:char-width sdl:*default-font*)) )
	 (height (sdl:char-height sdl:*default-font*))
	 (sdl:*default-surface* (surface :chrome))
	 (y (* y-start height))
	 (x 10))
    ;;TODO: why doesn't the solid white look solid unless the fill-surf is totally opaque?
    (sdl:fill-surface (sdl:color :a 200) :template (sdl:rectangle :x x :y y :w width :h height))
    (sdl:draw-string-solid-* (format nil "~a: ~a" text new-amt) x y :color sdl:*white*)))

(defvar *game-state*)

(defun new-game (width height &aux (b (rpd-boardgame:make-board 10 20 :type :hex)))
  (setf *game-state*
	(make-instance 'game-state
		       :board b
		       :screen (rpd-boardgame:make-screen b width height)
		       :simulation (make-simulation))))

(let (highlighted-cell)
  (defun mouse-motion (x y x-rel y-rel state
		       &aux (s (screen *game-state*))
			 (sdl:*default-surface* (surface :mouse))
			 (cell (rpd-boardgame:cell-at s y x)))
    (declare (ignore x-rel y-rel state))
    ;;if we've selected something else, clear the grid
    (when (and highlighted-cell (not (eq cell highlighted-cell)))
      (sdl:fill-surface (sdl:color :a 0) :template
			(iter
			  (for v in (rpd-boardgame:screen-vertices highlighted-cell s))
			  (minimizing (aref v 0) into min-x)
			  (maximizing (aref v 0) into max-x)
			  (minimizing (aref v 1) into min-y)
			  (maximizing (aref v 1) into max-y)
			  (finally (return (sdl:rectangle-from-edges-* min-x min-y max-x max-y ))))))
    (when cell (rpd-boardgame-sdl:render cell :screen s :fill sdl:*green*
					 :color sdl:*red*))
    (setf highlighted-cell cell)))

(defun render-game (width height &aux (step 0))
  (with-accessors ((sim simulation)
		   (board board)) *game-state*
    (rpd-boardgame:with-board (board)
      (activate sim (make-instance 'command-pod :coordinates #(5 5)))
      (sdl:with-init ()
	(sdl:initialise-default-font sdl:*font-9x15* )
	(sdl:window width height :title-caption "RPD's Tower Defense" :double-buffer T)
	(setf (sdl:frame-rate) 15)
	
	(ensure-surface :board width height)
	(dolist (key '(:chrome :actors :mouse))
	  (ensure-surface key width height :pixel-alpha T))
	
	(rpd-boardgame-sdl:render board :surface (surface :board)) ;draw the board once
 
	(unwind-protect
	     (let ((lispbuilder-sdl:*default-surface* (surface :actors)))
	       (sdl:with-events ()
		 (:quit-event () T)
		 (:MOUSE-MOTION-EVENT (:STATE STATE :X X :Y Y :X-REL X-REL :Y-REL Y-REL)
				      (mouse-motion x y x-rel y-rel state))
		 (:idle ()
			(simulation-step sim)
			(draw-level "Step" 3 step (incf step))
			(dolist (key '(:board :actors :mouse :chrome))
			  (sdl:blit-surface (surface key) sdl:*default-display*))
			(sdl:update-display))))
	  (alexandria:maphash-values #'sdl:free (surfaces *game-state*)))
	))
    )
  )

(defun run-game (&key (width 600) (height 600) (threaded-p T))
  (new-game width height)
  (if threaded-p
      (bordeaux-threads:make-thread (lambda ()
				      (render-game width height))
				    :name "render thread")
      (render-game width height)))
