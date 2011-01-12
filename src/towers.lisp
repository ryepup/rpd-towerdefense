(in-package :rpd-towerdefense)

(defclass tower (spatial)
  ((max-health :accessor max-health :initarg :max-health)
   (health :accessor health :initarg :health)
   (size :accessor size :initarg :size :initform 20)))

(defactor refinery (tower)
  ((income-rate :accessor income-rate :initform 10)
   (cooldown :accessor cooldown :initform 0)
   (max-cooldown :accessor max-cooldown :initform 100))
  (:function self
	     (if (zerop (cooldown self))
		 (progn
		   (incf (mass *game-state*) (income-rate self))
		   (setf (cooldown self) (max-cooldown self)))
		 (decf (cooldown self)))
	     (cooldown self)))

(defmethod simulation-step :after ((self refinery))
	   (let ((heat (truncate (alexandria:lerp (/ (cooldown self)
						  (max-cooldown self))
					       128 255))))
	     (sdl:draw-box-* (x self) (y self) (size self) (size self)
			   :color (sdl:color :g (- 255 heat) :r heat))))