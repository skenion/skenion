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

## Product Release Train

Repository package versions stay independent, but product releases must be
aligned by a release train manifest.

The product train is the user-facing compatibility unit. A train manifest should
record:

- product train id, such as `0.29` or `2026.06`
- `@skenion/contracts` npm version and `skenion-contracts` crate version
- `skenion-runtime` crate version
- `skenion-runtime` binary release assets by OS/arch, with checksums
- `@skenion/sdk` npm version
- Studio web/desktop release version
- Examples tag or commit used for conformance
- Manual version and GitHub Pages deployment
- graph, node, runtime-wire, extension, and manifest protocol baselines
- required and optional runtime capabilities

Do not force every repository to bump to the same SemVer number just to ship a
product train. Instead, ship the train only when the manifest points to released
artifacts that have all passed compatibility checks.

Recommended release order:

1. Contracts npm/crate.
2. Runtime crate and multi-arch binary assets.
3. SDK npm.
4. Examples conformance against released artifacts.
5. Studio web/desktop package.
6. Docs Manual deployment.

PR CI may checkout sibling in-flight branches for integration. Release and
publish workflows must consume released artifacts only: registry packages,
release tags, GitHub Release assets, or a checked-in train manifest.

## Runtime And Desktop Artifacts

`skenion-runtime` is both a Rust crate and a product binary.

The crate is useful for Rust consumers and docs.rs. The binary is required for
standalone Runtime installs and for Studio Desktop `local-managed` mode where
Tauri bundles Runtime as a sidecar. Runtime release completion therefore
requires GitHub Release assets in addition to crates.io publication.

Design target matrix:

| Target | Initial tier |
| --- | --- |
| `aarch64-apple-darwin` | release-blocking |
| `x86_64-apple-darwin` | release-blocking |
| `x86_64-pc-windows-msvc` | release-blocking |
| `aarch64-pc-windows-msvc` | preview until native smoke is stable |
| `x86_64-unknown-linux-gnu` | release-blocking |
| `aarch64-unknown-linux-gnu` | preview until native smoke is stable |

Runtime binary assets should use sidecar-consumable names, include checksums,
and be verified by Studio Desktop packaging before a product train is marked
complete.

Studio Desktop release workflows should download Runtime artifacts from the
train manifest, verify checksums, stage the sidecar binaries for Tauri, build
per-platform installers, and eventually handle signing and notarization before
public desktop release.

Full desktop app auto-updater rollout is not required for the initial product
train. Package and patch update UX is separate from app auto-update: users must
still be able to discover, install, and update public patcher/package artifacts
through the package marketplace flow.

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

Release Please workflows should use this token order:

```yaml
with:
  token: ${{ secrets.SKENION_RELEASE_PLEASE_TOKEN || secrets.GITHUB_TOKEN }}
```

`SKENION_RELEASE_PLEASE_TOKEN` should be a repository or organization secret
backed by a fine-grained personal access token that can create release PRs,
tags, and releases. Without that secret, Release Please falls back to
`GITHUB_TOKEN`; the release PR will still be created, but GitHub will not start
normal PR CI from events created by that token.

This is expected GitHub Actions recursion protection, not a test failure. Do not
treat an empty-job `action_required` release PR run as a code failure. Configure
the PAT secret before enabling required PR checks for release branches.

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
