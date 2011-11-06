(in-package :rpd-towerdefense)

(defclass tower ()
  ((max-health :accessor max-health :initarg :max-health)
   (health :accessor health :initarg :health)
   (coordinates :initarg :coordinates :reader coordinates
		:type (simple-vector 2))
   (size :accessor size :initarg :size :initform 1)))

(defgeneric tower-p (thing)
  (:method ((self tower)) T)
  (:method ((self T)) nil))

(defactor refinery (tower)
  ((income-rate :accessor income-rate :initform 10)
   (cooldown :accessor cooldown :initform 0)
   (max-cooldown :accessor max-cooldown :initform 10))
  (:action self
	   (iter
	     (if (zerop (cooldown self))
		 (progn
		   (yield :decf (energy *game-state*) (income-rate self))
		   (yield :incf (mass *game-state*) (income-rate self))
		   (setf (cooldown self) (max-cooldown self)))
		 (decf (cooldown self)))
	     (yield (cooldown self)))))

(defmethod simulation-step :after ((self refinery))
	   (let ((heat (truncate (alexandria:lerp (/ (cooldown self)
						  (max-cooldown self))
					       128 255))))
	     (sdl:draw-box-* (x self) (y self) (size self) (size self)
			   :color (sdl:color :g (- 255 heat) :r heat))))

(defactor command-pod (tower)
  ()
  (:action self
	   (iter
	     (yield :incf (mass *game-state*) 10)
	     (yield :incf (energy *game-state*) 10)
	     (yield 100))))

(defmethod simulation-step :after ((self command-pod))
  (rpd-boardgame-sdl:render (coordinates self)
			    :color sdl:*blue*
			    :fill sdl:*blue*))
