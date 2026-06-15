# Skenion

Skenion is an open-source interactive artwork platform by EchoVisionLab.

The core design is simple:

```text
Browser controls.
Rust renders.
The preview shows the Rust runtime's real output.
```

Skenion is not a browser-only clone of TouchDesigner. The browser is the editor,
controller, and viewer. A native Rust runtime owns graph compilation,
scheduling, rendering, output, plugin execution, preview generation, and runtime
telemetry.

## Repository Family

Skenion starts as a multi-repository project:

| Repository | Role |
| --- | --- |
| `skenion` | Project hub, architecture, RFCs, ADRs, roadmap, governance |
| `skenion-contracts` | Protobuf, JSON Schema, OpenAPI, generated packages, conformance tests |
| `skenion-runtime` | Rust native runtime and CLI |
| `skenion-studio` | Mantine-based browser editor, controller, and viewer |
| `skenion-sdk` | TypeScript SDK for runtime connections, commands, and capability negotiation |
| `skenion-examples` | Example scenes, fixtures, sample projects, and compatibility examples |
| `skenion-ci` | Reusable GitHub Actions workflows and composite actions |

See [Repository Map](docs/repository-map.md) for ownership boundaries.

## Key Decisions

- Use Mantine as the primary frontend component system for `skenion-studio`.
- Use Protobuf + Buf as the live TS/Rust control contract.
- Use JSON Schema for persisted graph/project documents.
- Use Release Please and Semantic Versioning per repository, without lockstep
  versioning.
- Keep control, media, telemetry, assets, and debug planes separate.
- Do not create a vague `common` repository.

## Status

The project is in bootstrap. The initial work is defining repository boundaries,
contracts, release rules, and the MVP runtime/editor protocol.

License is not finalized yet.
