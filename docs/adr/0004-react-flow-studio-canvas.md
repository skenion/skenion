# ADR 0004: Use React Flow For The Studio Canvas Layer

## Status

Accepted

## Context

Skenion Studio needs a node-link canvas with pan, zoom, selection, drag handles,
connection gestures, custom node rendering, and edge feedback. Building that
interaction layer directly would delay the more important contract, runtime,
and authoring work.

The canvas library must not become the saved graph format or execution model.
Skenion already has a graph document contract, node definition manifests, and a
runtime-owned execution model.

## Decision

Use `@xyflow/react` as the Studio canvas interaction layer.

React Flow nodes and edges are derived view-model state. They are not persisted
as Skenion project files, and they are not runtime IR.

Studio must keep explicit conversion boundaries:

- `toReactFlowViewModel()` maps Skenion graph documents, patch definitions, and
  node definitions into canvas nodes, handles, and edges.
- Studio command builders map canvas gestures into Runtime operation envelopes,
  such as move, connect, edit params, and `pasteGraphFragment`.
- edge validation calls Skenion compatibility logic before a connection is
  committed.

Mantine remains the default component system for node bodies, inspectors,
palettes, panels, dialogs, and settings UI.

## Type Mapping Rules

Canvas styling follows the active graph/node contract:

- edge category comes from `type.flow`
- GPU styling comes from `type.dataKind === "gpu.texture2d"`
- boolean values use `dataKind: "boolean"`
- bang triggers use `flow: "event"` and `dataKind: "bang"`
- video assets use `dataKind: "asset.video"`
- GPU textures use `flow: "resource"` and `dataKind: "gpu.texture2d"`

There is no `flow: "gpu"` value.

## Consequences

React Flow gives the project a strong default interaction layer without
capturing Skenion's storage or execution model.

If performance or rendering limits appear later, Studio can replace the canvas
implementation while preserving the Skenion graph and patch boundary.

ELK.js remains a likely later dependency for auto-layout, but it is not an
initial requirement.
