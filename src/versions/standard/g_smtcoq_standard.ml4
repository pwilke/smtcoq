(**************************************************************************)
(*                                                                        *)
(*     SMTCoq                                                             *)
(*     Copyright (C) 2011 - 2019                                          *)
(*                                                                        *)
(*     See file "AUTHORS" for the list of authors                         *)
(*                                                                        *)
(*   This file is distributed under the terms of the CeCILL-C licence     *)
(*                                                                        *)
(**************************************************************************)


DECLARE PLUGIN "smtcoq_plugin"

open Stdarg

(* This is requires since Coq 8.7 because the Ltac machinery became a
   plugin
   see: https://lists.gforge.inria.fr/pipermail/coq-commits/2017-February/021276.html *)
open Ltac_plugin

VERNAC COMMAND EXTEND Vernac_zchaff CLASSIFIED AS QUERY
| [ "Parse_certif_zchaff" 
    ident(dimacs) ident(trace) string(fdimacs) string(fproof) ] ->
  [
    Zchaff.parse_certif dimacs trace fdimacs fproof
  ]
| [ "Zchaff_Checker" string(fdimacs) string(fproof) ] ->
  [
    Zchaff.checker fdimacs fproof
  ]
| [ "Zchaff_Theorem" ident(name) string(fdimacs) string(fproof) ] ->
  [
    Zchaff.theorem name fdimacs fproof
  ]
END

VERNAC COMMAND EXTEND Vernac_verit CLASSIFIED AS QUERY
| [ "Parse_certif_verit"
    ident(t_i) ident(t_func) ident(t_atom) ident(t_form) ident(root) ident(used_roots) ident(trace) string(fsmt) string(fproof) ] ->
  [
    Verit.parse_certif t_i t_func t_atom t_form root used_roots trace fsmt fproof
  ]
| [ "Verit_Checker" string(fsmt) string(fproof) ] ->
  [
    Verit.checker fsmt fproof
  ]
| [ "Verit_Checker_Debug" string(fsmt) string(fproof) ] ->
  [
    Verit.checker_debug fsmt fproof
  ]
| [ "Verit_Theorem" ident(name) string(fsmt) string(fproof) ] ->
  [
    Verit.theorem name fsmt fproof
  ]
END

TACTIC EXTEND Tactic_zchaff
| [ "zchaff_bool" ] -> [ Zchaff.tactic () ]
| [ "zchaff_bool_no_check" ] -> [ Zchaff.tactic_no_check () ]
END

let lemmas_list = Summary.ref ~name:"Selected lemmas" []

let cache_lemmas (_, lems) =
  lemmas_list := lems

let declare_lemmas : Structures.constr_expr list -> Libobject.obj =
  let open Libobject in
  declare_object
    {
      (default_object "LEMMAS") with
      cache_function = cache_lemmas;
      load_function = (fun _ -> cache_lemmas);
    }

let add_lemmas lems =
  Lib.add_anonymous_leaf (declare_lemmas (lems @ !lemmas_list))

let clear_lemmas () =
  Lib.add_anonymous_leaf (declare_lemmas [])

let get_lemmas () = !lemmas_list

VERNAC COMMAND EXTEND Add_lemma CLASSIFIED AS SIDEFF
| [ "Add_lemmas" constr_list(lems) ] -> [ add_lemmas lems ]
| [ "Clear_lemmas" ] -> [ clear_lemmas () ]
END


TACTIC EXTEND Tactic_verit
| [ "verit_bool_base" constr(lpl) ] -> [ Verit.tactic lpl (get_lemmas ()) ]
| [ "verit_bool_no_check_base" constr(lpl) ] -> [ Verit.tactic_no_check lpl (get_lemmas ()) ]
END