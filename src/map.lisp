(in-package :rpd-towerdefense)

(defclass game-piece ()
  ((x :accessor x)
   (y :accessor y)
   (board :accessor board)))

(defgeneric plan (piece)
  (:method ((p game-piece))
    (declare (ignore p))
    nil))

(defgeneric act (piece plan)
  (:method ((p game-piece) plan)
    (declare (ignore plan))
    nil))

(defvar *simple-map*
  (let ((mp (make-array '(10 10) :initial-element 0)))
    (setf (aref mp 5 5) :r)
    (setf (aref mp 2 5) :r)
    mp
    ))

(defgeneric parse-map-square (item)
  (:method ((x (eql 0))) nil))

(defclass board ()
  ((pieces :accessor pieces :initform nil)
   (bounds :accessor bounds)
   (money :accessor money :initform 0)))

(defgeneric snapshot (thing)
  (:method ((b board))
    b
    ))

(defmethod add-piece ((board board) (piece game-piece) x y)
  (push piece (pieces board))
  (setf (x piece) x
	(y piece) y
	(board piece) board))

(defmethod mapc-board ((board board) callback)
  (dotimes (x (first (bounds board)))
    (dotimes (y (second (bounds board)))
      (funcall callback x y))))

(defun parse-map (input &aux (board (make-instance 'board)))
  "returns a ready game map.  Input is a 2d vector."
  (setf (bounds board) (array-dimensions input))
  (mapc-board
   board
   #'(lambda (x y)
       (when-let (p (parse-map-square
		     (aref input x y)))
	 (add-piece board p x y))))
  board)