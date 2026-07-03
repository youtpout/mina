(** A constraint system backed by the Rust snarky implementation
    (proof-systems' [snarky] crate), via the
    [Kimchi_bindings.Protocol.SnarkyConstraintSystem] externals.

    This is the replacement for the OCaml {!Plonk_constraint_system}: the
    constraint reduction, gate layout, permutation and witness computation
    all live on the Rust side. Circuit variables are flattened to linear
    combinations [(constant, [(coefficient, var_index); ...])] before
    crossing the FFI boundary.

    Current scope: all constraint variants except the lookup-table
    configurations (AddFixedLookupTable / AddRuntimeTableCfg), which still
    need a real port on the Rust side — see src/lib/snarky/CLAUDE.md for
    the migration status. *)

(* alias before [open Core_kernel], which has its own [Field] module *)
module Backend_field = Field

open Core_kernel

(** The signature of the generated externals
    ([Kimchi_bindings.Protocol.SnarkyConstraintSystem.Fp] and [.Fq]). *)
module type Ffi = sig
  type field

  type gates

  type t

  val create : unit -> t

  val set_primary_input_size : t -> int -> unit

  val get_primary_input_size : t -> int

  val set_prev_challenges : t -> int -> unit

  val get_rows_len : t -> int

  val add_boolean : t -> field option * (field * int) array -> unit

  val add_equal :
       t
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> unit

  val add_square :
       t
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> unit

  val add_r1cs :
       t
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> unit

  val add_basic :
       t
    -> field * (field option * (field * int) array)
    -> field * (field option * (field * int) array)
    -> field * (field option * (field * int) array)
    -> field
    -> field
    -> unit

  val add_poseidon : t -> (field option * (field * int) array) array array -> unit

  val add_ec_add_complete :
       t
    -> (field option * (field * int) array) * (field option * (field * int) array)
    -> (field option * (field * int) array) * (field option * (field * int) array)
    -> (field option * (field * int) array) * (field option * (field * int) array)
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> unit

  val add_ec_scale :
       t
    -> ( ( (field option * (field * int) array)
         * (field option * (field * int) array) )
         array
       * (field option * (field * int) array) array
       * (field option * (field * int) array) array
       * ( (field option * (field * int) array)
         * (field option * (field * int) array) )
       * (field option * (field * int) array)
       * (field option * (field * int) array) )
       array
    -> unit

  val add_ec_endoscale :
       t
    -> (field option * (field * int) array) array array
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> field option * (field * int) array
    -> unit

  val add_ec_endoscalar :
    t -> (field option * (field * int) array) array array -> unit

  val add_range_check0 : t -> (field option * (field * int) array) array -> field -> unit

  val add_range_check1 : t -> (field option * (field * int) array) array -> (field option * (field * int) array) array -> unit

  val add_lookup : t -> (field option * (field * int) array) array -> unit

  val add_row :
       t
    -> Kimchi_types.gate_type
    -> (field option * (field * int) array) option array
    -> field array
    -> unit

  val to_gate_vector : t -> gates

  val finalize : t -> unit

  val digest : t -> bytes

  val get_gates : t -> field Kimchi_types.circuit_gate array

  val compute_witness : t -> field array -> field array -> field array array
end

module Make
    (Fp : Backend_field.S)
    (Gates : sig
      type t
    end)
    (Ffi : Ffi with type field := Fp.t and type gates := Gates.t) =
struct
  (* the same constraint type as the OCaml backend, so that this module is a
     drop-in replacement *)
  module Constraint = Plonk_constraint_system.Plonk_constraint.Make (Fp)

  type constraint_ = Constraint.t

  type t =
    { cs : Ffi.t
    ; mutable public_input_size : int Set_once.t
    ; mutable auxiliary_input_size : int Set_once.t
    ; mutable prev_challenges : int Set_once.t
    }

  let create () : t =
    { cs = Ffi.create ()
    ; public_input_size = Set_once.create ()
    ; auxiliary_input_size = Set_once.create ()
    ; prev_challenges = Set_once.create ()
    }

  (* input sizes *)

  let get_public_input_size (t : t) = t.public_input_size

  let get_primary_input_size (t : t) = Ffi.get_primary_input_size t.cs

  let set_primary_input_size (t : t) x =
    Set_once.set_exn t.public_input_size [%here] x ;
    Ffi.set_primary_input_size t.cs x

  let get_auxiliary_input_size (t : t) = t.auxiliary_input_size

  let set_auxiliary_input_size (t : t) x =
    Set_once.set_exn t.auxiliary_input_size [%here] x

  let get_prev_challenges (t : t) = Set_once.get t.prev_challenges

  let set_prev_challenges (t : t) x =
    Set_once.set_exn t.prev_challenges [%here] x ;
    Ffi.set_prev_challenges t.cs x

  let get_rows_len (t : t) = Ffi.get_rows_len t.cs

  (* constraints *)

  (** Flattens a [Cvar.t] tree into the linear combination representation
      expected by the FFI. *)
  let flatten (v : Fp.t Snarky_backendless.Cvar.t) :
      Fp.t option * (Fp.t * int) array =
    let constant, terms =
      Snarky_backendless.Cvar.to_constant_and_terms ~equal:Fp.equal
        ~add:Fp.add ~mul:Fp.mul ~zero:Fp.zero ~one:Fp.one v
    in
    (constant, Array.of_list terms)

  let add_constraint (t : t) (c : constraint_) =
    let pair (x, y) = (flatten x, flatten y) in
    match c with
    | Plonk_constraint_system.Plonk_constraint.Boolean v ->
        Ffi.add_boolean t.cs (flatten v)
    | Plonk_constraint_system.Plonk_constraint.Equal (v1, v2) ->
        Ffi.add_equal t.cs (flatten v1) (flatten v2)
    | Plonk_constraint_system.Plonk_constraint.Square (a, b) ->
        Ffi.add_square t.cs (flatten a) (flatten b)
    | Plonk_constraint_system.Plonk_constraint.R1CS (a, b, c) ->
        Ffi.add_r1cs t.cs (flatten a) (flatten b) (flatten c)
    | Plonk_constraint_system.Plonk_constraint.Basic
        { l = cl, vl; r = cr, vr; o = co, vo; m; c } ->
        Ffi.add_basic t.cs (cl, flatten vl) (cr, flatten vr) (co, flatten vo)
          m c
    | Plonk_constraint_system.Plonk_constraint.Poseidon { state } ->
        Ffi.add_poseidon t.cs (Array.map state ~f:(Array.map ~f:flatten))
    | Plonk_constraint_system.Plonk_constraint.EC_add_complete
        { p1; p2; p3; inf; same_x; slope; inf_z; x21_inv } ->
        Ffi.add_ec_add_complete t.cs (pair p1) (pair p2) (pair p3)
          (flatten inf) (flatten same_x) (flatten slope) (flatten inf_z)
          (flatten x21_inv)
    | Plonk_constraint_system.Plonk_constraint.EC_scale { state } ->
        let round (r : _ Scale_round.t) =
          ( Array.map r.accs ~f:pair
          , Array.map r.bits ~f:flatten
          , Array.map r.ss ~f:flatten
          , pair r.base
          , flatten r.n_prev
          , flatten r.n_next )
        in
        Ffi.add_ec_scale t.cs (Array.map state ~f:round)
    | Plonk_constraint_system.Plonk_constraint.EC_endoscale
        { state; xs; ys; n_acc } ->
        (* fixed order expected by the FFI:
           [xt; yt; xp; yp; n_acc; xr; yr; s1; s3; b1; b2; b3; b4; inv] *)
        let round (r : _ Endoscale_round.t) =
          Array.map ~f:flatten
            [| r.xt
             ; r.yt
             ; r.xp
             ; r.yp
             ; r.n_acc
             ; r.xr
             ; r.yr
             ; r.s1
             ; r.s3
             ; r.b1
             ; r.b2
             ; r.b3
             ; r.b4
             ; r.inv
            |]
        in
        Ffi.add_ec_endoscale t.cs
          (Array.map state ~f:round)
          (flatten xs) (flatten ys) (flatten n_acc)
    | Plonk_constraint_system.Plonk_constraint.EC_endoscalar { state } ->
        (* fixed order expected by the FFI:
           [n0; n8; a0; b0; a8; b8; x0; x1; x2; x3; x4; x5; x6; x7] *)
        let round (r : _ Endoscale_scalar_round.t) =
          Array.map ~f:flatten
            [| r.n0
             ; r.n8
             ; r.a0
             ; r.b0
             ; r.a8
             ; r.b8
             ; r.x0
             ; r.x1
             ; r.x2
             ; r.x3
             ; r.x4
             ; r.x5
             ; r.x6
             ; r.x7
            |]
        in
        Ffi.add_ec_endoscalar t.cs (Array.map state ~f:round)
    | Plonk_constraint_system.Plonk_constraint.RangeCheck0
        { v0
        ; v0p0
        ; v0p1
        ; v0p2
        ; v0p3
        ; v0p4
        ; v0p5
        ; v0c0
        ; v0c1
        ; v0c2
        ; v0c3
        ; v0c4
        ; v0c5
        ; v0c6
        ; v0c7
        ; compact
        } ->
        Ffi.add_range_check0 t.cs
          (Array.map ~f:flatten
             [| v0; v0p0; v0p1; v0p2; v0p3; v0p4; v0p5; v0c0; v0c1; v0c2
              ; v0c3; v0c4; v0c5; v0c6; v0c7
             |] )
          compact
    | Plonk_constraint_system.Plonk_constraint.RangeCheck1
        { v2
        ; v12
        ; v2c0
        ; v2p0
        ; v2p1
        ; v2p2
        ; v2p3
        ; v2c1
        ; v2c2
        ; v2c3
        ; v2c4
        ; v2c5
        ; v2c6
        ; v2c7
        ; v2c8
        ; v2c9
        ; v2c10
        ; v2c11
        ; v0p0
        ; v0p1
        ; v1p0
        ; v1p1
        ; v2c12
        ; v2c13
        ; v2c14
        ; v2c15
        ; v2c16
        ; v2c17
        ; v2c18
        ; v2c19
        } ->
        Ffi.add_range_check1 t.cs
          (Array.map ~f:flatten
             [| v2; v12; v2c0; v2p0; v2p1; v2p2; v2p3; v2c1; v2c2; v2c3
              ; v2c4; v2c5; v2c6; v2c7; v2c8
             |] )
          (Array.map ~f:flatten
             [| v2c9; v2c10; v2c11; v0p0; v0p1; v1p0; v1p1; v2c12; v2c13
              ; v2c14; v2c15; v2c16; v2c17; v2c18; v2c19
             |] )
    | Plonk_constraint_system.Plonk_constraint.Lookup
        { w0; w1; w2; w3; w4; w5; w6 } ->
        Ffi.add_lookup t.cs
          (Array.map ~f:flatten [| w0; w1; w2; w3; w4; w5; w6 |])
    | Plonk_constraint_system.Plonk_constraint.Xor
        { in1
        ; in2
        ; out
        ; in1_0
        ; in1_1
        ; in1_2
        ; in1_3
        ; in2_0
        ; in2_1
        ; in2_2
        ; in2_3
        ; out_0
        ; out_1
        ; out_2
        ; out_3
        } ->
        let s x = Some (flatten x) in
        Ffi.add_row t.cs Kimchi_types.Xor16
          [| s in1; s in2; s out; s in1_0; s in1_1; s in1_2; s in1_3; s in2_0
           ; s in2_1; s in2_2; s in2_3; s out_0; s out_1; s out_2; s out_3
          |]
          [||]
    | Plonk_constraint_system.Plonk_constraint.Rot64
        { word
        ; rotated
        ; excess
        ; bound_limb0
        ; bound_limb1
        ; bound_limb2
        ; bound_limb3
        ; bound_crumb0
        ; bound_crumb1
        ; bound_crumb2
        ; bound_crumb3
        ; bound_crumb4
        ; bound_crumb5
        ; bound_crumb6
        ; bound_crumb7
        ; two_to_rot
        } ->
        let s x = Some (flatten x) in
        Ffi.add_row t.cs Kimchi_types.Rot64
          [| s word; s rotated; s excess; s bound_limb0; s bound_limb1
           ; s bound_limb2; s bound_limb3; s bound_crumb0; s bound_crumb1
           ; s bound_crumb2; s bound_crumb3; s bound_crumb4; s bound_crumb5
           ; s bound_crumb6; s bound_crumb7
          |]
          [| two_to_rot |]
    | Plonk_constraint_system.Plonk_constraint.ForeignFieldAdd
        { left_input_lo
        ; left_input_mi
        ; left_input_hi
        ; right_input_lo
        ; right_input_mi
        ; right_input_hi
        ; field_overflow
        ; carry
        ; foreign_field_modulus0
        ; foreign_field_modulus1
        ; foreign_field_modulus2
        ; sign
        } ->
        let s x = Some (flatten x) in
        Ffi.add_row t.cs Kimchi_types.ForeignFieldAdd
          [| s left_input_lo; s left_input_mi; s left_input_hi
           ; s right_input_lo; s right_input_mi; s right_input_hi
           ; s field_overflow; s carry; None; None; None; None; None; None
           ; None
          |]
          [| foreign_field_modulus0
           ; foreign_field_modulus1
           ; foreign_field_modulus2
           ; sign
          |]
    | Plonk_constraint_system.Plonk_constraint.ForeignFieldMul
        { left_input0
        ; left_input1
        ; left_input2
        ; right_input0
        ; right_input1
        ; right_input2
        ; remainder01
        ; remainder2
        ; quotient0
        ; quotient1
        ; quotient2
        ; quotient_hi_bound
        ; product1_lo
        ; product1_hi_0
        ; product1_hi_1
        ; carry0
        ; carry1_0
        ; carry1_12
        ; carry1_24
        ; carry1_36
        ; carry1_48
        ; carry1_60
        ; carry1_72
        ; carry1_84
        ; carry1_86
        ; carry1_88
        ; carry1_90
        ; foreign_field_modulus2
        ; neg_foreign_field_modulus0
        ; neg_foreign_field_modulus1
        ; neg_foreign_field_modulus2
        } ->
        let s x = Some (flatten x) in
        Ffi.add_row t.cs Kimchi_types.ForeignFieldMul
          [| s left_input0; s left_input1; s left_input2; s right_input0
           ; s right_input1; s right_input2; s product1_lo; s carry1_0
           ; s carry1_12; s carry1_24; s carry1_36; s carry1_84; s carry1_86
           ; s carry1_88; s carry1_90
          |]
          [| foreign_field_modulus2
           ; neg_foreign_field_modulus0
           ; neg_foreign_field_modulus1
           ; neg_foreign_field_modulus2
          |] ;
        Ffi.add_row t.cs Kimchi_types.Zero
          [| s remainder01; s remainder2; s quotient0; s quotient1
           ; s quotient2; s quotient_hi_bound; s product1_hi_0
           ; s product1_hi_1; s carry1_48; s carry1_60; s carry1_72; s carry0
           ; None; None; None
          |]
          [||]
    | _ ->
        failwithf
          "Rust_constraint_system.add_constraint: kimchi constraint not yet \
           exposed through the FFI (lookup / range check / xor / foreign \
           field / rot): %s"
          (Sexp.to_string (Constraint.sexp_of_t c))
          ()

  (* compilation *)

  let finalize (t : t) = Ffi.finalize t.cs

  (** The gates as OCaml values (used by the parity tests). *)
  let get_gates (t : t) =
    Ffi.finalize t.cs ;
    Ffi.get_gates t.cs

  (** The gates as a native (Rust-side) gate vector, handed directly to the
      index-creation path. Lookup tables are not supported yet. *)
  let finalize_and_get_gates (t : t) :
      Gates.t
      * Fp.t Kimchi_types.lookup_table array
      * Fp.t Kimchi_types.runtime_table_cfg array =
    (Ffi.to_gate_vector t.cs, [||], [||])

  (** Note: this is the (md5 of the) Rust-side digest of the gates; it is a
      circuit identity, but it is NOT equal to the digest computed by the
      OCaml {!Plonk_constraint_system} (different serialization and hash). *)
  let digest (t : t) = Md5.digest_bytes (Ffi.digest t.cs)

  let num_constraints = get_rows_len

  let next_row = get_rows_len

  (* witness *)

  let compute_witness (t : t) (external_values : int -> Fp.t) :
      Fp.t array array =
    let primary = Ffi.get_primary_input_size t.cs in
    let auxiliary = Set_once.get_exn t.auxiliary_input_size [%here] in
    let public_inputs = Array.init primary ~f:external_values in
    let private_inputs =
      Array.init auxiliary ~f:(fun i -> external_values (primary + i))
    in
    Ffi.compute_witness t.cs public_inputs private_inputs
end

