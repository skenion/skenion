# skenion CI Policy

skenion is a multi-repository project. A green check in one repository is not enough when a change affects contracts, builtin nodes, compatibility fixtures, Runtime planning, or Studio graph UX.

## Required Local Gates

Run the repository-local CI before opening or updating a PR:

- `skenion-contracts`: `pnpm run ci` and `cargo test --all-targets --all-features`
- `skenion-examples`: contract fixture validation, builtin audit, runtime payload validation
- `skenion-runtime`: `cargo fmt --check`, `cargo clippy --all-targets --all-features -- -D warnings`, `cargo test --all-targets --all-features`
- `skenion-studio`: `pnpm run ci`

For cross-repository compatibility changes, run the hub smoke script:

```bash
bash scripts/smoke-compatibility.sh
```

The script assumes sibling checkouts under one workspace directory by default:

```text
Skenion/
Skenion-contracts/
Skenion-examples/
Skenion-runtime/
Skenion-studio/
```

Override paths with `SKENION_CONTRACTS_DIR`, `SKENION_EXAMPLES_DIR`, `SKENION_RUNTIME_DIR`, and `SKENION_STUDIO_DIR` when needed.

## Visual Gate Policy

Studio graph UX changes must keep Storybook and the visual gate in CI. The `studio-visual-gate` artifact must be present and must contain the expected non-empty PNG screenshots. Missing visual artifacts are build failures, not warnings.

Review the artifacts before merging changes that touch:

- node shell layout
- port rows or handles
- cable routing or edge labels
- connection validation UX
- runtime/session panels
- inspector diagnostics

## Release Hygiene

Do not use manual package version bumps to describe compatibility. During v0,
the hub conductor dispatches Release Please with an explicit `release-as` for
the lockstep train version. Release Please still owns version files,
changelogs, tags, and GitHub releases after that dispatch.

- Use `fix(...)` when a compatibility, validation, CI gate, or graph UX hardening change should produce a patch release.
- Use `feat(...)` when adding a product capability or public contract surface.
- Use `test(...)`, `ci(...)`, or `docs(...)` only when no release note or version signal is needed.

If a repository consumes a newly published contract surface, update the
compatibility matrix, use the exact released train version, and add an explicit
release note in the consuming repository.

Publishing to npm, crates.io, GitHub Releases, or GitHub Pages must happen from
GitHub Actions release workflows only. Local commands may run dry-run
verification, but must not upload release artifacts.

## Merge Readiness

A PR is ready to merge only when:

- repository-local CI is green
- semantic PR title checks are green
- cross-repository smoke has passed for compatibility-affecting changes
- required release notes are implied by the Conventional Commit title
- visual artifacts have been reviewed for Studio graph UX changes
- unrelated dirty worktree changes are not mixed into the PR
