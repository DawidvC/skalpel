(* Copyright 2009 2010 2011 2012 Heriot-Watt University
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
 *  o Authors:     Vincent Rahli, John Pirie
 *  o Affiliation: Heriot-Watt University, MACS
 *  o Date:        21 May 2010
 *  o File name:   RunSlicer.sig
 *  o Description: Defines the signature SLICER which is the signature
 *      of the functions that serve as interface with the slicer.
 *)

(** The signature SLICER, used by the structure refstruct{Slicer}. *)
signature SLICER = sig

    (* remove this when the test database is converted to json format *)
    val convertErrors      : JsonParser.error -> string -> unit
    val generateTests      : int -> int -> unit

    (* lists the tests in the database
     * if true list the typable ones otherwise all of them *)
    val listtests          : bool -> unit

    (*val getLastRegions     : unit -> ER.regs list
    val getLastSlices      : unit -> string list
    val getLastMin         : unit -> bool*)

    (* true if we want to be in the online demo mode:
     * no SKALPEL-USE-FILE and no SKALPEL-SET-BASIS *)
    val setWebDemo         : bool -> unit

    val smlnjEntryPoint          :   string * string list -> OS.Process.status
    val mltonEntryPoint          :  unit -> OS.Process.status
    val polymlEntryPoint         :  unit -> unit

    val commslicerp        : string      -> (* basis file       *)
    			     string list -> (* input files      *)
    			     string      -> (* HTML output file *)
    			     string      -> (* XML  output file *)
    			     string      -> (* SML  output file *)
    			     string      -> (* LISP output file *)
    			     string      -> (* PERL output file *)
    			     int         -> (* 0/1/2, this is for the basis *)
    			     int         -> (* desired running time         *)
    			     int         -> (* basis overloading         *)
    			     unit

    val smlTesStrArgs : string -> OS.Process.status

    val error : JsonParser.error

end
