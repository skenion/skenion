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
9. Open the Dynamic Shader Inputs tutorial graph from `skenion-examples/tutorials/v0.1`.
10. Inspect the Shader Diagnostics tutorial and confirm the expected diagnostic appears before syncing inputs.
11. Load the Send / Receive Panel Controls sample in Studio.
12. Connect Runtime, Load Current Graph, move the `ui.slider-f32` runtime control, and click the `ui.toggle`.
13. Confirm Runtime control state exposes `number.f32:speed` and `boolean:enabled` channels.
14. Start preview, move the slider again, and confirm telemetry reports `controlLive: true` with matching `controlRevision` and `previewControlRevision`.
15. Apply a graph edit and confirm preview graph staleness is separate from runtime control live state.

## Save And Reopen Projects

Project documents use the `.skenion.json` extension and contain the execution
graph plus Studio view state. Graph JSON export remains graph-only.

Manual persistence smoke:

1. Load the Send / Receive Panel Controls sample.
2. Move several nodes and pan or zoom the canvas.
3. Save Project.
4. Refresh Studio or start a new Studio session.
5. Open Project and confirm node positions and viewport are restored.
6. Confirm Runtime did not auto-load the opened project.
7. Connect Runtime and explicitly Load Current Graph.
8. Start preview and confirm slider/toggle live control still updates the running preview.
9. Export Graph and confirm the exported JSON has no `viewState` field.
10. Import Graph and confirm Studio generates a default view state.

Do not use tutorial graphs as compatibility fixtures. Compatibility fixtures stay under `skenion-examples/compatibility`.

The direct runtime smoke for the panel-control path lives in
`skenion-examples/scripts/smoke-runtime-send-receive-panel.sh`.
The live preview control path is covered by
`skenion-examples/scripts/smoke-runtime-live-control-preview.sh`.
