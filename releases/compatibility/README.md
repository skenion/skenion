# Compatibility Matrix Manifests

This directory contains active product compatibility matrix manifests owned by
the `skenion/skenion` hub.

The hub records and verifies released artifacts that work together for a
Contracts line. It does not conduct component releases, dispatch Release Please,
force `release-as` versions, or publish component artifacts. Component
repositories keep their natural Release Please releases; this directory records
the compatible set after artifacts exist.

The active manifest schema is `skenion.compatibility-matrix` with
`schema-version` `0.1.0`. The reusable verifier is
`skenion/skenion-ci/.github/workflows/verify-compatibility-matrix.yml@v2`.
Hub workflows must pass the organization secret `GH_TOKEN` for GitHub release
asset verification and fail closed if that secret is unavailable.

The first corrected v0 line is Contracts `0.45`, meaning
`>=0.45.0 <0.46.0`. Component versions remain independent.

Historical lockstep train manifests under `releases/trains/` were removed from
the active tree. If old train files are needed later for archaeology, restore
them only in a clearly historical location that cannot be mistaken for active
release metadata.
