(** A constraint system backed by the Rust snarky implementation
    (proof-systems' [snarky] crate), via the
    [Kimchi_bindings.Protocol.SnarkyConstraintSystem] externals.

    This is the replacement for the OCaml {!Plonk_constraint_system}: the
    constraint reduction, gate layout, permutation and witness computation
    all live on the Rust side. Circuit variables are flattened to linear
    combinations [(constant, [(coefficient, var_index); ...])] before
    crossing the FFI boundary.

    Current scope: the basic snarky constraints (boolean, equal, square,
    r1cs). The kimchi custom constraints (Poseidon, EC gates, range checks,
    lookups) are implemented in Rust but their FFI is not wired yet — see
    src/lib/snarky/CLAUDE.md for the migration status. *)

(* alias before [open Core_kernel], which has its own [Field] module *)
module Backend_field = Field

open Core_kernel

(** The signature of the generated externals
    ([Kimchi_bindings.Protocol.SnarkyConstraintSystem.Fp] and [.Fq]). *)
module type Ffi = sig
  type field

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

  val finalize : t -> unit

  val digest : t -> bytes

  val get_gates : t -> field Kimchi_types.circuit_gate array

  val compute_witness : t -> field array -> field array -> field array array
end

module Make
    (Fp : Backend_field.S)
    (Ffi : Ffi with type field := Fp.t) =
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
    | _ ->
        failwithf
          "Rust_constraint_system.add_constraint: kimchi constraint not yet \
           exposed through the FFI (lookup / range check / xor / foreign \
           field / rot): %s"
          (Sexp.to_string (Constraint.sexp_of_t c))
          ()

  (* compilation *)

  let finalize (t : t) = Ffi.finalize t.cs

  let finalize_and_get_gates (t : t) =
    Ffi.finalize t.cs ;
    Ffi.get_gates t.cs

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

