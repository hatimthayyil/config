# Perfectionist and a reproducible Rust quality workflow

## What does it enforce, and how useful is it for AI Rust quality?

### Takeaway
Perfectionist is a Rust compiler lint plugin with useful checks for oversized functions, files, conditions, nesting, structs, and unnecessary ownership. Its default policy also contains substantial author-specific style and dependency preferences. Adopt a curated policy after a pilot; do not equate its complete default rule set with idiomatic Rust or architectural correctness.

### Cited Findings
- Inspected local checkout `/hatimthayyil/code/perfectionist` at `e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a`; no `.codegraph` directory. The plugin registers 54 rules through one index, independently registering names and conditionally installing passes. [Index, lines 98–152](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/src/rule_index.rs#L98).
- The author expressly created this to encode rules agents failed to follow in Markdown; README also says the code is almost entirely AI generated. This explains the fit to this user's search, but supplies no evidence of accuracy or adoption quality. [README, lines 56–68](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/README.md#L56).
- Complete implemented lint roster, grouped by purpose below; **inactive** denotes the seven opt-in rules, all others are active by default. This is the implemented catalogue, not the much larger planned-rules backlog. [Generated implemented catalogue](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/README.md).

| Purpose | Implemented rules |
|---|---|
| Structure and complexity | `excessive_cognitive_complexity`, `excessive_inline_tests`, `excessive_nesting`, `overly_complex_condition`, `overly_long_file`, `overly_long_function`, `overly_long_method_chain` (**inactive**), `too_many_local_bindings`, `too_many_struct_fields` |
| Ownership and API conventions | `cloning_getter`, `costless_to_conversion`, `needless_borrowed_parameters`, `owned_as_conversion`, `unconsumed_into_conversion`, `exhaustive_error_enums` (**inactive**) |
| Imports and arrangement | `arbitrary_source_item_ordering`, `core_instead_of_std` (**inactive**), `import_granularity_mismatch`, `import_grouping_mismatch` (**inactive**), `named_prelude_imports`, `uncombined_self_import` (**inactive**), `unordered_derives` (**inactive**), `wildcard_imports` |
| Names | `single_letter_closure_param`, `single_letter_const_generic`, `single_letter_const_item`, `single_letter_function_param`, `single_letter_generic`, `single_letter_let_binding`, `single_letter_static_item` |
| Macro, expression and dependency preferences | `folded_command_setter`, `impure_macro_arguments`, `macro_trailing_comma`, `mutating_command_builder`, `overly_long_print_macro`, `redundant_derive_more_forward_template`, `some_bool_comparison`, `splittable_adapter_closure`, `thiserror_usage` |
| Docs, comments and literals | `avoidable_string_escapes`, `bare_email`, `bare_identifier_reference`, `bare_issue_reference`, `bare_url`, `clap_help_markdown`, `numeric_escape_for_visible_character`, `unicode_ellipsis_in_comments`, `unicode_ellipsis_in_docs`, `unicode_ellipsis_in_panic_messages`, `unpinned_repo_ref` |
| Suppression hygiene | `allow_attributes`, `allow_attributes_without_reason`, `lint_attribute_trailing_comment`, `unknown_perfectionist_lints` |

- Structural defaults: cognitive complexity 15; nesting 3; boolean operators per condition 3; function code lines 50; file code lines 500; local bindings 15; struct fields 10; inline test lines 50. Test exemptions are configurable, and structural tests generally count by default. [Complexity](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/excessive_cognitive_complexity.md), [nesting](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/excessive_nesting.md), [conditions](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/overly_complex_condition.md), [function](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/overly_long_function.md), [file](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/overly_long_file.md), [bindings](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/too_many_local_bindings.md), [fields](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/too_many_struct_fields.md), [inline tests](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/excessive_inline_tests.md).
- The complexity rule uses nesting-weighted control flow, boolean operator runs, recursion, etc. It ignores generated macro bodies, measures nested functions independently, and charges neither `?` nor `.await`. Its own documentation explicitly warns that moving tangled code into a meaningless private helper lowers the score without reducing the reader's burden. [Source, lines 18–75](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/src/rules/excessive_cognitive_complexity.rs#L18); [fix guidance, lines 119–146](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/excessive_cognitive_complexity.md#L119).
- `thiserror_usage` is active by default and flags use of thiserror, explicitly preferring derive_more. It acknowledges this is stylistic and that crate-wide alias collection can cause false positives. This should be disabled for projects deliberately using thiserror. [Rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/thiserror_usage.md).
- `mutating_command_builder` prefers command-extra's by-value setters and defaults to considering a workspace dependency declaration enough to recommend them. This is an ecosystem choice, not a standard requirement of Rust. `named_prelude_imports` deliberately prefers glob imports of prelude modules; `wildcard_imports` has corresponding prelude exceptions. [Command rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/mutating_command_builder.md), [prelude rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/named_prelude_imports.md), [glob rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/wildcard_imports.md).
- `impure_macro_arguments` can catch e.g. `debug_assert_eq!(map.insert(...), None)` silently dropping the mutation in release builds. Purity is a syntactic heuristic, including selected method names, rather than an effect proof. Default mode also flags uncatalogued macros; `mode = "deny_only"` narrows to debug assertions and explicit additions. [Rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/impure_macro_arguments.md).
- `cloning_getter` catches whole-body copies of fields and recommends borrowed return types, while exempting Copy and Arc/Rc, trait methods, macro-generated methods, and tests by default. `owned_as_conversion`, `costless_to_conversion`, `unconsumed_into_conversion` refine API prefix semantics beyond Clippy's receiver-oriented `wrong_self_convention`. [Getter](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/cloning_getter.md), [owned as conversion](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/owned_as_conversion.md).
- Some checks deliberately overlap Clippy: function length, nesting, suppression reasons; its complexity measure differs from Clippy's, and documentation recommends choosing one complexity rule rather than both. For suppression reason presence alone, Clippy already suffices; Perfectionist additionally checks blank reasons, minimum length (3 by default), and exemptions. [Complexity interaction](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/excessive_cognitive_complexity.md#L56), [reason rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/allow_attributes_without_reason.md).

### Inferences
- The most relevant initial rules are cognitive complexity, nesting, condition complexity, function/file length, local binding count, struct field count, ownership/API checks and suppression hygiene. They detect measurable symptoms of poor decomposition. They do not verify DRY across the codebase, module cohesion, SOLID, justified abstractions, appropriate dependency boundaries, domain correctness or useful tests. No implemented rule in the complete index establishes those properties.
- Threshold-only optimization can encourage meaningless helper extraction, over-splitting modules and overly small wrappers. The appropriate policy is “resolve the design problem or document a narrow exception,” with architectural review and behavioral tests alongside linting.
- Most of the default roster is formatting, naming, docs, import layout or preference enforcement. These may be useful only when the user actually wants the encoded style. Single-letter generics such as `T` and closure binders such as `x` are widespread Rust conventions; a blanket prohibition should be a conscious project choice.

### Gaps
- No empirical accuracy, false-positive rate, runtime overhead or architecture-quality improvement was measured in this investigation. Tests and CI were inspected, not executed. No evidence supports claiming that passing these lints guarantees maintainability.

## How do toolchains, configuration and enforcement really work?

### Takeaway
This is a compiler plugin, not a standalone `cargo install perfectionist` CLI. It requires Dylint and a specific nightly compiler; lint registration and error severity are independent. A required external check makes feedback mandatory at merge, while policy changes and suppression still require review.

### Cited Findings
- Perfectionist is a `cdylib`, uses `#![feature(rustc_private)]`, and depends on `clippy_utils = "=0.1.99"` and `dylint_linting = "6.1.0"` (resolved 6.1.0 in Cargo.lock). The checkout pins `nightly-2026-07-09` with `llvm-tools-preview`, `rustc-dev`, `rust-src`. [Manifest, lines 44–55](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/Cargo.toml#L44), [toolchain](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rust-toolchain), [entry point](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/src/lib.rs#L1).
- Dylint applies a lint library using the compiler that built that library. If the target project needs another compiler, the library may not apply. Thus a normal successful stable build does not establish that Perfectionist can compile the project. [Dylint limitations](https://github.com/trailofbits/dylint/blob/master/docs/how_dylint_works.md#limitations).
- Dylint discovers libraries by workspace metadata, Git/path arguments or prebuilt libraries in `DYLINT_LIBRARY_PATH`; Git specifications support `rev`. Git/path entries are downloaded/built, and drivers are built and cached per toolchain. [Dylint metadata](https://github.com/trailofbits/dylint#workspace-metadata), [discovery](https://github.com/trailofbits/dylint/blob/master/docs/how_dylint_works.md#how-libraries-are-found), [driver builder](https://github.com/trailofbits/dylint/blob/master/dylint/src/driver_builder.rs).
- Author documents CLI/linker ABI coupling to the resolved dylint_linting version and installs pinned cargo-dylint/dylint-link locally for its own development. Its `.cargo/config.toml` makes `dylint-link` the library's linker. Do not copy that linker override into every consumer workspace: it is library-build infrastructure. [README, lines 42–48](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/README.md#L42), [library linker](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/.cargo/config.toml).
- `[perfectionist].enable` and `.disable` switch passes, accepting strings or `{ name, reason }` entries. Reasons here are decorative; unknown names silently do nothing; contradictory enable/disable is fatal. Registered lint names remain resolvable when a pass is disabled. Per-rule tables use `"perfectionist::<rule>"`; unqualified keys go in enable/disable lists. [Schema](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/CONFIGURATION.md), [implementation, lines 42–178](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/src/common.rs#L42).
- Active rules default to warnings, not errors. Severity uses rustc lint attributes and flags: `DYLINT_RUSTFLAGS='-D perfectionist::<rule>'` or `-D warnings` promotes findings. A disabled pass emits nothing regardless of severity. There is no `perfectionist::all` group registered in the index. [Control guide](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/CONTROLLING_RULES.md), [index](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/src/rule_index.rs).
- Source-level `allow`/`expect`/`deny` of Perfectionist names requires gated `feature(register_tool)` / `register_tool(perfectionist)` attributes at each crate root and declaring `cfg(dylint_lib, values("perfectionist"))` through Cargo's unexpected_cfgs lint. These are gated to Dylint so normal stable builds remain possible. Flags passed through DYLINT_RUSTFLAGS do not require that boilerplate. [Control guide, lines 15–31](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/CONTROLLING_RULES.md#L15).
- Suppression hygiene prefers `expect` over deterministic `allow`, requires reasons, and detects unknown Perfectionist attribute names. The reason checker does not evaluate whether a reason is truthful or convincing. A planned ancestry-aware lint downgrade rule is not implemented; existing reason checks do not cover a `#[warn(...)]` downgrade. [Allow rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/allow_attributes.md), [reason rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/allow_attributes_without_reason.md), [planned index](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/planned-rules/README.md).
- Upstream maintains UI expectation tests, TOML configuration tests, integration fixtures and unit tests. CI runs fmt/build/docs/Clippy/tests/self-lint, using the locked dependency graph and caches. Manifest version is `0.0.0-rc.22`; license is MIT. [Tests](https://github.com/KSXGitHub/perfectionist/tree/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/tests), [CI](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/.github/workflows/test.yaml), [version](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/Cargo.toml#L22), [license](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/LICENSE.md).

### Inferences
- `deny` is appropriate for checks with justified narrow exceptions; `forbid` makes source-level downgrades impossible but also prohibits intentional `expect` exceptions. Neither can force a disabled pass to execute. A mandatory CI check should verify tool presence and library discovery (`--fail-on-no-libraries`) and run an actual failing fixture when the integration is first added.
- Agents can skip local commands, bypass Git hooks, edit YAML/TOML to disable checks or loosen thresholds, add suppressions, alter features/targets, or game thresholds. Protect required checks and review changes to workflow, policy and suppression sites. A hook helps feedback speed; an external merge requirement is the enforcement boundary.
- An active maintenance cadence and substantial test suite are encouraging; a pre-release compiler plugin with opinionated rules and an explicitly AI-written implementation still deserves conservative pinning and a pilot before becoming a universal gate.

### Gaps
- Did not establish CI's latest run result, all published version availability, cross-platform support, or that a July nightly builds the user's actual Rust projects. Those are adoption acceptance checks, not assumptions.

## How should it be deployed through shared dev tooling on NixOS?

### Takeaway
Keep project policy and required CI in the project, and reusable packaging/toolchain integration in `dev`; avoid making this dependent on the personal NixOS configuration. A scoped Dylint wrapper is needed if the normal devenv compiler comes from Nix while Dylint expects rustup-managed toolchain selection. Start with one representative project and verify a cold-cache run before generalizing.

### Cited Findings
- The existing dev repo is explicitly for shared devenv environments and templates, imported as a non-flake input. Its Rust environment provides languages.rust plus bacon/nextest/workspaces/watchexec. [Local README](/hatimthayyil/code/dev/README.md:3), [local environment](/hatimthayyil/code/dev/envs/rust/devenv.nix:1).
- devenv supports Nixpkgs and rust-overlay toolchains, including an explicit rust-toolchain.toml. That is not the same thing as Dylint finding the correct toolchain through rustup. [devenv Rust docs](https://devenv.sh/languages/rust/).
- Current research shell resolves cargo directly to `/nix/store/xkgfcablpm0h97g7q5sim5q1fdjmr7gx-rust-stable-1.99.0-1.99.0/bin/cargo` and rustup separately to `/home/hatim/.nix-profile/bin/rustup`; cargo-dylint and dylint-link are absent from PATH. This was a read-only `command -v` observation, not a build test. Dylint uses rustup to discover toolchains, clears CARGO/RUSTC/RUSTUP_TOOLCHAIN for some subprocesses, and spawns plain `cargo` from PATH for builds. [Dylint rustup helper](https://github.com/trailofbits/dylint/blob/master/internal/src/rustup.rs), [Cargo command helper](https://github.com/trailofbits/dylint/blob/master/internal/src/cargo.rs), [driver builder](https://github.com/trailofbits/dylint/blob/master/dylint/src/driver_builder.rs).
- The local Nixpkgs rustup package patches downloaded Linux binaries for NixOS and provides rustup proxy symlinks for cargo/rustc/rustdoc, etc. [Local package, lines 60–75 and 99–111](/hatimthayyil/code/nixpkgs/pkgs/development/tools/rust/rustup/default.nix:60). Therefore use the Nix-packaged rustup rather than assuming a curl-installed upstream rustup works identically on NixOS.
- Verified installed store package `/nix/store/s5g2mz2zr526hfvzf7si9ghsd221nn6z-rustup-1.29.1/bin/{cargo,rustc}` are symlinks to `rustup`; the home-profile links also resolve to those proxies. The current shell nevertheless picks direct Nix stable cargo earlier in PATH. A reusable wrapper should use the declared rustup package bin directory rather than depending on the person's profile. This is a read-only filesystem observation consistent with [the package definition](/hatimthayyil/code/nixpkgs/pkgs/development/tools/rust/rustup/default.nix:99).
- Dylint recommends caching ordinary Cargo artifacts plus Cargo Git checkouts, `~/.dylint_drivers`, rustup toolchains, and at least `target/dylint/libraries` if not the complete target directory. [Dylint CI caching](https://github.com/trailofbits/dylint#caching-in-ci).

### Inferences
Recommended minimal responsibilities:
1. `dev`: package or pin cargo-dylint and dylint-link together (6.1.0 for this reviewed checkout), expose a Rust quality environment and a scoped wrapper, plus any reproducible prebuilt library/driver packaging if the pilot proves that worthwhile. Keep ordinary project toolchains declared with languages.rust. Do not globally replace stable Rust with Perfectionist's nightly.
2. Project: commit the reviewed Perfectionist Git revision, chosen lints/thresholds/exceptions, lockfiles, and a single check command. Run that command in devenv locally and CI. Use feature configurations meaningful to the application; `--all-features` is only correct when features are compatible.
3. Config: consume dev tooling where convenient; personal overlays should not be the only source available to CI and collaborators.

Minimal consumer `dylint.toml` (supported shape, not executed):

```toml
[workspace.metadata.dylint]
libraries = [{ git = "https://github.com/KSXGitHub/perfectionist", rev = "e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a" }]

["perfectionist::impure_macro_arguments"]
mode = "deny_only"

["perfectionist::excessive_cognitive_complexity"]
max_complexity = 15

["perfectionist::overly_long_function"]
max_lines = 50
```

Direct comprehensive invocation, after explicitly disabling unwanted default policies:

```sh
DYLINT_RUSTFLAGS='-D warnings' cargo dylint --all --fail-on-no-libraries -- --workspace --all-targets --locked
```

For a deliberately curated first pilot, keep passes enabled but only fail named selected checks, with ordinary compiler warning enforcement handled by a separate Clippy command:

```sh
DYLINT_RUSTFLAGS='-A warnings -D perfectionist::excessive_cognitive_complexity -D perfectionist::excessive_nesting -D perfectionist::overly_long_function -D perfectionist::overly_long_file -D perfectionist::too_many_struct_fields -D perfectionist::cloning_getter -D perfectionist::impure_macro_arguments -D perfectionist::allow_attributes_without_reason' \
  cargo dylint --all --fail-on-no-libraries -- --workspace --all-targets --locked
```

This uses existing rustc lint levels instead of inventing an unsupported “only these rules” config. It avoids newly added default rules silently becoming errors at an upgrade. It still runs other active passes, and explicit selected lints must not be disabled. A final audited policy may instead disable the unwanted passes and promote every remaining warning. Normal `cargo clippy --workspace --all-targets --locked -- -D warnings` remains separate.

A shared Nix wrapper should put `${pkgs.rustup}/bin` ahead of the normal Nix Rust bin directories **inside this command only**, retain the packaged cargo-dylint/dylint-link on PATH, and provide the exact nightly/components. Calling outer `rustup run ... cargo dylint` alone does not establish that internal plain-cargo processes use rustup proxies; inspect and test PATH. Prefer a pinned, Nix-provided nightly linked into rustup if feasible; otherwise make the rustup download/provisioning step explicit and recognize it as mutable runtime state. Do not call a network-downloading cold-start Dylint command a pure Nix build.

If packaging everything hermetically later, package the compiler-bound library and matching driver as well as CLI/linker, preload vendor dependencies, and expose prebuilt library discovery. Merely using buildRustPackage for cargo-dylint does not prebuild the runtime driver/library. Pinning `rev` and passing consumer `--locked` do not themselves prove all runtime driver resolutions are locked; verify this in the pilot.

A practical first pilot need not build any compiler infrastructure. In a scoped environment with the Nix rustup proxy directory first, provision existing Rust binary distributions and build the pinned CLI/linker into a project-local tool directory, then run the direct command:

```sh
rustup toolchain install stable --profile minimal
rustup toolchain install nightly-2026-07-09 --profile minimal --component rustc-dev --component llvm-tools-preview --component rust-src
cargo +stable install --locked --version 6.1.0 --root .dev-tools cargo-dylint dylint-link
```

These are proposed setup commands, not executed commands or a final reproducible Nix package. The scoped runner must include both `.dev-tools/bin` and the Nix rustup bin directory before ordinary Rust bins. The explicit setup has downloads for toolchains, Cargo dependencies and Git lint sources; cold execution additionally builds the lint library and driver. It is an appropriate feasibility experiment, while the long-term implementation should put versioned packages and policy in dev rather than leave ad hoc bootstrap scripts as the permanent distribution system.

The lint library itself should be packageable as an ordinary, deterministic Nix Rust cdylib build: fixed Git source, Cargo.lock with vendored dependencies, exact binary nightly with rustc-dev, and a linker. A direct `cargo build --release --locked --package perfectionist` does not invoke cargo-dylint or need to generate a Dylint driver; its entry point just exports `register_lints` and `dylint_version`. Avoid IFD by declaring the resolved dependencies and hashes normally. Its existing linker wrapper reads `RUSTUP_TOOLCHAIN` to name the output, so a Nix build must supply a deliberate matching toolchain identity, or override the linker to `cc` and install the output under Dylint's required `libperfectionist@<toolchain>.so` name. This is an implementation inference from [the entry point](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/src/lib.rs), [manifest](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/Cargo.toml), [Dylint filename contract](https://github.com/trailofbits/dylint/blob/master/docs/how_dylint_works.md#library-requirements), and [dylint-link implementation](https://github.com/trailofbits/dylint/blob/master/dylint-link/src/main.rs), not a validated derivation. Runtime execution still requires the matched compiler and driver even after the library has a Nix store path.

Source exception boilerplate if per-site suppressions are desired:

```rust
#![cfg_attr(dylint_lib = "perfectionist", feature(register_tool))]
#![cfg_attr(dylint_lib = "perfectionist", register_tool(perfectionist))]

#[expect(perfectionist::overly_long_function, reason = "the generated protocol table is reviewed as one unit")]
fn protocol_table() { /* ... */ }
```

```toml
[workspace.lints.rust]
unexpected_cfgs = { level = "warn", check-cfg = ['cfg(dylint_lib, values("perfectionist"))'] }

# In each member Cargo.toml:
[lints]
workspace = true
```

First acceptance check: on a clean CI machine run the wrapper against one real project, deliberately introduce a violation and confirm a nonzero exit, confirm stable normal builds still work, assess diagnostics/false positives, record cold/warm timing, and verify failure for missing libraries. This is a useful engineering check, not a claim already tested here.

### Gaps
- No installations or builds were performed; source repositories were not changed. This report does not present the wrapper or any Nix package as implemented or validated.
- Exact wrapper/driver packaging needs a small real-project spike. The source-backed concern is strong, but a working Nix-native custom rustup toolchain has not been demonstrated here.
