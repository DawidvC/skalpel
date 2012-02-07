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
 *  o Date:        24 May 2010
 *  o File name:   Env.sig
 *  o Description: Defines the ENV signature which is the signature of
 *      our constraint system.
 *)


signature ENV = sig

    (* ====== TYPES AND DATATYPES ====== *)

    (* ------ MAPPINGS ------ *)
    type 'a cmap (* mapping for constraints       *)
    type 'a emap (* mapping for environments      *)
    type 'a omap (* mapping for open environments *)

    (* ------ VARIABLES ------ *)
    type envvar         = int

    (* ------ BINDERS ------ *)
    type 'a bind        = 'a ConsId.bind ExtLab.extLab

    (* ------ GENERIC ENVIRONMENT ------ *)
    type 'a genv        = 'a bind list emap
    (*(2010-04-08)We should use genv for all our similar environments*)

    (* ------ OPENENV ------ *)
    datatype opnkind    = OST (* opened structure     *)
			| DRE (* datatype replication *)
			| ISI (* included signature   *)
    type opnsem         = Id.lid      * (* identifier of the structure to open *)
			  Label.label * (* label of the structure to open      *)
			  opnkind       (* kind of the opening                 *)
    type opnenv         = opnsem omap

    (* ------ VARENV ------ *)
    type extvar         = Ty.ty bind
    type varenv         = Ty.ty genv

    (* ------ KIND OF A TYPE DECLARATION *)
    datatype tnKind     = DAT | TYP

    (* ------ TYPENV ------ *)
    type exttyp         = (Ty.tyfun * tnKind * (varenv * bool) ref) bind (*(2010-06-10)The Boolean is to indicate if the varenv is complete or not.*)
    type typenv         = (Ty.tyfun * tnKind * (varenv * bool) ref) genv

    (* ------ OVERLADINGENV ------ *)
    type extovc         = Ty.seqty bind
    type ovcenv         = Ty.seqty genv

    (* ------ TYVARENV ------ *)
    type exttyv         = (Ty.tyvar * bool) bind (*(2010-06-14)The Boolean is true for an explicit type variable and false for an implicit one.*)
    type tyvenv         = (Ty.tyvar * bool) genv

    (* ------ INFORMATION ON ENVIRONMENTS ------ *)
    type tname          = {id : Id.id, lab : Label.label, kind : tnKind, name : Ty.tyname}
    type tnmap          = tname list (* This should be: tname extLab list *)
    datatype names      = TYNAME    of tname ExtLab.extLab (* Definitely is a type name                                       *)
			| DUMTYNAME of tname               (* Maybe a type name defining tname but not enough info to be sure *)
			| MAYTYNAME                        (* Maybe a type name but not enough info to know                   *)
			| NOTTYNAME of Id.id ExtLab.extLab (* Definitely not a type name                                      *)
    (* I should find a better name for infoEnv: *)
    type infoEnv        = {lab : Label.label, (* This should be a list or a set.  See uenvEnv in Analyze.sml. *)
			   cmp : bool,        (* true if the environment is complete (true when initialised and can be false during unification) *)
			   tns : tnmap,       (* type names introduced in the structure *)
			   fct : bool}        (* true if the environment is the argument of a functor *)
    (* The tns part is to ease the collection of type names when pushing an environment onto
     * a unification context. *)

    (*(* ------ CLASSES OF IDENTIFIERS ------ *)
    datatype class      = VCL of ClassId.classvar
			| CCL of ClassId.class * Label.label * Id.lid * bool (* true for an id at a binding position *)*)

    type class = ClassId.class

    (* ------ ACCESSORS ------ *)
    type 'a accid       = {lid : Id.lid, sem : 'a, class : ClassId.class, lab : Label.label}

    (* ------ LONG TYPE CONSTRUCTOR BINDER ------ *)
    type longtyp        = Ty.tyfun accid ExtLab.extLab

    (* ------ ENRICHEMENT AND INSTANTIATION ------ *)
    type evsbind        = envvar * envvar option * envvar * envvar option * Label.label
    (* 1st envvar: instantiated signature
     * 2nd envvar: signature matching
     * 3rd envvar: enriched structure
     * 4th envvar: resulting structure
     * the bool if false if we want to impose some restrictions based on the
     * structure environment (where clauses). *)

    (* ------ FUNCTOR INSTANTIATION ------ *)
    type evfbind        = envvar * envvar * envvar * envvar * Label.label
    (* functor  : 1st envvar -> 2nd envvar
     * argument : 3rd envvar
     * result   : 4th envvar *)

    (* ------ SHARING ------ *)
    type shabind        = envvar * envvar * envvar * Label.label

    (* ------ SIGNATURE MATCHING ------ *)
    datatype matchKind  = OPA (* Opaque      *)
			| TRA (* Translucent *)

    (*(* ------ GENERALISATION OF EXPLICIT TYPE VARIABLES ------ *)
    type tvsbind        = (Ty.tyvar * Label.label) list
    type exttv          = Ty.tyvar bind (*(2010-04-08)Can't we use varenv?*)
    (* tvsbind stands for Type Variable Sequence Binding
     * it contains the type variables bound at a value declaration *)*)

    (* ------ ENVIRONMENTS ------ *)
    datatype environment        = ENVIRONMENT_CONSTRUCTOR of {vids : varenv,
				     (* value identifiers *)
				     typs : typenv,
				     (* type names *)
				     tyvs : tyvenv,
				     (* explicit type variables - not used anymore *)
				     strs : environment genv,
				     (* structures - this is strenv *)
				     sigs : environment genv,
				     (* signatures - this is sigenv *)
				     funs : (environment * environment) genv,
				     (* functors this is a funenv *)
				     ovcs : ovcenv,
				     (* overloading classes *)
				     info : infoEnv}
			| ENVVAR of envvar * Label.label
			| SEQUENCE_ENV of environment * environment
			| ENVLOC of environment * environment
			| ENVSHA of environment * environment     (*(2010-07-07)We want something like: Ty.tyfun accid extLab list, instead of the second environment.*)
			| SIGNATURE_ENV of environment * environment * matchKind
			| ENVWHR of environment * longtyp
			| ENVPOL of tyvenv * environment  (* the first environment is the explicit type variables and the second the value bindings *)
			| DATATYPE_CONSTRUCTOR_ENV of Id.idl * environment  (* (2010-06-10)This is to associate constructors to a datatype *)
			| ENVOPN of opnenv
			| ENVDEP of environment ExtLab.extLab (* we want to move from ENVOPN to ENVDEP *)
			| FUNCTOR_ENV of constraints (*(2010-06-22)This environment is only solved when dealing with CSTFUN.*)
			| CONSTRAINT_ENV of constraints
			| ENVPTY of string (* This is generated by a sml-tes special comment SML-TES-TYPE and used to print the type of an identifier *)
			| ENVFIL of string * environment * (unit -> environment) (* Like a SEQ but the first environment is from a file which has the name given by the string and the second environment is a stream *)
			| TOP_LEVEL_ENV (*(2010-06-24)To mark that we reached the top-level.*)

	and accessor        = VALUEID_ACCESSOR of Ty.ty       accid ExtLab.extLab (* value identifiers        *)
	                    | EXPLICIT_TYPEVAR_ACCESSOR of Ty.tyvar    accid ExtLab.extLab (* explicit type variables  *)
                       	    | TYPE_CONSTRUCTOR_ACCESSOR of Ty.tyfun    accid ExtLab.extLab (* type constructors        *)
	                    | OVERLOADING_CLASSES_ACCESSOR of Ty.seqty    accid ExtLab.extLab (* overloading classes      *)
	                    | STRUCTURE_ACCESSOR of environment         accid ExtLab.extLab (* structures               *)
	                    | SIGNATURE_ACCESSOR of environment         accid ExtLab.extLab (* signatures               *)
                            | FUNCTOR_ACCESSOR of (environment * environment) accid ExtLab.extLab (* functors              *)

	 and oneConstraint       = TYPE_CONSTRAINT of (Ty.ty    * Ty.ty)    ExtLab.extLab
	                         | TYPENAME_CONSTRAINT of (Ty.tnty  * Ty.tnty)  ExtLab.extLab
				 | SEQUENCE_CONSTRAINT of (Ty.seqty * Ty.seqty) ExtLab.extLab
				 | ROW_CONSTRAINT of (Ty.rowty * Ty.rowty) ExtLab.extLab
				 | LABEL_CONSTRAINT of (Ty.labty * Ty.labty) ExtLab.extLab
				 | ENV_CONSTRAINT of (environment      * environment)      ExtLab.extLab
				 | IDENTIFIER_CLASS_CONSTRAINT of (class    * class)    ExtLab.extLab
				 | FUNCTION_TYPE_CONSTRAINT of (Ty.tyfun * Ty.tyfun) ExtLab.extLab
				 | ACCESSOR_CONSTRAINT of accessor
	                         | LET_CONSTRAINT of environment
	                         | SIGNATURE_CONSTRAINT of evsbind (* Transform that into an environment with a switch for opaque and translucent *)
	                         | FUNCTOR_CONSTRAINT of evfbind (* Transform that into an environment *)
                                 | SHARING_CONSTRAINT of shabind (* Transform that into an environment *)

	 (* Concerning CSTVAL (used to close value declarations):
	  * - the first  tvsbind is for the IMPLICIT bound tyvar at the val
	  * - the second tvsbind is for the EXPLICIT bound tyvar at the val
          * - the third element is for the tyvar to build *)
	 (* Concerning ACCID: it will replace some type environments
          * - 1st csenv: variables, 2nd csenv: rec/constructors, 3rd csenv: types
          * - 1st cst: pattern, 2nd cst: expression
	  * - we would have to have the same for constructors, types and structures
          * - what about tvenv? *)
	 and constraints        = OCST of oneConstraint list cmap
    (* constraints maps integers (program point labels) to lists (conceptually sets) of oneConstraint's *)
    (*(2010-04-14)Conceptually, (INJI extty) seems to be an environment of the form:
     * ENVS (ENVV ev, ENVC x), where extty is declared in x and ev is fresh.*)
    (*(2010-03-02)not withtype because it is not SML valid and even though SML/NJ
     * does not complain, MLton does.*)

    type extstr = environment bind
    type strenv = environment genv

    type extsig = environment bind
    type sigenv = environment genv

    (* functor has type environment1 -> environment2 *)
    type funsem = environment * environment
    type extfun = funsem bind
    type funenv = funsem genv

    datatype ocss       = CSSMULT of Label.labels (* for a multi occurrence - the 'id list' is then always empty *)
			(*| CSG of csstya (* for long non-applied identifiers in patterns that should be constructors (because long) but are variables *)*)
			| CSSCVAR of Label.labels (* for applied identifiers in patterns that should be constructors but are variables *)
			(* CSCs should only be reported when the context dependency set is empty.
			 * And something similar for CSMs generated for constructors in patterns. *)
			| CSSEVAR of Label.labels (* for identifiers in exception bindings that should be exceptions but are variables *)
			| CSSECON of Label.labels (* for identifiers in exception bindings that should be exceptions but are datatype constructors *)
			| CSSINCL of Label.labels (* for non inclusion of type variable in dataptype         *)
			| CSSAPPL of Label.labels (* for applied and not applied value in pattern            *)
			| CSSFNAM of Label.labels (* for different function names                            *)
			| CSSFARG of Label.labels (* a function with different number of arguments           *)
			| CSSTYVA of Label.labels (* free type variable at top-level                         *)
			| CSSLEFT of Label.labels (* ident to left of as in pattern must be a variable       *)
			| CSSFREC of Label.labels (* expressions within rec value bindings must be functions *)
			| CSSREAL of Label.labels (* reals cannot occur within patterns                      *)
			| CSSFREE of Label.labels (* free identifier                                         *)
			| CSSWARN of Label.labels * string (* for a warning *)
			| CSSPARS of Label.labels * string (* for a parsing problem *)
    type css            = ocss list

    type envcss = environment * css


    (* ====== FUNCTIONS ====== *)

    val resetEnvVar  : unit  -> unit

    val freshEnvVar  : unit -> envvar
    val getEnvVar    : unit -> envvar

    val envVarToInt  : envvar -> int

    val eqEnvVar     : envvar -> envvar -> bool

    val newEnvVar    : Label.label -> environment
    val consENVVAR   : envvar -> Label.label -> environment

    val consEnvironmentConstructor     : varenv  ->
		       typenv  ->
		       tyvenv  ->
		       strenv  ->
		       sigenv  ->
		       funenv  ->
		       ovcenv  ->
		       infoEnv ->
		       environment
    val consInfo     : Label.label ->
		       bool        ->
		       tnmap       ->
		       bool        ->
		       infoEnv

    val emptyEnvironment : environment
    val emvar        : varenv
    val emtyp        : typenv
    val emstr        : strenv
    val emsig        : sigenv
    val emfun        : funenv
    val emopn        : opnenv
    val emtv         : tyvenv
    val emoc         : ovcenv
    val emgen        : 'a emap
    val emnfo        : infoEnv

    val consBind     : Id.id -> 'a -> ClassId.class -> Label.label -> Poly.poly -> 'a bind
    val consBindPoly : Id.id -> 'a -> ClassId.class -> Label.label              -> 'a bind
    val consBindMono : Id.id -> 'a -> ClassId.class -> Label.label              -> 'a bind

    val consAccId    : Id.lid -> 'a -> ClassId.class -> Label.label -> 'a accid

    val getBindI     : 'a bind -> Id.id
    val getBindT     : 'a bind -> 'a
    val getBindC     : 'a bind -> ClassId.class
    val getBindL     : 'a bind -> Label.label
    val getBindP     : 'a bind -> Poly.poly

    val getVids      : environment -> varenv
    val getTyps      : environment -> typenv
    val getTyvs      : environment -> tyvenv
    val getStrs      : environment -> strenv
    val getSigs      : environment -> sigenv
    val getFuns      : environment -> funenv
    val getOvcs      : environment -> ovcenv
    val getInfo      : environment -> infoEnv
    val getILab      : environment -> Label.label
    val getICmp      : environment -> bool
    val getITns      : environment -> tnmap
    val getIFct      : environment -> bool

    val projVids     : varenv -> environment
    val projTyps     : typenv -> environment
    val projTyvs     : tyvenv -> environment
    val projStrs     : strenv -> environment
    val projSigs     : sigenv -> environment
    val projFuns     : funenv -> environment
    val projOpns     : opnenv -> environment
    val projOvcs     : ovcenv  -> environment

    val updateVids   : varenv -> environment -> environment
    val updateTyps   : typenv -> environment -> environment
    val updateTyvs   : tyvenv -> environment -> environment
    val updateStrs   : strenv -> environment -> environment
    val updateOvcs   : ovcenv  -> environment -> environment
    val updateILab   : Label.label -> environment -> environment
    val updateICmp   : bool   -> environment -> environment
    val updateITns   : tnmap  -> environment -> environment
    val updateIFct   : bool   -> environment -> environment

    val getTyNames   : typenv -> names list

    val plusEnv            : environment -> environment -> environment

    val pushExtEnv         : environment -> Label.labels -> Label.labels -> LongId.set -> environment

    val isEmptyIdEnv       : 'a emap  -> bool
    val isEmptyEnv         : environment      -> bool

    (* Generates an environment from a long identifier and a type function *)
    val genLongEnv    : Id.lid -> Ty.tyfun -> constraints * environment

    (* Checks whether the environment is contains an environment variable *)
    val hasEnvVar     : environment -> bool

    (* true if a the environment is complete: checks the second element in infoEnv
     * of an ENVC (false if not a ENVC). *)
    val completeEnv     : environment -> bool
    (*(* Marks an environment as being incomplete *)
    val toIncompleteEnv : environment -> environment*)

    val isEnvV        : environment -> bool

    (* Checks the shape of the environment: if it is a ENVC *)
    val isEnvC          : environment -> bool

    (* Returns the ids (as ints) of an environment along with the associated labels.
     * The int is a debugging info. *)
    val getLabsIdsEnv : environment -> int -> (int * int) list * Label.labels

    (* Returns the label associated to a environment (dummylab if not an ENVC). *)
    val getLabEnv     : environment -> Label.label

    (* Filters the constraintss that are not in the label set *)
    val filterEnv     : environment -> Label.labels -> environment

    (*(* Get all the type names defined by an environment *)
    val getAllTns     : environment -> tnmap*)

    (*(* Returns the variable contained in the ENVV if the environment is a ENVV. *)
    val getEnvVar     : environment -> envvar option

    (* Extracts the identifiers of a structure/signature. *)
    (*val envToStrIds  : environment -> ClassId.str*)

    (* Extract the variable from an environment.  The environment has to be a variable. *)
    val envToEnvvar  : environment -> envvar*)

    val addenv       : (Id.id * 'a) -> 'a emap -> 'a emap
    val singenv      : (Id.id * 'a) -> 'a emap
    (*val findenv      : Id.id -> 'a emap -> 'a option*)
    val plusproj     : 'a genv -> Id.id -> 'a bind list
    (*val appenv       : ('a -> unit) -> 'a emap -> unit
    val appienv      : ((Id.id * 'a) -> unit) -> 'a emap -> unit*)
    val mapenv       : ('a -> 'a) -> 'a emap -> 'a emap
    val uenv         : 'a genv list -> 'a genv
    (*val remenv       : Id.id -> 'a emap -> 'a emap
    val inenv        : 'a emap -> Id.set -> 'a emap
    val outenv       : 'a emap -> Id.set -> 'a emap*)
    val plusenv      : 'a genv -> 'a genv -> 'a genv
    (*val foldrenv     : (('a * 'b) -> 'b) -> 'b -> 'a emap -> 'b
    val foldlenv     : (('a * 'b) -> 'b) -> 'b -> 'a emap -> 'b*)
    val foldrienv    : ((Id.id * 'a * 'b) -> 'b) -> 'b -> 'a emap -> 'b
    (*val foldlienv    : ((Id.id * 'a * 'b) -> 'b) -> 'b -> 'a emap -> 'b*)
    val dom          : 'a emap -> Id.set
    (*val doms         : 'a emap list -> Id.set*)

    val isMonoBind   : 'a bind -> bool

    val toMonoVids   : varenv -> Label.labels -> varenv
    val toPolyVids   : varenv -> varenv
    val toRECVids    : varenv -> Label.labels -> varenv
    val toPATVids    : varenv -> Label.labels -> varenv
    val toEX0Vids    : varenv -> Label.labels -> varenv
    val toEX1Vids    : varenv -> Label.labels -> varenv
    val toDA0Vids    : varenv -> Label.labels -> varenv
    val toDA1Vids    : varenv -> Label.labels -> varenv
    val toDATVids    : varenv -> Label.labels -> varenv
    val toCLSVids    : varenv -> ClassId.class -> Label.labels -> varenv
    val toTYCONTyps  : typenv -> varenv -> bool -> Label.labels -> typenv

    val closeVids    : varenv -> Expans.nonexp -> varenv

    val allEqualVids : varenv -> constraints

    val bindToEnv    : 'a bind list -> 'a genv
    val envToBind    : 'a genv      -> 'a bind list

    (* Union of environment *)
    val uenvEnv      : environment list -> environment

    val envsToSeq    : environment list -> environment

    val appOEnv      : (opnsem -> unit) -> opnenv -> unit
    val addOEnv      : opnsem -> opnenv -> opnenv
    val singOEnv     : opnsem -> opnenv
    val uOEnv        : opnenv list -> opnenv
    val foldlOEnv    : ((opnsem * 'b) -> 'b) -> 'b -> opnenv -> 'b

    (* ------ FUNCTIONS FOR CONSTRAINTS ------*)
    val emcss            : css
    val emptyConstraint  : constraints
    val consConstraint   : (Label.label * oneConstraint) -> constraints -> constraints
    val conscsts         : (Label.label * oneConstraint list) -> constraints -> constraints
    val singleConstraint : (Label.label * oneConstraint) -> constraints
    val singcss          : ocss -> css
    val singcsss         : ocss list -> css
    val singcsts         : (Label.label * oneConstraint list) -> constraints
    val uenvcss          : css list -> css
    val uenvcst          : constraints list -> constraints
    val getnbcs          : envcss -> int
    val getnbcss         : envcss -> int
    val getnbcst         : envcss -> int
    val getnbcsttop      : envcss -> int
    val foldlicst        : ((int * oneConstraint list * 'b) -> 'b) -> 'b -> constraints -> 'b
    val getbindings      : environment -> Label.labels list * Label.labels
    
    val genCstTyAll  : Ty.ty     -> Ty.ty    -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstTfAll  : Ty.tyfun  -> Ty.tyfun -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstTnAll  : Ty.tnty   -> Ty.tnty  -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstSqAll  : Ty.seqty  -> Ty.seqty -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstRtAll  : Ty.rowty  -> Ty.rowty -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstLtAll  : Ty.labty  -> Ty.labty -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstEvAll  : environment       -> environment      -> Label.labels -> Label.labels -> LongId.set -> oneConstraint
    val genCstClAll  : class     -> class    -> Label.labels -> Label.labels -> LongId.set -> oneConstraint

    val genValueIDAccessor  : Ty.ty    accid -> Label.labels -> Label.labels -> LongId.set -> accessor

    val initTypeConstraint         : Ty.ty    -> Ty.ty    -> Label.label -> oneConstraint
    val initFunctionTypeConstraint : Ty.tyfun -> Ty.tyfun -> Label.label -> oneConstraint
    val initTypenameConstraint     : Ty.tnty  -> Ty.tnty  -> Label.label -> oneConstraint
    val initSequenceConstraint     : Ty.seqty -> Ty.seqty -> Label.label -> oneConstraint
    val initRowConstraint          : Ty.rowty -> Ty.rowty -> Label.label -> oneConstraint
    val initLabelConstraint        : Ty.labty -> Ty.labty -> Label.label -> oneConstraint
    val initEnvConstraint          : environment      -> environment      -> Label.label -> oneConstraint
    val initClassConstraint        : class    -> class    -> Label.label -> oneConstraint

    val genAccIvEm   : Ty.ty    accid -> Label.label -> accessor
    val genAccIeEm   : Ty.tyvar accid -> Label.label -> accessor
    val genAccItEm   : Ty.tyfun accid -> Label.label -> accessor
    val genAccIoEm   : Ty.seqty accid -> Label.label -> accessor
    val genAccIsEm   : environment      accid -> Label.label -> accessor
    val genAccIiEm   : environment      accid -> Label.label -> accessor
    val genAccIfEm   : funsem   accid -> Label.label -> accessor

    val printEnv     : environment    -> string -> string
end
