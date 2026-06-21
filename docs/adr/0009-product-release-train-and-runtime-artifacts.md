# ADR 0009: Product Release Train And Runtime Binary Artifacts

## Status

Accepted

## Context

Skenion is a multi-repository product. Contracts, Runtime, SDK, Studio,
examples, and docs do not all share the same implementation cadence. Forcing
all repositories to use one lockstep SemVer number would create artificial
releases and noisy version bumps.

At the same time, users need a clear answer to which released artifacts work
together.

Runtime is also both a Rust crate and an executable product binary. Tauri
Desktop `local-managed` mode cannot bundle a crates.io package directly; it
needs OS/arch-specific Runtime binaries.

## Decision

Repository versions remain independent SemVer.

Product releases are aligned by a machine-readable release train manifest. The
manifest is the product compatibility unit.

The manifest schema is owned by `skenion-contracts`.

Product train manifest instances are owned by the root `skenion` repository
under:

```text
releases/trains/<train-id>.json
```

The release train manifest must include:

- product train id
- Contracts npm/crate versions
- Runtime crate version
- Runtime binary artifacts by target, with checksums
- SDK npm version
- Studio web/desktop version
- Examples tag or commit
- Manual version and deploy status
- protocol baselines
- capability set
- release completion gates

Runtime release workflows must publish multi-arch binary assets in addition to
the Rust crate.

Runtime binary release asset names use:

```text
skenion-runtime-<version>-<target>.tar.gz
skenion-runtime-<version>-<target>.zip
```

Use `.zip` for Windows assets and `.tar.gz` for Unix-like assets. Each asset
must have a checksum entry in the train manifest. Studio Desktop packaging
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
packages, release tags, GitHub Release assets, or a checked-in train manifest.
PR CI may still checkout sibling branches for in-flight integration.

Manual deployment is a release completion gate. Main branch CI is not release
completion.
