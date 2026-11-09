#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Takes the README screenshots on an iOS simulator and frames them into images/.
#
# Usage: scripts/screenshots/take_screenshots.sh ["iPhone 17"]
# Without an argument it picks the newest available iPhone simulator.
# Needs Xcode; Pillow is installed into a local venv automatically if missing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RAW_DIR="$ROOT/build/screenshots"

# Resolve the wanted device (name or UDID, empty = newest iPhone) to a concrete
# simulator UDID on the newest installed iOS runtime. Running against a UDID avoids
# xcodebuild's `OS:latest` matching, which fails when the named device only exists
# on an older runtime (e.g. "iPhone 16" on iOS 18 while the latest runtime is 26).
DEVICE_LINE="$(python3 - "${1:-}" <<'PY'
import json, re, subprocess, sys

want = sys.argv[1] if len(sys.argv) > 1 else ""
data = json.loads(subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "--json"]))

candidates = []  # (ios_version_tuple, is_plain_iphone, name, udid)
for runtime, devices in data["devices"].items():
    match = re.search(r"iOS[- ]([0-9]+(?:[.-][0-9]+)*)", runtime)
    if not match:
        continue
    version = tuple(int(part) for part in re.split(r"[.-]", match.group(1)))
    for device in devices:
        if not device.get("isAvailable"):
            continue
        name, udid = device["name"], device["udid"]
        if want:
            if want in (name, udid):
                candidates.append((version, 1, name, udid))
        elif name.startswith("iPhone"):
            plain = 1 if re.fullmatch(r"iPhone \d+", name) else 0
            candidates.append((version, plain, name, udid))

if not candidates:
    sys.exit('no available simulator found' + (f' matching "{want}"' if want else ''))

candidates.sort()
_, _, name, udid = candidates[-1]
print(f"{udid}\t{name}")
PY
)"
DEVICE_ID="$(cut -f1 <<<"$DEVICE_LINE")"
DEVICE_NAME="$(cut -f2 <<<"$DEVICE_LINE")"
echo "Using simulator: $DEVICE_NAME ($DEVICE_ID)"

rm -rf "$RAW_DIR"
mkdir -p "$RAW_DIR"

# clean status bar like in the App Store screenshots
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl ui "$DEVICE_ID" appearance light
xcrun simctl status_bar "$DEVICE_ID" override --time "9:41" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100

# TEST_RUNNER_ variables are passed to the UI test process without the prefix
TEST_RUNNER_SCREENSHOT_DIR="$RAW_DIR" xcodebuild test \
    -project "$ROOT/BackApp.xcodeproj" \
    -scheme "Back App Debug" \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -only-testing "Back App iOSUITests/ReadmeScreenshots/testTakeReadmeScreenshots"

# the screenshots are taken, so give the simulator its real status bar back
# (time, network and battery) instead of the fixed 9:41 one set above
xcrun simctl status_bar "$DEVICE_ID" clear

# Frame the screenshots. Use Pillow if available, otherwise a local venv so the
# script works without touching the system Python (which may be externally managed).
if python3 -c "import PIL" >/dev/null 2>&1; then
    FRAME_PY=python3
else
    VENV="$ROOT/build/screenshot-venv"
    if [ ! -x "$VENV/bin/python" ]; then
        python3 -m venv "$VENV"
        "$VENV/bin/pip" install --quiet --upgrade pip pillow
    fi
    FRAME_PY="$VENV/bin/python"
fi

"$FRAME_PY" "$ROOT/scripts/screenshots/frame_screenshots.py" "$RAW_DIR" "$ROOT/images"
