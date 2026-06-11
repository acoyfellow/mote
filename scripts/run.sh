#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/app"
MOTE_WORKSPACE="$ROOT/workspace" swift run Mote
