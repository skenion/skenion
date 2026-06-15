# Releases

Skenion uses independent Semantic Versioning per repository.

Versions are not lockstep:

```text
skenion-contracts 1.4.0
skenion-runtime   0.3.12
skenion-sdk       0.5.2
skenion-studio    0.2.18
```

Compatibility is determined by protocol version ranges and negotiated runtime
capabilities, not by matching application versions.

## Release Please

Every releasable repository should use Release Please.

Release Please owns:

- release PRs
- changelog updates
- version file updates
- GitHub release creation
- tags

Package publishing should be separate and should run only after Release Please
reports that a release was created.

## Conventional Commits

Use Conventional Commits for PR titles and merge commits.

Examples:

```text
feat(contracts): add runtime capability handshake
fix(runtime): prevent preview encoding from blocking render loop
chore(studio): configure Mantine provider
feat(contracts)!: replace graph patch envelope
```

Recommended scopes:

- `contracts`
- `runtime`
- `studio`
- `sdk`
- `examples`
- `ci`
- `docs`

## Required Repository Checks

All repositories:

- lint
- tests
- build or package check
- semantic PR title check
- Release Please config validation

Rust repositories:

- `cargo fmt --check`
- `cargo clippy --workspace --all-targets --all-features -- -D warnings`
- `cargo test --workspace --all-features`
- `cargo test --workspace --no-default-features`
- `cargo doc --workspace --no-deps` with warnings denied
- `cargo semver-checks` for public crates
- `cargo deny`

TypeScript repositories:

- frozen pnpm install
- lint
- typecheck
- tests
- build
- package exports check

Contract repository:

- Buf lint and breaking checks
- schema validation
- generated output drift check
- TS/Rust conformance
- golden fixture compatibility

## `skenion-ci`

Common automation belongs in `skenion-ci`, not in an org-level `.github`
repository.

`skenion-ci` should provide reusable workflows with `workflow_call`, tagged as
stable major versions:

```text
v1
v2
```

Repository workflows should call pinned reusable workflows:

```yaml
jobs:
  ci:
    uses: EchoVisionLab/skenion-ci/.github/workflows/ts-ci.yml@v1
```

Publish workflows should use minimal permissions and GitHub environments for
manual approval where appropriate.
