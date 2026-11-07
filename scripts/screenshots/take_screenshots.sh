#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Takes the README screenshots on an iOS simulator and frames them into images/.
#
# Usage: scripts/screenshots/take_screenshots.sh ["iPhone 16"]
# Needs Xcode and Pillow (pip3 install pillow).
set -euo pipefail

DEVICE="${1:-iPhone 16}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RAW_DIR="$ROOT/build/screenshots"

rm -rf "$RAW_DIR"
mkdir -p "$RAW_DIR"

# clean status bar like in the App Store screenshots
xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE" -b
xcrun simctl ui "$DEVICE" appearance light
xcrun simctl status_bar "$DEVICE" override --time "9:41" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100

# TEST_RUNNER_ variables are passed to the UI test process without the prefix
TEST_RUNNER_SCREENSHOT_DIR="$RAW_DIR" xcodebuild test \
    -project "$ROOT/BackApp.xcodeproj" \
    -scheme "Back App Debug" \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -only-testing "Back App iOSUITests/ReadmeScreenshots/testTakeReadmeScreenshots"

xcrun simctl status_bar "$DEVICE" clear

python3 "$ROOT/scripts/screenshots/frame_screenshots.py" "$RAW_DIR" "$ROOT/images"
