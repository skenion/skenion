# ADR 0008: Package Marketplace And Install UX Are v0 Scope

## Status

Accepted

## Context

Patchers and packages are part of Skenion's product model. Users need to
publish reusable patch libraries and other users need to discover, install,
update, and use them. Deferring package install/update UX would leave extension
and patch-library contracts without a real product path.

This is separate from desktop application auto-update.

## Decision

Public package and patch marketplace install/update UX is v0 scope.

Full desktop app auto-updater rollout is not v0 scope.

The initial marketplace can avoid in-app account auth and permission policy by
starting with public read/install flows and package metadata sourced from public
indexes, registries, repositories, or released artifacts.

The v0 UX should include:

- package discovery
- search and filtering
- Stargazed or equivalent public ranking signals
- package detail pages
- install/update/remove
- installed package inventory
- compatibility diagnostics
- insertion of package patch libraries into projects

Studio owns the user-facing marketplace and install/update/remove commands.
Runtime owns the installed package registry, package cache/load paths, manifest
validation, package patch-library resolution, and compatibility diagnostics.
Tauri may provide desktop filesystem and network capability mediation, but it
does not own package semantics.

The v0 package cache and lockfile belong to the project/workspace when a package
is a project dependency. A user-level package cache may exist as an optimization,
but project reproducibility comes from the project lockfile.

Network access must be explicit. Studio may fetch public listings and package
artifacts through the marketplace client, but Runtime must not execute or load
native package artifacts until manifest, compatibility, and capability checks
pass.

## Required Contracts

Contracts must define:

- package and patch bundle manifests
- package source references
- version and compatibility ranges
- artifact checksums and provenance metadata
- installed package lockfile
- dependency graph and conflict diagnostics
- marketplace listing metadata
- ranking/discovery metadata

## Consequences

Runtime must validate manifests and capabilities before loading package content.
Studio must clearly distinguish first-party, project, package, and extension
patch libraries.

Publishing workflows can start outside Studio, but install/update/discovery is
part of the v0 product.
