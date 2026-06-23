# Codex Agent Context

GitHub milestones, issues, and the `skenion Product Release Train` org Project
(`skenion/projects/1`) are the source of truth for sequencing skenion work.
Before committing, opening PRs, or writing close keywords, check the relevant
repo milestone, issue state, and org Project item when the work is part of a
release train. Do not treat moving an org Project item as release completion;
the release matrix and artifact gates remain authoritative.

skenion v0 release state is coordinated through natural component releases plus
a promoted compatibility matrix. Release Please owns each repository's natural
version, changelog, release PR, tag, and GitHub Release flow. The hub repository
`skenion/skenion` verifies and promotes compatibility matrices; it is not the
component release conductor and must not dispatch Release Please with forced
`release-as` train versions. The `skenion/skenion-ci` repository owns reusable
workflow implementation.

Component releases may be public before they are promoted as a product
compatible set. A release is product-ready only after the compatibility matrix
verifies the Contracts line/range, Contracts npm/crate versions, Runtime
version/tag/assets/checksums, SDK package version and supported Contracts range,
Studio web/desktop versions and Runtime sidecars, Docs Manual version/path,
protocol baselines, capabilities, and Examples conformance evidence. The
dangling 0.44 release state must not be repaired with tag surgery, forced train
rewrites, or local publish compensation. Contracts 0.45 is the first
compatibility-matrix line for the corrected model.
Contracts v0 compatibility is rooted in the Contracts package/crate `0.minor`
line, such as `>=0.45.0 <0.46.0` for line `0.45`; exact graph, project,
extension, Runtime HTTP, and protocol discriminator fields remain exact
current-version checks.

skenion v0 does not support legacy, deprecated, or import-only compatibility
paths. Unsupported graph, project, node, operation, extension, package,
manifest, Runtime HTTP, or protocol versions must be rejected with structured
diagnostics. Do not add migration/import fallbacks, default-session aliases, or
deprecated compatibility surfaces as v0 product behavior.
Contracts are consolidated to `0.1` as the single current product contract.
Remove v0.2 as a separate surface and keep the current content under the `0.1`
label. Do not preserve the old v0.1 meaning as legacy compatibility.

Release and publish workflows must run through Release Please and GitHub
Actions only. Release Please is repository-local release authority for
version-file, changelog, tag, and GitHub Release preparation; the hub promotes
only verified compatibility matrices. Publish registry packages only for
importable libraries: `@skenion/contracts`, `skenion-contracts`, and
`@skenion/sdk`. Runtime binaries, Studio builds, examples, Manual pages, and
`skenion-ci` are release assets, tags, deployments, or workflow refs. Do not
publish npm packages, crates, Runtime binaries, Studio packages, or Manual
releases from a local machine.

All release-state writes must happen inside GitHub Actions as well. Do not
create, edit, delete, promote, demote, or repair GitHub Releases, release
assets, tags, prerelease/draft flags, release notes, compatibility matrices,
Manual promotion state, npm packages, or crates from a local shell. This
includes `gh release edit`, `gh release upload`, `gh release delete`, manual tag
mutation, local registry publish, or ad hoc release metadata patches with a
locally exported token. Local commands may inspect state, run dry-run checks,
create normal code PRs, or trigger approved `workflow_dispatch` jobs; the
actual release mutation must run in CI with reviewed workflow code and
auditable logs.

GitHub Actions workflows that need cross-repository or release automation
credentials must use the organization Actions secret `GH_TOKEN`. Do not create
separate Release Please credentials, release-train credentials, or default
Actions-token fallbacks for release, compatibility-matrix,
artifact-verification, or promotion workflows; missing `GH_TOKEN` must fail
closed with a clear diagnostic.

Runtime IO must remain node/object-level behavior. Do not add Runtime-global
MIDI, Runtime-global clock source, or Runtime-owned semantic IO start/stop UI.
Runtime IO discovery may expose raw device descriptors and binding config for
node/object parameter editors.

## Manager, Worker, And Review Gate Defaults

Codex should operate as a manager/orchestrator on skenion work. The manager owns
sequencing, milestone and issue hygiene, PR title/body/close-keyword control,
worker assignment, integration, and final reporting. Except for trivial
documentation, context, issue, or status edits, the manager should not directly
modify code. Implementation work and follow-up fixes should be delegated to
focused worker agents, then integrated by the manager. Workers must receive a
clear ownership scope, usually specific files, modules, or repository slices,
and must be told that other agents may be editing nearby code.

Follow-up work is not an exception: if review, CI, or user feedback requires
non-trivial code changes, the manager must assign that work to a worker and send
the completed slice through a separate review gate again. The manager may run
verification and status commands, but should not directly patch non-trivial
implementation code.

Every completed worker slice needs a separate review gate before it is treated
as done. The gate should be a different expert agent from the worker. A gate
review should prioritize correctness, API cleanliness, responsibility
boundaries, readability, test coverage, CI risk, and milestone acceptance
criteria. If the gate fails, the manager must send concrete fixes back to a
worker, then run the gate again until the slice passes or a real blocker is
recorded in the issue. The manager may only make trivial documentation,
context, issue, or status corrections directly.

Default code quality requirements:

- Write code that is easy to read before it is clever.
- Follow clean-code principles: clear names, small responsibilities, explicit
  data flow, predictable control flow, and low incidental coupling.
- Do not introduce interface-based abstraction lightly. Public APIs, traits,
  generated clients, schemas, and extension points must earn their existence and
  remain small, stable, and understandable.
- Keep responsibility ownership clear. Runtime, Studio, Contracts, SDK,
  Examples, and Docs must not duplicate each other's source-of-truth roles.
- UI/UX work must be reviewed for actual workflow quality, not merely rendered
  components.

Issues and milestones are the operating ledger. When work discovers new debt,
missing scope, or a design risk, record it on the relevant GitHub issue or open
a properly milestoned issue before burying it in local context. Close issues
only when the repository-specific acceptance criteria are genuinely complete.
Use `Refs` for partial or cross-repo work and `Closes` only for finished scope.
