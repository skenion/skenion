# ADR 0006: Tauri Multi-Window And Help Working Copy Model

## Status

Accepted

## Context

Skenion Studio remains a React/Vite web client. The desktop product needs native
window management, local Runtime sidecar lifecycle, shared clipboard bridging,
and connection profiles for local and remote Runtime targets.

Help must behave like a live patch surface. Users should be able to open a help
patch, move/edit nodes for experimentation, select a fragment, copy it, and
paste it into their own graph. The package or first-party help source must not
be mutated by that experimentation.

## Decision

Studio Desktop uses Tauri. Alternative desktop shells are out of v0 scope.

Tauri coordinates:

- windows and webviews
- local-managed Runtime sidecars
- local-shared and remote Runtime profiles
- app-level graph clipboard bridging
- sidecar permissions and lifecycle

Tauri is not the graph authority. Runtime sessions are authoritative for shared
graph documents.

Multiple windows may open the same Runtime session and same patch graph. This
is same-session multi-view editing:

- shared: graph documents, patch libraries, diagnostics, runtime events
- window-local: viewport, selection, inspector, focus, text editing, drag state

Help opens as:

```text
immutable help source -> volatile editable working copy
```

The working copy is window-local unless explicitly promoted or pasted into a
project-owned graph. Save-back to first-party or package help source must be
structurally impossible.

Every help working copy must carry:

- `sourceRef` for the immutable help patch definition
- `workingCopySessionId` or equivalent volatile session target
- `windowId` or `viewId` for window-local UI state
- discard/reset/promote behavior

Runtime may validate and preview a help working copy as a volatile session, but
normal project sessions change only when the user explicitly pastes or promotes
content into them.

## Desktop Runtime Profiles

- `local-managed`: Tauri starts and owns a Runtime sidecar.
- `local-shared`: Studio connects to an existing local Runtime and must not
  terminate it.
- `remote`: Studio connects to a configured remote Runtime and starts no local
  process.
- `isolated-window`: each window owns an isolated Runtime process/session for
  demos and tests.

## Viability Gate

Before broad desktop implementation, Tauri must pass a platform viability gate
on macOS, Windows, and Linux for:

- graph rendering
- selection and drag
- keyboard shortcuts
- IME and text entry
- graph clipboard MIME behavior
- drag/drop
- sidecar startup/shutdown/crash handling
- reconnect and session replay
