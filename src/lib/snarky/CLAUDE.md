# Migration snarky OCaml → snarky Rust (proof-systems)

Suivi du branchement de mina sur l'implémentation Rust de snarky
(`src/lib/crypto/proof-systems/snarky`, branche `snarky-rs` de proof-systems).
Stratégie retenue : **suppression totale** du submodule snarky, remplacement
progressif des modules OCaml par des shims au-dessus du crate Rust.

## État

| Étape | Statut | Notes |
|---|---|---|
| Submodule `proof-systems` → branche `snarky-rs` (`272cbc7cb7`) | ✅ fait | contient le crate `snarky` + `snarky-deriver` |
| Suppression du submodule `src/lib/snarky` | ✅ fait | retiré de `.gitmodules` |
| Vendoring in-tree du subset nécessaire | ✅ fait | voir liste ci-dessous ; `dune build src/lib/snarky` passe |
| Environnement opam local (`_opam`) | ✅ fait | via `scripts/update-opam-switch.sh` (+ `--assume-depexts` sur l'import) ; voir « Prérequis d'environnement » |
| `kimchi_bindings` complet (natif + WASM + NAPI) | ✅ vérifié | compile contre le submodule `snarky-rs` |
| Consommateurs snarky : pickles, kimchi_backend, snark_params, kimchi_pasta_snarky_backend | ✅ vérifié | `dune build` exit 0 — le vendoring est transparent pour les 111 fichiers dépendants |
| transaction_snark + blockchain_snark | ✅ vérifié | `dune build` exit 0 |
| Stubs `SnarkyConstraintSystem` dans kimchi-stubs | ✅ fait | proof-systems `7d77f25c4f` : `kimchi-stubs/src/snarky_constraint_system.rs` — create, add_{boolean,equal,square,r1cs}, finalize, digest, get_gates, compute_witness (Fp et Fq) ; les cvars traversent la frontière en combinaisons linéaires aplaties `(constant, [(coeff, idx)])` |
| Externals OCaml générés | ✅ fait | `Kimchi_bindings.Protocol.SnarkyConstraintSystem.Fp/Fq` (déclarés dans `kimchi_bindings/stubs/src/main.rs`, régénérés dans `kimchi_bindings.ml`) ; pickles rebuild OK |
| Module OCaml `Rust_constraint_system` | ✅ fait (contraintes de base) | `kimchi_pasta_snarky_backend/rust_constraint_system.ml` : implémente l'interface du CS sur les externals ; instancié comme `Vesta_based_plonk.Rust_R1CS_constraint_system` (et Pallas). Les contraintes kimchi custom (Poseidon, EC…) lèvent encore une exception — FFI à étendre |
| **Parité de gates OCaml vs Rust** | ✅ validée (base) | `test/test_rust_constraint_system.ml` : même circuit gate à gate (types, wiring, coefficients, rows publiques) pour boolean/square/r1cs/equal — `dune build @src/lib/crypto/kimchi_pasta_snarky_backend/test/runtest` |
| FFI contraintes kimchi : Basic, Poseidon, EC_add_complete, EC_scale, EC_endoscale, EC_endoscalar | ✅ fait | proof-systems `c3781739d6` + dispatch OCaml ; le Rust `EndoscaleRound` a été aligné sur mina (champ `inv`, colonne 2 du gate EndoMul) |
| **Parité gates étendue : Poseidon (55 rounds) + Basic** | ✅ validée | même circuit gate à gate, round constants compris |
| FFI RangeCheck0/1 + Lookup | ✅ fait | émetteurs portés dans le crate Rust (proof-systems `ad66738cb4`) + dispatch OCaml |
| FFI restant : Xor, ForeignFieldAdd/Mul, Rot64, AddFixedLookupTable/RuntimeTableCfg | ⬜ à faire | émetteurs à porter dans le crate Rust ; exception explicite côté OCaml en attendant |
| Parité EC (add_complete/scale/endoscale/endoscalar) à tester | ⬜ à faire | FFI câblé, test à écrire avec des rounds réalistes |
| Basculer `Vesta/Pallas_based_plonk.R1CS_constraint_system` sur le module Rust | ⬜ à faire | après extension du FFI + parité re-validée sur un circuit pickles réel |
| Supprimer `plonk_constraint_system.ml` (~1900 l.) | ⬜ à faire | dernière étape après la bascule |
| Stubs `RunState` (witness côté Rust) | ⬜ optionnel | `compute_witness` est déjà exposé au niveau CS ; RunState complet utile pour amincir `checked_runner.ml` ensuite |
| Test de parité : digests de circuits identiques OCaml vs Rust | ⬜ à faire | critique : un layout de gates différent change les verification keys (hard fork) |
| Amincir le DSL vendoré (état déporté côté Rust) | ⬜ à faire | après la parité de digest |
| Remplacer les gadgets OCaml (sponge, group_map, snarky_curve) par les ports Rust | ⬜ à faire | possible seulement pour les usages hors circuits OCaml |

## Contenu vendoré (ex-submodule, élagué)

Gardé (requis par les dune de mina — comptes d'usages) :
`src/` = `snarky.backendless` (77) + `snarky.intf` (18), `ppx_snarky` (45),
`h_list` (31), `tuple_lib` (27), `sponge` (27), `bitstring_lib` (27),
`fold_lib` (21), `group_map` (17), `snarkette` (11), `snarky_curve` (11),
`interval_union` (6), `snarky_monad_lib` (2).

Gardé aussi : `snarky_integer` (utilisé par `snarky_taylor`, `consensus/vrf`,
`transaction_snark` — restauré après un premier élagage trop agressif).

Supprimé (non utilisé par mina) : `snarky_signature`, `src/tests`,
les tests des libs utilitaires (`fold_lib/test`, `interval_union/test`,
`sponge/test_vectors`), `Dockerfile`, `Makefile`, `scripts`.

## Prérequis d'environnement (découverts pendant la validation)

- Switch opam **local** `_opam` créé par `scripts/update-opam-switch.sh`
  (OCaml 4.14.2 exact ; les dépôts opam sont pinnés à des commits précis car
  certaines dépendances ont été archivées upstream).
- L'import `opam.export` nécessite `--assume-depexts` en non-interactif.
- Dépendances système brew : bzip2, gcc, libffi, libsodium, lmdb, pkg-config,
  postgresql@15, zlib, capnp. `sodium` (OCaml) doit être installé avec
  `CPATH=/opt/homebrew/include LIBRARY_PATH=/opt/homebrew/lib`.
- **Node ≥ 22** requis dans le PATH pour la cible NAPI de kimchi_bindings
  (`npm i -g @napi-rs/cli` ; la 3.x ne marche pas sous Node 14).
- Composant `rust-src` pour le toolchain nightly pinné (cibles WASM) :
  `rustup component add rust-src --toolchain <nightly pinné>`.
- Les pins opam `~dev` vers `git+ssh://github.com/o1-labs/snarky.git` sont
  **obsolètes** (retirés du switch default ; à purger de `opam.export` —
  les libs vendorées in-tree les shadowent dans le workspace dune).
- Le build de `libp2p_ipc` (hors périmètre snarky) demande en plus le module
  Go capnproto (`go mod download capnproto.org/go/capnp/v3@v3.0.0-alpha.5`).

## Architecture cible

```
Circuits OCaml (inchangés au début)
  → snarky.backendless (vendoré ici, DSL pur OCaml, à amincir)
  → NOUVEAU backend Rust : kimchi_pasta_snarky_backend délègue à
    proof-systems/snarky (SnarkyConstraintSystem + RunState) via kimchi-stubs
  → kimchi (prover/verifier, comme aujourd'hui)
```

Points durs identifiés :
- **Parité des digests** : `plonk_constraint_system.ml` et le
  `constraint_system.rs` Rust descendent du même code ; deux bugs ont été
  corrigés côté Rust dans `reduce_to_var` (arguments constant/lincom croisés
  par rapport à l'OCaml) — comparer gate à gate avec `prover_index.asm()`.
- **Coût FFI** : ne pas franchir la frontière OCaml↔Rust à chaque contrainte ;
  batcher comme les gate vectors actuels de kimchi_bindings.
- Le crate Rust fixe `FULL_ROUNDS = 55` (kimchi) — cohérent avec mina.

## Vérification

```sh
# dans mina (nécessite l'environnement opam du projet) :
dune build src/lib/snarky              # le vendoring compile
dune build src/lib/crypto              # la crypto compile
dune runtest src/lib/transaction_snark # parité des circuits
```
