#!/usr/bin/env bash
set -euo pipefail

# Publishes a new XDDBOT release into the self-hosted F-Droid repository.
#
# Requirements:
#   - fdroidserver (`fdroid`) in PATH
#   - Android SDK + JDK 17 to build the APK
#   - the repository signing keystore
#
# Usage:
#   XDBBOT_SRC=../XDDbot \
#   FDROID_KEYSTORE=~/XDDbot-keys/fdroid.jks \
#   ./scripts/publish.sh
#
# Optional env:
#   FDROID_KEYPASS   keystore/key password (otherwise fdroid prompts)
#   FDROID_KEYALIAS  defaults to "xddbot"

XDBBOT_SRC="${XDBBOT_SRC:?set XDBBOT_SRC to the XDDbot checkout path}"
FDROID_KEYSTORE="${FDROID_KEYSTORE:?set FDROID_KEYSTORE to the F-Droid signing keystore}"

cd "$(dirname "$0")/.."

echo "==> Building release APK from $XDBBOT_SRC"
( cd "$XDBBOT_SRC" && ./gradlew :app:assembleRelease )

echo "==> Copying APK into the repository"
mkdir -p repo
cp "$XDBBOT_SRC"/app/build/outputs/apk/release/*.apk repo/

echo "==> Updating F-Droid index"
keypass_arg=()
if [[ -n "${FDROID_KEYPASS:-}" ]]; then
  keypass_arg=(--keypass "$FDROID_KEYPASS")
fi
fdroid update \
  --create-key \
  --keystore "$FDROID_KEYSTORE" \
  --repo-keyalias "${FDROID_KEYALIAS:-xddbot}" \
  "${keypass_arg[@]}"

echo "==> Done. Commit repo/ and push — GitHub Pages then serves the index."
