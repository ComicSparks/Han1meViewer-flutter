#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter config --enable-macos-desktop

flutter build macos --release
rm -f build/build.dmg
hdiutil create \
  -volname HaVF \
  -srcfolder build/macos/Build/Products/Release/HaVF.app \
  -ov \
  -format UDZO \
  build/build.dmg
