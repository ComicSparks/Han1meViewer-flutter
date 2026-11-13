import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../src/rust/api/app.dart' as rapi;

/// UI 偏好，持久化在 Rust 数据库的 kv 表里
class Pref<T> {
  final String key;
  final T def;
  late final Signal<T> signal;

  Pref(this.key, this.def) {
    T v = def;
    final raw = rapi.kvGet(key: key);
    if (raw != null) {
      try {
        v = jsonDecode(raw) as T;
      } catch (_) {}
    }
    signal = Signal<T>(v);
  }

  T get value => signal.value;
  set value(T v) {
    signal.value = v;
    rapi.kvSet(key: key, value: jsonEncode(v));
  }
}

class Prefs {
  Prefs._();

  // 外观
  static late final Pref<String> theme; // system / light / dark
  static late final Pref<String> locale; // system / zh / zh_TW / en / ja

  // 播放
  static late final Pref<String> defaultQuality;
  static late final Pref<double> longPressSpeed;
  static late final Pref<bool> gestures;
  static late final Pref<bool> resumePlayback;
  static late final Pref<bool> autoFullscreenLandscape;
  static late final Pref<bool> hKeyframesEnabled;
  static late final Pref<bool> sharedKeyframesEnabled;
  static late final Pref<bool> sharedKeyframesFirst;
  static late final Pref<int> keyframeCountdownSec;
  static late final Pref<bool> keyframeShowPrompt;

  // 内容
  static late final Pref<bool> hideComments;
  static late final Pref<bool> clipboardDetect;
  static late final Pref<String> lastClipboardCode;
  static late final Pref<String> searchSort;
  static late final Pref<String> historySort;
  static late final Pref<String> userVideosSort;
  static late final Pref<bool> subUpdates;
  static late final Pref<String> subSeenCode;

  // 隐私
  static late final Pref<bool> lockEnabled;
  static late final Pref<String> pinHash;
  static late final Pref<bool> biometric;
  static late final Pref<int> lockDelaySec;
  static late final Pref<bool> blurInBackground;
  static late final Pref<String> disguiseIcon;
  static late final Pref<bool> browserPassed;
  static late final Pref<bool> updateRemind;

  static void load() {
    theme = Pref('theme', 'system');
    locale = Pref('locale', 'system');
    defaultQuality = Pref('default_quality', '1080P');
    longPressSpeed = Pref('long_press_speed', 2.0);
    gestures = Pref('gestures', true);
    resumePlayback = Pref('resume_playback', true);
    autoFullscreenLandscape = Pref('fullscreen_landscape', true);
    hKeyframesEnabled = Pref('h_keyframes', true);
    sharedKeyframesEnabled = Pref('shared_keyframes', true);
    sharedKeyframesFirst = Pref('shared_keyframes_first', false);
    keyframeCountdownSec = Pref('keyframe_countdown', 10);
    keyframeShowPrompt = Pref('keyframe_show_prompt', true);
    hideComments = Pref('hide_comments', false);
    clipboardDetect = Pref('clipboard_detect', false);
    lastClipboardCode = Pref('last_clipboard_code', '');
    searchSort = Pref('search_sort', '');
    historySort = Pref('history_sort', 'latest');
    userVideosSort = Pref('user_videos_sort', '');
    subUpdates = Pref('sub_updates', false);
    subSeenCode = Pref('sub_seen_code', '');
    lockEnabled = Pref('lock_enabled', false);
    pinHash = Pref('pin_hash', '');
    biometric = Pref('biometric', true);
    lockDelaySec = Pref('lock_delay', 0);
    blurInBackground = Pref('blur_background', true);
    disguiseIcon = Pref('disguise_icon', 'default');
    browserPassed = Pref('browser_passed', false);
    updateRemind = Pref('update_remind', true);
  }

  static ThemeMode get themeMode => switch (theme.value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static Locale? get localeValue => switch (locale.value) {
        'zh' => const Locale('zh'),
        'zh_TW' => const Locale('zh', 'TW'),
        'en' => const Locale('en'),
        'ja' => const Locale('ja'),
        _ => null,
      };
}
