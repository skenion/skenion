# ADR 0010: Graph 0.1 Patch Library And Subpatch Boundary Model

## Status

Accepted

## Context

Live help, user-defined patchers, first-party convenience patches, and extension
packages all need the same graph substrate. Treating help as a separate document
model or treating subpatches as an editor-only feature would make copy/paste,
package distribution, and Runtime execution diverge.

The v0 graph contract is consolidated under the current `0.1` label. The
patch-library, richer port contract, subpatch, and live help design is merged
into that current `0.1` surface. The older pre-consolidation `0.1` meaning is
not preserved as a legacy import/read-only compatibility surface.

## Decision

Current `0.1` projects contain a patch library. A patch library entry is a
named patch definition with:

- stable patch id
- revision
- metadata
- graph document
- optional view state
- package/source metadata when the patch comes from outside the project

Patch definitions can be:

- project-owned
- first-party package patches
- installed package patches
- extension package patches
- immutable help source patches
- volatile help working copies

Subpatch references are explicit graph nodes. Object text such as
`p my-patcher` resolves through the object-text resolver to a patch-backed node
that references a patch definition.

Embedded patch instances and referenced patch definitions are different:

- embedded instance: owned by one project/node instance
- referenced definition: loaded from a project, package, or extension patch
  library; edits to the definition affect references that target it
- graph fragment/snippet: reusable selected nodes and edges, not a runtime
  object by itself

## Boundary Nodes

`core.inlet` and `core.outlet` nodes inside a patch define that patch's external
contract.

`core.inlet` has one internal output port and creates one external input port on
the patch-backed node.

`core.outlet` has one internal input port and creates one external output port
on the patch-backed node.

Boundary metadata comes from node params and current `0.1` port fields:

- `portId`
- label
- type
- rate
- default value
- required
- trigger mode
- description
- order

`description` is the tooltip/help text source of truth for the boundary port.

Duplicate boundary `portId` values are invalid. Zero-port, input-only,
output-only, and N/M port patches are valid.

## Resolution And Precedence

Patch ids are resolved with explicit source context. Ambient search path
behavior is not enough for v0.

Resolution order:

1. project patch library
2. explicitly installed package dependency selected by the project lockfile
3. first-party package library
4. extension package library

Ambiguous patch ids must produce diagnostics rather than picking an arbitrary
candidate. Package-qualified references may bypass ambiguity.

## Version Policy

Current graph/project/patch-library documents use the consolidated `0.1`
surface. Unsupported versions and stale pre-consolidation documents must be
rejected with structured diagnostics rather than migrated, imported, or kept as
deprecated compatibility surfaces.

## Consequences

Runtime can start by flattening patch-backed nodes before validation, planning,
and run. True nested Runtime state boundaries are out of scope until a later
milestone explicitly adds them.

Studio can open a patch definition or help working copy as a real graph editor
surface. Copy/paste uses graph fragments; promote/fork operations create
project-owned patch definitions rather than mutating package source.
