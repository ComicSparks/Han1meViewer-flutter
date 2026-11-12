import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
// clearCache 只在 video_player 实现里，库的公开出口没有再导出这个类。
// ignore: implementation_imports
import 'package:better_player_plus/src/video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

/// 播放器边播边下的磁盘缓存。和图片、页面缓存分开，一次播放一个子目录。
class PlaybackCache {
  static const maxBytes = 1024 * 1024 * 1024;
  static int _networkPlayers = 0;

  /// 手机的磁盘缓存是进程内一份，多个播放器共用。计数归零才清。
  static void retainNetwork() => _networkPlayers++;

  static Future<void> releaseNetwork() async {
    if (_networkPlayers <= 0) return;
    _networkPlayers--;
    if (_networkPlayers == 0) await clearPlugin();
  }

  static Future<Directory> root() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/cache/playback');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> createSession() async {
    final dir = Directory('${(await root()).path}/${DateTime.now().microsecondsSinceEpoch}');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<void> delete(Directory? dir) async {
    if (dir == null) return;
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  static Future<void> clearPlugin() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    try {
      await VideoPlayerController.clearCache();
    } catch (_) {}
  }

  /// 启动时清掉上次进程留下的播放缓存。不碰图片、页面和下载。
  static Future<void> clearAll() async {
    final support = await getApplicationSupportDirectory();
    await delete(Directory('${support.path}/cache/playback'));
    await clearPlugin();
  }
}

/// 手机网络源的磁盘缓存。Android 的上限在进程内第一次创建后不能再改。
const playbackCacheConfiguration = BetterPlayerCacheConfiguration(
  useCache: true,
  maxCacheSize: PlaybackCache.maxBytes,
  maxCacheFileSize: PlaybackCache.maxBytes,
);
