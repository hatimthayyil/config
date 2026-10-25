# cargo-crap: measured Rust change risk and enforcement

## What does it measure, and how much trust should the gate receive?

### Takeaway

cargo-crap is useful as a deterministic check for complex functions lacking exercised lines. It is one signal in a Rust quality workflow; neither its metric nor its source analysis establishes correctness, good architecture, idiomatic Rust, or meaningful assertions.

### Cited Findings

- Inspected local checkout `49f6703`, version 0.9.0, Rust edition 2024, minimum Rust 1.88, MIT. Current upstream changelog independently confirms release 0.9.0 on 2026-10-17. [Cargo manifest](/hatimthayyil/code/cargo-crap/Cargo.toml:1), [upstream changelog](https://github.com/minikin/cargo-crap/blob/main/CHANGELOG.md).
- Exact formula is `CC² × (1 − line_coverage / 100)³ + CC`; default threshold 30, with failure classification strictly greater than threshold. Full coverage reduces CRAP to CC; zero coverage gives `CC² + CC`. [Implementation](/hatimthayyil/code/cargo-crap/src/score.rs:27), [original authors' formula](https://www.artima.com/weblogs/viewpost.jsp?thread=210575).
- Calculated directly from that implementation: CC 5 / 0% scores 30 and passes threshold 30; CC 6 / 0% scores 42 and fails. CC 12 / 0%, 50%, 80%, 100% scores 156, 30, 13.152, 12. At threshold 10, CC 3 / 0% scores 12 and fails; fully covered CC 10 scores 10 and passes. Threshold 10 is materially stricter than the default; there is no local evidence establishing either number as a universal Rust standard. [Formula and comparison](/hatimthayyil/code/cargo-crap/src/score.rs:44).
- Its complexity is tool-specific: starts at 1, increments for `if`, loops, **each** match arm, `&&`, `||`, and `?`; three match arms therefore give CC 4, differing from textbook McCabe's N−1 decision convention. Config-only `try-weight` defaults to 1 and can discount `?`. [Counting code](/hatimthayyil/code/cargo-crap/src/complexity.rs:239), [documented convention](/hatimthayyil/code/cargo-crap/docs/reference/complexity.md:19), [weight defaults](/hatimthayyil/code/cargo-crap/src/config.rs:221).
- Free functions, impl methods, and trait methods with default bodies are extracted from the unexpanded `syn` AST. Required trait signatures are absent. It skips functions with simple `#[test]` and entire modules marked exactly `#[cfg(test)]`; other cfg expressions are not evaluated. [Extraction](/hatimthayyil/code/cargo-crap/src/complexity.rs:129).
- Material documentation ambiguity: complexity docs say closures/nested items have their own scopes, but the implementation does **not** extract them as their own score rows and excludes their decisions from the outer function. Local test `nested_fn_does_not_inflate_enclosing_cc` explicitly expects exactly one function, and the closure test checks that branches do not increase outer CC. Macro token bodies are not expanded for analysis either. [Visitor](/hatimthayyil/code/cargo-crap/src/complexity.rs:150), [counter exclusions](/hatimthayyil/code/cargo-crap/src/complexity.rs:314), [nested test](/hatimthayyil/code/cargo-crap/src/complexity.rs:690), [closure test](/hatimthayyil/code/cargo-crap/src/complexity.rs:953).
- LCOV parser consumes source paths and executable line hits (`SF`, `DA`); it ignores LCOV function and branch information. Per-function coverage intersects the AST's inclusive line span with the executable line records. It measures line execution, not branch outcomes or assertion strength. [Coverage parser](/hatimthayyil/code/cargo-crap/src/coverage.rs:149), [span calculation](/hatimthayyil/code/cargo-crap/src/coverage.rs:89).
- Precisely distinguish two cases: (1) no matching LCOV **file** => coverage absent, default pessimistic policy scores as 0%; (2) a matching LCOV file but no executable DA lines in this function's span => reported coverage 100%, even if omission resulted from disabled cfg/instrumentation rather than actual execution. This is explicit code and `empty_span_yields_full_coverage` test behavior. `--missing pessimistic` only controls case 1. [Merge](/hatimthayyil/code/cargo-crap/src/merge.rs:205), [empty span implementation](/hatimthayyil/code/cargo-crap/src/coverage.rs:94), [test](/hatimthayyil/code/cargo-crap/src/coverage.rs:320).
- Source walking honors `.gitignore`, default excludes `tests/**`, `benches/**`, `examples/**`, and merely warns when a source file cannot be read/parsed, skipping that file. It does not fail the entire analysis. Therefore success cannot certify that every production function was analyzed. [Default exclusions](/hatimthayyil/code/cargo-crap/src/main.rs:299), [walker](/hatimthayyil/code/cargo-crap/src/complexity.rs:606), [uncached warning](/hatimthayyil/code/cargo-crap/src/complexity.rs:473), [cached warning](/hatimthayyil/code/cargo-crap/src/complexity.rs:555).
- Paths use canonical absolute matching or component-wise relative suffix matching, preferring the longest matching suffix and merging aliases. Relative LCOV keys are deliberately not canonicalized against CWD. Broad relative `src/lib.rs` records can still match multiple same-suffix source files; prefer coverage emitted by the matching workspace invocation. [Path index](/hatimthayyil/code/cargo-crap/src/merge.rs:295), [path explanation](/hatimthayyil/code/cargo-crap/docs/explanation/path-matching.md:1).
- Scope mismatch diagnostics warn on unmatched source/LCOV paths but do not independently fail the gate. An empty coverage map, including an empty LCOV file or omitted `--lcov`, produces no diagnostics and uses the missing-coverage policy. [Warning code](/hatimthayyil/code/cargo-crap/src/main.rs:1210), [coverage load](/hatimthayyil/code/cargo-crap/src/main.rs:1057), [diagnostics condition](/hatimthayyil/code/cargo-crap/src/merge.rs:193).
- Original authors explicitly caution against treating CRAP as a proxy for overall quality; their original coverage choice was basis-path coverage, whereas this implementation uses line coverage. [Original publication](https://www.artima.com/weblogs/viewpost.jsp?thread=210575).

### Inferences

- Use CRAP as a maintenance-risk alarm, alongside compilation, Clippy and behavior tests. A low score leaves correctness, ownership choices, APIs, unsafe soundness, and performance largely unassessed.
- Formula gaming is possible without malicious intent: split one complicated routine into tiny helpers, move branches into closures/macros, or execute lines with weak tests. A useful agent policy asks for clear ownership and behavioral tests, then treats metric output as a repair target under human review.
- Start with upstream threshold 30, inspect real violations, and decide whether a stricter threshold helps that project. Choosing 10 globally before calibration may penalize otherwise readable `?` chains and small dispatch matches. Keep `try-weight` fixed when comparing runs.

### Gaps

- No runtime measurements or proof that real excluded generic functions appear as covered were performed; the empty-span behavior is source/test verified and its consequence conditional on actual LCOV omission. No claim that all untested functions become 100% covered is justified.
- No population study establishing defect prediction or an optimal Rust threshold was found in the inspected primary sources.

## What can enforce a workflow, especially for workspaces and new code?

### Takeaway

Use a project-owned devenv task for reproducible local feedback and the same command as a required CI check. The baseline regression gate is valuable for existing code, but **alone it permits newly added high-risk functions**.

### Cited Findings

- `--workspace` discovers all Cargo workspace members using `cargo metadata`; repeated `-p NAME` selects named members. These modes ignore `--path`, prevent nested members being walked twice, and produce per-crate summaries. `--workspace` and `-p` conflict. [CLI](/hatimthayyil/code/cargo-crap/src/main.rs:68), [workspace guide](/hatimthayyil/code/cargo-crap/docs/guides/workspaces.md:1).
- Feature, target, integration-test, doctest, and test runner selection belong to **cargo-llvm-cov**, not cargo-crap. cargo-crap walks the selected source trees, including source behind arbitrary feature/platform cfgs it does not evaluate. cargo-llvm-cov supports `--features`, `--all-features`, `--target`, `--all-targets`, workspace/package scope, nextest and merging compatible coverage runs. Doctests remain disabled by default and require nightly coverage support. [cargo-crap CLI source](/hatimthayyil/code/cargo-crap/src/main.rs:51), [cargo-llvm-cov documentation](https://github.com/taiki-e/cargo-llvm-cov#readme).
- JSON reports can be stored as baselines; `--sort file` makes their ordering stable. Baseline matching uses exact path/name/line, suffix-aware path pairing, then unique-name fallback. Changed scores compare against epsilon 0.01 by default; moving a uniquely named function does not alone trigger regression. This is name/path/score matching, **not body hashing**, despite guide language mentioning an unchanged body. [Delta implementation](/hatimthayyil/code/cargo-crap/src/delta.rs:522), [regression guide](/hatimthayyil/code/cargo-crap/docs/guides/regression-gate.md:1).
- Truly new functions receive `New`, never `Regressed`, without a baseline score. `regression_count` and CLI gate count only `Regressed`. Thus `--fail-regression` on an empty baseline can accept a new function with any score. The implementation and `truly_new_function_stays_new` test establish this. [Status assignment](/hatimthayyil/code/cargo-crap/src/delta.rs:275), [count](/hatimthayyil/code/cargo-crap/src/delta.rs:179), [test](/hatimthayyil/code/cargo-crap/src/delta.rs:1031), [CLI gate](/hatimthayyil/code/cargo-crap/src/main.rs:1906).
- `--fail-above` fails on any selected entry strictly above threshold. `--fail-regression` fails on any whole-run regression outside epsilon. `--top`/`--min` only limit display for regression detection, but absolute failure uses the selected display entries. Avoid row filters in enforcement commands. [Gate inputs](/hatimthayyil/code/cargo-crap/src/main.rs:1893).
- Exit statuses: 0 completed and requested gates passed; 1 completed with a gate violation; 2 run/config/input/output error. Report is flushed before gate result. Reporting without failure flags normally succeeds even with poor scores. [Exit handling](/hatimthayyil/code/cargo-crap/src/main.rs:1990), [final verdict](/hatimthayyil/code/cargo-crap/src/main.rs:2210).
- Upstream GitHub Action defaults `fail-regression: true`, `fail-above: false`; it can compute base-commit coverage and score in the same job, or consume supplied LCOV/baseline. Its automatic setup uses rustup and installs cargo-llvm-cov, which is unnecessary when devenv already owns the toolchain. [Action](/hatimthayyil/code/cargo-crap/action.yml:31), [upstream](https://github.com/minikin/cargo-crap/blob/main/action.yml).
- `--duplicates` is a separate structural analysis needing no coverage; default similarity 0.82 and minimum 20 normalized AST nodes. It can report newly added/grown duplicate groups against a baseline, but duplicate counts/AI triage do not affect CRAP scores or exit codes. AI triage is opt-in, sends function bodies to a provider, and adds HTTP/TLS dependencies only under source build feature `triage`. [CLI](/hatimthayyil/code/cargo-crap/src/main.rs:211), [duplicate configuration](/hatimthayyil/code/cargo-crap/src/config.rs:155), [README](https://github.com/minikin/cargo-crap#duplicates-triaged).

### Inferences

- Smallest useful starting point: one explicit coverage-and-CRAP task, threshold 30, uncovered hints, no AI triage, plus compiler/Clippy/tests. Use CI as the required merge boundary. A markdown skill explains what to do; the task and CI make the result executable and reviewable.
- Prefer a task or pre-push stage over full coverage in a pre-commit hook: coverage runs instrumented compilation and tests; repeated commits should not require a second full build/test cycle. Hooks remain useful feedback but are bypassable.
- For a greenfield project combine `--fail-above` and `--fail-regression` once a baseline exists. For existing debt, `--fail-regression` preserves progress, but new-above-threshold code needs explicit review or an additional JSON-based new-function policy; upstream offers no built-in `--fail-new-above` switch. Do not claim the default Action forbids every new risk.
- Keep coverage selection and source scope aligned. Do not blindly add `--all-features` for mutually exclusive features. Use the project's actual supported configuration/matrix, merging LCOV as appropriate; audit uninstrumented spans and warnings before relying on a gate.

Command examples below are checked against source and official docs, **not executed end to end**:

```sh
# Project/workspace audit and absolute gate.
cargo llvm-cov --workspace --lcov --output-path target/quality.lcov
cargo crap --workspace --lcov target/quality.lcov --missing pessimistic --threshold 30 --fail-above

# Baseline creation on trusted main, using the same coverage selection.
cargo crap --workspace --lcov target/quality.lcov --format json --sort file --output target/crap-baseline.json

# Greenfield project comparison, with saved trusted baseline available.
cargo crap --workspace --lcov target/quality.lcov --baseline baseline.json --missing pessimistic --threshold 30 --fail-regression --fail-above

# Advisory duplicate review; this command does not add a duplicate gate.
cargo crap --workspace --duplicates --summary
```

Minimal project config:

```toml
threshold = 30
missing = "pessimistic"
uncovered-hints = true
```

### Gaps

- Baseline storage, required-check enforcement and feature matrix must be selected per consuming project. A committed baseline can be edited by the same agent; recomputing the trusted base in CI avoids that weakness at the cost of another coverage run.
- No generic pre-commit workflow prevents an agent from editing its own policy. Required CI and review are the external enforcement boundary; this is architecture guidance, not a property promised by cargo-crap.

## What does packaging and running it cost on NixOS?

### Takeaway

cargo-crap itself is a conventional standalone Rust executable, well suited to a pinned Nix package supplied to development environments. Matching LLVM coverage tooling and stable coverage inputs matter more than cargo-crap runtime overhead.

### Cited Findings

- cargo-crap parses source without compiling the inspected project and reads an already generated LCOV file. It does not run tests. rayon parallelizes source parsing; `--jobs` can cap threads. A default content cache avoids reparsing unchanged files, but every file is still read/hashed. [CLI jobs](/hatimthayyil/code/cargo-crap/src/main.rs:183), [analysis](/hatimthayyil/code/cargo-crap/src/complexity.rs:473), [cache documentation](/hatimthayyil/code/cargo-crap/docs/explanation/how-it-works.md:52).
- Source build has normal Rust dependencies and optional `ureq`/rustls only for triage; no bespoke system dependency or compiler plugin is declared. Ordinary source installs omit triage; release binaries include it. [Manifest](/hatimthayyil/code/cargo-crap/Cargo.toml:45).
- Local Git checkout deliberately ignores `Cargo.lock` and no lockfile exists. A reproducible Git-source Nix derivation therefore needs a maintained/pinned lockfile or equivalent vendoring lock strategy. Inspect whether the published crate tarball supplies one before choosing `fetchCrate`; do not assume absence in the Git checkout proves absence from a published crate. Source packaging excludes `tests/`, docs, and examples, so GitHub source is preferable if running the full upstream fixture tests. [Ignore rules](/hatimthayyil/code/cargo-crap/.gitignore:92), [package excludes](/hatimthayyil/code/cargo-crap/Cargo.toml:14), [Nix Rust packaging manual](https://nixos.org/manual/nixpkgs/stable/#rust).
- Local nixpkgs contains `cargo-llvm-cov` 0.9.0 but no cargo-crap package was found. Its derivation states users need `llvm-tools-preview` through rustup or Nix toolchain providers such as fenix/rust-overlay, and documents LLVM version mismatch as a common failure. Its build-time LLVM environment is not proof the binary will find runtime tools for an unrelated project toolchain. [Local package](/hatimthayyil/code/nixpkgs/pkgs/by-name/ca/cargo-llvm-cov/package.nix:23).
- Rust's coverage tooling requires LLVM coverage/profdata versions matching rustc's LLVM; the official rustc docs recommend the toolchain's `llvm-tools-preview`. cargo-llvm-cov supports explicit LLVM tool paths and warns about compatible LLVM when mixing toolchains. [rustc coverage documentation](https://doc.rust-lang.org/rustc/instrument-coverage.html), [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov#readme).
- cargo-llvm-cov creates instrumented builds and runs tests; it normally cleans some artifacts to avoid stale data, and has explicit clean/report/merge flows. Reusing stale LCOV after source edits invalidates AST-line joins. [Official coverage workflow](https://github.com/taiki-e/cargo-llvm-cov#merge-coverages-generated-under-different-test-conditions).
- This is an actively changing pre-1.0 tool: 0.7, 0.8 and 0.9 landed within days, introducing cache, trait scoring, grouping, Action and workspace-relative report-path changes. Pin a release; upgrades can change analyzed rows/report schemas and require re-recording baselines. Tests cover formula, merge paths, CLI exit/gating and many report scenarios, but test presence is not independent validation. [Changelog](https://github.com/minikin/cargo-crap/blob/main/CHANGELOG.md), [integration tests](/hatimthayyil/code/cargo-crap/tests/integration.rs:1), [CLI tests](/hatimthayyil/code/cargo-crap/tests/cli.rs:1484).

### Inferences

- Put reusable package definitions and Rust development/quality modules in the user's shared `dev` tooling repository if that repository owns environments; the machine config can consume its overlay for optional global convenience. A system overlay alone installs a binary but cannot reproduce per-project gate thresholds, source scopes, coverage feature selections or CI policy.
- Declare Rust toolchain + matching LLVM tools through `languages.rust` and reusable tooling in `packages`; expose the concrete coverage/CRAP command through a devenv task. Avoid runtime cargo installs or rustup component changes inside the task.
- Build the first package without triage. It keeps this quality check deterministic and avoids configuring paid model requests for a problem already addressed by static structural reports and review.

### Gaps

- No package was built, no tests run, and no release binary downloaded. A scratch `cargo build --offline` failed immediately because dependency `lcov` was not cached. The source checkout is untouched; this report does not claim tested Nix packaging or measured performance.
- Published crate lockfile contents and per-project coverage runtime remain to be verified during actual packaging and a small project pilot. No extrapolated speed claim is justified.
