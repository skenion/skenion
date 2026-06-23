# ADR 0002: Apache-2.0 Open Source License

## Status

Accepted.

## Context

skenion is intended to grow as an open-source interactive artwork platform. Its
value depends on adoption across runtime users, editor contributors, protocol
consumers, SDK users, artists, researchers, and installation teams.

The project also needs credit preservation so downstream users and derivative
tools keep attribution to skenion and its contributors.

## Decision

Use the Apache License, Version 2.0 as the default license for skenion
repositories.

Each repository should include:

- `LICENSE`
- `NOTICE`
- `CITATION.cff`
- `TRADEMARKS.md`

Credit preservation should rely on the Apache-2.0 license and NOTICE mechanism.
The project may request citation and visible credit in documentation, examples,
publications, and artwork presentations, but should avoid custom source-license
terms that make skenion non-standard or non-open-source.

skenion names and marks are protected separately through trademark policy.

## Consequences

Benefits:

- clear open-source status
- commercial and non-commercial adoption both allowed
- patent grant for contributors and users
- standard license accepted by common package ecosystems
- NOTICE-based attribution preservation

Costs:

- commercial use cannot be restricted through the source license
- revenue must come from support, services, hosted products, integration work,
  certification, training, or related offerings
- brand protection must be handled separately from copyright licensing

## Follow-Ups

- Add license files to all skenion repositories.
- Add package-level SPDX identifiers during source scaffolding.
- Define asset-specific licenses in `skenion-examples`.
- Add third-party notice handling once dependencies are introduced.
