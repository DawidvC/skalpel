(* old test case name: code262.sml *)

(* Free Identifier warnings are not considered as minimal errors *)
datatype ('a, 'b) t = T of u | U of 'a u;
