#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Captures raw App Store screenshots on the iOS simulators listed in config.json
# by running the ReadmeScreenshots UI test once per device and language.
#
# Output: build/appstore-screenshots/raw/<device>/<lang>/<screen>.png
#
# Usage: scripts/screenshots/capture.sh [device_key ...]
#   e.g. scripts/screenshots/capture.sh iphone_6_3 ipad_13
# Environment: LANGUAGES="en de" to override the languages from config.json
#              POSE_COMMAND / SCREENSHOT_COMMAND to replace duoctl for the iPhone Duo

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
CONFIG="$HERE/config.json"
RAW_DIR="$ROOT/build/appstore-screenshots/raw"
DERIVED_DATA="$ROOT/build/appstore-screenshots/DerivedData"
SCHEME="Back App Debug"
TEST_ID="Back App iOSUITests/ReadmeScreenshots/testTakeReadmeScreenshots"

json() { python3 -c "import json,sys; c=json.load(open('$CONFIG')); $1"; }

LANGUAGES="${LANGUAGES:-$(json 'print(" ".join(c["languages"]))')}"
if [[ $# -gt 0 ]]; then
    DEVICES="$*"
else
    DEVICES="$(json 'print(" ".join(c["devices"].keys()))')"
fi

# Finds the UDID of the first available simulator matching one of the configured names
# (newest runtime first).
find_simulator() {
    local key="$1"
    xcrun simctl list devices available --json | python3 -c "
import json, sys
names = json.load(open('$CONFIG'))['devices']['$key'].get('simulators', [])
runtimes = json.load(sys.stdin)['devices']
for name in names:
    for runtime in sorted(runtimes, reverse=True):
        if 'iOS' not in runtime:
            continue
        for device in runtimes[runtime]:
            if device['name'] == name:
                print(device['udid'], device['name'], sep='\t')
                sys.exit(0)
"
}

echo "▸ Building app and UI tests"
xcodebuild build-for-testing \
    -project "$ROOT/BackApp.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS Simulator" \
    -derivedDataPath "$DERIVED_DATA" \
    -quiet

# Foldable simulators (iPhone Duo) are handled with duoctl (https://github.com/skarol/duoctl,
# `brew install skarol/tap/duoctl`), because simctl can neither fold the Duo nor screenshot
# the display that is showing. The commands can be overridden in config.json
# ("pose_command", "screenshot_command") or via $POSE_COMMAND / $SCREENSHOT_COMMAND.
template() {
    local env_value="$1" key="$2"
    if [[ -n "$env_value" ]]; then echo "$env_value"; else json "print(c['$key'])"; fi
}
fill() {   # fill <template> <udid> [pose] [path]
    local cmd="${1//\{udid\}/$2}"
    cmd="${cmd//\{pose\}/${3:-}}"
    echo "${cmd//\{path\}/${4:-}}"
}

# Folds ("close", outer display) or unfolds ("open", inner display) the simulator.
set_pose() {
    local udid="$1" pose="$2" cmd
    cmd="$(fill "$(template "${POSE_COMMAND:-}" pose_command)" "$udid" "$pose")"
    if ! command -v "${cmd%% *}" >/dev/null; then
        echo "⚠︎  ${cmd%% *} not found – install it with 'brew install skarol/tap/duoctl'. Skipping."
        return 1
    fi
    echo "  ▸ $cmd"
    eval "$cmd"
    sleep 2   # the active display switches 1–2.5 s after the hinge moves
}

# For foldables the UI test can't tell which display is live, so it asks for each
# screenshot by creating <name>.request in the output folder; this loop answers with
# the screenshot command and the test continues once <name>.png exists.
serve_screenshots() {
    local udid="$1" dir="$2" template req name cmd
    template="$(template "${SCREENSHOT_COMMAND:-}" screenshot_command)"
    while true; do
        for req in "$dir"/*.request; do
            [[ -e "$req" ]] || continue
            name="$(basename "$req" .request)"
            cmd="$(fill "$template" "$udid" "" "$dir/.$name.partial.png")"
            if eval "$cmd" >/dev/null; then
                mv "$dir/.$name.partial.png" "$dir/$name.png"
            else
                echo "    ⚠︎ screenshot failed: $cmd"
            fi
            rm -f "$req"
        done
        sleep 0.3
    done
}

# Warns when the captured screens don't have the aspect ratio of the App Store size,
# e.g. because the Duo was in the wrong pose.
check_aspect() {
    local key="$1" dir="$2"
    python3 - "$CONFIG" "$key" "$dir" <<'PY'
import json, struct, sys
from pathlib import Path
config, key, directory = sys.argv[1:]
device = json.load(open(config))["devices"][key]
w, h = sorted(device["size"])
if device.get("orientation") == "landscape":
    w, h = h, w
for png in sorted(Path(directory).glob("*.png")):
    pw, ph = struct.unpack(">II", png.read_bytes()[16:24])
    if abs(pw / ph - w / h) > 0.03:
        print(f"    ⚠︎ {png.name} is {pw}×{ph}, expected the aspect ratio of {w}×{h}")
PY
}

trap 'jobs -p | xargs kill 2>/dev/null || true' EXIT

for key in $DEVICES; do
    match="$(find_simulator "$key" || true)"
    if [[ -z "$match" ]]; then
        echo "⚠︎  $key: none of the configured simulators is installed – skipping"
        echo "   (compose.py will use the 'fallback' device's screenshots if configured)"
        continue
    fi
    udid="${match%%$'\t'*}"
    name="${match#*$'\t'}"

    echo "▸ $key: $name ($udid)"
    orientation="$(json "print(c['devices']['$key'].get('orientation', 'portrait'))")"
    xcrun simctl boot "$udid" 2>/dev/null || true
    xcrun simctl bootstatus "$udid" -b >/dev/null
    xcrun simctl ui "$udid" appearance light
    xcrun simctl status_bar "$udid" override \
        --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 \
        --cellularMode active --cellularBars 4 --operatorName "" \
        --batteryState charged --batteryLevel 100

    pose="$(json "print(c['devices']['$key'].get('pose', ''))")"
    if [[ -n "$pose" ]] && ! set_pose "$udid" "$pose"; then
        xcrun simctl shutdown "$udid" || true
        continue
    fi

    for lang in $LANGUAGES; do
        out="$RAW_DIR/$key/$lang"
        rm -rf "$out"
        mkdir -p "$out"
        echo "  ▸ $lang ($orientation)"
        server=""
        if [[ -n "$pose" ]]; then
            serve_screenshots "$udid" "$out" &
            server=$!
        fi
        TEST_RUNNER_SCREENSHOT_DIR="$out" \
        TEST_RUNNER_SCREENSHOT_LANGUAGE="$lang" \
        TEST_RUNNER_SCREENSHOT_ORIENTATION="$orientation" \
        TEST_RUNNER_SCREENSHOT_CAPTURE="$([[ -n "$pose" ]] && echo host || echo device)" \
        xcodebuild test-without-building \
            -project "$ROOT/BackApp.xcodeproj" \
            -scheme "$SCHEME" \
            -destination "id=$udid" \
            -derivedDataPath "$DERIVED_DATA" \
            -only-testing:"$TEST_ID" \
            -testLanguage "$lang" \
            -quiet
        [[ -n "$server" ]] && { kill "$server" 2>/dev/null || true; wait "$server" 2>/dev/null || true; }
        echo "    $(ls "$out" | wc -l | tr -d ' ') screenshots"
        check_aspect "$key" "$out"
    done

    xcrun simctl status_bar "$udid" clear
    # keep foldables booted so the next pose can be applied without re-folding from scratch
    [[ -z "$pose" ]] && { xcrun simctl shutdown "$udid" || true; }
done

echo "✓ Raw screenshots in $RAW_DIR"
