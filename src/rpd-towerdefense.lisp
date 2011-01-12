;;; -*- mode: lisp; indent-tabs: nil -*-

(in-package :rpd-towerdefense)

(defclass game-state ()
  ((mass :accessor mass :initarg :mass :initform 0)
   (energy :accessor energy :initarg :energy :initform 0)
   (simulation :accessor simulation :initarg :simulation)
   (font :accessor font :initarg :font )))

(defmethod (setf mass) :after (val (gs game-state))
	   (let ((str (format nil "  Mass: ~a" val))
		 (width (sdl:char-width sdl:*default-font*))
		 (height (sdl:char-height sdl:*default-font*)))
	     (sdl:draw-box-* 10 10 (* (length (format nil "  Mass: ~a" (mass gs))) width) height
			     :color sdl:*black*)
	     (sdl:draw-string-solid-* str 10 10
				      :color sdl:*white*)))
(defmethod (setf energy) :after (val (gs game-state))
	   (let ((str (format nil "Energy: ~a" val))
		 (width (sdl:char-width sdl:*default-font*))
		 (height (sdl:char-height sdl:*default-font*)))
	     (sdl:draw-box-* 10 10 (* (length (format nil "Energy: ~a" (energy gs))) width) height
			     :color sdl:*black*)
	     (sdl:draw-string-solid-* str 10 10
				      :color sdl:*white*)))


(defvar *game-state*)

(defun new-game (width height)
  (setf *game-state*
	(make-instance 'game-state
		       :simulation (make-simulation
				    :board (make-board width height)))))

(defun render-game (width height)
  (with-accessors ((sim simulation)) *game-state*
    (activate sim
	      (make-instance 'refinery :location (make-location 300 300)))
    (sdl:with-init ()
      (sdl:initialise-default-font sdl:*font-9x15* )
      (sdl:window width height :title-caption ") RPD's Tower Defense")
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
