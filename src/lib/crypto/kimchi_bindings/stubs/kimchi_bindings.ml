(* This file is generated automatically with ocaml_gen. *)

module FieldVectors = struct
  module Fp = struct
    type nonrec t

    type nonrec elt = Pasta_bindings.Fp.t

    external create : unit -> t = "caml_fp_vector_create"

    external length : t -> int = "caml_fp_vector_length"

    external emplace_back : t -> elt -> unit = "caml_fp_vector_emplace_back"

    external get : t -> int -> elt = "caml_fp_vector_get"

    external set : t -> int -> elt -> unit = "caml_fp_vector_set"
  end

  module Fq = struct
    type nonrec t

    type nonrec elt = Pasta_bindings.Fq.t

    external create : unit -> t = "caml_fq_vector_create"

    external length : t -> int = "caml_fq_vector_length"

    external emplace_back : t -> elt -> unit = "caml_fq_vector_emplace_back"

    external get : t -> int -> elt = "caml_fq_vector_get"

    external set : t -> int -> elt -> unit = "caml_fq_vector_set"
  end
end

module Protocol = struct
  module Gates = struct
    module Vector = struct
      module Fp = struct
        type nonrec t

        type nonrec elt = Pasta_bindings.Fp.t Kimchi_types.circuit_gate

        external create : unit -> t = "caml_pasta_fp_plonk_gate_vector_create"

        external add : t -> elt -> unit = "caml_pasta_fp_plonk_gate_vector_add"

        external get : t -> int -> elt = "caml_pasta_fp_plonk_gate_vector_get"

        external len : t -> int = "caml_pasta_fp_plonk_gate_vector_len"

        external wrap : t -> Kimchi_types.wire -> Kimchi_types.wire -> unit
          = "caml_pasta_fp_plonk_gate_vector_wrap"

        external digest : int -> t -> bytes
          = "caml_pasta_fp_plonk_gate_vector_digest"

        external to_json : int -> t -> string
          = "caml_pasta_fp_plonk_circuit_serialize"
      end

      module Fq = struct
        type nonrec t

        type nonrec elt = Pasta_bindings.Fq.t Kimchi_types.circuit_gate

        external create : unit -> t = "caml_pasta_fq_plonk_gate_vector_create"

        external add : t -> elt -> unit = "caml_pasta_fq_plonk_gate_vector_add"

        external get : t -> int -> elt = "caml_pasta_fq_plonk_gate_vector_get"

        external len : t -> int = "caml_pasta_fq_plonk_gate_vector_len"

        external wrap : t -> Kimchi_types.wire -> Kimchi_types.wire -> unit
          = "caml_pasta_fq_plonk_gate_vector_wrap"

        external digest : int -> t -> bytes
          = "caml_pasta_fq_plonk_gate_vector_digest"

        external to_json : int -> t -> string
          = "caml_pasta_fq_plonk_circuit_serialize"
      end
    end
  end

  module SnarkyConstraintSystem = struct
    module Fp = struct
      type nonrec t

      external create : unit -> t = "caml_fp_snarky_cs_create"

      external set_primary_input_size : t -> int -> unit
        = "caml_fp_snarky_cs_set_primary_input_size"

      external get_primary_input_size : t -> int
        = "caml_fp_snarky_cs_get_primary_input_size"

      external set_prev_challenges : t -> int -> unit
        = "caml_fp_snarky_cs_set_prev_challenges"

      external get_rows_len : t -> int = "caml_fp_snarky_cs_get_rows_len"

      external add_boolean :
           t
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> unit = "caml_fp_snarky_cs_add_boolean"

      external add_equal :
           t
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> unit = "caml_fp_snarky_cs_add_equal"

      external add_square :
           t
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> unit = "caml_fp_snarky_cs_add_square"

      external add_r1cs :
           t
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> unit = "caml_fp_snarky_cs_add_r1cs"

      external add_basic :
           t
        -> Pasta_bindings.Fp.t
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
        -> Pasta_bindings.Fp.t
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
        -> Pasta_bindings.Fp.t
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
        -> Pasta_bindings.Fp.t
        -> Pasta_bindings.Fp.t
        -> unit
        = "caml_fp_snarky_cs_add_basic_bytecode" "caml_fp_snarky_cs_add_basic"

      external add_poseidon :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
           array
        -> unit = "caml_fp_snarky_cs_add_poseidon"

      external add_ec_add_complete :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> unit
        = "caml_fp_snarky_cs_add_ec_add_complete_bytecode" "caml_fp_snarky_cs_add_ec_add_complete"

      external add_ec_scale :
           t
        -> ( ( (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
             * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
             )
             array
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
             array
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
             array
           * ( (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
             * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
             )
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           * (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array) )
           array
        -> unit = "caml_fp_snarky_cs_add_ec_scale"

      external add_ec_endoscale :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
           array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array
        -> unit = "caml_fp_snarky_cs_add_ec_endoscale"

      external add_ec_endoscalar :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
           array
        -> unit = "caml_fp_snarky_cs_add_ec_endoscalar"

      external add_range_check0 :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
        -> Pasta_bindings.Fp.t
        -> unit = "caml_fp_snarky_cs_add_range_check0"

      external add_range_check1 :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
        -> unit = "caml_fp_snarky_cs_add_range_check1"

      external add_lookup :
           t
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           array
        -> unit = "caml_fp_snarky_cs_add_lookup"

      external add_row :
           t
        -> Kimchi_types.gate_type
        -> (Pasta_bindings.Fp.t option * (Pasta_bindings.Fp.t * int) array)
           option
           array
        -> Pasta_bindings.Fp.t array
        -> unit = "caml_fp_snarky_cs_add_row"

      external to_gate_vector : t -> Gates.Vector.Fp.t
        = "caml_fp_snarky_cs_to_gate_vector"

      external finalize : t -> unit = "caml_fp_snarky_cs_finalize"

      external digest : t -> bytes = "caml_fp_snarky_cs_digest"

      external get_gates :
        t -> Pasta_bindings.Fp.t Kimchi_types.circuit_gate array
        = "caml_fp_snarky_cs_get_gates"

      external compute_witness :
           t
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fp.t array array = "caml_fp_snarky_cs_compute_witness"
    end

    module Fq = struct
      type nonrec t

      external create : unit -> t = "caml_fq_snarky_cs_create"

      external set_primary_input_size : t -> int -> unit
        = "caml_fq_snarky_cs_set_primary_input_size"

      external get_primary_input_size : t -> int
        = "caml_fq_snarky_cs_get_primary_input_size"

      external set_prev_challenges : t -> int -> unit
        = "caml_fq_snarky_cs_set_prev_challenges"

      external get_rows_len : t -> int = "caml_fq_snarky_cs_get_rows_len"

      external add_boolean :
           t
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> unit = "caml_fq_snarky_cs_add_boolean"

      external add_equal :
           t
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> unit = "caml_fq_snarky_cs_add_equal"

      external add_square :
           t
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> unit = "caml_fq_snarky_cs_add_square"

      external add_r1cs :
           t
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> unit = "caml_fq_snarky_cs_add_r1cs"

      external add_basic :
           t
        -> Pasta_bindings.Fq.t
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
        -> Pasta_bindings.Fq.t
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
        -> Pasta_bindings.Fq.t
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
        -> Pasta_bindings.Fq.t
        -> Pasta_bindings.Fq.t
        -> unit
        = "caml_fq_snarky_cs_add_basic_bytecode" "caml_fq_snarky_cs_add_basic"

      external add_poseidon :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
           array
        -> unit = "caml_fq_snarky_cs_add_poseidon"

      external add_ec_add_complete :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> unit
        = "caml_fq_snarky_cs_add_ec_add_complete_bytecode" "caml_fq_snarky_cs_add_ec_add_complete"

      external add_ec_scale :
           t
        -> ( ( (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
             * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
             )
             array
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
             array
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
             array
           * ( (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
             * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
             )
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           * (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array) )
           array
        -> unit = "caml_fq_snarky_cs_add_ec_scale"

      external add_ec_endoscale :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
           array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array
        -> unit = "caml_fq_snarky_cs_add_ec_endoscale"

      external add_ec_endoscalar :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
           array
        -> unit = "caml_fq_snarky_cs_add_ec_endoscalar"

      external add_range_check0 :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
        -> Pasta_bindings.Fq.t
        -> unit = "caml_fq_snarky_cs_add_range_check0"

      external add_range_check1 :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
        -> unit = "caml_fq_snarky_cs_add_range_check1"

      external add_lookup :
           t
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           array
        -> unit = "caml_fq_snarky_cs_add_lookup"

      external add_row :
           t
        -> Kimchi_types.gate_type
        -> (Pasta_bindings.Fq.t option * (Pasta_bindings.Fq.t * int) array)
           option
           array
        -> Pasta_bindings.Fq.t array
        -> unit = "caml_fq_snarky_cs_add_row"

      external to_gate_vector : t -> Gates.Vector.Fq.t
        = "caml_fq_snarky_cs_to_gate_vector"

      external finalize : t -> unit = "caml_fq_snarky_cs_finalize"

      external digest : t -> bytes = "caml_fq_snarky_cs_digest"

      external get_gates :
        t -> Pasta_bindings.Fq.t Kimchi_types.circuit_gate array
        = "caml_fq_snarky_cs_get_gates"

      external compute_witness :
           t
        -> Pasta_bindings.Fq.t array
        -> Pasta_bindings.Fq.t array
        -> Pasta_bindings.Fq.t array array = "caml_fq_snarky_cs_compute_witness"
    end
  end

  module SRS = struct
    module Fp = struct
      type nonrec t

      module Poly_comm = struct
        type nonrec t =
          Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
      end

      external create : int -> t = "caml_fp_srs_create"

      external write : bool option -> t -> string -> unit = "caml_fp_srs_write"

      external read : int option -> string -> t option = "caml_fp_srs_read"

      external lagrange_commitment :
           t
        -> int
        -> int
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        = "caml_fp_srs_lagrange_commitment"

      external lagrange_commitments_whole_domain :
           t
        -> int
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           array = "caml_fp_srs_lagrange_commitments_whole_domain"

      external add_lagrange_basis : t -> int -> unit
        = "caml_fp_srs_add_lagrange_basis"

      external commit_evaluations :
           t
        -> int
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        = "caml_fp_srs_commit_evaluations"

      external b_poly_commitment :
           t
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        = "caml_fp_srs_b_poly_commitment"

      external batch_accumulator_check :
           t
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity array
        -> Pasta_bindings.Fp.t array
        -> bool = "caml_fp_srs_batch_accumulator_check"

      external batch_accumulator_generate :
           t
        -> int
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity array
        = "caml_fp_srs_batch_accumulator_generate"

      external urs_h : t -> Pasta_bindings.Fq.t Kimchi_types.or_infinity
        = "caml_fp_srs_h"
    end

    module Fq = struct
      type nonrec t

      external create : int -> t = "caml_fq_srs_create"

      external write : bool option -> t -> string -> unit = "caml_fq_srs_write"

      external read : int option -> string -> t option = "caml_fq_srs_read"

      external lagrange_commitment :
           t
        -> int
        -> int
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        = "caml_fq_srs_lagrange_commitment"

      external lagrange_commitments_whole_domain :
           t
        -> int
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           array = "caml_fq_srs_lagrange_commitments_whole_domain"

      external add_lagrange_basis : t -> int -> unit
        = "caml_fq_srs_add_lagrange_basis"

      external commit_evaluations :
           t
        -> int
        -> Pasta_bindings.Fq.t array
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        = "caml_fq_srs_commit_evaluations"

      external b_poly_commitment :
           t
        -> Pasta_bindings.Fq.t array
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        = "caml_fq_srs_b_poly_commitment"

      external batch_accumulator_check :
           t
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity array
        -> Pasta_bindings.Fq.t array
        -> bool = "caml_fq_srs_batch_accumulator_check"

      external batch_accumulator_generate :
           t
        -> int
        -> Pasta_bindings.Fq.t array
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity array
        = "caml_fq_srs_batch_accumulator_generate"

      external urs_h : t -> Pasta_bindings.Fp.t Kimchi_types.or_infinity
        = "caml_fq_srs_h"
    end
  end

  module Index = struct
    module Fp = struct
      type nonrec t

      external create :
           Gates.Vector.Fp.t
        -> int
        -> Pasta_bindings.Fp.t Kimchi_types.lookup_table array
        -> Pasta_bindings.Fp.t Kimchi_types.runtime_table_cfg array
        -> int
        -> SRS.Fp.t
        -> bool
        -> t
        = "caml_pasta_fp_plonk_index_create_bytecode" "caml_pasta_fp_plonk_index_create"

      external max_degree : t -> int = "caml_pasta_fp_plonk_index_max_degree"

      external public_inputs : t -> int
        = "caml_pasta_fp_plonk_index_public_inputs"

      external domain_d1_size : t -> int
        = "caml_pasta_fp_plonk_index_domain_d1_size"

      external domain_d4_size : t -> int
        = "caml_pasta_fp_plonk_index_domain_d4_size"

      external domain_d8_size : t -> int
        = "caml_pasta_fp_plonk_index_domain_d8_size"

      external read : int option -> SRS.Fp.t -> string -> t
        = "caml_pasta_fp_plonk_index_read"

      external write : bool option -> t -> string -> unit
        = "caml_pasta_fp_plonk_index_write"
    end

    module Fq = struct
      type nonrec t

      external create :
           Gates.Vector.Fq.t
        -> int
        -> Pasta_bindings.Fq.t Kimchi_types.lookup_table array
        -> Pasta_bindings.Fq.t Kimchi_types.runtime_table_cfg array
        -> int
        -> SRS.Fq.t
        -> bool
        -> t
        = "caml_pasta_fq_plonk_index_create_bytecode" "caml_pasta_fq_plonk_index_create"

      external max_degree : t -> int = "caml_pasta_fq_plonk_index_max_degree"

      external public_inputs : t -> int
        = "caml_pasta_fq_plonk_index_public_inputs"

      external domain_d1_size : t -> int
        = "caml_pasta_fq_plonk_index_domain_d1_size"

      external domain_d4_size : t -> int
        = "caml_pasta_fq_plonk_index_domain_d4_size"

      external domain_d8_size : t -> int
        = "caml_pasta_fq_plonk_index_domain_d8_size"

      external read : int option -> SRS.Fq.t -> string -> t
        = "caml_pasta_fq_plonk_index_read"

      external write : bool option -> t -> string -> unit
        = "caml_pasta_fq_plonk_index_write"
    end
  end

  module VerifierIndex = struct
    module Fp = struct
      type nonrec t =
        ( Pasta_bindings.Fp.t
        , SRS.Fp.t
        , Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        )
        Kimchi_types.VerifierIndex.verifier_index

      external create : Index.Fp.t -> t
        = "caml_pasta_fp_plonk_verifier_index_create"

      external read : int option -> SRS.Fp.t -> string -> t
        = "caml_pasta_fp_plonk_verifier_index_read"

      external write : bool option -> t -> string -> unit
        = "caml_pasta_fp_plonk_verifier_index_write"

      external shifts : int -> Pasta_bindings.Fp.t array
        = "caml_pasta_fp_plonk_verifier_index_shifts"

      external dummy : unit -> t = "caml_pasta_fp_plonk_verifier_index_dummy"

      external deep_copy : t -> t
        = "caml_pasta_fp_plonk_verifier_index_deep_copy"
    end

    module Fq = struct
      type nonrec t =
        ( Pasta_bindings.Fq.t
        , SRS.Fq.t
        , Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
        )
        Kimchi_types.VerifierIndex.verifier_index

      external create : Index.Fq.t -> t
        = "caml_pasta_fq_plonk_verifier_index_create"

      external read : int option -> SRS.Fq.t -> string -> t
        = "caml_pasta_fq_plonk_verifier_index_read"

      external write : bool option -> t -> string -> unit
        = "caml_pasta_fq_plonk_verifier_index_write"

      external shifts : int -> Pasta_bindings.Fq.t array
        = "caml_pasta_fq_plonk_verifier_index_shifts"

      external dummy : unit -> t = "caml_pasta_fq_plonk_verifier_index_dummy"

      external deep_copy : t -> t
        = "caml_pasta_fq_plonk_verifier_index_deep_copy"
    end
  end

  module Oracles = struct
    module Fp = struct
      type nonrec t = Pasta_bindings.Fp.t Kimchi_types.oracles

      external create :
           Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           array
        -> ( Pasta_bindings.Fp.t
           , SRS.Fp.t
           , Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.prover_proof
        -> t = "fp_oracles_create_no_public"

      external create_with_public_evals :
           Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           array
        -> ( Pasta_bindings.Fp.t
           , SRS.Fp.t
           , Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public
        -> t = "fp_oracles_create"

      external dummy : unit -> Pasta_bindings.Fp.t Kimchi_types.random_oracles
        = "fp_oracles_dummy"

      external deep_copy :
           Pasta_bindings.Fp.t Kimchi_types.random_oracles
        -> Pasta_bindings.Fp.t Kimchi_types.random_oracles
        = "fp_oracles_deep_copy"
    end

    module Fq = struct
      type nonrec t = Pasta_bindings.Fq.t Kimchi_types.oracles

      external create :
           Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           array
        -> ( Pasta_bindings.Fq.t
           , SRS.Fq.t
           , Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.prover_proof
        -> t = "fq_oracles_create_no_public"

      external create_with_public_evals :
           Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           array
        -> ( Pasta_bindings.Fq.t
           , SRS.Fq.t
           , Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public
        -> t = "fq_oracles_create"

      external dummy : unit -> Pasta_bindings.Fq.t Kimchi_types.random_oracles
        = "fq_oracles_dummy"

      external deep_copy :
           Pasta_bindings.Fq.t Kimchi_types.random_oracles
        -> Pasta_bindings.Fq.t Kimchi_types.random_oracles
        = "fq_oracles_deep_copy"
    end
  end

  module Proof = struct
    module Fp = struct
      external create :
           Index.Fp.t
        -> FieldVectors.Fp.t array
        -> Pasta_bindings.Fp.t Kimchi_types.runtime_table array
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity array
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public = "caml_pasta_fp_plonk_proof_create"

      external create_and_verify :
           Index.Fp.t
        -> FieldVectors.Fp.t array
        -> Pasta_bindings.Fp.t Kimchi_types.runtime_table array
        -> Pasta_bindings.Fp.t array
        -> Pasta_bindings.Fq.t Kimchi_types.or_infinity array
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_create_and_verify"

      external example_with_lookup :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * Pasta_bindings.Fp.t
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_lookup"

      external example_with_ffadd :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * Pasta_bindings.Fp.t
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_ffadd"

      external example_with_xor :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * (Pasta_bindings.Fp.t * Pasta_bindings.Fp.t)
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_xor"

      external example_with_rot :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * (Pasta_bindings.Fp.t * Pasta_bindings.Fp.t)
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_rot"

      external example_with_foreign_field_mul :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_foreign_field_mul"

      external example_with_range_check :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_range_check"

      external example_with_range_check0 :
           SRS.Fp.t
        -> bool
        -> Index.Fp.t
           * ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
             , Pasta_bindings.Fp.t )
             Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_example_with_range_check0"

      external verify :
           ( Pasta_bindings.Fp.t
           , SRS.Fp.t
           , Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public
        -> bool = "caml_pasta_fp_plonk_proof_verify"

      external batch_verify :
           ( Pasta_bindings.Fp.t
           , SRS.Fp.t
           , Pasta_bindings.Fq.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
           array
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public
           array
        -> bool = "caml_pasta_fp_plonk_proof_batch_verify"

      external dummy :
           unit
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public = "caml_pasta_fp_plonk_proof_dummy"

      external deep_copy :
           ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public
        -> ( Pasta_bindings.Fq.t Kimchi_types.or_infinity
           , Pasta_bindings.Fp.t )
           Kimchi_types.proof_with_public
        = "caml_pasta_fp_plonk_proof_deep_copy"
    end

    module Fq = struct
      external create :
           Index.Fq.t
        -> FieldVectors.Fq.t array
        -> Pasta_bindings.Fq.t Kimchi_types.runtime_table array
        -> Pasta_bindings.Fq.t array
        -> Pasta_bindings.Fp.t Kimchi_types.or_infinity array
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public = "caml_pasta_fq_plonk_proof_create"

      external verify :
           ( Pasta_bindings.Fq.t
           , SRS.Fq.t
           , Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public
        -> bool = "caml_pasta_fq_plonk_proof_verify"

      external batch_verify :
           ( Pasta_bindings.Fq.t
           , SRS.Fq.t
           , Pasta_bindings.Fp.t Kimchi_types.or_infinity Kimchi_types.poly_comm
           )
           Kimchi_types.VerifierIndex.verifier_index
           array
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public
           array
        -> bool = "caml_pasta_fq_plonk_proof_batch_verify"

      external dummy :
           unit
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public = "caml_pasta_fq_plonk_proof_dummy"

      external deep_copy :
           ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public
        -> ( Pasta_bindings.Fp.t Kimchi_types.or_infinity
           , Pasta_bindings.Fq.t )
           Kimchi_types.proof_with_public
        = "caml_pasta_fq_plonk_proof_deep_copy"
    end
  end
end
