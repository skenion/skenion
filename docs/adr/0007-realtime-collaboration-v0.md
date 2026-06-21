# ADR 0007: Realtime Collaboration Is A v0 Foundation

## Status

Accepted

## Context

Same-session multi-window editing and multi-client Runtime connections cannot
be treated as a later collaboration feature. If concurrent graph edits are not
contracted early, paste, help working copies, session replay, undo, and Runtime
events will all grow incompatible assumptions.

## Decision

Realtime collaboration is in v0 scope.

The v0 collaboration model is Runtime-authoritative:

```text
client operation -> Runtime ordering/rebase -> ack/broadcast -> client reconcile
```

Use an OT/rebase operation log with CRDT-compatible stable ids and
deterministic merge rules for graph and view operations. This is not a
peer-to-peer offline CRDT requirement.

Auth and permission policy are deferred. Collaboration still requires
server-issued participant/session ids for:

- presence
- causality
- idempotency
- pending operation reconciliation
- actor-scoped undo metadata

These participant ids are collaboration metadata, not security identities.

## Required Surfaces

Contracts must define operation envelopes, causal metadata, idempotency keys,
ack/nack responses, rebase results, event replay, presence, remote
selection/cursor state, and actor-scoped undo metadata.

Runtime must own operation ordering, rebase/merge, acknowledgement, broadcast,
event replay, participant lifecycle, and authoritative session history.

Studio must own optimistic local apply, pending operation UI, remote
selection/cursor rendering, per-window focus and selection state, and reconnect
UX.

## Consequences

Global session history remains the authoritative audit log. Interactive undo in
collaborative sessions must carry actor-scoped metadata from v0, even if the
first UI exposes only a conservative subset. The v0 contract must not bake in a
global-only undo model that would let one participant accidentally undo another
participant's recent work during normal collaborative editing.

Offline collaboration is not required for v0.
