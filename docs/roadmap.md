# Roadmap

This roadmap orders the first public Skenion repositories by contract risk.
The goal is to stabilize the shared language before building a large Studio UI.

## Milestone Baseline

The GitHub roadmap is tracked with repository milestones across the Skenion
family. The current baseline is:

| Milestone | Status | Scope |
| --- | --- | --- |
| M01 Builtin Surface Cleanup / Object Taxonomy | Closed | Canonical object taxonomy and pre-v1 cleanup of duplicate/debug builtins. |
| M02 Clock / Transport Contract v0 | Closed | Clock/transport model and object-level clock state contract. |
| M03 Audio Backend v0: Single Output CPAL | Closed | One default CPAL output and one output sample clock domain. |
| M04 Audio Multi-Endpoint / Clock Domain Planning | Current | Endpoint descriptors, input/output clock domains, partition planning, explicit bridge/resample validation. |
| M05 Runtime IO Substrate v0 | Current | Transport-neutral raw IO discovery and per-object binding contracts for MIDI, HID, Serial, and inline fixtures. |
| M06 IO Codec Contract v0 | Current | Decoder/encoder contracts that interpret raw transport frames as Skenion messages/values and encode messages/values back to transport frames. |
| M06.5 Native Runtime Extension ABI v0 | Current | Native extension ABI, package manifests, capability registration, diagnostics, and SDK authoring substrate. |
| M06.75 Graph 0.1 Subpatch / Live Help Foundation | Current | Patch libraries, `core.inlet`/`core.outlet`, live help as real patch graphs, `GraphFragmentV01`, and high-level paste semantics on the consolidated current `0.1` graph surface. |
| M06.8 Desktop Multi-Window / Runtime Session Profiles v0 | Current | Tauri desktop shell, local-managed/local-shared/remote profiles, sidecar lifecycle, and same-session multi-view editing. |
| M06.81 Graph 0.1 Active Consolidation | Current | Make the consolidated current `0.1` graph/project/patch-library documents the active editor/runtime/source-of-truth model and reject unsupported versions instead of preserving legacy import/migration paths. |
| M06.82 Realtime Collaboration / CRDT-OT Sync v0 | Current | Runtime-authoritative OT/rebase collaboration, CRDT-compatible ids, presence, operation replay, and actor-scoped undo metadata. |
| M06.85 Package Marketplace / Install UX v0 | Current | Public package/patch discovery, Stargazed ranking, install/update/remove UX, installed inventory, and package compatibility diagnostics. |
| M06.9 Product Release Train / Multi-Arch Distribution v0 | Current | Release train manifest, Runtime multi-arch binary artifacts, desktop sidecar packaging, and Manual release gates. |
| M07 Native IO Convenience Objects v0 | Planned | `midiin`, `midiout`, serial/HID IO, and generic sensor IO as convenience objects composed from IO bindings and codecs. |
| M08 Studio IO Binding UX v0 | Planned | Per-object device dropdowns, codec selection, raw monitor, and diagnostics without Runtime-global IO panels. |
| M09 Audio Device Format / Input Backend v0 | Planned | Actual `audio.input` backend, same-device duplex routing, device format conversion, and input latency reporting. |
| M10 Spatial Audio / Channel Layout Contract v0 | Planned | Channel layout, speaker layout, audio bus metadata, spatial source/listener/panner skeletons, and downmix/upmix policy. |
| M11 Performance / Presentation Mode v0 | Deferred | Performance-oriented presentation flow after Runtime sync, IO object UX, audio input, and spatial/channel models stabilize. |
| M12 Link / MTC / Host Transport Objects v0 | Planned | Ableton Link, MTC/SMPTE, and plugin-host/DAW transport modeled as explicit graph objects, not Runtime-global sources. |

## Next Implementation Focus

The current v0 foundation is stricter than the older bootstrap roadmap. These
items must be treated as foundational contracts, not optional polish:

1. Graph 0.1 subpatch/live help and `GraphFragmentV01`.
2. Current graph active editor/runtime cutover; unsupported versions are rejected.
3. Explicit Runtime session addressing and high-level paste operations.
4. Tauri desktop window/profile/sidecar substrate.
5. Runtime-authoritative realtime collaboration.
6. Package marketplace/install/update UX.
7. Product release train manifest and Runtime multi-arch binary artifacts.

The implementation order is contract-first:

```text
skenion ADRs and release policy
  -> skenion-contracts schemas/OpenAPI
  -> skenion-runtime session/paste/collaboration/package substrate
  -> skenion-studio Tauri, graph fragment UX, collaboration, marketplace
  -> skenion-sdk helpers
  -> skenion-examples conformance
  -> skenion-docs Manual
```

M06.75 through M06.9 are now the active Runtime/session, desktop, collaboration,
marketplace, and release foundation. The previous split between graph patch,
project response, view-state response, and local Studio authority is
superseded: Runtime owns the session copy of graph, object/node view state,
history, diagnostics, operation ordering, and the snapshots/events that other
clients converge on.

M06.81 is the hard consolidation point for graph contracts. New authoring,
Runtime, collaboration, marketplace, package, extension, SDK, examples, and
Manual work must use the consolidated current `0.1`
project/graph/patch-library contracts. Documents that do not match the current
`0.1` schema/protocol surface must be rejected rather than imported, migrated,
or kept as deprecated compatibility surfaces.

Foundation session scope:

- `GET /v0/sessions/{sessionId}` returns one canonical
  `RuntimeSessionSnapshot`.
- `POST /v0/sessions/{sessionId}/operations` is the forward graph/view
  operation surface. `/v0/session/project`, `/v0/session/patch`, and
  `/v0/session/view-state` are not Studio contract surfaces.
- `/v0/session` and `/v0/session/mutate` are transitional technical debt to
  remove; new work must use explicit session ids and must not add compatibility
  aliases.
- Runtime-owned view state is limited to object/node view data such as
  coordinates, size, and collapsed state. Viewport pan/zoom remains client-local.
- Graph and view mutations can be submitted atomically. Adding a node at a
  canvas position is `graphPatch.addNode + viewPatch.setNodeView` in one
  mutation.
- Dragging a node from A to B is one `viewPatch.moveNodeView` operation, one
  history entry, one undo, and one redo.
- Removing a node reconciles Runtime-owned view state. Replacing a node keeps
  the existing view state for the same node id.
- Runtime keeps an authoritative session history. Collaboration operations must
  carry actor-scoped undo metadata from v0; global history remains available as
  an audit/log surface.
- Session events stream canonical snapshots and/or ordered operation metadata
  so multiple clients can converge on Runtime-owned state.
- Runtime diagnostics are non-fatal session facts when the graph can still be
  loaded, applied, and shown.

The canonical object box model remains part of the graph/runtime foundation.
Pd-style text-entry object boxes
are user-facing objects regardless of whether the text resolves today:

- A typed object box persists as a canonical object box, not as a special
  "unresolved object" class when resolution fails.
- `objectText` is the user-entered source of truth for text-entry boxes.
- `decode`, `upload`, `preview`, `*~`, and `user.manipulator` are all object
  text. Native aliases and extension names are resolver inputs, not separate UI
  concepts.
- Runtime resolves object text to an internal implementation kind such as
  `core.video-decode`, `core.gpu-upload`, or an extension implementation.
- Resolution success/failure is reported as object resolution state and
  diagnostics. Unresolved text remains editable on the canvas with warning/error
  styling.
- Extension candidates must be namespaced, for example `user.manipulator`.
  Namespace-free unknown text remains an unresolved object box with a diagnostic.
- `core.unresolved-object` is not the target model. It should be removed before
  the v0 object-box contract stabilizes in favor of `core.object` plus
  resolution state.
- Display text prefers `objectText`, then a native alias, then the internal kind
  only as a fallback.

M06 defines codecs. A decoder maps raw transport frames into Skenion
messages/values; an encoder maps messages/values back to transport frames.
MIDI note/CC/clock parsing, serial line parsing, binary sensor packet parsing,
and HID report interpretation are codec behavior, not Runtime IO discovery.
Custom extensions should be able to provide codecs without patching Runtime
core.

M07 provides convenience objects. `midiin` and `midiout` are native convenience
objects composed from MIDI transport bindings plus MIDI decoder/encoder
contracts. Serial and HID objects follow the same pattern. Sensor support stays
generic: an Arduino temperature sensor, wind direction sensor, potentiometer, or
custom controller is a selected device plus framing plus decoder, not a
hard-coded `TemperatureDecoder` built into Runtime discovery.

M08 is the first Studio IO UX milestone. Studio should expose target device
dropdowns, transport options, codec selection, raw frame monitoring, decoded
preview, and diagnostics inside selected object/node parameter editors. It must
not add a Runtime-wide IO discovery panel or global MIDI settings.

Clock-producing sources remain explicit graph objects. A MIDI Clock object may
output `clock.state`; Link, MTC, and host transport objects move to M12. None of
these should reintroduce Runtime-global clock source APIs.

## Current Order

1. `skenion-contracts`
2. `skenion-runtime`
3. `skenion-sdk`
4. `skenion-studio`
5. `skenion-examples`
6. `skenion-docs`

## 1. Contracts

`skenion-contracts` is the source of truth for graph documents, node definition
manifests, live protocol envelopes, and HTTP surfaces.

Immediate foundation work:

- define Graph 0.1 patch libraries and `GraphFragmentV01`
- define strict current-version validators and remove import/migration helpers
- define session-addressed Runtime operations and event envelopes
- define collaboration operation, presence, causality, and undo metadata
- define package marketplace/install/update contracts
- define release train manifest and Runtime artifact metadata

The TypeScript SDK and Rust runtime should consume this repository rather than
copying schemas.

## 2. Runtime

`skenion-runtime` is the authoritative session, operation, collaboration, and
package-resolution coordinator.

Immediate foundation work:

- implement explicit session registry and remove default-session aliases
- make current `ProjectDocumentV01` and patch libraries the active session model
- implement operation envelope ingestion and event replay
- implement high-level `pasteGraphFragment` lowering
- implement Runtime-authoritative collaboration ordering/rebase
- implement package cache, installed registry, and manifest validation
- publish multi-arch Runtime binary assets

## 3. Studio

`skenion-studio` consumes Runtime-owned state and provides web/desktop user
interfaces.

Immediate foundation work:

- implement Tauri shell, window registry, and runtime profiles
- switch active editor/project state to the current `0.1` graph contract and
  reject unsupported inputs
- implement graph fragment copy/paste UX
- implement help volatile working-copy windows
- implement collaborative editing UI
- implement marketplace browser and installed package inventory
- implement desktop sidecar packaging

React Flow state remains a derived view model only.

## 4. SDK

`skenion-sdk` provides helper APIs after the underlying contract surfaces are
stable enough to wrap.

Immediate foundation work:

- graph fragment and paste helpers
- session-aware Runtime client helpers
- collaboration operation builders and reconciliation helpers
- package marketplace/install/update helpers
- release train manifest validation and consumption helpers

The SDK must stay UI-framework agnostic.

## 5. Examples

`skenion-examples` proves the contract, Runtime, Studio, and SDK with
license-clean fixtures and conformance scripts.

Immediate foundation work:

- subpatch/live-help fixtures
- graph fragment copy/paste fixtures
- realtime collaboration convergence fixtures
- package marketplace/install/update fixtures
- released-artifact conformance against train manifests

Examples must not depend on unpublished private packages for release
conformance.

## 6. Docs

`skenion-docs` publishes the public Manual after the contracts and behavior are
stable enough to document without exposing internal research.

Immediate foundation work:

- subpatch/live help Manual pages
- desktop multi-window and runtime profile Manual pages
- collaboration behavior Manual pages
- marketplace/install/update Manual pages
- release train and install artifact Manual pages
