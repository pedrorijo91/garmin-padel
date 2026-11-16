#!/bin/bash

# Use the SDK currently selected in the Garmin SDK Manager (keep it on the latest version,
# to match the ghcr.io/matco/connectiq-tester:latest image used in CI).
SDK_CFG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
if [ ! -f "$SDK_CFG" ]; then
    echo "Could not find $SDK_CFG. Select an SDK in the Garmin SDK Manager first."
    exit 1
fi
SDK_PATH="$(cat "$SDK_CFG")"
SDK_PATH="${SDK_PATH%/}"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "exporting app using SDK $SDK_PATH"
java -Xms1g -Dfile.encoding=UTF-8 -Dapple.awt.UIElement=true -jar "$SDK_PATH/bin/monkeybrains.jar" -o "$REPO_ROOT/releases/garminpadel.iq" -f "$REPO_ROOT/monkey.jungle" -y "$REPO_ROOT/developer_key" -e -r -w
