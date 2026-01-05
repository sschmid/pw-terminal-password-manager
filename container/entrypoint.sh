#!/usr/bin/env bash
set -euo pipefail

# Set up virtual display (Xvfb) for clipboard support
export DISPLAY=:99
Xvfb "${DISPLAY}" &>/dev/null &

exec "$@"
