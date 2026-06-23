# Compatibility Matrix Manifests

This directory contains product compatibility matrix manifests owned by the
`skenion/skenion` hub.

The hub is the source of truth for product promotion state: Contracts line,
protocol baselines, artifact inventory, verification gates, and release
completion reporting. The manifest shape is owned by the flat
`skenion.release-train` schema in `skenion-contracts`; the hub must not invent a
second manifest shape. Reusable workflow implementation belongs in
`skenion/skenion-ci`; it should not own product compatibility state.

Each manifest must also record the release authority model in
`release-authority`. The authority model is:

- Release Please owns each repository's natural version, changelog, release PR,
  tag, and GitHub Release flow
- the checked-in hub manifest plus verification evidence is the product
  promotion authority
- the hub verifies released artifacts and promotes compatibility matrices; it
  does not dispatch Release Please with forced `release-as` train versions
- component releases may be public but unpromoted until matrix verification
  passes

The product promotion state must use this order:

```text
component_released -> artifacts_collected -> checksums_verified -> examples_conform -> docs_deployed -> promoted
```

State may only advance monotonically. A later state cannot be `passed` while an
earlier state is `pending` or `failed`. A `waived` state must have a matching
`release-authority.waivers.<state>` record with `reason`, `approved-by`, and
`approved-at`. `promoted: passed` additionally requires every required
`release-gates` entry to be `passed` or explicitly `waived`.

## Lifecycle

1. Create or update the draft manifest before release work starts.
2. Release components through their repository-local Release Please and release
   workflows.
3. Collect released artifact evidence in dependency order.
4. Record released artifact names, URLs, checksums, tags, and deployment state.
5. Verify every release gate from published artifacts, not local worktrees.
6. Mark the manifest complete only after every blocking gate has passed.

The v0 component order is:

1. Contracts.
2. Runtime.
3. SDK.
4. Studio.
5. Examples.
6. Docs.

Contracts are the compatibility seed. Runtime, SDK, Studio, Examples, and Docs
must declare the supported Contracts `0.minor` line/range and consume released
registries, release tags, GitHub Release assets, or this checked-in manifest.
Release and publish jobs must not consume sibling branches, `main`, or stale
hard-coded dependency tags.

Contracts `0.45` is the first compatibility-matrix line for the corrected
release model. The dangling 0.44 state must not be repaired with tag surgery,
forced train rewrites, or local publish compensation.

Contracts package/crate compatibility uses the `0.minor` SemVer range for the
declared line, but exact graph, project, extension, Runtime HTTP, and protocol
discriminator fields remain exact current-version checks.

## Manifest Requirements

Each manifest should use the Contracts release-train schema and include:

- flat `schema`, `schema-version`, `train-id`, and `train-version` fields
- `release-authority` with the hub promotion role, Release Please role,
  repository workflow guardrails, and explicit promotion state
- Contracts line and SemVer range
- exact released component versions, tags, assets, and supported Contracts
  ranges
- current protocol baselines
- `capability-set` with schema-approved Runtime, Studio, marketplace, and
  Manual capability areas
- Runtime and Studio multi-arch artifact placeholders or released artifacts
- checksums for every released binary/package asset
- release-blocking and preview target tiers
- `release-gates` with pending, passed, failed, or waived state

## Release Gates

A promoted matrix is not complete when main branch CI is green. It is complete
only when the manifest verifies all blocking gates:

- Contracts npm package and Rust crate published for the Contracts line.
- Runtime blocking-tier binary assets published with supported Contracts line
  evidence.
- Runtime binary checksums recorded and verified.
- SDK npm package published with supported Contracts range evidence.
- Studio web/desktop artifacts published and verified against Runtime sidecars.
- Examples conformance tag or commit verifies against released artifacts.
- Manual metadata and GitHub Pages deployment match the promoted matrix.

Required asset, checksum, and smoke gates may list only release-blocking target
artifacts. Preview-tier target evidence must stay visible in non-required gates,
such as `github-release-assets.runtime-preview`,
`github-release-assets.studio-preview`, `preview-checksum-verification`, or
target smoke rows with `required: false`.

Registry and release publishing must run only from GitHub Actions release
workflows. Local machines may run dry-run checks, but must never upload npm
packages, crates, Runtime binaries, Studio packages, or Manual releases.
Registry packages are only for importable libraries; Runtime, Studio, Examples,
Manual, and CI distribution surfaces are release assets, tags, deployments, or
workflow refs.
