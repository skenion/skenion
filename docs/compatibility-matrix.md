# Compatibility Matrix

This matrix records the current source-of-truth boundaries for graph, node, and
runtime compatibility. It exists to keep `skenion-contracts`, `skenion-examples`,
`skenion-studio`, and `skenion-runtime` aligned through verified compatibility
matrices.

Contracts v0 compatibility is rooted in the Contracts package/crate line, not
in equal product versions. A v0 Contracts line is `0.minor`: supporting `0.45`
means supporting `>=0.45.0 <0.46.0`. Patch releases inside a Contracts line must
remain backward compatible. Breaking Contracts schema, wire, or public API
changes require a new line such as `0.46.0`.

skenion v0 has no legacy or deprecated compatibility mode. Each surface accepts
only the current exact schema/protocol version listed here. Older graph,
project, node, operation, extension, package, manifest, Runtime HTTP, or
protocol versions must be rejected with structured diagnostics.

## Current Baseline

| Surface | Current baseline | Owner |
| --- | --- | --- |
| Graph document schema | Current exact: `skenion.graph` `0.1.0`; reject all other versions | `skenion-contracts/json-schema/graph/v0.1/graph.schema.json` |
| View state schema | `skenion.view-state` `0.1.0` | `skenion-contracts/json-schema/view/v0.1/view-state.schema.json` |
| Project document schema | Current exact: `skenion.project` `0.1.0`; reject all other versions | `skenion-contracts/json-schema/project/v0.1/project.schema.json` |
| Node definition schema | Current exact: `skenion.node.definition` `0.1.0`; reject all other versions | `skenion-contracts/json-schema/node/v0.1/node-definition.schema.json` |
| Graph patch / operation schema | Current Runtime graph target operations only; reject `skenion.graph.patch` `0.1.0` | `skenion-contracts/openapi/runtime-http.v0.yaml` |
| Built-in node definitions | Current consolidated `0.1` definitions only; stale pre-consolidation copies are removal debt | `skenion-contracts` builtins |
| Built-in node help | Current consolidated `0.1` patch definitions/live-help graphs only; stale pre-consolidation help graphs are removal debt | `skenion-contracts` help patch definitions |
| Typed control routing | Object-owned `sendName` / `receiveName` on semantic value/control objects | `skenion-contracts/builtins/v0.1` plus `skenion-contracts/docs/control-routing.md` |
| Live preview control updates | `skenion.preview.control-state` `0.1.0` runtime-internal snapshot plus telemetry revision fields | `skenion-contracts/docs/live-preview-control-updates.md` and `skenion-contracts/openapi/runtime-http.v0.yaml` |
| External clock source state | Object-owned clock state and MIDI Clock parser behavior only. Runtime-global clock-source list/read/start/stop APIs are removal debt and must not be preserved as compatibility. Link, MTC/SMPTE, and host transport are M12 scope as explicit graph objects. | `skenion-contracts` clock contracts and `skenion-runtime` MIDI Clock adapter |
| Audio clock-domain planning | `AudioDeviceDescriptorV01`, `AudioClockDomainV01`, `AudioGraphPartitionV01`, `AudioClockBridgePlanV01` | `skenion-contracts/docs/audio-clock-domain-contract.md` and `skenion-runtime` audio DSP planner |
| Runtime HTTP API | `runtime-http.v0` canonical session snapshot + mutation protocol | `skenion-contracts/openapi/runtime-http.v0.yaml` |

## Project Documents and View State

`GraphDocument` remains the runtime/execution graph. It stores nodes, ports,
params, edges, and graph revision. It must not store viewport, panel layout, or
selection state.

When a project is loaded into Runtime, Runtime is authoritative for
`snapshot.project.graph` and Runtime-owned `snapshot.project.viewState`. In v0
that Runtime-owned view state is limited to object box/node view data such as
canvas coordinates, size, and collapsed state. The Runtime strips viewport
pan/zoom from canonical session snapshots because viewport is client-local UI
state.

Node drag changes are runtime mutations, not graph patches and not continuous
viewport sync:

```text
node drag A -> B
  -> one /v0/sessions/{sessionId}/operations request
  -> viewPatch.moveNodeView
  -> no graph patch
  -> graph revision unchanged
  -> view revision increments
  -> one runtime history entry
  -> one undo restores A, one redo restores B
```

Viewport pan/zoom stays local to each Studio client and does not send a Runtime
mutation.

`ProjectDocumentV01` stores `metadata`, a root graph, a patch library, and view
state together and is the active user-facing file format for `.skenion.json`.
Studio and Runtime must reject unsupported project/graph versions before
editing, Runtime session load, collaboration, marketplace, or package
resolution begins. Loading the current project into Runtime makes Runtime
authoritative for the session copy, and Studio thereafter reads graph, patch
library, and node view state from `RuntimeSessionSnapshot.project`.

The canonical v0 Runtime session API is session-addressed:

```text
GET /v0/sessions/{sessionId}
  -> RuntimeSessionResponse { ok, snapshot, diagnostics, report }

POST /v0/sessions/{sessionId}/operations
  -> RuntimeOperationResponse { ok, applied, conflict, snapshot, history, diagnostics }

SSE /v0/sessions/{sessionId}/events/stream
  -> RuntimeSessionEvent { sessionId, sequence, kind, snapshot, history, operation?, diagnostics }
```

`/v0/session`, `/v0/session/mutate`, and `/v0/session/events/stream` are
transitional removal debt, not compatibility promises. New clients and
contracts must use explicit session ids. `pasteGraphFragment` is a high-level
operation under `/v0/sessions/{sessionId}/operations`; it should not be
pre-lowered by Studio into unrelated low-level `addNode` and `addEdge` patches.

The removed v0 surfaces are `/v0/session/project`, `/v0/session/patch`, and
`/v0/session/view-state`. Clients must not read graph or view state from
duplicate top-level response fields.

## Object Boxes And Resolution

Text-entry object boxes are the user-facing model. A user who types `decode`,
`upload`, `preview`, `*~`, or `user.manipulator` has created an object box with
object text; they have not chosen an internal Runtime implementation class.

The current object-box target for v0 is:

```text
object box
  objectText: "decode"
  resolution.status: resolved
  resolution.kind: core.video-decode

object box
  objectText: "user.manipulator"
  resolution.status: unresolved
  diagnostics: [...]
```

Resolved implementation kinds such as `core.video-decode`,
`core.gpu-upload`, and `core.preview` are Runtime execution targets. They are
not the primary identity of a Pd-style text-entry object box in the saved/user
model. Resolution failure is a diagnostic state on the same object box, not a
separate user-visible node class.

`core.unresolved-object` is therefore not the stabilized contract direction.
Any interim placeholder use must migrate to a canonical object box model such
as `core.object` plus explicit resolution state before the object-box contract
is considered stable.

Extension object text must be namespaced, for example `user.manipulator`.
Namespace-free unknown text remains editable as an unresolved object box with a
diagnostic. Runtime load/mutation should keep the session usable and surface the
diagnostic through the snapshot and log/event surfaces.

Graph-only import/export stays separate:

```text
Save Project  -> graph + viewState + metadata
Open Project  -> graph + viewState
Export Graph  -> graph only
Import Graph  -> graph only, generated default viewState
```

Help source remains immutable, but a help window may open a volatile editable
working copy. Users can pan, zoom, select, move, edit, connect, delete, copy
graph fragments, and promote/fork into a project-owned patch. The working copy
must not save back to first-party or package help source.

## Verified Compatibility Matrix

This section must name the promoted Contracts line and exact released artifacts
when a compatibility matrix is ready. Do not record local worktree versions
here. Component releases may be public but unpromoted until matrix verification
passes.

Contracts `0.45` is the first compatibility-matrix line for the corrected
release model. The dangling 0.44 state must not be repaired with tag surgery,
forced train rewrites, or local publishing.

The active checked-in draft matrix is
`releases/compatibility/0.45.json`. It remains unpromoted until Runtime,
SDK, Studio, Examples, and Manual gates are verified from released artifacts.

| Artifact group | Required matrix state |
| --- | --- |
| Contracts npm/crate | Contracts line and range, exact npm/crate versions, published from Release Please/GitHub Actions |
| Runtime binaries | Exact release tag, multi-arch sidecar assets, checksums, and supported Contracts line |
| SDK npm | Exact npm version and supported Contracts range |
| Studio web/desktop | Exact web/desktop versions, Runtime sidecar versions, and supported Contracts range |
| Examples | Exact tag/commit, current-version fixtures only, conformance against released artifacts |
| Manual | Exact Manual version/path deployed to GitHub Pages |

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
session-addressed control operations and updates runtime control state; it must
not create graph patches. The `/v0/session/control/event` default-session path
is transitional removal debt and must not be preserved as compatibility. New
clients must target explicit session ids. Editing labels, ranges, names, or
defaults remains graph editing.

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
- `skenion-studio` consumes the current built-in node definitions from
  `@skenion/contracts`.
- `skenion-examples` may keep current-version fixture copies, but CI must
  structurally audit them against the current contracts built-in manifest.
- `skenion-runtime` validates and plans canonical examples from
  `skenion-examples`.
- Product-facing render cables may display as `render.frame`; the low-level
  stored resource type must follow the current accepted graph schema exactly.
- Every new builtin node must include node definition, compact help metadata,
  and a valid help graph in the same PR.
- Studio must consume the current built-in help metadata and help graphs from
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
| Builtin help graphs | `skenion-contracts` | Small immutable source example patches for each builtin node |
| Tutorial manifest and graphs | `skenion-examples` | User-facing learning paths across multiple nodes |
| Help graph viewer | `skenion-studio` | Volatile editable working-copy view, graph fragment copy, and promote/fork flow |

Existing help graphs must be current-version patch definitions/graph fragments
or be rejected. Do not preserve stale pre-consolidation help graphs as legacy
import documents.
Tutorial graphs may intentionally include shader analysis errors only when their
manifest lists the expected diagnostics.

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
