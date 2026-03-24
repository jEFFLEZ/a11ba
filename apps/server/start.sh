#!/usr/bin/env bash
set -euo pipefail

# Include common user-local bin paths where pip installs executables.
export PATH="/opt/venv/bin:/root/.local/bin:/app/.local/bin:${PATH}"

echo "[A11] Booting server..."

PIPER_PID=""

if [ "${ENABLE_PIPER_HTTP:-false}" = "true" ]; then
	export TTS_OUT_DIR="${TTS_OUT_DIR:-/app/public/tts}"
	export PIPER_HTTP_PORT="${TTS_PORT:-5002}"
	mkdir -p "${TTS_OUT_DIR}"
	echo "[A11] Starting Piper HTTP server (serve.py) on port ${PIPER_HTTP_PORT}"
	echo "[A11]   Model  : ${TTS_MODEL_PATH:-/app/apps/server/tts/fr_FR-siwis-medium.onnx}"
	echo "[A11]   OutDir : ${TTS_OUT_DIR}"
	python3 /app/apps/server/tts/serve.py &
	PIPER_PID=$!
	echo "[A11] Piper PID: ${PIPER_PID}"
else
	echo "[A11] ENABLE_PIPER_HTTP=false (Piper HTTP process not started)"
fi

cleanup() {
	if [ -n "${PIPER_PID}" ] && kill -0 "${PIPER_PID}" 2>/dev/null; then
		echo "[A11] Stopping Piper PID ${PIPER_PID}"
		kill "${PIPER_PID}" 2>/dev/null || true
	fi
}

trap cleanup EXIT INT TERM

node server.cjs