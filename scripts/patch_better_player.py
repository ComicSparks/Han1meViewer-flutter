#!/usr/bin/env python3
"""Patch better_player_plus 1.1.5 for iOS duration 0 and seek clamping.

Idempotent. Fails if the packaged source no longer matches 1.1.5.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

SWIFT_READY_OLD = """        guard player.status == .readyToPlay else { return }"""
SWIFT_READY_NEW = """        // hvf: wait until the item itself is ready (betterplayer#1258).
        guard player.currentItem?.status == .readyToPlay, player.status == .readyToPlay else { return }"""

SWIFT_CLIP_OLD = """        let durMs = BetterPlayerTimeUtils.cmTimeToMillis(player.currentItem!.asset.duration)
        if overriddenDuration > 0 && durMs > Int64(overriddenDuration) {
            player.currentItem?.forwardPlaybackEndTime = CMTimeMake(value: Int64(overriddenDuration/1000), timescale: 1)
        }"""
SWIFT_CLIP_NEW = """        // hvf: overriddenDuration fills a zero AVPlayer duration. Do not clip playback with it."""

SWIFT_DURATION_OLD = """    public func duration() -> Int64 {
        let time: CMTime
        if #available(iOS 13, *) {
            time = player.currentItem?.duration ?? .zero
        } else {
            time = player.currentItem?.asset.duration ?? .zero
        }
        if let endTime = player.currentItem?.forwardPlaybackEndTime, !CMTIME_IS_INVALID(endTime) {
            return BetterPlayerTimeUtils.cmTimeToMillis(endTime)
        }
        return BetterPlayerTimeUtils.cmTimeToMillis(time)
    }"""
SWIFT_DURATION_NEW = """    public func duration() -> Int64 {
        if let endTime = player.currentItem?.forwardPlaybackEndTime, endTime.isValid, !CMTIME_IS_INDEFINITE(endTime), !CMTIME_IS_INVALID(endTime) {
            let endMs = BetterPlayerTimeUtils.cmTimeToMillis(endTime)
            if endMs > 0 { return endMs }
        }
        let native = nativeDurationMs()
        if native > 0 { return native }
        // hvf: playlist length when AVPlayer still reports 0.
        if overriddenDuration > 0 { return Int64(overriddenDuration) }
        return 0
    }

    private func nativeDurationMs() -> Int64 {
        guard let item = player.currentItem else { return 0 }
        let itemMs = usableMs(item.duration)
        if itemMs > 0 { return itemMs }
        return usableMs(item.asset.duration)
    }

    private func usableMs(_ time: CMTime) -> Int64 {
        if !time.isValid || CMTIME_IS_INDEFINITE(time) || CMTIME_IS_INVALID(time) { return 0 }
        let ms = BetterPlayerTimeUtils.cmTimeToMillis(time)
        return ms > 0 ? ms : 0
    }"""

DART_SEEK_OLD = """    Duration? positionToSeek = position;
    if (position! > value.duration!) {
      positionToSeek = value.duration;
    } else if (position < Duration.zero) {
      positionToSeek = Duration.zero;
    }"""
DART_SEEK_NEW = """    // hvf: a zero duration is unknown, not the end of the video.
    Duration? positionToSeek = position;
    final cap = value.duration;
    if (cap != null && cap > Duration.zero && position! > cap) {
      positionToSeek = cap;
    } else if (position! < Duration.zero) {
      positionToSeek = Duration.zero;
    }"""


def package_dirs() -> list[Path]:
    cache = Path(os.environ.get("PUB_CACHE", Path.home() / ".pub-cache"))
    root = cache / "hosted"
    found = sorted(root.glob("*/better_player_plus-1.1.5"))
    if not found:
        found = sorted(root.glob("*/better_player_plus-*"))
    return [p for p in found if p.is_dir()]


def replace_once(path: Path, old: str, new: str, marker: str) -> None:
    text = path.read_text()
    if marker in text:
        return
    if old not in text:
        raise SystemExit(f"{path} does not match better_player_plus 1.1.5; patch not applied")
    path.write_text(text.replace(old, new, 1))


def main() -> None:
    dirs = package_dirs()
    if not dirs:
        raise SystemExit("better_player_plus is not in the pub cache; run flutter pub get first")
    for pkg in dirs:
        swift = pkg / "ios" / "Classes" / "BetterPlayer.swift"
        dart = pkg / "lib" / "src" / "video_player" / "video_player.dart"
        if not swift.is_file() or not dart.is_file():
            raise SystemExit(f"unexpected better_player layout: {pkg}")
        replace_once(swift, SWIFT_READY_OLD, SWIFT_READY_NEW, "hvf: wait until the item itself is ready")
        replace_once(swift, SWIFT_CLIP_OLD, SWIFT_CLIP_NEW, "hvf: overriddenDuration fills a zero AVPlayer duration")
        replace_once(swift, SWIFT_DURATION_OLD, SWIFT_DURATION_NEW, "hvf: playlist length when AVPlayer still reports 0")
        replace_once(dart, DART_SEEK_OLD, DART_SEEK_NEW, "hvf: a zero duration is unknown")
        print(f"patched {pkg}")


if __name__ == "__main__":
    main()
