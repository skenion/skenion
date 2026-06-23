# ADR 0005: Runtime Session Addressing And Paste Semantics

## Status

Accepted

## Context

skenion Runtime currently exposes a singleton session surface such as
`/v0/session`, `/v0/session/mutate`, and `/v0/session/events/stream`. That was
enough for a local bootstrap, but it is not enough for desktop multi-window
editing, volatile help working copies, remote Runtime connections, or realtime
collaboration.

Copy/paste also cannot remain a Studio-only lowering to low-level graph patch
operations. A pasted graph fragment needs target resolution, id remapping,
revision checks, boundary validation, diagnostics, history, and collaboration
ordering. Those are Runtime/session concerns.

## Decision

The canonical v0 session-addressed Runtime API is:

```text
/v0/sessions/{sessionId}/...
```

`/v0/session/...` is removal debt from the bootstrap surface, not a v0 product
compatibility alias. New clients and contracts must use explicit session ids.

Paste is a high-level Runtime operation. The semantic input is:

- target session id
- target graph or patch path
- base revision for that target
- destination position or anchor
- `GraphFragmentV01`
- paste options

Actor/client identity is not part of graph fragment semantics. It is optional
request attribution or collaboration metadata. Authenticated remote deployments
must infer security identity from server-side auth context instead of trusting a
client-provided string.

The canonical operation endpoint is:

```text
POST /v0/sessions/{sessionId}/operations
```

`pasteGraphFragment` is an operation kind inside that envelope, not a separate
ad-hoc endpoint. `/v0/session/mutate` is removal debt and must not be
preserved as a default-session compatibility alias or legacy low-level
graph/view mutation surface.

`PatchPath` must distinguish at least:

- root project graph
- project patch definition
- package patch definition
- embedded patch instance
- volatile help working copy

The path must identify which revision its `baseRevision` refers to.

## Required Contract Shapes

Contracts must define:

- `GraphFragmentV01`
- `GraphTargetRef`
- `PatchPath`
- `PasteGraphFragmentRequest`
- `PasteGraphFragmentResponse`
- `RuntimeOperationEnvelope`
- id remap results
- conflict and rebase diagnostics
- per-session event envelopes

Runtime paste responses should include enough information for Studio to update
local optimistic state:

- `nodeIdMap`
- `edgeIdMap`
- revision before and after
- history entry id
- diagnostics

## Consequences

Runtime owns id remapping, fragment validation, paste lowering, history, and
event broadcast. Studio owns selection-to-fragment conversion and destination
choice, but it does not own paste semantics.

Default-session compatibility aliases are not part of the v0 product contract.
Code should be written against explicit session ids, and remaining aliases
should be removed as technical debt.
