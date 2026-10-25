# Make Rust quality checks enforceable

**Put reusable tooling in `dev`, keep policy in each Rust project, and require the same checks in CI.** Extend your existing `envs/rust` with a small executable workflow: formatting, Clippy and tests first; fresh coverage plus cargo-crap as a separate check; Perfectionist after a curated pilot. This addresses the weakness you identified in Markdown skills: acceptance depends on an executable result. Your host configuration can consume these packages for convenience. It should not become a prerequisite for another machine to validate a project. Keep a short Rust review checklist for ownership, APIs and domain behavior, because these tools only automate part of that judgment. This assessment reviewed source and documentation; no successful installation, tool execution or Nix build validates the proposed integration yet.

## Let `dev` own packages and shared commands

Your existing repository already has the right boundary. `dev` provides shared environments using each consumer's `pkgs`, and `envs/rust` already supplies Rust, bacon, nextest, cargo-workspaces and watchexec. Projects import its source through `flake: false`. By comparison, `config` applies its overlay to the host's package set; consuming Rust projects do not inherit it. Putting these tools only in that overlay would leave their project and CI dependencies implicit. ([dev README](/hatimthayyil/code/dev/README.md), [Rust environment](/hatimthayyil/code/dev/envs/rust/devenv.nix:1), [host overlay wiring](/hatimthayyil/code/config/modules/overlays.nix:60))

I recommend adding pinned package definitions under `dev/pkgs/` for tools absent from the consuming Nixpkgs, starting with cargo-crap. Call them from `envs/rust` through the consumer's `pkgs.callPackage`; reuse existing Nixpkgs tools such as cargo-llvm-cov. Declare the compiler and matching LLVM tools through `languages.rust`, binaries through `packages`, and shared commands through devenv tasks or scripts. Each project owns its lint policy, supported features, coverage scope, exceptions and required CI checks. This fits the current interface without adding a second package set.

An overlay exported by `dev` becomes useful when a concrete host consumer needs it; it can reuse those package definitions. The current flake exports templates only, so direct `nix build` package outputs would require a new public interface. Extend `envs/rust` first. A separate optional environment becomes justified if Perfectionist's validated toolchain or build costs warrant it. ([current flake](/hatimthayyil/code/dev/flake.nix:1))

Packaging has two practical constraints. cargo-crap's Git checkout lacks a committed `Cargo.lock`; reproducible packaging needs a maintained lock or equivalent vendoring strategy, with the published crate's contents checked before choosing that source. Coverage needs LLVM tools matching the project's compiler: installing cargo-llvm-cov alone does not establish that match. Package cargo-crap without its optional AI triage initially; static reports already provide the signal needed here. ([manifest](/hatimthayyil/code/cargo-crap/Cargo.toml:14), [ignore rules](/hatimthayyil/code/cargo-crap/.gitignore:92), [Rust coverage requirements](https://doc.rust-lang.org/rustc/instrument-coverage.html))

## Make the ordinary Rust checks mandatory first

Use a proposed shared `rust-check` command with this conservative baseline:

```sh
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --locked -- -D warnings
cargo test --workspace --locked
```

These commands are checked against documentation; they have not been executed on your projects during this investigation. Keep compiler and Clippy policy checked into Cargo manifests, including workspace inheritance. Select extra Clippy lints individually. Feature combinations belong to each project's supported configuration; blanket `--all-features` can select incompatible features. Where nextest already provides value, preserve it and run applicable doctests separately, because nextest excludes doctests. ([Cargo lint configuration](https://doc.rust-lang.org/cargo/reference/manifest.html#the-lints-section), [Clippy usage](https://doc.rust-lang.org/clippy/usage.html), [nextest documentation tests](https://nexte.st/docs/running/#documentation-tests))

Have `devenv test` invoke the canonical command through `enterTest` or its task dependency. Humans, agents and CI then share one definition. Keep formatting and Clippy in inexpensive local hooks; run tests before completion and in CI. Your Dioxus template already has formatting and Clippy hooks, so consolidate those when introducing shared commands rather than multiplying full check sequences. ([devenv tests](https://devenv.sh/tests/), [existing Dioxus environment](/hatimthayyil/code/dev/templates/dioxus/devenv.nix:12))

**A required CI check is the enforcement boundary.** Git hooks are bypassable, and an agent Stop hook is another feedback mechanism. Configure protected branches so the required check runs against the submitted commit and pinned environment; review changes to workflows, thresholds, exclusions and suppressions. GitHub permits administrative and configured bypasses unless protection disables them. The practical guarantee depends on those repository settings as well as the command. ([Git hooks](https://git-scm.com/docs/githooks), [GitHub required checks and bypasses](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches))

## Use cargo-crap to identify complex, weakly exercised code

cargo-crap combines source complexity with supplied line coverage. The score is `CC² × (1 − coverage)³ + CC`, with coverage expressed from zero to one. An untested function with complexity 6 scores 42; complexity 12 at 50% coverage scores 30. At full coverage, the score equals complexity. The default threshold is 30, and failure means strictly greater than 30. Start there and inspect actual findings before adopting a stricter project threshold. Its complexity convention counts each match arm and `?`, so a score also reflects ordinary Rust control flow. ([score implementation](/hatimthayyil/code/cargo-crap/src/score.rs:27), [complexity convention](/hatimthayyil/code/cargo-crap/docs/reference/complexity.md:19))

Create a separate proposed `rust-quality` command, generating coverage from the current source before scoring it:

```sh
cargo llvm-cov --workspace --lcov --output-path target/quality.lcov
cargo crap --workspace --lcov target/quality.lcov --missing pessimistic --threshold 30 --fail-above
```

These are source-checked examples, not validated runs. Adapt the coverage invocation to supported targets/features and merge compatible runs where appropriate. Coverage performs instrumented compilation and tests, so it belongs in CI and deliberate local validation rather than after every agent edit. Reusing LCOV after source changes invalidates the association between source spans and executed lines. ([cargo-llvm-cov workflows](https://github.com/taiki-e/cargo-llvm-cov#readme), [CLI implementation](/hatimthayyil/code/cargo-crap/src/main.rs:51))

For existing debt, a trusted baseline enables `--fail-regression`, but **new functions receive `New`, not `Regressed`**. A regression-only check can accept a newly introduced function with any score. A clean project can combine `--baseline baseline.json --fail-regression --fail-above`; existing projects that cannot pass the absolute threshold need explicit review of new above-threshold functions or an additional policy implemented later. The upstream Action defaults to regression failure without absolute failure. Avoid `--top` and `--min` in enforcement commands because the absolute gate operates on selected report entries. ([baseline status assignment](/hatimthayyil/code/cargo-crap/src/delta.rs:275), [gate implementation](/hatimthayyil/code/cargo-crap/src/main.rs:1893), [Action defaults](/hatimthayyil/code/cargo-crap/action.yml:31))

There are meaningful blind spots. This version excludes closure and nested-function decisions from the outer score without reporting them as independent rows; macro bodies are unexpanded. It measures line execution, leaving branch outcomes and assertion quality unassessed. Missing LCOV files default pessimistically, but a matching file with no executable coverage lines inside a function's span yields 100% coverage. That can matter for feature-gated or uninstrumented code; `--missing pessimistic` does not fix that case. Parse failures and scope mismatches warn and can leave analysis incomplete. Audit representative coverage output and warnings before trusting the gate. ([complexity exclusions](/hatimthayyil/code/cargo-crap/src/complexity.rs:314), [coverage calculation](/hatimthayyil/code/cargo-crap/src/coverage.rs:89), [parse handling](/hatimthayyil/code/cargo-crap/src/complexity.rs:473))

Treat the metric as a repair priority. Executing lines with weak assertions or moving branches into closures can lower a score without improving the product. Its duplicate report, `cargo crap --workspace --duplicates --summary`, offers useful advisory review, but duplicate counts do not fail the gate. ([duplicate options](/hatimthayyil/code/cargo-crap/src/main.rs:211), [original CRAP authors' cautions](https://www.artima.com/weblogs/viewpost.jsp?thread=210575))

## Pilot Perfectionist against an explicit policy

Perfectionist directly addresses your original frustration: its author created compiler checks for rules agents ignored in Markdown. It adds useful checks for cognitive complexity, nesting, large functions/files, ownership conventions and suppression reasons. However, its defaults also encode personal preferences, including rejecting thiserror in favor of derive_more. Choose the rules that match your engineering policy before making findings fatal. ([project motivation](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/README.md#L56), [implemented rules](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/README.md), [thiserror rule](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rules/thiserror_usage.md))

The main adoption cost is compiler coupling. This is a Dylint compiler library; the reviewed revision pins `nightly-2026-07-09` and Dylint 6.1.0. Dylint checks a project using the compiler that built the library, so compatibility with your ordinary stable build must be demonstrated. On NixOS, its rustup discovery and internally spawned Cargo commands also require deliberate PATH handling. A scoped runner should expose the Nix-packaged rustup proxies and exact lint toolchain while preserving the project's ordinary compiler outside that command. Merely packaging cargo-dylint leaves runtime library and driver builds unresolved. ([pinned toolchain](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/rust-toolchain), [Dylint limitations](https://github.com/trailofbits/dylint/blob/master/docs/how_dylint_works.md#limitations), [Dylint driver implementation](https://github.com/trailofbits/dylint/blob/master/dylint/src/driver_builder.rs))

Pin the library revision through Dylint workspace metadata. In the pilot, make only selected structural and ownership checks fatal. After disabling unwanted policies and auditing the remainder, a comprehensive invocation is:

```sh
DYLINT_RUSTFLAGS='-D warnings' cargo dylint --all --fail-on-no-libraries -- --workspace --all-targets --locked
```

Active rules ordinarily warn, and disabling a pass prevents it from emitting findings regardless of lint severity. There is no registered `perfectionist::all` lint group. Source-level exceptions additionally need the documented gated tool registration. Verify the chosen command rejects a deliberately introduced violation and missing libraries on a clean machine before making it required. Measure diagnostic usefulness and cold/warm cost there. ([rule controls](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/CONTROLLING_RULES.md), [configuration](https://github.com/KSXGitHub/perfectionist/blob/e6fa707f279e2ef7216d4cd2a8aab2e332da5e8a/CONFIGURATION.md))

## Preserve judgment through a smaller review checklist

rust-skills remains useful as a source of questions about who owns state, expected failures, invalid states, cancellation and public APIs. Its full plugin prints routing instructions through a prompt hook; that does not validate source. Extract a short project review checklist and translate only mechanically checkable requirements into executable rules. ([ownership guidance](/hatimthayyil/code/rust-skills/skills/m01-ownership/SKILL.md), [prompt hook](/hatimthayyil/code/rust-skills/.claude/hooks/rust-skill-eval-hook.sh))

Use review to ask whether modules have coherent responsibilities, abstractions serve actual requirements, ownership matches the domain, and tests exercise observable behavior and failure paths. Neither complexity thresholds nor coverage establishes those properties. The first implementation should therefore deliver the stable baseline and one coverage pilot, then establish whether Perfectionist earns its maintenance cost on a representative project. That sequence produces useful enforcement at every stage while keeping architectural judgment visible.
