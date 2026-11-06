#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_ID="${1:-}"
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID="$(xcrun simctl list devices available -j | python3 -c '
import json,re,sys
devices = [d for runtime, group in json.load(sys.stdin)["devices"].items()
           if (match := re.search(r"iOS-(\d+)-(\d+)", runtime))
           and tuple(map(int, match.groups())) >= (27, 1)
           for d in group if "Duo" in d["name"]]
devices.sort(key=lambda d: d["state"] != "Booted")
print(devices[0]["udid"] if devices else "")
')"
fi
if [ -z "$DEVICE_ID" ]; then
    echo "No compatible Duo simulator found. Add an iPhone Duo with iOS 27.1+ in Xcode’s Device Hub, then retry."
    exit 1
fi

STATE="$(xcrun simctl list devices -j | python3 -c 'import json,sys; target=sys.argv[1]; print(next((d["state"] for group in json.load(sys.stdin)["devices"].values() for d in group if d["udid"] == target), "Missing"))' "$DEVICE_ID")"
if [ "$STATE" = "Shutdown" ]; then xcrun simctl boot "$DEVICE_ID"; fi
xcrun simctl bootstatus "$DEVICE_ID" -b
xcodebuild -project "$ROOT/DuoPlayground.xcodeproj" -scheme DuoPlayground \
    -sdk iphonesimulator -destination "id=$DEVICE_ID" \
    -derivedDataPath "$ROOT/.build" CODE_SIGNING_ALLOWED=NO build
xcrun simctl install "$DEVICE_ID" "$ROOT/.build/Build/Products/Debug-iphonesimulator/DuoPlayground.app"
xcrun simctl launch "$DEVICE_ID" dev.tudor.DuoPlayground
echo "Open Device Hub, select iPhone Duo, then try Closed / Partially Open / Open and Rotate Right."
