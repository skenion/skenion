#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUB_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_DIR="$(cd "${HUB_DIR}/.." && pwd)"

CONTRACTS_DIR="${SKENION_CONTRACTS_DIR:-${WORKSPACE_DIR}/Skenion-contracts}"
EXAMPLES_DIR="${SKENION_EXAMPLES_DIR:-${WORKSPACE_DIR}/Skenion-examples}"
RUNTIME_DIR="${SKENION_RUNTIME_DIR:-${WORKSPACE_DIR}/Skenion-runtime}"
STUDIO_DIR="${SKENION_STUDIO_DIR:-${WORKSPACE_DIR}/Skenion-studio}"

require_dir() {
  local label="$1"
  local dir="$2"
  if [[ ! -d "${dir}" ]]; then
    echo "${label} directory not found: ${dir}" >&2
    exit 1
  fi
}

run() {
  local label="$1"
  shift
  echo
  echo "==> ${label}"
  "$@"
}

require_dir "contracts" "${CONTRACTS_DIR}"
require_dir "examples" "${EXAMPLES_DIR}"
require_dir "runtime" "${RUNTIME_DIR}"
require_dir "studio" "${STUDIO_DIR}"

run "contracts: build TypeScript artifacts" bash -lc \
  "cd '${CONTRACTS_DIR}' && pnpm install --frozen-lockfile && pnpm run build"

run "contracts: validate schemas and builtins" bash -lc \
  "cd '${CONTRACTS_DIR}' && pnpm run lint:json && pnpm --filter @skenion/contracts run ci"

run "examples: validate fixtures against contracts" bash -lc \
  "cd '${EXAMPLES_DIR}' && SKENION_CONTRACTS_PACKAGE='${CONTRACTS_DIR}/packages/ts/dist' node scripts/validate-with-contracts.mjs"

run "examples: audit builtin copies against contracts manifest" bash -lc \
  "cd '${EXAMPLES_DIR}' && SKENION_CONTRACTS_DIR='${CONTRACTS_DIR}' node scripts/audit-node-conventions.mjs"

run "examples: validate runtime project payloads" bash -lc \
  "cd '${EXAMPLES_DIR}' && SKENION_CONTRACTS_PACKAGE='${CONTRACTS_DIR}/packages/ts/dist' node scripts/validate-runtime-project-payloads.mjs"

run "runtime: Rust tests" bash -lc \
  "cd '${RUNTIME_DIR}' && cargo test --all-targets --all-features"

run "runtime: validate examples fixtures" bash -lc \
  "cd '${EXAMPLES_DIR}' && bash scripts/validate-with-runtime.sh '${RUNTIME_DIR}'"

run "examples: audio clock-domain planning smoke" bash -lc \
  "cd '${EXAMPLES_DIR}' && bash scripts/smoke-runtime-audio-clock-domains.sh '${RUNTIME_DIR}'"

run "examples: runtime MIDI Clock fixture/input smoke" bash -lc \
  "cd '${EXAMPLES_DIR}' && bash scripts/smoke-runtime-midi-clock-fixture.sh '${RUNTIME_DIR}'"

run "examples: live preview control HTTP smoke" bash -lc \
  "cd '${RUNTIME_DIR}' && SKENION_PREVIEW_DRY_RUN=1 cargo run -- serve --host 127.0.0.1 --port 3762 &
SERVER_PID=\$!
trap 'kill \${SERVER_PID} 2>/dev/null || true' EXIT
READY=false
for attempt in \$(seq 1 20); do
  if curl --fail --silent http://127.0.0.1:3762/health >/dev/null; then
    READY=true
    break
  fi
  sleep 1
done
if [[ \"\${READY}\" != \"true\" ]]; then
  echo 'runtime health endpoint did not become ready' >&2
  exit 1
fi
cd '${EXAMPLES_DIR}' && SKENION_RUNTIME_URL=http://127.0.0.1:3762 bash scripts/smoke-runtime-live-control-preview.sh"

run "examples: runtime IO device discovery HTTP smoke" bash -lc \
  "cd '${RUNTIME_DIR}' && SKENION_PREVIEW_DRY_RUN=1 cargo run -- serve --host 127.0.0.1 --port 3763 &
SERVER_PID=\$!
trap 'kill \${SERVER_PID} 2>/dev/null || true' EXIT
READY=false
for attempt in \$(seq 1 20); do
  if curl --fail --silent http://127.0.0.1:3763/health >/dev/null; then
    READY=true
    break
  fi
  sleep 1
done
if [[ \"\${READY}\" != \"true\" ]]; then
  echo 'runtime health endpoint did not become ready' >&2
  exit 1
fi
cd '${EXAMPLES_DIR}' && SKENION_RUNTIME_URL=http://127.0.0.1:3763 bash scripts/smoke-runtime-io-device-api.sh"

run "studio: app build smoke" bash -lc \
  "cd '${STUDIO_DIR}' && pnpm install --frozen-lockfile && pnpm run build"

echo
echo "Skenion cross-repo compatibility smoke passed."
