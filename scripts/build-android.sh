#!/usr/bin/env bash
# 一次打出 armeabi-v7a、arm64-v8a、x86_64 三个 APK。Rust 由 cargokit 在编译时产出。
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build apk --release --split-per-abi
