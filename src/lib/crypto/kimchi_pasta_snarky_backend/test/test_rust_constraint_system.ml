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
  add (PC.Poseidon { state })

let num_aux =
  (* v1..v4 + poseidon intermediary states *)
  4 + (56 * 3)

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
