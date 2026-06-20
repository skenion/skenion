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
| M04 Audio Multi-Endpoint / Clock Domain Planning | Closed | Endpoint descriptors, input/output clock domains, partition planning, explicit bridge/resample validation. |
| M05 External Clock Sources v0 | Next | MIDI Clock first, then MTC, Ableton Link, and plugin-host/DAW transport capability mapping. |
| M06 Studio Audio / Clock UI v0 | Planned | Audio endpoint and clock-domain inspection/control surfaces. |
| M07 Audio Device Format / Input Backend v0 | Planned | Actual `audio.input` backend, same-device duplex routing, device format conversion, and input latency reporting. |
| M08 Spatial Audio / Channel Layout Contract v0 | Planned | Channel layout, speaker layout, audio bus metadata, spatial source/listener/panner skeletons, and downmix/upmix policy. |
| M09 Performance / Presentation Mode v0 | Deferred | Performance-oriented presentation flow after audio/clock UI, input backend, and spatial/channel models stabilize. |

## Next Implementation Focus

M05 remains open. The first slice is `M05.1 — clock.midi-clock
contract/parser`, because the clock authority model already exists and MIDI
Clock can validate external-source snapshot handoff without driving the audio
callback directly.

M05.1 first slice:

- parse MIDI tick, start, stop, continue, and Song Position Pointer messages.
- emit `ClockState` with explicit capability and authority metadata.
- derive bar/beat only when meter configuration is available.
- keep Link, MTC, and host transport compatible with the same
  capability/authority model.
- reject designs where an external source directly drives the realtime audio
  callback.

M05 is not complete until Runtime consumes external MIDI source snapshots
without coupling MIDI input to the realtime audio callback.

M05.1 contract/parser artifacts are released in
`skenion-contracts-v0.31.0`, with examples MIDI Clock parser fixtures merged on
`skenion-examples` `main`.

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
