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
| M06 Runtime-Authoritative Session Protocol / Studio Sync v0 | Current | Runtime owns canonical session state, graph/view mutations, global history, diagnostics, and multi-client snapshot events. |
| M07 Studio Inspect / Logs / Runtime Surface Split v0 | Next | Client logs, Runtime diagnostics, inspector surfaces, and clear Studio-vs-Runtime ownership after session sync cleanup. |
| M08 IO Codec Contract v0 | Next | Decoder/encoder contracts that interpret raw transport frames as Skenion messages/values and encode them back to transport frames. |
| M09 Native IO Convenience Objects v0 | Planned | `midiin`, `midiout`, serial/HID IO, and generic sensor IO as convenience objects composed from IO bindings and codecs. |
| M10 Studio IO Binding UX v0 | Planned | Per-object device dropdowns, codec selection, raw monitor, and diagnostics without Runtime-global IO panels. |
| M11 Audio Device Format / Input Backend v0 | Planned | Actual `audio.input` backend, same-device duplex routing, device format conversion, and input latency reporting. |
| M12 Spatial Audio / Channel Layout Contract v0 | Planned | Channel layout, speaker layout, audio bus metadata, spatial source/listener/panner skeletons, and downmix/upmix policy. |
| M13 Performance / Presentation Mode v0 | Deferred | Performance-oriented presentation flow after Runtime sync, IO object UX, audio input, and spatial/channel models stabilize. |
| M14 Link / MTC / Host Transport Objects v0 | Planned | Ableton Link, MTC/SMPTE, and plugin-host/DAW transport modeled as explicit graph objects, not Runtime-global sources. |

## Next Implementation Focus

M06 is now the active Runtime/session foundation. The previous split between
graph patch, project response, view-state response, and local Studio authority
is superseded: Runtime owns the session copy of graph, object/node view state,
history, diagnostics, and the snapshots that other clients converge on.

M06 scope:

- `GET /v0/session` returns one canonical `RuntimeSessionSnapshot`.
- `POST /v0/session/mutate` is the only Studio-used graph/view mutation
  surface. `/v0/session/project`, `/v0/session/patch`, and
  `/v0/session/view-state` are not Studio contract surfaces.
- Runtime-owned view state is limited to object/node view data such as
  coordinates, size, and collapsed state. Viewport pan/zoom remains client-local.
- Graph and view mutations can be submitted atomically. Adding a node at a
  canvas position is `graphPatch.addNode + viewPatch.setNodeView` in one
  mutation.
- Dragging a node from A to B is one `viewPatch.moveNodeView` operation, one
  history entry, one undo, and one redo.
- Removing a node reconciles Runtime-owned view state. Replacing a node keeps
  the existing view state for the same node id.
- Undo/redo is global Runtime history for v0. Selective per-client undo is out
  of scope.
- Session events stream full canonical snapshots so multiple clients can keep a
  nearly synchronized view of Runtime-owned state.
- Runtime diagnostics are non-fatal session facts when the graph can still be
  loaded, applied, and shown.

M06.1 defines the canonical object box model. Pd-style text-entry object boxes
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

M07 turns those Runtime facts into Studio surfaces: logs, inspector diagnostics,
object resolution status, and clear Runtime-vs-client ownership cues. It should
not reintroduce local graph/view authority in Studio.

M08 defines codecs. A decoder maps raw transport frames into Skenion
messages/values; an encoder maps messages/values back to transport frames.
MIDI note/CC/clock parsing, serial line parsing, binary sensor packet parsing,
and HID report interpretation are codec behavior, not Runtime IO discovery.
Custom extensions should be able to provide codecs without patching Runtime
core.

M09 provides convenience objects. `midiin` and `midiout` are native convenience
objects composed from MIDI transport bindings plus MIDI decoder/encoder
contracts. Serial and HID objects follow the same pattern. Sensor support stays
generic: an Arduino temperature sensor, wind direction sensor, potentiometer, or
custom controller is a selected device plus framing plus decoder, not a
hard-coded `TemperatureDecoder` built into Runtime discovery.

M10 is the first Studio IO UX milestone. Studio should expose target device
dropdowns, transport options, codec selection, raw frame monitoring, decoded
preview, and diagnostics inside selected object/node parameter editors. It must
not add a Runtime-wide IO discovery panel or global MIDI settings.

Clock-producing sources remain explicit graph objects. A MIDI Clock object may
output `clock.state`; Link, MTC, and host transport objects move to M14. None of
these should reintroduce Runtime-global clock source APIs.

## Current Order

1. `skenion-contracts`
2. `skenion-sdk`
3. `skenion-runtime`
4. `skenion-examples`
5. `skenion-studio`

## 1. Contracts

`skenion-contracts` is the source of truth for graph documents, node definition
manifests, live protocol envelopes, and HTTP surfaces.

Immediate work:

- release the current v0.1 graph and node definition contract
- expose a TypeScript package for schema constants and validation helpers
- keep `schemaVersion: "0.0.0"` graph files as the frozen legacy baseline
- keep v0.1 graph documents as patch wiring documents, not runtime schedules

The TypeScript SDK and Rust runtime should consume this repository rather than
copying schemas.

## 2. SDK

`skenion-sdk` starts before Studio because node authoring and manifest
normalization need to be stable before a visual editor depends on them.

Immediate work:

- provide `defineNode()` for script and plugin node manifests
- provide `t.*` type builders that emit v0.1 `flow + dataKind + constraints`
- validate generated manifests through `@skenion/contracts`
- expose only the v0.1 script lifecycle hooks: `onInit`, `onInput`,
  `onEvent`, and `onDispose`

The SDK must stay UI-framework agnostic.

## 3. Runtime

`skenion-runtime` should load and validate the same node definition manifests
that the SDK emits.

Immediate work:

- load built-in node manifests
- reject unsupported permissions and incompatible graph edges
- compile graph documents into runtime internals without persisting scheduler
  details back into the graph document
- expose MVP control over WebSocket Protobuf envelopes and HTTP diagnostics

## 4. Examples

`skenion-examples` should prove the contract and SDK with small, public,
license-clean projects.

Immediate work:

- minimal value graph
- bang/event trigger graph
- video asset decode and GPU upload graph
- audio analysis signal graph
- script node authoring example

Examples must not depend on unpublished private packages.

## 5. Studio

`skenion-studio` comes after the contract, SDK, and runtime loader have enough
shape to avoid baking temporary model assumptions into the editor.

Initial Studio direction:

- React + TypeScript + Mantine
- `@xyflow/react` for the canvas interaction layer
- Skenion Graph v0.1 as the saved project format
- React Flow state as a derived view model only
- edge validation delegated to the Skenion compatibility validator

Auto-layout can add ELK.js later when the graph model and canvas needs are
clearer.
