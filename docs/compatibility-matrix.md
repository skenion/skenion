# Compatibility Matrix

This matrix records the current source-of-truth boundaries for graph, node, and
runtime compatibility. It exists to keep `skenion-contracts`, `skenion-examples`,
`skenion-studio`, and `skenion-runtime` from drifting independently.

## Current Baseline

| Surface | Current baseline | Owner |
| --- | --- | --- |
| Graph document schema | `skenion.graph` `0.1.0` | `skenion-contracts/json-schema/graph/v0.1/graph.schema.json` |
| View state schema | `skenion.view-state` `0.1.0` | `skenion-contracts/json-schema/view/v0.1/view-state.schema.json` |
| Project document schema | `skenion.project` `0.1.0` | `skenion-contracts/json-schema/project/v0.1/project.schema.json` |
| Node definition schema | `skenion.node.definition` `0.1.0` | `skenion-contracts/json-schema/node/v0.1/node-definition.schema.json` |
| Graph patch schema | `skenion.graph.patch` `0.1.0` | `skenion-contracts/json-schema/graph/v0.1/patch.schema.json` |
| Built-in node definitions | `builtins/v0.1` | `skenion-contracts/builtins/v0.1/builtins.manifest.json` and `skenion-contracts/builtins/v0.1/nodes/*.node.json` |
| Built-in node help | `skenion.node.help` `0.1.0` plus help graphs | `skenion-contracts/builtins/v0.1/help/*.help.json` and `skenion-contracts/help/v0.1/nodes/*.help.graph.json` |
| Typed control routing | Object-owned `sendName` / `receiveName` on semantic value/control objects | `skenion-contracts/builtins/v0.1` plus `skenion-contracts/docs/control-routing.md` |
| Live preview control updates | `skenion.preview.control-state` `0.1.0` runtime-internal snapshot plus telemetry revision fields | `skenion-contracts/docs/live-preview-control-updates.md` and `skenion-contracts/openapi/runtime-http.v0.yaml` |
| External clock source state | `ClockStateV01` field authority plus MIDI Clock tick/start/stop/continue/SPP parser, `clock.midi-clock` builtin, examples parser fixtures, runtime fixture snapshots, the physical MIDI input boundary, and Runtime HTTP clock source list/read/start/stop APIs. M05 remains open while later external-clock closure scope is decided. | `skenion-contracts/packages/ts/src/clock.ts`, `skenion-contracts/packages/rust/src/v0_1/clock.rs`, `skenion-contracts/openapi/runtime-http.v0.yaml`, `skenion-contracts/builtins/v0.1/nodes/clock.midi-clock.node.json`, `skenion-examples/compatibility/v0.1/clock-midi-fixtures`, `skenion-examples/compatibility/v0.1/runtime-midi-clock-fixtures`, `skenion-examples/scripts/smoke-runtime-clock-source-api.sh`, and `skenion-runtime` MIDI Clock adapter / clock source API |
| Audio clock-domain planning | `AudioDeviceDescriptorV01`, `AudioClockDomainV01`, `AudioGraphPartitionV01`, `AudioClockBridgePlanV01` | `skenion-contracts/docs/audio-clock-domain-contract.md` and `skenion-runtime` audio DSP planner |
| Runtime HTTP API | `runtime-http.v0` | `skenion-contracts/openapi/runtime-http.v0.yaml` |

## Project Documents and View State

`GraphDocument` remains the runtime/execution graph. It stores nodes, ports,
params, edges, and graph revision. It must not store Studio layout, viewport,
panel layout, selection, or collapsed UI state.

`ViewState` is Studio-owned layout state. v0.1 stores canvas node positions and
viewport. Node drag and viewport pan/zoom update `viewState` only:

```text
node drag or viewport pan
  -> viewState change
  -> no graph patch
  -> graph revision unchanged
  -> runtime session sync state unchanged
```

`ProjectDocument` stores `metadata`, `graph`, and `viewState` together and is
the user-facing file format for `.skenion.json`. Opening a project replaces the
local graph/view state and clears pending runtime patch/session UI state, but it
does not automatically load Runtime. The user must explicitly use Load Current
Graph after connecting Runtime.

Graph-only import/export stays separate:

```text
Save Project  -> graph + viewState + metadata
Open Project  -> graph + viewState
Export Graph  -> graph only
Import Graph  -> graph only, generated default viewState
```

Help graph viewer remains read-only. Open as New Graph copies a help graph into
an editable graph and generates a default view state for that copy.

## Verified Releases

| Repository | Release / branch | Compatibility note |
| --- | --- | --- |
| `skenion-contracts` | `skenion-contracts-v0.32.0` | Publishes audio endpoint descriptors, stream config request/resolution, audio clock domains, graph partitions, bridge/resample planning contracts, canonical audio builtins, the `clock.midi-clock` contract/parser first slice, and Runtime clock source API request/response contracts. |
| `skenion-runtime` | `skenion-runtime-v0.34.0` | Plans audio endpoints and clock-domain bridge requirements, exposes the `audio-plan` CLI, runs simulated and physical MIDI Clock adapter paths, and serves Runtime clock source list/read/input/start/stop APIs without coupling them to the audio callback. |
| `skenion-examples` | `main` after Runtime clock source API smoke merge | Contains compatibility fixtures and runtime smoke coverage for same-domain audio routing, explicit bridge/resample routing, rejected independent-domain crossing without a bridge, simulated MIDI Clock snapshots, no-device MIDI input smoke, and Runtime clock source HTTP API smoke. |
| `skenion-studio` | `skenion-studio-v0.27.0` | Renders Max-style object controls and keeps runtime control interactions separate from graph patching. |

## Canonical Data Kinds

Use namespaced data kinds in persisted graph node snapshots and node
definition manifests.

| Concept | Canonical data kind |
| --- | --- |
| Float value | `number.float` |
| Integer value | `number.int` |
| Unsigned integer value | `number.uint` |
| Bang event | `event.bang` |
| Video asset resource | `asset.video` |
| Video frame stream | `video.frame` |
| GPU texture resource | `gpu.texture2d` |
| Color value | `color` |

## Typed Control Channels

Typed named routing belongs to the object that emits or receives the value.
Dedicated `core.send-*` and `core.receive-*` routing nodes are not part of the
current builtin contract.

Objects publish channels when they emit and have a non-empty `sendName`.
Compatible objects with matching `receiveName` can update their runtime control
state from that channel:

```text
core.float(widget=slider, sendName: speed)
  -> channel number.float:speed
  -> core.float(widget=slider, receiveName: speed)
  -> render.fullscreen-shader.speed

core.bool(widget=toggle, sendName: enabled)
  -> channel boolean:enabled
  -> core.bool(widget=toggle, receiveName: enabled)
  -> render.fullscreen-shader.enabled

core.bang(sendName: reset)
  -> channel event.bang:reset
  -> core.message(receiveName: reset)
```

`core.float`, `core.int`, `core.uint`, `core.bool`, `core.color`,
`core.string`, `core.message`, `core.bang`, `core.comment`, and `core.panel`
own their routing params where
applicable. Runtime interaction with these nodes sends
`/v0/session/control/event` requests and updates runtime control state; it must
not create graph patches. Editing labels, ranges, names, or defaults remains
graph editing.

Pre-v1 cleanup: value objects no longer expose separate `bang` or `set` input
ports. `bang` and `set` are `ControlMessage` selectors handled by the hot
`in` inlet; value objects use `in` / `cold` / `value`, `core.bang` uses
`in` / `out`, and `core.message` uses `in` / `out`.

When local preview is running, runtime control events can update the preview
control-state snapshot and telemetry `controlRevision` /
`previewControlRevision` fields without restarting preview. Graph patches,
shader source/interface edits, and render output changes still mark preview
graph state stale and require restart.

Representation names such as `f32`, `f16`, `i8`, `u8`, and `rgba8unorm` are
storage/transport representation metadata, not semantic data kinds. Newly
created documents and fixtures must use `number.float`, `number.int`,
`number.uint`, `boolean`, and `color` as the semantic value data kinds.

## Built-in Node Rules

- `skenion-contracts` owns canonical built-in node manifests.
- `skenion-studio` consumes `builtinNodeDefinitionsV01` from `@skenion/contracts`.
- `skenion-examples` may keep fixture copies, but CI must structurally audit
  them against `skenion-contracts/builtins/v0.1/builtins.manifest.json` and
  `skenion-contracts/builtins/v0.1/nodes`.
- `skenion-runtime` validates and plans canonical examples from
  `skenion-examples`.
- Product-facing render cables may display as `render.frame`; the low-level
  v0.1 stored resource type remains `resource<gpu.texture2d>` until a later
  persisted schema changes that contract.
- Every new builtin node must include node definition, compact help metadata,
  and a valid help graph in the same PR.
- Studio must consume `builtinNodeHelpV01` and `builtinNodeHelpGraphsV01` from
  `@skenion/contracts`; it must not keep a separate hand-written help registry.

## Audio Clock Domains

Audio endpoint clocks are explicit planning metadata. `audio.output` owns an
audio device sample clock for its realtime DSP subgraph, and `audio.input`
represents an input endpoint with its own clock-domain authority. Matching
sample rates are not enough to prove a shared clock domain.

Direct `signal.audio` routes are valid only when the planner can resolve the
source and target endpoint path to the same audio clock domain. Independent
input/output domains require an explicit `audio.clock-bridge` or
`audio.resample` node:

```text
audio.input(clockDomain: device:aggregate-a).left
  -> audio.output(clockDomain: device:aggregate-a).left
  -> direct route

audio.input(clockDomain: device:input-clock).left
  -> audio.clock-bridge.in
  -> audio.clock-bridge.out
  -> audio.output(clockDomain: device:output-clock).left

audio.input(clockDomain: device:input-clock).left
  -> audio.output(clockDomain: device:output-clock).left
  -> invalid without bridge/resample
```

`audio.clock-bridge` and `audio.resample` are planning/validation boundary
nodes in the current baseline. They do not imply multi-device realtime I/O yet.
The audio callback remains realtime-safe: it must not access graph/session/UI,
HTTP, file I/O, allocation-heavy code paths, or blocking locks.

## Learning Surfaces

Learning surfaces are intentionally separate from compatibility fixtures.

| Surface | Owner | Purpose |
| --- | --- | --- |
| Builtin help metadata | `skenion-contracts` | Inspector/palette help text and node behavior summary |
| Builtin help graphs | `skenion-contracts` | Small read-only example patches for each builtin node |
| Tutorial manifest and graphs | `skenion-examples` | User-facing learning paths across multiple nodes |
| Help graph viewer | `skenion-studio` | Read-only graph display and "Open as New Graph" copy flow |

Help graphs must be valid `skenion.graph` `0.1.0` documents. Tutorial graphs
may intentionally include shader analysis errors only when their manifest lists
the expected diagnostics.

## Compatibility Checks

Required cross-repository checks:

- contracts validate built-in manifests and export them from the TypeScript
  package.
- examples audit fixture node manifests, graph node snapshots, project payloads,
  and graph patches against contracts builtins.
- studio tests prove its registry IDs and render ports match contracts builtins,
  and that newly created sample graphs store semantic value data kinds rather
  than representation names.
- contracts own `ShaderInterfaceV01`, `ShaderDiagnosticV01`, and
  `replaceNodeInterface`. Shader input parsing is part of the contract surface,
  not a Studio-only convention.
- `render.fullscreen-shader` builtins provide the stable `out` port. Individual
  graph node instances own annotation-generated input ports after Studio syncs
  the analyzed interface.
- studio analyzes WGSL `@skenion.uniform` annotations and queues
  `replaceNodeInterface` graph patches through Sync Inputs.
- runtime generates the WGSL support header and dynamic uniform layout from the
  analyzed shader interface.
- runtime tests and CI smoke validate canonical dynamic shader uniform projects:

```text
core.float.value
  -> render.fullscreen-shader.speed

core.bool.value
  -> render.fullscreen-shader.enabled

core.int.value
  -> render.fullscreen-shader.iterations

core.color.value
  -> render.fullscreen-shader.tint

render.fullscreen-shader.out
  -> render.output.in
```

The object routing panel demo validates this additional path:

```text
core.float(widget=slider, sendName: speed)
  -> channel number.float:speed

core.float(widget=slider, receiveName: speed).value
  -> render.fullscreen-shader.speed

core.bool(widget=toggle, sendName: enabled)
  -> channel boolean:enabled

core.bool(widget=toggle, receiveName: enabled).value
  -> render.fullscreen-shader.enabled
```

The live preview control smoke validates that slider/toggle widgets on
`core.float` and `core.bool` update typed channels and preview control revision
while preview `stale` remains false.

The audio clock-domain smoke validates:

```text
same audio clock domain
  -> direct route

independent audio clock domains + audio.clock-bridge
  -> planned clock bridge route

independent audio clock domains + audio.resample
  -> planned resample route

independent audio clock domains without bridge/resample
  -> validation error from audio DSP planner
```

Dynamic shader input parsing is supported through WGSL `@skenion.uniform`
annotations. GLSL, texture inputs, asset loading, script nodes, and multi-pass
rendering remain out of scope.

Run the hub-level smoke script before merging compatibility-affecting changes:

```bash
bash scripts/smoke-compatibility.sh
```
