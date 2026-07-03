(* Parity test between the OCaml constraint system (Plonk_constraint_system)
   and the Rust-backed one (Rust_constraint_system, via the snarky crate of
   proof-systems): for the same basic snarky constraints, both must produce
   the same circuit (same rows, same gate types, same wiring, same
   coefficients), otherwise the verification keys would differ. *)

open Core_kernel
module Backend = Kimchi_pasta_snarky_backend.Vesta_based_plonk
module Ocaml_cs = Backend.R1CS_constraint_system
module Rust_cs = Backend.Rust_R1CS_constraint_system
module Field = Backend.Field
module PC = Kimchi_pasta_snarky_backend.Plonk_constraint_system.Plonk_constraint

(* a small but representative sequence of basic constraints, with one public
   input (v0):
   - v0 boolean
   - v1 * v1 = v2
   - v0 * v1 = v3
   - v2 + 2*v3 = v4 *)
let v i : Field.t Snarky_backendless.Cvar.t =
  Snarky_backendless.Cvar.Unsafe.of_index i

let add_constraints (add : Backend.Constraint.t -> unit) =
  add (PC.Boolean (v 0)) ;
  add (PC.Square (v 1, v 2)) ;
  add (PC.R1CS (v 0, v 1, v 3)) ;
  add
    (PC.Equal
       ( Snarky_backendless.Cvar.Add
           (v 2, Snarky_backendless.Cvar.Scale (Field.of_int 2, v 3))
       , v 4 ) ) ;
  (* generic kimchi gate: 3*v1 + 4*v2 - v3 + 5*v1*v2 + 7 = 0 *)
  add
    (PC.Basic
       { l = (Field.of_int 3, v 1)
       ; r = (Field.of_int 4, v 2)
       ; o = (Field.of_int (-1), v 3)
       ; m = Field.of_int 5
       ; c = Field.of_int 7
       } ) ;
  (* a full poseidon permutation: 55 rounds + final state, SPONGE_WIDTH 3;
     the wiring uses fresh variables per intermediary state *)
  let rounds = 55 in
  let first_var = 5 in
  let state =
    Array.init (rounds + 1) ~f:(fun round ->
        Array.init 3 ~f:(fun i -> v (first_var + (round * 3) + i)) )
  in
  add (PC.Poseidon { state }) ;
  (* fresh variable supply for the remaining constraint kinds *)
  let next = ref (first_var + (56 * 3)) in
  let fresh () =
    let x = v !next in
    incr next ; x
  in
  let fresh_n n = Array.init n ~f:(fun _ -> fresh ()) in
  let fresh_pair () = (fresh (), fresh ()) in
  (* EC complete addition *)
  add
    (PC.EC_add_complete
       { p1 = fresh_pair ()
       ; p2 = fresh_pair ()
       ; p3 = fresh_pair ()
       ; inf = fresh ()
       ; same_x = fresh ()
       ; slope = fresh ()
       ; inf_z = fresh ()
       ; x21_inv = fresh ()
       } ) ;
  (* variable-base scalar multiplication, one round *)
  add
    (PC.EC_scale
       { state =
           [| { Kimchi_pasta_snarky_backend.Scale_round.accs =
                  Array.init 6 ~f:(fun _ -> fresh_pair ())
              ; bits = fresh_n 5
              ; ss = fresh_n 5
              ; base = fresh_pair ()
              ; n_prev = fresh ()
              ; n_next = fresh ()
              }
           |]
       } ) ;
  (* endoscaling, one round *)
  add
    (PC.EC_endoscale
       { state =
           [| { Kimchi_pasta_snarky_backend.Endoscale_round.xt = fresh ()
              ; yt = fresh ()
              ; xp = fresh ()
              ; yp = fresh ()
              ; n_acc = fresh ()
              ; xr = fresh ()
              ; yr = fresh ()
              ; s1 = fresh ()
              ; s3 = fresh ()
              ; b1 = fresh ()
              ; b2 = fresh ()
              ; b3 = fresh ()
              ; b4 = fresh ()
              ; inv = fresh ()
              }
           |]
       ; xs = fresh ()
       ; ys = fresh ()
       ; n_acc = fresh ()
       } ) ;
  (* endoscalar, one round *)
  add
    (PC.EC_endoscalar
       { state =
           [| { Kimchi_pasta_snarky_backend.Endoscale_scalar_round.n0 =
                  fresh ()
              ; n8 = fresh ()
              ; a0 = fresh ()
              ; b0 = fresh ()
              ; a8 = fresh ()
              ; b8 = fresh ()
              ; x0 = fresh ()
              ; x1 = fresh ()
              ; x2 = fresh ()
              ; x3 = fresh ()
              ; x4 = fresh ()
              ; x5 = fresh ()
              ; x6 = fresh ()
              ; x7 = fresh ()
              }
           |]
       } ) ;
  (* range checks *)
  (let f = fresh in
   add
     (PC.RangeCheck0
        { v0 = f ()
        ; v0p0 = f ()
        ; v0p1 = f ()
        ; v0p2 = f ()
        ; v0p3 = f ()
        ; v0p4 = f ()
        ; v0p5 = f ()
        ; v0c0 = f ()
        ; v0c1 = f ()
        ; v0c2 = f ()
        ; v0c3 = f ()
        ; v0c4 = f ()
        ; v0c5 = f ()
        ; v0c6 = f ()
        ; v0c7 = f ()
        ; compact = Field.zero
        } ) ;
   add
     (PC.RangeCheck1
        { v2 = f ()
        ; v12 = f ()
        ; v2c0 = f ()
        ; v2p0 = f ()
        ; v2p1 = f ()
        ; v2p2 = f ()
        ; v2p3 = f ()
        ; v2c1 = f ()
        ; v2c2 = f ()
        ; v2c3 = f ()
        ; v2c4 = f ()
        ; v2c5 = f ()
        ; v2c6 = f ()
        ; v2c7 = f ()
        ; v2c8 = f ()
        ; v2c9 = f ()
        ; v2c10 = f ()
        ; v2c11 = f ()
        ; v0p0 = f ()
        ; v0p1 = f ()
        ; v1p0 = f ()
        ; v1p1 = f ()
        ; v2c12 = f ()
        ; v2c13 = f ()
        ; v2c14 = f ()
        ; v2c15 = f ()
        ; v2c16 = f ()
        ; v2c17 = f ()
        ; v2c18 = f ()
        ; v2c19 = f ()
        } ) ;
   (* lookup *)
   add
     (PC.Lookup
        { w0 = f ()
        ; w1 = f ()
        ; w2 = f ()
        ; w3 = f ()
        ; w4 = f ()
        ; w5 = f ()
        ; w6 = f ()
        } ) ;
   (* xor *)
   add
     (PC.Xor
        { in1 = f ()
        ; in2 = f ()
        ; out = f ()
        ; in1_0 = f ()
        ; in1_1 = f ()
        ; in1_2 = f ()
        ; in1_3 = f ()
        ; in2_0 = f ()
        ; in2_1 = f ()
        ; in2_2 = f ()
        ; in2_3 = f ()
        ; out_0 = f ()
        ; out_1 = f ()
        ; out_2 = f ()
        ; out_3 = f ()
        } ) ;
   (* rotation *)
   add
     (PC.Rot64
        { word = f ()
        ; rotated = f ()
        ; excess = f ()
        ; bound_limb0 = f ()
        ; bound_limb1 = f ()
        ; bound_limb2 = f ()
        ; bound_limb3 = f ()
        ; bound_crumb0 = f ()
        ; bound_crumb1 = f ()
        ; bound_crumb2 = f ()
        ; bound_crumb3 = f ()
        ; bound_crumb4 = f ()
        ; bound_crumb5 = f ()
        ; bound_crumb6 = f ()
        ; bound_crumb7 = f ()
        ; two_to_rot = Field.of_int 256
        } ) ;
   (* foreign field addition *)
   add
     (PC.ForeignFieldAdd
        { left_input_lo = f ()
        ; left_input_mi = f ()
        ; left_input_hi = f ()
        ; right_input_lo = f ()
        ; right_input_mi = f ()
        ; right_input_hi = f ()
        ; field_overflow = f ()
        ; carry = f ()
        ; foreign_field_modulus0 = Field.of_int 11
        ; foreign_field_modulus1 = Field.of_int 12
        ; foreign_field_modulus2 = Field.of_int 13
        ; sign = Field.one
        } ) ;
   (* foreign field multiplication *)
   add
     (PC.ForeignFieldMul
        { left_input0 = f ()
        ; left_input1 = f ()
        ; left_input2 = f ()
        ; right_input0 = f ()
        ; right_input1 = f ()
        ; right_input2 = f ()
        ; remainder01 = f ()
        ; remainder2 = f ()
        ; quotient0 = f ()
        ; quotient1 = f ()
        ; quotient2 = f ()
        ; quotient_hi_bound = f ()
        ; product1_lo = f ()
        ; product1_hi_0 = f ()
        ; product1_hi_1 = f ()
        ; carry0 = f ()
        ; carry1_0 = f ()
        ; carry1_12 = f ()
        ; carry1_24 = f ()
        ; carry1_36 = f ()
        ; carry1_48 = f ()
        ; carry1_60 = f ()
        ; carry1_72 = f ()
        ; carry1_84 = f ()
        ; carry1_86 = f ()
        ; carry1_88 = f ()
        ; carry1_90 = f ()
        ; foreign_field_modulus2 = Field.of_int 13
        ; neg_foreign_field_modulus0 = Field.of_int 21
        ; neg_foreign_field_modulus1 = Field.of_int 22
        ; neg_foreign_field_modulus2 = Field.of_int 23
        } ) ) ;
  ignore (!next : int)

let num_aux =
  (* v1..v4 + poseidon states + all the fresh variables of the other kinds *)
  4 + (56 * 3) + 300

let build_ocaml () =
  let cs = Ocaml_cs.create () in
  Ocaml_cs.set_primary_input_size cs 1 ;
  add_constraints (Ocaml_cs.add_constraint cs) ;
  Ocaml_cs.set_auxiliary_input_size cs num_aux ;
  Ocaml_cs.finalize cs ;
  cs

let build_rust () =
  let cs = Rust_cs.create () in
  Rust_cs.set_primary_input_size cs 1 ;
  add_constraints (Rust_cs.add_constraint cs) ;
  Rust_cs.set_auxiliary_input_size cs num_aux ;
  Rust_cs.finalize cs ;
  cs

let test_rows_len () =
  let ocaml_cs = build_ocaml () in
  let rust_cs = build_rust () in
  Alcotest.(check int)
    "same number of rows"
    (Ocaml_cs.get_rows_len ocaml_cs)
    (Rust_cs.get_rows_len rust_cs)

let gate_type_to_string (t : Kimchi_types.gate_type) =
  match t with
  | Zero ->
      "Zero"
  | Generic ->
      "Generic"
  | Poseidon ->
      "Poseidon"
  | CompleteAdd ->
      "CompleteAdd"
  | VarBaseMul ->
      "VarBaseMul"
  | EndoMul ->
      "EndoMul"
  | EndoMulScalar ->
      "EndoMulScalar"
  | Lookup ->
      "Lookup"
  | _ ->
      "Other"

let show_gate (g : Field.t Kimchi_types.circuit_gate) =
  let wire (w : Kimchi_types.wire) = Printf.sprintf "(%d,%d)" w.row w.col in
  let w0, w1, w2, w3, w4, w5, w6 = g.wires in
  Printf.sprintf "typ=%s wires=%s coeffs=[%s]"
    (gate_type_to_string g.typ)
    (String.concat ~sep:";" (List.map ~f:wire [ w0; w1; w2; w3; w4; w5; w6 ]))
    (String.concat ~sep:";"
       (Array.to_list (Array.map g.coeffs ~f:Field.to_string)) )

(* compare the actual gates: type, wiring and coefficients *)
let test_gates () =
  let ocaml_cs = build_ocaml () in
  let rust_cs = build_rust () in
  let ocaml_gates, _, _ = Ocaml_cs.finalize_and_get_gates ocaml_cs in
  let rust_gates = Rust_cs.finalize_and_get_gates rust_cs in
  let module V = Kimchi_bindings.Protocol.Gates.Vector.Fp in
  (* both gate vectors include the public-input rows *)
  let n_ocaml = V.len ocaml_gates in
  Alcotest.(check int) "same gate count" n_ocaml (Array.length rust_gates) ;
  for i = 0 to n_ocaml - 1 do
    let g_ocaml = V.get ocaml_gates i in
    let g_rust = rust_gates.(i) in
    Alcotest.(check string)
      (Printf.sprintf "gate %d" i)
      (show_gate g_ocaml) (show_gate g_rust)
  done

let () =
  Alcotest.run "Rust constraint system parity"
    [ ( "parity"
      , [ Alcotest.test_case "rows_len" `Quick test_rows_len
        ; Alcotest.test_case "gates" `Quick test_gates
        ] )
    ]
