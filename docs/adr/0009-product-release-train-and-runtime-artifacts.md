# ADR 0009: Compatibility Matrix Promotion And Runtime Binary Artifacts

## Status

Accepted, amended by the M06.9 release model correction

## Context

skenion is a multi-repository product. Contracts, Runtime, SDK, Studio,
examples, and docs do not all share the same implementation cadence, but v0
users need one clear compatibility record that names the artifacts that work
together.

Runtime is an executable product binary in v0. Tauri Desktop `local-managed`
mode needs OS/arch-specific Runtime binaries that can be bundled as sidecars.

## Decision

skenion v0 repositories and artifacts use natural component releases plus a
promoted compatibility matrix. Release Please owns each repository's natural
version, changelog, release PR, tag, and GitHub Release flow. The hub verifies
released artifacts and promotes the compatibility matrix; it is not the
component release conductor and must not dispatch Release Please with forced
`release-as` train versions.

Contracts v0 compatibility is rooted in the Contracts package/crate line, not
in equal product versions. A v0 Contracts line is `0.minor`: supporting `0.45`
means supporting `>=0.45.0 <0.46.0`. Patch releases inside a Contracts line must
remain backward compatible. Breaking Contracts schema, wire, or public API
changes require a new line such as `0.46.0`.

Exact graph, project, node, operation, extension, package, manifest, Runtime
HTTP, and protocol discriminator fields remain exact current-version checks.
Do not confuse those wire/schema/protocol discriminators with package SemVer
ranges.

Product releases are coordinated by a machine-readable compatibility matrix.
The matrix is the product compatibility unit and promotion record.

The compatibility matrix schema is owned by `skenion-contracts`.

Compatibility matrix instances are owned by the hub repository,
`skenion/skenion`, under:

```text
releases/compatibility/<contracts-line>.json
```

The first active corrected matrix is `releases/compatibility/0.45.json`.
Historical lockstep train manifests are not active product release metadata.

Reusable release workflow implementation is owned by
`skenion/skenion-ci`. Hub verification workflows collect evidence and record
promotion state; reusable workflow details stay in `skenion-ci`.

The compatibility matrix must include:

- Contracts line and SemVer range
- exact Contracts npm/crate versions
- Runtime binary artifacts by target, with checksums
- SDK npm version and supported Contracts range
- Studio web/static and desktop artifact versions, plus Runtime sidecar versions
- Examples tag or commit
- Manual version and deploy status
- protocol baselines
- `capability-set` with protocol surfaces and required Runtime, Studio,
  package/marketplace, and Manual capabilities
- release completion gates

The recommended verification order is:

1. Contracts.
2. Runtime.
3. SDK.
4. Studio.
5. Examples.
6. Docs.

Contracts are the compatibility seed. Downstream release workflows must consume
released registries, release tags, GitHub Release assets, or the checked-in
compatibility matrix. Release jobs must not consume sibling branches, `main`,
or stale hard-coded dependency tags.

Component releases may be public before they are promoted as a product
compatible set. Contracts `0.45` is the first compatibility-matrix line for the
corrected release model. The dangling 0.44 release state must not be repaired
with tag surgery, forced train rewrites, or local publish compensation.

Runtime release workflows must publish multi-arch binary assets. Runtime
product distribution is GitHub Release assets, not a registry package.

Runtime binary release asset names use:

```text
skenion-runtime-<version>-<target>.tar.gz
skenion-runtime-<version>-<target>.zip
```

Use `.zip` for Windows assets and `.tar.gz` for Unix-like assets. Each asset
must have a checksum entry in the compatibility matrix. Studio Desktop packaging
must verify the checksum before staging the sidecar binary.

The unpacked Runtime sidecar binary should be staged under the Tauri desktop
project with a target-qualified filename that Tauri can bundle for the current
target.

Design target matrix:

- `aarch64-apple-darwin`
- `x86_64-apple-darwin`
- `x86_64-pc-windows-msvc`
- `aarch64-pc-windows-msvc`
- `x86_64-unknown-linux-gnu`
- `aarch64-unknown-linux-gnu`

The first release-blocking tier may be macOS arm64/x64, Windows x64, and Linux
x64. Windows arm64 and Linux arm64 may remain preview until native dependency
smoke tests are stable.

## Consequences

Release and publish workflows must consume released artifacts only: registry
packages, release tags, GitHub Release assets, or a checked-in compatibility
matrix.
PR CI may still checkout sibling branches for in-flight integration.

Manual deployment is a release completion gate. Main branch CI is not release
completion.

Registry publishing must run only from GitHub Actions release workflows. Local
machines may run dry-run verification, but must never publish npm packages,
crates, Runtime binaries, Studio packages, or Manual releases. Registry packages
are only for importable libraries; product binaries, Studio builds, Examples,
Manual, and CI surfaces are release assets, tags, deployments, or workflow refs.
