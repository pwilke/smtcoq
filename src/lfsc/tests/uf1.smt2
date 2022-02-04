(set-logic QF_UF)
(declare-sort U 0)
(declare-fun a () U)
(declare-fun b () U)
(declare-fun c () U)
(declare-fun f (U) U)
(declare-fun p (U) Bool)
(assert (and (= a c) (and (= b c) (or (not (= (f a) (f b))) (and (p a) (not (p b)))))))
(check-sat)
(exit)