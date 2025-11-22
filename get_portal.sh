#!/usr/bin/env bash
set -euo pipefail

URL="https://download2.interactivebrokers.com/portal/clientportal.gw.zip"

TMP_DIR=$(mktemp -d /tmp/XXXXXX)
TMP_ZIP="${TMP_DIR}/downloaded.zip"
PORTAL_DIR="${TMP_DIR}/clientportal"

mkdir "${PORTAL_DIR}"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading $URL..."
curl -L -o "$TMP_ZIP" "$URL"

echo "Unzipping $TMP_ZIP to /tmp..."
unzip -o "$TMP_ZIP" -d "$PORTAL_DIR"

if [ -d "$PORTAL_DIR" ]; then
    echo "Moving $PORTAL_DIR to /"
    mv "$PORTAL_DIR" /

else
    echo "Error: ${PORTAL_DIR} not found!"
    exit 1
fi
echo "Done!"
