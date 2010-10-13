(in-package :rpd-towerdefense)

(defclass tower (game-piece)
  ())

(defclass refinery (tower)
  ((income-rate :accessor income-rate :initform 10)))

(defmethod parse-map-square ((obj (eql :r)))
  (make-instance 'refinery))

(defmethod plan ((self refinery)) :refine)
(defmethod act ((self refinery) (plan (eql :refine)))
  (incf (money (board self)) (income-rate self)))
