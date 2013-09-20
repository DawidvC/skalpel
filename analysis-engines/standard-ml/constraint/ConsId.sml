(* Copyright 2009 2010 2012 Heriot-Watt University
 *
 * Skalpel is a free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Skalpel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Skalpel.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  o Authors:     Vincent Rahli
 *  o Affiliation: Heriot-Watt University, MACS
 *  o Date:        25 May 2010
 *  o File name:   ConsId.sml
 *  o Description: Defines the structure ConsId which has signature
 *      CONSID.  This structure is to deal with binders.
 *)


structure ConsId :> CONSID = struct

(* shorten names of structures *)
structure L  = Label
structure T  = Ty
structure P  = Poly
structure I  = Id
structure CL = ClassId
structure EH = ErrorHandler

(* a binder is used for program occurences of id that are being bound*)
type 'a bind = {id    : I.id,        (* Identifier for which we generate this constraint *)
		bind  : 'a,          (* Type of the identifier                           *)
		equalityTypeVar : Ty.equalityTypeVar,
		class : CL.class,    (* Status/class of the identifier                   *)
		lab   : L.label,     (* Label of the contraint                           *)
		poly  : P.poly}      (* Constraint on the poly/mono binding if binding   *)

(* grabs a different field from bind *)
fun getBindI (x : 'a bind) = #id    x
fun getBindT (x : 'a bind) = #bind  x
fun getBindEqualityTypeVar (x : 'a bind) = #equalityTypeVar  x
fun getBindC (x : 'a bind) = #class x
fun getBindL (x : 'a bind) = #lab   x
fun getBindP (x : 'a bind) = #poly  x

(*fun getREClabs {id, scope, bind, class, lab, poly} = (lab, CL.getClassREClabs class)*)

(* constructors of bind *)
fun consBind id bind equalityTypeVar class lab poly =
    {id    = id,
     bind  = bind,
     equalityTypeVar = equalityTypeVar,
     class = class,
     lab   = lab,
     poly  = poly}
fun consBindPoly id bind equalityTypeVar class lab = consBind id bind equalityTypeVar class lab P.POLY
fun consBindMono id bind equalityTypeVar class lab = consBind id bind equalityTypeVar class lab (P.MONO [P.MONBIN (L.singleton lab)])

fun toMonoBind {id, bind, equalityTypeVar, class, lab, poly} labs = consBind id bind equalityTypeVar class lab (P.polyToMono poly labs)
fun toPolyBind {id, bind, equalityTypeVar, class, lab, poly}      = consBind id bind equalityTypeVar class lab (P.toPoly poly)
fun resetPoly  {id, bind, equalityTypeVar, class, lab, poly}      = consBind id bind equalityTypeVar class lab P.POLY
fun updClass   {id, bind, equalityTypeVar, class, lab, poly} cl   = consBind id bind equalityTypeVar cl    lab poly
fun updPoly    {id, bind, equalityTypeVar, class, lab, poly} pol  = consBind id bind equalityTypeVar class lab pol

(* get the type variables from the record *)
fun getTypeVar {id, bind = T.TYPE_VAR (tv, _, _, _), equalityTypeVar, class, lab, poly} = SOME tv
  | getTypeVar {id, bind, equalityTypeVar, class, lab, poly} =
    (*(2010-07-02) This is not totally safe, we should really return the
     * list of types in bind. *)
    if CL.classIsEXC class
    then NONE
    else (print (I.printId id ^ " " ^ T.printty bind ^ "\n"); raise EH.DeadBranch "")

fun getTypeVars {id, bind, equalityTypeVar, class, lab, poly} = T.getTypeVarsTy bind

(* more checking to see what class the parameter is *)
fun isVAL {id, bind, equalityTypeVar, class, lab, poly} = CL.classIsVAL class
fun isPAT {id, bind, equalityTypeVar, class, lab, poly} = CL.classIsPAT class
fun isDA0 {id, bind, equalityTypeVar, class, lab, poly} = CL.classIsDA0 class
fun isREC {id, bind, equalityTypeVar, class, lab, poly} = CL.classIsREC class
(*fun isTYP {id, bind, class, lab, poly} = CL.classIsTYP class
fun isDAT {id, bind, class, lab, poly} = CL.classIsDAT class*)
fun isEX0 {id, bind, equalityTypeVar, class, lab, poly} = CL.classIsEX0 class

(* SIMPLE TRANSFORMATIONS *)
fun toPAT {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToPAT class) lab poly
fun toREC {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToREC class) lab poly
fun toVRC {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToVRC class) lab poly
fun toDA0 {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToDA0 class) lab poly
fun toDA1 {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToDA1 class) lab poly
fun toDAT {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToDAT class) lab poly
fun toEX0 {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToEX0 class) lab (P.polyToMono poly L.empty)
fun toEX1 {id, bind, equalityTypeVar, class, lab, poly} = consBind id bind equalityTypeVar (CL.classToEX1 class) lab (P.polyToMono poly L.empty)
(*fun toDAT {id, bind, class, lab, poly} = consBind id bind (CL.classToDATcons class CL.emCons) lab poly*)

fun toCLS {id, bind, class, equalityTypeVar, lab, poly} cls = consBind id bind equalityTypeVar cls lab poly

fun mapBind {id, bind, equalityTypeVar, class, lab, poly} f = consBind id (f bind) equalityTypeVar class lab poly

(* update an identifier constraint with information on the expansiveness
 * of the bound expression *)
fun closeBind {id, bind, equalityTypeVar, class, lab, poly} clos =
    consBind id bind equalityTypeVar class lab (P.mergePoly (P.fromNonexpToPoly clos) poly)


(* Resets the names of a recursive function if the constraint if for
 * a recursive function, otherwise does nothing. *)

(*fun setREClabs (x as {id, bind, class, lab, poly}) labs =
    if CL.classIsREC class
    then consBind id bind (CL.setClassREClabs class labs) lab poly
    else x*)


(* gather the labels in a set of extended type variables *)
fun getlabExtChk xs =
    foldr (fn (x, y) => L.cons (getBindL x) y)
	  L.empty
	  xs


(* gather the labels of EXCs in a list of extended type variables *)
fun getlabExtChkExc xs =
    foldr (fn ({id, bind, class, lab, poly}, y) =>
	      if CL.classIsEX0 class
	      then (P.getLabsPoly poly) :: y
	      else raise EH.DeadBranch "")
	  []
	  xs


(* PRINTING SECTION *)
fun printlistgen xs f = "[" ^ #1 (foldr (fn (t, (s, c)) => (f t ^ c ^ s, ",")) ("", "") xs) ^ "]"

fun printlabel l = "l"  ^ L.printLab l

fun printBind {id, bind, equalityTypeVar, poly, lab, class} fbind assoc =
    "(" ^ I.printId'  id assoc ^
    "," ^ fbind       bind     ^
    "," ^ T.printEqualityTypeVar equalityTypeVar     ^
    "," ^ P.toString  poly     ^
    "," ^ L.printLab  lab      ^
    "," ^ CL.toString class    ^ ")"

fun printBind' bind fbind = printBind bind fbind I.emAssoc

end
