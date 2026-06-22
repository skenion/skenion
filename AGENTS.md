# Codex Agent Context

GitHub milestones and issues are the source of truth for sequencing Skenion
work. Before committing, opening PRs, or writing close keywords, check the
relevant repo milestone and issue state.

Skenion v0 uses lockstep product SemVer across releasable repositories and
artifacts. If the product train is `0.55`, every package, crate, app, Runtime
sidecar asset, examples release marker, and Manual release marker in that train
must use the same product version, using registry-compatible SemVer such as
`0.55.0` where required.

Skenion v0 does not support legacy, deprecated, or import-only compatibility
paths. Unsupported graph, project, node, operation, extension, package,
manifest, Runtime HTTP, or protocol versions must be rejected with structured
diagnostics. Do not add migration/import fallbacks, default-session aliases, or
deprecated compatibility surfaces as v0 product behavior.

Release and publish workflows must run through Release Please and GitHub
Actions only. Do not publish npm packages or crates from a local machine.

Runtime IO must remain node/object-level behavior. Do not add Runtime-global
MIDI, Runtime-global clock source, or global IO discovery UI/API.
