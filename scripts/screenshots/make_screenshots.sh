#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# One command to produce all App Store screenshots:
#   1. capture raw screens on the simulators (capture.sh)
#   2. compose them into framed, captioned images at the exact
#      App Store Connect sizes (compose.py)
#
# Usage: scripts/screenshots/make_screenshots.sh [device_key ...]
# Result: build/appstore-screenshots/final/<lang>/<device>/<screen>.png

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
VENV="$ROOT/build/appstore-screenshots/venv"

if [[ ! -x "$VENV/bin/python" ]]; then
    python3 -m venv "$VENV"
fi
"$VENV/bin/pip" install --quiet --requirement "$HERE/requirements.txt"

"$HERE/capture.sh" "$@"

if [[ $# -gt 0 ]]; then
    "$VENV/bin/python" "$HERE/compose.py" --devices "$@"
else
    "$VENV/bin/python" "$HERE/compose.py"
fi

echo "✓ App Store screenshots in $ROOT/build/appstore-screenshots/final"
