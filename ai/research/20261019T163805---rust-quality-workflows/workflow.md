# Rust quality workflow integration

## Where should the packages and workflow live?

### Takeaway
Own reusable Rust tool packaging and check commands in `dev`. Extend the existing `envs/rust` first; `config` should configure agent clients and optionally consume the same packages for interactive use. A host overlay alone does not give a Rust repository a reproducible CI environment.

### Cited Findings
- `dev` already defines shared environments as functions of each consuming project's `pkgs`; its rules explicitly say environments contain repeated toolchains, libraries and project CLIs. Projects import its raw source with `flake: false`. — [dev README](/hatimthayyil/code/dev/README.md), [dev AGENTS](/hatimthayyil/code/dev/AGENTS.md)
- `envs/rust` currently enables Rust and installs bacon, nextest, cargo-workspaces and watchexec. It has no shared quality commands or hooks. — [Rust environment](/hatimthayyil/code/dev/envs/rust/devenv.nix:1)
- `dev/flake.nix` currently exports templates only: no inputs, packages or overlays. Direct `nix build github:hatimthayyil/dev#cargo-crap` is therefore not an existing interface. — [flake](/hatimthayyil/code/dev/flake.nix:1)
- `config` applies its default overlay only to its NixOS package set; the local package overlay currently defines only firefox-csshacks and zed-preview. Rust repositories importing `dev` do not inherit that host overlay. — [base](/hatimthayyil/code/config/modules/base.nix:49), [overlay composition](/hatimthayyil/code/config/modules/overlays.nix:60), [local packages](/hatimthayyil/code/config/pkgs/overlay.nix:1)
- The Dioxus template already has treefmt and a Clippy pre-commit hook with `allFeatures`, `denyWarnings` and `--all-targets`. `ai-tools` separately declares stable Rust, bacon, nextest, and `enterTest = cargo test`; it currently has no `.github` directory. — [Dioxus devenv](/hatimthayyil/code/dev/templates/dioxus/devenv.nix:12), [ai-tools devenv](/hatimthayyil/code/ai-tools/devenv.nix:15), [ai-tools inputs](/hatimthayyil/code/ai-tools/devenv.yaml:1)
- devenv supports Rust from the pinned nixpkgs revision, rust-overlay channels, and a project `rust-toolchain.toml`. The default channel is nixpkgs; setting stable uses rust-overlay. — [devenv Rust](https://devenv.sh/languages/rust/)

### Inferences
- Small file map: `dev/pkgs/cargo-crap.nix` and any genuinely missing Dylint package definitions hold pinned source/hash/Cargo-lock builds; `dev/envs/rust/devenv.nix` calls these with the consuming project's `pkgs` and provides the common commands; `dev/README.md` documents commands and prerequisites. Keep project-specific lint choices, feature sets, Perfectionist metadata and CRAP configuration in each Rust repository.
- Plain `pkgs.callPackage ../../pkgs/cargo-crap.nix { }` from the raw imported environment is the smallest valid initial package interface and respects the current project's package set. It avoids maintaining package derivations twice. A `dev` overlay/package output becomes worthwhile if a concrete consumer needs `nix build/run` or host installation; it should call those same definitions. Do not imply these exports already exist or invent a second independently pinned toolchain for the environment.
- Adding a full flake package export is a real implementation choice: the currently inputless template flake would need a package-set input and supported-system declarations. That is reasonable when direct builds are a requirement, but not necessary for consuming these tools through the already established devenv API.
- Extend `envs/rust` for universally desired binaries and commands. A new optional `rust-quality` environment is justified only if validated nightly/toolchain or closure costs make inclusion in every Rust environment undesirable; do not split simply to add another abstraction.
- No `programs.*` or `services.*` changes are needed. `config`'s NixOS/HM options can stay untouched. A `dev` environment edit needs a shell build/check, not `just switch`; `just switch` applies host/HM changes only if those are later made.

### Gaps
- No derivations or shell builds were implemented in this research. The other researchers are validating Perfectionist/Dylint runtime constraints and cargo-crap gate behavior; their findings must determine exact package definitions and mandatory check eligibility.

## How should checks enter the agent workflow?

### Takeaway
Use one command that agents, humans and CI can all execute. Local hooks provide timely feedback; a required trusted CI check is the acceptance boundary. Leave the costly coverage/CRAP execution in a separate command rather than running it after each edit.

### Cited Findings
- Git's pre-commit hook can be bypassed with `--no-verify`; hook files also live in configurable local hook paths. — [Git hooks](https://git-scm.com/docs/githooks)
- GitHub required checks must pass before merge when branch protection is configured. Administrators and bypass roles are exempt by default unless the corresponding no-bypass setting is enabled; expected GitHub App sources can constrain accepted checks. — [GitHub branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- devenv `enterTest` runs through `devenv test`; tasks can be attached before `devenv:enterTest`. Task caching is conditional on explicit status/file-change declarations, so it is not automatically an acceptance guarantee for every source/toolchain input. — [devenv tests](https://devenv.sh/tests/), [devenv tasks](https://devenv.sh/tasks/)
- Existing Claude hooks checkpoint git-ai, start Herdr and inject memory prompts; existing Codex hooks start Herdr and inject memory prompts. Neither JSON contains a Rust quality check. — [Claude settings](/hatimthayyil/code/config/home/hatim/claude/settings.json), [Codex hooks](/hatimthayyil/code/config/home/hatim/codex/hooks.json)
- Default Clippy catches established lints; restriction and nursery groups should be selected individually, and pedantic intentionally includes possible false positives. `-D warnings` makes warnings fail the command. Current docs recommend `CARGO_BUILD_WARNINGS=deny` starting with Cargo 1.97; the older form remains portable and may invalidate caches. — [Clippy usage](https://doc.rust-lang.org/clippy/usage.html), [lint groups](https://doc.rust-lang.org/clippy/lints.html)
- Cargo supports checked-in `[lints.rust]`, `[lints.clippy]` and workspace lint inheritance. Such policy applies to the packages opting into it, rather than all external dependencies. — [Cargo manifest lints](https://doc.rust-lang.org/cargo/reference/manifest.html#the-lints-section)
- Nextest currently excludes doctests; library projects using nextest need a separate `cargo test --doc` step. — [nextest running tests](https://nexte.st/docs/running/#documentation-tests)
- The local nixpkgs cargo-llvm-cov expression states that runtime needs `llvm-tools-preview` from the selected Rust toolchain. Its explicit LLVM variables are derivation test/build variables, not an installed runtime wrapper. — [local package](/hatimthayyil/code/nixpkgs/pkgs/by-name/ca/cargo-llvm-cov/package.nix), [upstream installation](https://github.com/taiki-e/cargo-llvm-cov#installation)

### Inferences
- Start with a shared `rust-check` script running `cargo fmt --all -- --check`, `cargo clippy --workspace --all-targets --locked -- -D warnings`, and `cargo test --workspace --locked`. This is a valid conservative baseline; configure feature combinations in each project rather than blindly forcing `--all-features` for every repository.
- `cargo test` is the simplest universal initial runner because it includes applicable doctests. Where nextest is already justified, use `cargo nextest run --workspace --locked` and add doctests for library targets. Avoid an unconditional `cargo test --doc` in a universal script for projects with no library target.
- Provide `rust-quality` separately for coverage generation and the cargo-crap invocation approved by the cargo-crap audit. When quality becomes mandatory on PRs, run that command there; keep edit-time feedback focused on format/Clippy/relevant tests. Perfectionist can add its own command initially and join required checks only after measuring false positives and maintenance cost.
- Have `enterTest` call the canonical check command OR attach that same command as a task before enterTest. Do not also duplicate its complete workload in enterTest and a full pre-commit hook. Existing Dioxus hooks must be consolidated when moving policy to shared commands.
- Keep pre-commit inexpensive: formatting and Clippy are a useful initial choice. Run full tests before completion/push and required CI. Calling coverage from every tool hook would repeatedly instrument/rebuild and consume agent feedback time.
- The CI implementation must not trust a pre-existing local success marker: execute against the checked-out commit, pinned environment and committed lockfiles. If the agent can edit the checks, suppressions, exclusions, thresholds or workflow itself, those policy changes need review; host hooks alone cannot establish an unchangeable boundary.
- A short agent instruction can say run `devenv shell -- rust-check` before completion. A per-client Stop hook may improve feedback, but it should invoke the same command, and must not be presented as universal or impossible to bypass.
- Suggested adoption commands: in dev, `devenv shell -- check` validates all environment shell builds. In a scratch project or pilot repository, `devenv -o dev path:/hatimthayyil/code/dev shell -- rust-check` exercises the local environment source. Then update and commit that repository's dev input lock and run `devenv shell -- rust-check` in CI. These commands need the proposed script to exist; they are an adoption plan, not current commands verified in this research.
- Preserve each project's existing stable/compiler pin. For coverage, add matching LLVM components through `languages.rust` or the project's aggregate toolchain; do not assume installing cargo-llvm-cov alone is sufficient, and do not inject LLVM from another compiler revision. Perfectionist's nightly stays a distinct selected lint toolchain until its constraints are validated.

### Gaps
- No repository branch protection, CI check or agent hook was changed. A CI file alone does not configure required merges. The actual stable compiler version of the ai-tools shell was not built/evaluated, so the portable `-- -D warnings` is used rather than assuming Cargo >=1.97.

## What remains useful from rust-skills?

### Takeaway
Keep a small advisory review checklist for ownership, errors, API boundaries and domain invariants. Mechanical checks can reject specified patterns, but cannot prove that ownership or architecture matches the product's requirements.

### Cited Findings
- rust-skills' skills-only mode has no automatic hooks. Full plugin mode runs a prompt hook that prints mandatory routing/reasoning instructions; the inspected shell script emits text with `cat`, not compiler or source validation. — [README](/hatimthayyil/code/rust-skills/README.md), [hook declaration](/hatimthayyil/code/rust-skills/hooks/hooks.json), [hook implementation](/hatimthayyil/code/rust-skills/.claude/hooks/rust-skill-eval-hook.sh)
- Ownership guidance asks who should own data, whether sharing is intended, and what domain role the data plays. Anti-pattern guidance questions cloning, unwraps, public fields, long functions and giant enums. — [ownership skill](/hatimthayyil/code/rust-skills/skills/m01-ownership/SKILL.md), [anti-pattern skill](/hatimthayyil/code/rust-skills/skills/m15-anti-pattern/SKILL.md)
- Config's current pinned skills manifest contains find-skills and stop-slop only. — [skill manifest](/hatimthayyil/code/config/modules/agent-skills.nix:18)
- Local git evidence: rust-skills HEAD is `5c40d3a`, August 23, 2026, frontmatter fixes; the latest logged change touching the representative ownership/anti-pattern/coding-guidelines paths is `f464484`, January 22, 2026. This distinction does not establish every one of the 179 guideline rules' last substantive change. — [local repository](/hatimthayyil/code/rust-skills)

### Inferences
- Use compiler/lints for locally recognizable mistakes, tests for observable requirements and failure paths, CRAP for prioritizing complex under-tested functions, and review for ownership/API/domain decisions. Passing one category does not prove another.
- Preserve questions such as “Who owns this state?”, “What failures are expected?”, “Which invalid states can these types represent?”, “What happens on cancellation/retry?” and “Do tests exercise user-visible invariants?”. Those remain useful after all automated gates pass.
- Do not adopt every heuristic as law: changing every `String` to borrowed text can complicate ownership, a domain entity does not always require shared `Arc`, and enums often express closed alternatives better than trait objects. Apply the conceptual questions to real requirements.
- Installing the whole routing framework would add large prompt/display obligations and agent-specific hooks while retaining the user's original problem: the agent can ignore printed instructions. A small checked-in review checklist complements executable checks with less noise.

### Gaps
- This is inspection of the named local checkouts, not a claim that rust-skills upstream is abandoned. No skill installation was performed, and no claim is made that all guidelines can be translated into sound lints.
