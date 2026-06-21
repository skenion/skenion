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
| M05 External Clock Sources v0 | Closed | MIDI Clock external source v0: contract/parser, fixture adapter, physical MIDI input boundary, Runtime clock source HTTP API, and compatibility smoke. |
| M06 Studio Audio / Clock UI v0 | Next | Audio endpoint and clock-domain inspection/control surfaces, starting with Studio clock source list/read/start/stop UI. |
| M07 Audio Device Format / Input Backend v0 | Planned | Actual `audio.input` backend, same-device duplex routing, device format conversion, and input latency reporting. |
| M08 Spatial Audio / Channel Layout Contract v0 | Planned | Channel layout, speaker layout, audio bus metadata, spatial source/listener/panner skeletons, and downmix/upmix policy. |
| M09 Performance / Presentation Mode v0 | Deferred | Performance-oriented presentation flow after audio/clock UI, input backend, and spatial/channel models stabilize. |
| M10 Link / MTC / Host Transport Sources v0 | Planned | Ableton Link, MTC/SMPTE, and plugin-host/DAW transport source contracts and runtime adapters. |

## Next Implementation Focus

M05 is complete for MIDI Clock external source v0. The closure scope is:

- `M05.1 — clock.midi-clock contract/parser`: parse MIDI tick, start, stop,
  continue, and Song Position Pointer messages; emit `ClockState` with explicit
  capability and authority metadata; derive bar/beat only when meter
  configuration is available.
- `M05.2 — Runtime MIDI Clock Adapter fixture/simulation mode`: store
  timestamped simulated MIDI Clock input as `ClockState` snapshots through
  `ClockSourceStore`, expose `clock-midi --simulate <fixture> --format json`,
  and keep MIDI adapter state out of the realtime audio callback.
- `M05.3 — Physical MIDI Input Adapter v0`: list MIDI input ports, open and
  close a selected port, receive raw MIDI realtime bytes, assign host monotonic
  timestamps, and feed `TimestampedMidiMessage` through `MidiClockAdapter` into
  `ClockSourceStore`.
- `M05.4 — Runtime Clock Source API v0`: promote `ClockSourceStore` from
  CLI-only state into Runtime server state and expose HTTP list/read/start/stop
  surfaces:

- `GET /v0/clock/sources`
- `GET /v0/clock/sources/{sourceId}`
- `GET /v0/clock/midi/inputs`
- `POST /v0/clock/midi/start`
- `POST /v0/clock/midi/stop`

The API keeps project open separate from external clock lifecycle: opening or
loading a project must not auto-start MIDI input. MIDI `inputPortIndex` values
are current Runtime enumeration indices, not stable device identities. Duplicate
running `sourceId` start requests return a diagnostic rather than replacing the
existing source.

M05 does not include Ableton Link, MTC/SMPTE, host transport, OSC clock, or
Studio UI. Link/MTC/host transport move to M10 so M06 can proceed with the
Runtime clock/audio state already available.

M06 is next. The first Studio slice is `M06.1 — Studio Clock Sources Panel v0`:

- consume `@skenion/contracts` `0.32.0` Runtime clock source API types.
- list/read clock source snapshots and MIDI input descriptors.
- start/stop MIDI clock sources through explicit Runtime API actions only.
- show field authority badges rather than hiding derived or unavailable state.
- treat no MIDI input ports as a normal no-device state.
- keep project open, Runtime connect, graph patching, and preview start
  separate from MIDI source start.

M06 UI surface policy:

- Inspect is an open/close side panel mode for one selected target at a time:
  node, edge, or builtin help. It should not host Runtime clock source
  list/start/stop controls.
- Runtime Control is the side panel mode for explicit Runtime actions:
  connection, session, preview, telemetry, history, and Runtime clock source
  list/read/start/stop.
- Settings are persistent project or object configuration and should use a
  Dialog once a saved settings model exists. Popovers are reserved for compact
  inline choices such as enum or format selection.
- M06.1 does not add persistent MIDI source configuration, auto-start settings,
  or stable MIDI input identity storage.

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
