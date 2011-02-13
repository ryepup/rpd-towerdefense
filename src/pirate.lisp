(in-package :rpd-towerdefense)

(defactor pirate (spatial)
  ((velocity :accessor velocity :initform (make-location 0 0)))
  (:action self
   (iter
     (if-let ((targets (look self :range 100 :predicate #'tower-p)))
       (progn
	 ;;attack targets
	 (yield 5)
	 )
       (progn
	 ;;fly around
	 (when (zerop (current-speed self))
	   (setf (velocity self)
		 (make-location (random 10) (random 10))))
	 (yield 1))))))

(defun current-speed (pirate)
  (+ (x pirate) (y pirate)))

(defmethod simulation-step :after ((self pirate))
	   (sdl:draw-pixel-* (x self) (y self) :color sdl:*red*))