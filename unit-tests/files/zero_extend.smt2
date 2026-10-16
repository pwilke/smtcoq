; Hand-written: CVC4 1.6 eliminates zero_extend before bit-blasting, so it
; never uses bv_bbl_zero_extend. Adapted from the proof CVC4 gives with
; sign_extend instead of zero_extend.
(set-logic QF_BV)
(declare-fun a () (_ BitVec 2))
(declare-fun b () (_ BitVec 4))
(assert (= b ((_ zero_extend 2) a)))
(assert (not (= ((_ extract 0 0) b) ((_ extract 0 0) a))))
(check-sat)
(exit)
