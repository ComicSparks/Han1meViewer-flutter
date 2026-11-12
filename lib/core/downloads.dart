import 'dart:async';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../src/rust/api/download.dart' as dl;
import '../src/rust/api/models.dart';

class DownloadState {
  static const queued = 0;
  static const downloading = 1;
  static const paused = 2;
  static const finished = 3;
  static const failed = 4;
}

/// 下载任务状态（Rust 调度，Dart 只做展示与前台服务保活）
class Downloads {
  Downloads._();

  static final tasks = signal<List<DownloadTask>>([]);
  static final groups = signal<List<DownloadGroup>>([]);
  static StreamSubscription<DownloadTask>? _sub;
  static bool _fgRunning = false;
  static DateTime _lastNotify = DateTime.fromMillisecondsSinceEpoch(0);

  /// 前台服务通知文字，由 UI 层按语言注入
  static String Function(int active, String title)? notificationText;
  static String notificationTitle = 'HaVF';

  static void init() {
    if (Platform.isAndroid) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'downloads',
          channelName: 'Downloads',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(showNotification: false),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    }
    reload();
    _sub ??= dl.downloadEventStream().listen(_onEvent);
  }

  static Future<void> reload() async {
    try {
      tasks.value = await dl.downloadList();
      groups.value = await dl.downloadGroups();
    } catch (_) {}
    _syncService();
  }

  static void _onEvent(DownloadTask t) {
    final list = [...tasks.value];
    final i = list.indexWhere((e) => e.id == t.id);
    if (i >= 0) {
      list[i] = t;
    } else {
      list.insert(0, t);
    }
    tasks.value = list;
    _syncService(t);
  }

  static List<DownloadTask> get active => tasks.value.where((t) => t.state != DownloadState.finished).toList();
  static List<DownloadTask> get finished => tasks.value.where((t) => t.state == DownloadState.finished).toList();

  static DownloadTask? finishedFor(String code) =>
      tasks.value.where((t) => t.videoCode == code && t.state == DownloadState.finished).firstOrNull;

  static Future<void> delete(DownloadTask t) async {
    await dl.downloadDelete(id: t.id);
    tasks.value = tasks.value.where((e) => e.id != t.id).toList();
    _syncService();
  }

  static Future<void> pause(DownloadTask t) => dl.downloadPause(id: t.id);
  static Future<void> resume(DownloadTask t) => dl.downloadResume(id: t.id);

  static Future<void> pauseAll() async {
    for (final t in active.where((t) => t.state == DownloadState.queued || t.state == DownloadState.downloading)) {
      await dl.downloadPause(id: t.id);
    }
  }

  static Future<void> resumeAll() async {
    for (final t in active.where((t) => t.state == DownloadState.paused || t.state == DownloadState.failed)) {
      await dl.downloadResume(id: t.id);
    }
  }

  static Future<void> add({
    required String videoCode,
    required String title,
    required String coverUrl,
    required VideoLink link,
    int groupId = 0,
  }) async {
    await dl.downloadAdd(
      videoCode: videoCode,
      title: title,
      coverUrl: coverUrl,
      quality: link.quality,
      videoUrl: link.url,
      suffix: link.suffix,
      groupId: groupId,
    );
    if (Platform.isAndroid) await _ensureNotificationPermission();
  }

  static Future<void> _ensureNotificationPermission() async {
    try {
      final p = await FlutterForegroundTask.checkNotificationPermission();
      if (p != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (_) {}
  }

  /// iOS 无法后台长时间下载：切后台挂起，回前台继续
  static void onBackground() {
    if (Platform.isIOS) dl.downloadSetSuspended(suspended: true);
  }

  static void onForeground() {
    if (Platform.isIOS) dl.downloadSetSuspended(suspended: false);
  }

  static Future<void> _syncService([DownloadTask? changed]) async {
    if (!Platform.isAndroid) return;
    final count = tasks.value
        .where((t) => t.state == DownloadState.queued || t.state == DownloadState.downloading)
        .length;
    try {
      if (count > 0 && !_fgRunning) {
        _fgRunning = true;
        await FlutterForegroundTask.startService(
          serviceId: 1001,
          serviceTypes: [ForegroundServiceTypes.dataSync],
          notificationTitle: notificationTitle,
          notificationText: notificationText?.call(count, changed?.title ?? '') ?? '$count',
        );
      } else if (count == 0 && _fgRunning) {
        _fgRunning = false;
        await FlutterForegroundTask.stopService();
      } else if (count > 0) {
        final now = DateTime.now();
        if (now.difference(_lastNotify).inMilliseconds < 1500) return;
        _lastNotify = now;
        final current = tasks.value.where((t) => t.state == DownloadState.downloading).firstOrNull;
        var text = notificationText?.call(count, current?.title ?? '') ?? '$count';
        if (current != null && current.length > 0) {
          text += ' · ${(current.downloaded * 100 ~/ current.length)}%';
        }
        await FlutterForegroundTask.updateService(notificationText: text);
      }
    } catch (_) {}
  }
}
