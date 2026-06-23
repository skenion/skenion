# Testing Standards

skenion packages use 100% test coverage as a release rule. This is a quality
bar, not a request to write low-value tests only to satisfy a number.

## Coverage Rule

- Every package with executable source must have an automated coverage command.
- CI must fail when covered source is below 100% lines, branches, functions, or
  statements where the runner supports those metrics.
- Coverage applies to the package's testable product surface: validators,
  builders, protocol clients, graph transforms, planners, schedulers, runtime
  API handlers, and other deterministic logic.
- Generated files, declaration files, framework bootstrap files, and visual or
  OS integration shells may be excluded only when the exclusion is explicit in
  the package configuration.
- Excluded code should be thin. If substantial logic needs exclusion, move that
  logic behind a testable boundary instead.

## What Counts As A Good Test

Good tests should verify behavior that would matter to a user, plugin author,
runtime implementer, or Studio developer. Prefer tests that cover:

- accepted and rejected contract shapes
- graph compatibility and wiring failures
- runtime planning and diagnostics
- SDK normalization and validation errors
- frontend client behavior around local Runtime requests
- serialization and stable public output

Avoid tests that only assert implementation trivia, duplicate TypeScript type
checking, or snapshot broad UI markup without proving behavior.

## Package Expectations

| Package | Coverage target | Notes |
| --- | --- | --- |
| `skenion-contracts` TS | 100% | Generated schema artifacts are excluded; validator behavior is covered. |
| `skenion-contracts` Rust | 100% | Contract validation and type helpers are covered. |
| `skenion-sdk` | 100% | Node definition builders and public SDK helpers are covered. |
| `skenion-runtime` | 100% on core runtime logic | CLI bootstrap, preview window, file loader, serve shell, and OS integration wrappers may be excluded if they stay thin and have integration coverage where useful. |
| `skenion-studio` | 100% on deterministic app logic | React rendering shells may be excluded initially; graph adapters and runtime clients are covered. |
| `skenion-examples` | Conformance checked | Fixtures are validated by contracts and runtime CI rather than line coverage. |

## Adding New Code

When adding code, choose one of these outcomes before merging:

1. Add meaningful tests and keep the package at 100%.
2. Move untestable integration glue into an explicitly excluded shell.
3. Delete or simplify code that cannot be justified with behavior tests.

Do not lower coverage thresholds to land a feature.
