# Releases

skenion v0 releases are coordinated component releases plus a promoted
compatibility matrix. Repositories keep their natural Release Please versions;
the hub verifies the released artifacts that work together and promotes that
set as a product-compatible matrix.

If the Contracts line is `0.45`, downstream components declare support for the
Contracts package/crate range `>=0.45.0 <0.46.0` and record the exact released
artifact versions that passed verification:

```text
Contracts line      0.45
Contracts range     >=0.45.0 <0.46.0
@skenion/contracts  0.45.x
skenion-contracts   0.45.x
skenion-runtime     <natural release tag>
@skenion/sdk        <natural release version>
skenion-studio      <natural release version>
```

Contracts v0 compatibility is rooted in the Contracts package/crate line, not
in equal product versions. Patch releases inside a Contracts line must remain
backward compatible. Breaking Contracts schema, wire, or public API changes
require a new line such as `0.46.0`.

Exact graph, project, node, operation, extension, package, manifest, Runtime
HTTP, and protocol discriminator fields remain exact current-version checks.
Do not confuse those wire/schema/protocol discriminators with package SemVer
ranges. Unsupported versions must be rejected with a structured diagnostic.

This supersedes the prior policy that the hub conducted lockstep product
versions, dispatched Release Please with forced `release-as` values, or used
the same product version as the release-completion authority. It also
supersedes the older policy that v0 could keep legacy import, migration,
default-alias, or deprecated compatibility paths.

The dangling 0.44 release state is historical evidence, not a state to repair
with tag surgery. Do not force-move tags, rewrite obsolete release metadata, or
compensate with local publishing. Record what exists, fix release workflows
through normal PRs, and use Contracts `0.45` as the first compatibility-matrix
line for the corrected model.

## Compatibility Matrix Promotion

The promoted compatibility matrix is the user-facing compatibility unit. A
matrix entry should record:

- Contracts line, such as `0.45`
- Contracts package/crate SemVer range, such as `>=0.45.0 <0.46.0`
- exact `@skenion/contracts` npm version and `skenion-contracts` crate version
- exact `skenion-runtime` release tag and binary assets by OS/arch, with
  checksums
- exact `@skenion/sdk` npm version and supported Contracts range
- exact Studio web/static deployment and desktop release version, plus Runtime
  sidecar versions
- Examples tag or commit used for conformance
- Manual version and GitHub Pages deployment
- exact graph, node, runtime-wire, extension, and manifest protocol baselines
- `capability-set` covering protocol surfaces plus required Runtime, Studio,
  package/marketplace, and Manual capabilities

`skenion/skenion` is the compatibility matrix verifier and promotion hub. It
owns matrix instances, artifact evidence, promotion gate state, and completion
reporting. It does not own component Release Please authority and must not
dispatch Release Please with forced `release-as` train versions.
`skenion/skenion-ci` owns reusable workflow implementation and exposes pinned
`workflow_call` entrypoints for verification and promotion evidence. The active
hub workflow is `.github/workflows/verify-compatibility-matrix.yml`, which calls
`skenion/skenion-ci/.github/workflows/verify-compatibility-matrix.yml@v2` with
the organization `GH_TOKEN` secret for GitHub artifact verification.

The checked-in compatibility matrix plus hub verification evidence is the
product promotion authority. Every matrix must make this state machine explicit:

```text
component_released -> artifacts_collected -> checksums_verified -> examples_conform -> docs_deployed -> promoted
```

Repository release workflows run from the component repository's normal Release
Please and release automation. A repository workflow may produce the tag,
GitHub release, registry package, artifact, or deployment for that component.
The hub later verifies those released artifacts as evidence for matrix
promotion.

The promotion state must move monotonically. A later state cannot be marked
`passed` while an earlier state is `pending` or `failed`; any `waived`
state needs a matching waiver record with a reason, approver, and timestamp.
`promoted: passed` is valid only when every required release gate is `passed` or
explicitly `waived`.

Do not close a product release milestone unless every required component
artifact has been released, verified against the Contracts line, and promoted in
the compatibility matrix. Component releases may be public but unpromoted until
matrix verification passes.

Recommended verification order:

1. Contracts npm/crate.
2. Runtime multi-arch binary assets.
3. SDK npm.
4. Studio web/static and desktop artifacts.
5. Examples conformance against released artifacts.
6. Docs Manual deployment.

PR CI may checkout sibling in-flight branches for integration. Release and
publish workflows must consume released artifacts only: registry packages,
release tags, GitHub Release assets, or a checked-in compatibility matrix.

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
and be verified by Studio Desktop packaging before a compatibility matrix is
promoted.

Studio Desktop release workflows should download Runtime artifacts from the
compatibility matrix, verify checksums, stage the sidecar binaries for Tauri,
build per-platform installers, and eventually handle signing and notarization
before public desktop release.

Full desktop app auto-updater rollout is not required for the initial v0
compatibility set. Package and patch update UX is separate from app
auto-update: users must still be able to discover, install, and update public
patcher/package artifacts through the package marketplace flow.

## Release Please

Every releasable repository should use Release Please for its natural component
release cadence. The hub does not force an equal product version into component
repositories.

Release Please owns:

- release PRs
- changelog updates
- version file updates
- release tags
- GitHub Releases

Release Please does not promote product compatibility. The hub promotes only a
verified compatibility matrix assembled from released component artifacts.

Package publishing should be separate and should run only after the relevant
release commit, tag, GitHub release, and artifact gates exist for that
component.

Do not merge or publish a Release Please PR merely to match another
repository's version. Do not use forced `release-as`, tag surgery, or local
publishing to repair the dangling 0.44 state. Let each component follow its
normal release flow and promote the product only when matrix verification
passes.

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

Hub verification workflows should pin
`skenion/skenion-ci/.github/workflows/verify-compatibility-matrix.yml@v2` for
compatibility matrix validation, artifact evidence, and promotion reporting. If
`@v2` is missing or does not expose the compatibility matrix verifier, the
workflow must fail clearly instead of falling back to `main`, sibling branches,
or an unpinned workflow ref.
