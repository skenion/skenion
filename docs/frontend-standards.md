# Frontend Standards

`skenion-studio` uses Mantine as the primary frontend component system.

## Defaults

- React + TypeScript
- Mantine for application UI components
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

`skenion-sdk` must stay UI-framework agnostic. It should expose runtime
connection and command APIs that can be used by React, non-React web apps,
scripts, or tests.

## Compatibility UX

The editor must not assume a runtime supports every command. It should inspect
runtime capabilities and adjust the UI:

- hide unsupported controls
- show read-only states when editing is unavailable
- display clear diagnostics for version or capability mismatches
- avoid sending unsupported commands
