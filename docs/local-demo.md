# Local Demo

This demo path is the current quickest way to learn Skenion locally.

## Start Runtime

```bash
cd /Users/state303/Documents/Skenion-runtime
cargo run -- serve --host 127.0.0.1 --port 3761
```

Use `SKENION_PREVIEW_DRY_RUN=1` when validating control-plane behavior without a native preview window.

## Start Studio

```bash
cd /Users/state303/Documents/Skenion-studio
pnpm dev
```

Open `http://127.0.0.1:5173`.

## Learn Nodes

Studio should expose builtin node Help from `@skenion/contracts`:

- summary, description, tags, ports, params, and runtime behavior
- read-only help patch graph
- Open as New Graph for editable exploration

Tutorial graphs live in `skenion-examples/tutorials/v0.1` and are indexed by
`tutorials.manifest.json`. These are learning graphs, not compatibility payloads.

Suggested manual flow:

1. Open Help for `core.value-f32`.
2. Inspect the help graph.
3. Open it as a new graph.
4. Connect Runtime.
5. Load Current Graph.
6. Send runtime control events through the inspector.
7. Open Help for `render.fullscreen-shader`.
8. Compare local annotation analysis, synced input ports, runtime diagnostics, and generated WGSL.

Do not use tutorial graphs as compatibility fixtures. Compatibility fixtures stay under `skenion-examples/compatibility`.
