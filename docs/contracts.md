# Contracts

Skenion separates persisted documents from live runtime communication.

## Live Control Plane

Use Protobuf + Buf as the canonical live wire contract between TypeScript and
Rust.

Transport for the MVP:

```text
Browser or SDK
  WebSocket binary frames containing Protobuf envelopes
Rust runtime
```

The live protocol should define envelopes, not raw ad hoc messages.

Required envelope concepts:

- protocol version
- session id
- message id
- correlation id
- sequence number
- payload oneof
- structured error code
- ack/ping/pong support

Handshake must negotiate:

- runtime/editor build version
- supported protocol version range
- graph schema version range
- capability set
- max message size
- compression support
- preview protocol support
- asset protocol support

Protocol major mismatches fail fast. Minor differences are allowed only when
capabilities gate behavior.

## Persisted Graph And Project Documents

Use JSON + JSON Schema for saved graph/project files.

Rationale:

- readable diffs
- easy export/import
- easier user support
- simple fixture authoring
- clear schema validation

Persisted documents must include schema identity and version fields.

## HTTP Surfaces

Use HTTP + OpenAPI for:

- health
- snapshots
- asset upload
- asset metadata
- preview stream setup
- diagnostics endpoints

Do not use HTTP polling for continuous runtime event traffic unless it is a
temporary diagnostic path.

## Preview And Media

Preview/media is not part of the control plane.

MVP order:

1. Rust local preview window
2. snapshot endpoint
3. browser preview stream
4. recording/export
5. optional NDI, SRT, RTSP, WebRTC, or WebTransport surfaces

Slow preview must never block the main render loop.

## Contract Repository Shape

`skenion-contracts` should contain:

```text
proto/
json-schema/
openapi/
fixtures/
golden/
conformance/
packages/ts/
crates/rust/
docs/
```

Required checks:

- `buf format`
- `buf lint`
- `buf breaking`
- Protobuf code generation drift check
- JSON Schema validation
- JSON fixture validation
- OpenAPI lint
- TypeScript roundtrip tests
- Rust roundtrip tests
- cross-language conformance tests

## SemVer For Contracts

Patch:

- docs fixes
- fixture clarifications
- generator fixes with identical wire behavior

Minor:

- optional field additions
- new commands or events gated by capabilities
- new safe enum values
- new schema features old runtimes can ignore safely

Major:

- removed, renamed, or retyped fields
- changed units or semantics
- new required fields
- incompatible graph schema behavior
- capability negotiation breaks
- plugin ABI breaks

Never reuse Protobuf field numbers or enum numbers.
