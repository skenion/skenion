# Compatibility Matrix

This matrix records the current source-of-truth boundaries for graph, node, and
runtime compatibility. It exists to keep `skenion-contracts`, `skenion-examples`,
`skenion-studio`, and `skenion-runtime` from drifting independently.

## Current Baseline

| Surface | Current baseline | Owner |
| --- | --- | --- |
| Graph document schema | `skenion.graph` `0.1.0` | `skenion-contracts/json-schema/graph/v0.1/graph.schema.json` |
| Node definition schema | `skenion.node.definition` `0.1.0` | `skenion-contracts/json-schema/node/v0.1/node-definition.schema.json` |
| Graph patch schema | `skenion.graph.patch` `0.1.0` | `skenion-contracts/json-schema/graph/v0.1/patch.schema.json` |
| Built-in node definitions | `builtins/v0.1` | `skenion-contracts/builtins/v0.1/builtins.manifest.json` and `skenion-contracts/builtins/v0.1/nodes/*.node.json` |
| Built-in node help | `skenion.node.help` `0.1.0` plus help graphs | `skenion-contracts/builtins/v0.1/help/*.help.json` and `skenion-contracts/help/v0.1/nodes/*.help.graph.json` |
| Runtime HTTP API | `runtime-http.v0` | `skenion-contracts/openapi/runtime-http.v0.yaml` |

## Verified Releases

| Repository | Release / branch | Compatibility note |
| --- | --- | --- |
| `skenion-contracts` | `skenion-contracts-v0.15.0` plus current branch | Publishes structured shader diagnostics and canonical builtin help metadata/help graphs. |
| `skenion-runtime` | `skenion-runtime-v0.18.0` | Exposes shader diagnostics and generated WGSL from the runtime session. |
| `skenion-examples` | current branch | Contains compatibility fixtures plus learning tutorial graph manifest. |
| `skenion-studio` | `skenion-studio-v0.17.0` plus current branch | Uses contracts builtins/help, displays read-only help graphs, and can open help graphs as editable copies. |

## Canonical Data Kinds

Use namespaced data kinds in persisted graph node snapshots and node
definition manifests.

| Concept | Canonical data kind |
| --- | --- |
| 32-bit float value | `number.f32` |
| Bang event | `event.bang` |
| Video asset resource | `asset.video` |
| Video frame stream | `video.frame` |
| GPU texture resource | `gpu.texture2d` |
| RGBA color value | `color.rgba` |

`f32` is legacy and non-canonical. Studio may normalize imported legacy graph
documents from `f32` to `number.f32`, but newly created documents and fixtures
must use `number.f32`.

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
  and that newly created sample graphs store `number.f32`.
- runtime tests and CI smoke validate the canonical shader uniform projects:

```text
core.value-f32.value
  -> render.fullscreen-shader.u_value
  -> render.output.in

core.value-f32.value
  -> render.fullscreen-shader.u_value
core.value-f32.value
  -> render.fullscreen-shader.u_value2
core.color-rgba.value
  -> render.fullscreen-shader.u_color
render.fullscreen-shader.out
  -> render.output.in
```

Do not add dynamic shader port parsing, texture inputs, asset loading, script
nodes, or new render nodes until this matrix remains green across the affected
repositories.

Run the hub-level smoke script before merging compatibility-affecting changes:

```bash
bash scripts/smoke-compatibility.sh
```
