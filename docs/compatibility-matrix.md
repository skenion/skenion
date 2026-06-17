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
| Runtime HTTP API | `runtime-http.v0` | `skenion-contracts/openapi/runtime-http.v0.yaml` |

## Verified Releases

| Repository | Release / branch | Compatibility note |
| --- | --- | --- |
| `skenion-contracts` | `skenion-contracts-v0.12.0` | Publishes `core.color-rgba` and fullscreen shader `u_value`, `u_value2`, `u_color` builtins. |
| `skenion-runtime` | `skenion-runtime-v0.15.0` plus current `main` CI | Extracts `u_value`, `u_value2`, and `u_color` for fullscreen shader preview. |
| `skenion-examples` | current `main` | Contains canonical multi-uniform shader project and patch smoke fixtures. |
| `skenion-studio` | `skenion-studio-v0.14.0` | Uses contracts builtins, exposes RGBA color node controls, and includes a multi-uniform visual gate sample. |

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
