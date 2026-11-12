import 'dart:convert';

import 'package:flutter/services.dart';

import '../src/rust/api/local.dart' as local;
import '../src/rust/api/models.dart';
import 'prefs.dart';

/// H 关键帧：本地（数据库）+ 共享（随包 assets）
class KeyframeStore {
  KeyframeStore._();

  static List<String>? _sharedFiles;

  static HKeyframes _fromJson(Map<String, dynamic> j) => HKeyframes(
        videoCode: j['videoCode'].toString(),
        title: (j['title'] ?? '').toString(),
        keyframes: ((j['keyframes'] as List?) ?? const [])
            .map((k) => Keyframe(position: (k['position'] as num).toInt(), prompt: k['prompt'] as String?))
            .toList(),
        author: j['author'] as String?,
        createdTime: 0,
        modifiedTime: 0,
        shared: true,
      );

  static Future<List<String>> _files() async {
    if (_sharedFiles != null) return _sharedFiles!;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _sharedFiles = manifest.listAssets().where((a) => a.startsWith('assets/h_keyframes/') && a.endsWith('.json')).toList();
    return _sharedFiles!;
  }

  static Future<HKeyframes?> shared(String code) async {
    final path = 'assets/h_keyframes/$code.json';
    if (!(await _files()).contains(path)) return null;
    try {
      return _fromJson(jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<List<HKeyframes>> allShared() async {
    final out = <HKeyframes>[];
    for (final f in await _files()) {
      try {
        out.add(_fromJson(jsonDecode(await rootBundle.loadString(f)) as Map<String, dynamic>));
      } catch (_) {}
    }
    return out;
  }

  static Future<HKeyframes?> resolve(String code) async {
    if (!Prefs.hKeyframesEnabled.value) return null;
    final sharedOn = Prefs.sharedKeyframesEnabled.value;
    if (sharedOn && Prefs.sharedKeyframesFirst.value) {
      final s = await shared(code);
      if (s != null) return s;
    }
    final mine = await local.keyframesGet(videoCode: code);
    if (mine != null && mine.keyframes.isNotEmpty) return mine;
    return sharedOn ? shared(code) : null;
  }

  static Future<void> save(String code, String title, List<Keyframe> frames) {
    final sorted = [...frames]..sort((a, b) => a.position.compareTo(b.position));
    return local.keyframesSave(videoCode: code, title: title, keyframes: sorted);
  }
}
