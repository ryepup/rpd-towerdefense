(in-package :rpd-towerdefense)

(defclass tower (game-piece)
  ())

(defclass refinery (tower)
  ((income-rate :accessor income-rate :initform 10)
   (waiting :accessor waiting :initform 3)))

(defmethod can-refine-p ((self refinery))
  (zerop (decf (waiting self))))

(defmethod parse-map-square ((obj (eql :r)))
  (make-instance 'refinery))

(defmethod plan ((self refinery))
  (if (can-refine-p self) :refine :idle))

(defmethod act ((self refinery) (plan (eql :refine)))
  (incf (money (board self)) (income-rate self))
  (incf (waiting self) (* 4 (income-rate self))))

;; want something like this
(defmethod script ((self refinery))
  (make-coroutine ()
    (iter
      (while (alive-p self))
      (yield (list :wait 4))
      (incf (money (board self))
	    (income-rate self)))

    )

  )