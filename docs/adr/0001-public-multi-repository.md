# ADR 0001: Public Multi-Repository Bootstrap

## Status

Accepted.

## Context

skenion has separate implementation surfaces:

- Rust native runtime
- browser editor/controller/viewer
- TypeScript SDK
- cross-language protocol contracts
- examples and fixtures
- shared CI and release automation

These surfaces have different release cadences and different stability
requirements. A single monorepo would make early bootstrapping convenient, but
it would blur the most important boundary: contracts versus implementations.

## Decision

Start skenion as a public multi-repository project under the `skenion` GitHub
organization.

Initial repositories:

- `skenion`
- `skenion-contracts`
- `skenion-runtime`
- `skenion-studio`
- `skenion-sdk`
- `skenion-examples`
- `skenion-ci`

Use `skenion-ci` for skenion-specific reusable workflows instead of an org-level
`.github` repository.

Use Mantine as the default UI component system for `skenion-studio`.

Use Protobuf + Buf for the live TS/Rust control protocol, JSON Schema for
persisted graph/project documents, and HTTP/OpenAPI for asset, health, snapshot,
and diagnostics endpoints.

## Consequences

Benefits:

- explicit contract ownership
- independent implementation ownership with v0 compatibility matrix promotion
- cleaner public contribution boundaries
- less pressure to create vague shared utility packages
- CI/release policy remains reusable without becoming org-global

Costs:

- more repository setup work
- compatibility metadata is required from the beginning
- cross-repository changes need discipline
- automation must be maintained carefully

## Follow-Ups

- Choose project license.
- Bootstrap `skenion-contracts`.
- Bootstrap `skenion-ci`.
- Define the first protocol envelope.
- Define the first graph schema.
- Scaffold `skenion-runtime`.
- Scaffold `skenion-studio` with Mantine.
