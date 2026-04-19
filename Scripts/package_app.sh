#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="OnTrack"
APP_DIR="$ROOT_DIR/$APP_NAME.app"
DERIVED_DATA_DIR="$ROOT_DIR/.build/xcode-release"
BUILT_APP_DIR="$DERIVED_DATA_DIR/Build/Products/Release/$APP_NAME.app"

cd "$ROOT_DIR"
xcodebuild \
  -project "$ROOT_DIR/$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  CODE_SIGN_IDENTITY=- \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

rm -rf "$APP_DIR"
cp -R "$BUILT_APP_DIR" "$APP_DIR"

codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true

echo "Packaged $APP_DIR"
