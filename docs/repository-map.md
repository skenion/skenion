# Repository Map

Skenion uses multiple public repositories because the runtime, editor, protocol,
SDK, examples, and CI rules have different release cadences and stability
requirements.

## Immediate Repositories

### `skenion`

Project hub.

Owns:

- architecture notes
- RFCs and ADRs
- release policy
- repository boundaries
- compatibility policy
- roadmap
- contributor-facing project rules

Does not own product source code.

### `skenion-contracts`

Contract source of truth.

Owns:

- Protobuf definitions for live runtime control
- JSON Schema for persisted graph/project files
- OpenAPI definitions for HTTP surfaces
- generated TypeScript protocol package
- generated Rust protocol crate
- golden fixtures
- cross-language conformance tests
- compatibility and evolution rules

This repository is the shared contract between TypeScript and Rust. It is not a
general-purpose utility package.

### `skenion-runtime`

Rust native runtime.

Owns:

- graph compiler
- runtime IR
- scheduler
- renderer
- output targets
- preview window
- control server
- telemetry source
- asset cache integration
- plugin host
- CLI and native release artifacts

Runtime internals should remain in one Cargo workspace until there is a real
external-consumer reason to split them.

### `skenion-studio`

Browser editor, controller, and viewer.

Owns:

- graph editor UI
- parameter panels
- timeline and preset UI
- preview panel
- logs and telemetry views
- diagnostics and runtime connection UX
- Storybook and UI documentation

Frontend UI should be built primarily on Mantine.

### `skenion-sdk`

TypeScript SDK.

Owns:

- runtime connection lifecycle
- transport abstraction
- reconnect behavior
- command APIs
- capability negotiation helpers
- protocol envelope helpers

The SDK should not depend on React, Mantine, or editor-specific UI code.

### `skenion-examples`

Examples and compatibility samples.

Owns:

- demo graph files
- minimal project fixtures
- SDK usage examples
- runtime/editor compatibility examples
- public sample assets with clear licenses

Examples must not depend on unpublished private packages.

### `skenion-ci`

Skenion-specific CI and release automation.

Owns:

- reusable GitHub Actions workflows
- composite actions
- Release Please wrappers
- Rust CI templates
- TypeScript CI templates
- protocol lint and conformance templates
- publish workflows

Use `skenion-ci` instead of an org-level `.github` repository so the automation
scope stays product-specific.

## Repositories To Add Later

Create these only after their responsibility is proven:

- `skenion-session` for collaboration, project state, deployment, and runtime
  registry services
- `skenion-agent` for local device discovery and runtime orchestration
- `skenion-cloud` for hosted accounts, sync, and remote project services
- `skenion-integrations-*` for hardware or venue-specific integrations
- `skenion-pack-*` for optional asset, shader, and node packs
- `skenion-sdk-rust` only if a higher-level Rust client SDK emerges beyond the
  generated protocol crate

## Anti-Boundaries

Do not create these as top-level repositories early:

- `skenion-common`
- `skenion-utils`
- `skenion-core`
- `skenion-graph`
- `skenion-renderer`
- `skenion-scheduler`

Shared code must have a named contract and real consumers. Runtime internals
belong inside `skenion-runtime` until external use justifies extraction.
