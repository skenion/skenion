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
| `skenion-contracts` | `skenion-contracts-v0.21.0` | Removes legacy routing objects and publishes object-owned control routing builtins/help. |
| `skenion-runtime` | `skenion-runtime-v0.21.0` | Routes typed channels through object-owned `sendName` / `receiveName` and keeps live preview control updates separate from graph staleness. |
| `skenion-examples` | `main` after object routing panel merge | Contains compatibility fixtures, project documents, tutorial graphs, and runtime smoke coverage for object-owned typed channels. |
| `skenion-studio` | `skenion-studio-v0.22.0` | Renders Max-style object controls and keeps runtime control interactions separate from graph patching. |

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

Dynamic shader input parsing is supported through WGSL `@skenion.uniform`
annotations. GLSL, texture inputs, asset loading, script nodes, and multi-pass
rendering remain out of scope.

Run the hub-level smoke script before merging compatibility-affecting changes:

```bash
bash scripts/smoke-compatibility.sh
```
