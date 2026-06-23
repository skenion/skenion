# Releases

skenion v0 uses lockstep product Semantic Versioning across releasable
repositories and artifacts.

If the product train is `0.55`, every releasable package/application/artifact
in that train must ship the same product version, using registry-compatible
SemVer such as `0.55.0` where a patch component is required:

```text
@skenion/contracts  0.55.0
skenion-contracts   0.55.0
skenion-runtime     0.55.0
@skenion/sdk        0.55.0
skenion-studio      0.55.0
```

Compatibility is determined by the release train and exact current protocol
versions, not by accepting older repository versions, deprecated paths, or broad
version ranges. Unsupported graph, project, node, operation, extension,
package, manifest, Runtime HTTP, or protocol versions must be rejected with a
structured diagnostic.

This supersedes the prior policy that repository versions were independent
SemVer streams and that v0 could keep legacy import, migration, default-alias,
or deprecated compatibility paths.

The first v0 train defaults to product version `0.43.0` with
`train-id: "0.43"`.

## Product Release Train

The product train is the user-facing compatibility unit. A train manifest should
record:

- product train id, such as `0.55`
- the lockstep `@skenion/contracts` npm version and `skenion-contracts` crate version
- the lockstep `skenion-runtime` product binary release assets by OS/arch, with
  checksums
- the lockstep `@skenion/sdk` npm version
- the lockstep Studio web/static deployment and desktop release version
- Examples tag or commit used for conformance
- Manual version and GitHub Pages deployment
- exact graph, node, runtime-wire, extension, and manifest protocol baselines
- `capability-set` covering protocol surfaces plus required Runtime, Studio,
  package/marketplace, and Manual capabilities

`skenion/skenion` is the conductor and product state owner. It owns train
manifest instances, release order, cross-repository dispatch, release gate
state, and completion reporting. `skenion/skenion-ci` owns reusable
workflow implementation and should expose pinned `workflow_call` entrypoints
for conductor use.

Do not close a product release milestone unless every releasable repository and
artifact in the train has published the same product version and passed the
release train gates.

Recommended release order:

1. Contracts npm/crate.
2. Runtime multi-arch binary assets.
3. SDK npm.
4. Studio web/static and desktop artifacts.
5. Examples conformance against released artifacts.
6. Docs Manual deployment.

PR CI may checkout sibling in-flight branches for integration. Release and
publish workflows must consume released artifacts only: registry packages,
release tags, GitHub Release assets, or a checked-in train manifest.

## Runtime And Desktop Artifacts

`skenion-runtime` is a product binary. The binary is required for standalone Runtime installs and for Studio Desktop
`local-managed` mode where Tauri bundles Runtime as a sidecar. Runtime release
completion is based on GitHub Release assets and checksums, not registry
publishing.

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

Every releasable repository should use Release Please for version files,
changelogs, tags, and GitHub releases. During v0, Release Please PRs are
conductor-dispatched from `skenion/skenion` with an explicit
`release-as` matching the train version. Automatic independent per-repository
release authority is stale for v0 product trains.

Release Please owns:

- release PRs
- changelog updates
- version file updates
- GitHub release creation
- tags

Package publishing should be separate and should run only after Release Please
reports that a release was created.

Do not merge or publish a Release Please PR that bumps a package, app, artifact,
or Manual version away from the current product train version. A repository with
no code changes still remains part of the lockstep train through its release
tag, artifact metadata, deployment marker, or train manifest entry.

Release train workflows should use this token order when dispatching
cross-repository Release Please or verification jobs:

```yaml
with:
  token: ${{ secrets.SKENION_RELEASE_TRAIN_TOKEN || secrets.GITHUB_TOKEN }}
```

`SKENION_RELEASE_TRAIN_TOKEN` should be a repository or organization secret
backed by a fine-grained personal access token that can dispatch workflows
across `skenion/*`, create release PRs, tags, and releases, and read release
artifacts. Without that secret, workflows may fall back to `GITHUB_TOKEN` only
for same-repository dry runs; cross-repository publish orchestration is not
release-complete until the train token is configured.

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

`skenion-ci` is the reusable workflow library. It should provide reusable
workflows with `workflow_call`, tagged as stable major versions:

```text
v1
v2
```

Repository workflows should call pinned reusable workflows:

```yaml
jobs:
  ci:
    uses: skenion/skenion-ci/.github/workflows/ts-ci.yml@v1
```

Publish workflows should use minimal permissions and GitHub environments for
manual approval where appropriate.

The hub conductor workflow may prepare and validate a train locally before
`skenion-ci@v1` exists. Publish and verification modes should call the pinned
workflow library once the corresponding `@v1` reusable workflows are available.
