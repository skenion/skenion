# Release Train Manifests

This directory contains product release train manifests owned by the
`skenion/skenion` hub conductor.

The hub is the source of truth for product state: train identity, component
order, protocol baselines, artifact inventory, release gates, and release
completion reporting. The manifest shape is owned by the flat
`skenion.release-train` schema in `skenion-contracts`; the hub must not invent a
second manifest shape. Reusable workflow implementation belongs in
`skenion/skenion-ci`; it should not own product train state.

Each manifest must also record the release authority model in
`release-authority`. The authority model is:

- the checked-in hub manifest plus `.github/workflows/release-train.yml` is the
  product train authority
- Release Please may prepare release PRs, but it is not independent authority
  for train tags, GitHub releases, artifacts, registry packages, or Manual
  promotion
- repository workflows must run from conductor-dispatched steps that identify
  the manifest row and expected source commit for the component being released
- `contracts`, `runtime`, `sdk`, and `studio` rows must include
  `expected-source-commit` as a full 40-character Git commit SHA before publish
  dispatch

The product train state must use this order:

```text
prepared_pr -> merged_release_commit -> tag_exists -> github_release_exists -> artifacts_uploaded -> registry_package_exists -> docs_deployed -> verified
```

State may only advance monotonically. A later state cannot be `passed` while an
earlier state is `pending` or `failed`. A `waived` state must have a matching
`release-authority.waivers.<state>` record with `reason`, `approved-by`, and
`approved-at`. `verified: passed` additionally requires every required
`release-gates` entry to be `passed` or explicitly `waived`.

## Lifecycle

1. Create or update the draft manifest before release work starts.
2. Prepare the train from the conductor workflow in dry-run mode.
3. Release components in dependency order.
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

Contracts are the train seed. Runtime, SDK, Studio, Examples, and Docs must
consume the exact released train version from registries, release tags, GitHub
Release assets, or this checked-in manifest. Release and publish jobs must not
consume sibling branches, `main`, broad semver ranges, or stale hard-coded
dependency tags.

## Manifest Requirements

Each manifest should use the Contracts release-train schema and include:

- flat `schema`, `schema-version`, `train-id`, and `train-version` fields
- `release-authority` with the hub conductor, Release Please role, repository
  workflow guardrails, and explicit train state
- lockstep component versions
- `expected-source-commit` for each component that receives a Release Please
  publish dispatch
- current protocol baselines
- `capability-set` with schema-approved Runtime, Studio, marketplace, and
  Manual capability areas
- Runtime and Studio multi-arch artifact placeholders or released artifacts
- checksums for every released binary/package asset
- release-blocking and preview target tiers
- `release-gates` with pending, passed, failed, or waived state

The first v0 train is `0.43.0` with `train-id: "0.43"`.

## Release Gates

A train is not complete when main branch CI is green. It is complete only when
the manifest verifies all blocking gates:

- Contracts npm package and Rust crate published at the train version.
- Runtime blocking-tier binary assets published at the train version.
- Runtime binary checksums recorded and verified.
- SDK npm package published at the train version.
- Studio web/desktop artifacts published at the train version and verified
  against Runtime sidecars.
- Examples conformance tag or commit verifies against released artifacts.
- Manual metadata and GitHub Pages deployment match the train.

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
