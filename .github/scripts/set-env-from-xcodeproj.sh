#!/bin/bash

set -euo pipefail

DEBUG_SCHEME="$(xcodebuild -list -json | jq -r '.project.schemes[0]')"
RELEASE_SCHEME="$(xcodebuild -list -json | jq -r '.project.schemes[1]')"

PRODUCT_NAME="$(xcodebuild -scheme "$DEBUG_SCHEME" -showBuildSettings | grep " PRODUCT_NAME " | sed "s/[ ]*PRODUCT_NAME = //")"
echo "::set-env name=PRODUCT_NAME::$PRODUCT_NAME"
