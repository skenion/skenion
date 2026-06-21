# Frontend Standards

`skenion-studio` uses Mantine as the primary frontend component system.

## Defaults

- React + TypeScript
- Mantine for application UI components
- `@xyflow/react` for the node canvas interaction layer
- Mantine hooks where they fit naturally
- Tabler or Lucide icons, chosen consistently during app bootstrap
- CSS modules or Mantine-supported styling primitives for local component style
- Storybook for component and interaction development

## UI Principles

- Build an operational editor, not a marketing landing page.
- Prefer dense, scannable, work-focused layouts.
- Use familiar controls: tabs for views, segmented controls for modes, sliders
  and numeric inputs for parameters, switches for binary state, menus for option
  sets, and icon buttons for common tools.
- Keep visual styling restrained and readable.
- Avoid nested card layouts and decorative UI that competes with the graph,
  preview, timeline, or telemetry surfaces.
- Runtime diagnostics must show exact versions and capability mismatches.

## Repository Boundary

Mantine belongs in `skenion-studio`.

React Flow also belongs in `skenion-studio`. It must remain a visual
interaction dependency, not a shared graph model or execution dependency.

`skenion-sdk` must stay UI-framework agnostic. It should expose runtime
connection and command APIs that can be used by React, non-React web apps,
scripts, or tests.

## Canvas Boundary

Skenion Graph v0.2 is the forward saved graph/project format for subpatches,
patch libraries, live help, and graph fragments. Graph v0.1 remains an
import/read-only compatibility surface. React Flow nodes and edges are derived
view-model state.

The Studio implementation must keep an explicit translation layer:

- `toReactFlowViewModel()` maps Skenion graph documents, patch definitions, and
  node definitions into canvas nodes, handles, and edges.
- Studio command builders map canvas gestures into Runtime operation envelopes,
  such as move, connect, edit params, and `pasteGraphFragment`.
- edge validation calls the Skenion compatibility validator before committing a
  connection.

The canvas must follow the v0.1 type model:

- edge styling is based on `type.flow`
- GPU styling is based on `type.dataKind === "gpu.texture2d"`
- boolean values use `dataKind: "boolean"`
- bang triggers use `flow: "event"` and `dataKind: "bang"`
- video assets use `dataKind: "asset.video"`
- GPU textures use `flow: "resource"` and `dataKind: "gpu.texture2d"`

There is no `flow: "gpu"` value.

## Compatibility UX

The editor must not assume a runtime supports every command. It should inspect
runtime capabilities and adjust the UI:

- hide unsupported controls
- show read-only states when editing is unavailable
- display clear diagnostics for version or capability mismatches
- avoid sending unsupported commands
