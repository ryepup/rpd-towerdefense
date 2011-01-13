;;; -*- mode: lisp; indent-tabs: nil -*-

(in-package :rpd-towerdefense)

(defclass game-state ()
  ((mass :accessor mass :initarg :mass
	 :initform (make-level :onchange (alexandria:curry #'draw-level "  Mass" 1)
			       :capacity 20))
   (energy :accessor energy :initarg :energy
	   :initform (make-level :onchange (alexandria:curry #'draw-level "Energy" 2)
				 :capacity 20))
   (simulation :accessor simulation :initarg :simulation)
   (font :accessor font :initarg :font )))

(defun draw-level (text y-start old-amt new-amt)
	   (let ((width (sdl:char-width sdl:*default-font*))
		 (height (sdl:char-height sdl:*default-font*)))
	     (sdl:draw-box-* 10 (* y-start height)
			     (* (max (length (format nil "~a: ~a" text old-amt))
				     (length (format nil "~a: ~a" text new-amt)))
				width) height
			     :color sdl:*black*)
	     (sdl:draw-string-solid-* (format nil "~a: ~a" text new-amt) 10 (* y-start height)
				      :color sdl:*white*))
  )


(defvar *game-state*)

(defun new-game (width height)
  (setf *game-state*
	(make-instance 'game-state
		       :simulation (make-simulation
				    :board (make-board width height)))))

(defun render-game (width height)
  (with-accessors ((sim simulation)) *game-state*
    (activate sim
	      (make-instance 'command-pod :location (make-location 300 300)))
    (sdl:with-init ()
      (sdl:initialise-default-font sdl:*font-9x15* )
      (sdl:window width height :title-caption "RPD's Tower Defense")
      (setf (sdl:frame-rate) 30) 
      (sdl:with-events ()
	(:quit-event () T)
	(:idle ()
	       (simulation-step sim)
	       (sdl:update-display)
	       ))
      ))
  )

(defun run-game (&key (width 600) (height 600) (threaded-p T))
  (new-game width height)
  (if threaded-p
      (bordeaux-threads:make-thread (lambda ()
				      (render-game width height))
				    :name "render thread")
      (render-game width height)))
