#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter config --enable-linux-desktop

flutter build linux --release

rm -rf build/AppDir
mkdir -p build/AppDir/usr/bin
cp -a build/linux/x64/release/bundle/. build/AppDir/usr/bin/
cp linux/runner/app_icon.png build/AppDir/HaVF.png
cat >build/AppDir/HaVF.desktop <<'EOF'
[Desktop Entry]
Name=HaVF
Exec=HaVF
Icon=HaVF
Type=Application
Categories=AudioVideo;
EOF
cat >build/AppDir/AppRun <<'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="${HERE}/usr/bin/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/HaVF" "$@"
EOF
chmod +x build/AppDir/AppRun

if [[ ! -x "${HOME}/bin/appimagetool" && ! -x /usr/local/bin/appimagetool ]]; then
  mkdir -p "${HOME}/bin"
  curl -L -o "${HOME}/bin/appimagetool" \
    https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x "${HOME}/bin/appimagetool"
  export PATH="${HOME}/bin:${PATH}"
fi
export APPIMAGE_EXTRACT_AND_RUN=1
appimagetool build/AppDir build/build.AppImage
chmod +x build/build.AppImage
