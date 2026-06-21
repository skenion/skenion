# ADR 0003: Build The SDK Before Studio

## Status

Accepted

## Context

Skenion Studio needs a visual node editor, inspector panels, runtime
connection UX, and preview surfaces. Those UI pieces depend on a stable contract
for node definitions, port types, lifecycle hooks, and validation behavior.

Starting Studio too early would push temporary authoring and validation rules
into UI code. That would make the editor look usable before the graph and node
contract are actually stable enough for runtime execution.

## Decision

Build the first `skenion-sdk` surface before the full Studio implementation.

The SDK owns:

- `defineNode()` for script and plugin node manifests
- `t.*` builders for v0.1 port types
- manifest normalization
- validation through `@skenion/contracts`
- TypeScript lifecycle types for `onInit`, `onInput`, `onEvent`, and
  `onDispose`

The SDK does not own React, Mantine, Studio UI state, canvas layout, or runtime
internals.

## Consequences

Studio can later treat node definitions as stable data instead of inventing a
separate UI-local model.

The runtime can load the same manifest format that the SDK emits.

Visual editor work is delayed until the core authoring and validation surface is
less likely to churn.

## Supersession Note

This ADR still applies to the original node authoring SDK surface. It does not
mean every later Studio capability must wait for SDK implementation. For the v0
session, paste, collaboration, marketplace, and Tauri desktop substrate, the
current implementation order is contracts first, then Runtime/Studio substrate,
then SDK helpers once the protocol shape is stable.
