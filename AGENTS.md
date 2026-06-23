# Codex Agent Context

GitHub milestones, issues, and the `skenion Product Release Train` org Project
(`skenion/projects/1`) are the source of truth for sequencing skenion work.
Before committing, opening PRs, or writing close keywords, check the relevant
repo milestone, issue state, and org Project item when the work is part of a
release train. Do not treat moving an org Project item as release completion;
the release matrix and artifact gates remain authoritative.

skenion v0 uses lockstep product SemVer across releasable repositories and
artifacts. If the product train is `0.55`, every package, crate, app, Runtime
sidecar asset, examples release marker, and Manual release marker in that train
must use the same product version, using registry-compatible SemVer such as
`0.55.0` where required.
The hub repository `skenion/skenion` owns product train conductor state,
release manifests, release ordering, and completion reporting. The
`skenion/skenion-ci` repository owns reusable workflow implementation.
The first v0 train default is product version `0.43.0` with `train-id: "0.43"`.
Train releases follow Contracts -> Runtime -> SDK -> Studio -> Examples ->
Docs.

skenion v0 does not support legacy, deprecated, or import-only compatibility
paths. Unsupported graph, project, node, operation, extension, package,
manifest, Runtime HTTP, or protocol versions must be rejected with structured
diagnostics. Do not add migration/import fallbacks, default-session aliases, or
deprecated compatibility surfaces as v0 product behavior.
Contracts are consolidated to `0.1` as the single current product contract.
Remove v0.2 as a separate surface and keep the current content under the `0.1`
label. Do not preserve the old v0.1 meaning as legacy compatibility.

Release and publish workflows must run through Release Please and GitHub
Actions only. During v0, Release Please PRs are conductor-dispatched with an
explicit `release-as` matching the train version. Independent automatic
per-repository Release Please authority is stale. Publish registry packages
only for importable libraries: `@skenion/contracts`, `skenion-contracts`, and
`@skenion/sdk`. Runtime binaries, Studio builds, examples, Manual pages, and
`skenion-ci` are release assets, tags, deployments, or workflow refs. Do not
publish npm packages, crates, Runtime binaries, Studio packages, or Manual
releases from a local machine.

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
