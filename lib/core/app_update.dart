import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/gen/app_localizations.dart';
import '../src/rust/api/cfg.dart' as cfg;
import 'prefs.dart';
import 'pro.dart';

/// 版本和友情链接都来自 CDN 配置。没有更新时不保留、也不打开下载地址。
class AppUpdate {
  AppUpdate._();

  static final latest = signal<String?>(null);
  static final changeLog = signal('');
  static final downloadUrl = signal<String?>(null);
  static final links = signal<Map<String, String>>({});

  static String current = '';
  static String _announcement = '';
  static Future<void>? _loading;
  static bool _loaded = false;
  static bool _forceShown = false;
  static bool _optionalShown = false;
  static bool _announcementBusy = false;
  static bool _announcementDone = false;

  /// 未发电时提醒始终开启。发电用户可以关掉可选更新的红点和弹窗。
  static bool get shouldRemind => !Pro.isPro || Prefs.updateRemind.value;

  static Future<void> refresh() {
    if (_loaded) return Future.value();
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      current = info.version;
      final config = await cfg.appConfig();
      final map = await cfg.configLinks();
      _announcement = config.announcement;
      final newer = _isNewer(current, config.latestVersion);
      latest.value = newer ? config.latestVersion : null;
      changeLog.value = newer ? config.changeLog : '';
      final url = config.downloadUrl.trim();
      downloadUrl.value = newer && url.isNotEmpty ? url : null;
      links.value = map;
      _loaded = true;
    } catch (_) {
      _loading = null;
    }
  }

  static bool get force {
    final version = latest.value;
    return version != null && _isForce(current, version);
  }

  static bool get hasUpdate => latest.value != null;

  static bool get showDot => hasUpdate && shouldRemind;

  /// 启动后调用。强制更新不能关掉；可选更新在提醒开启时弹一次。
  static Future<void> present(BuildContext context, {bool manual = false}) async {
    final version = latest.value;
    if (version != null && _isForce(current, version)) {
      if (!manual && _forceShown) {
        await _presentAnnouncement(context);
        return;
      }
      _forceShown = true;
      await _presentAnnouncement(context);
      if (!context.mounted) return;
      await _forceDialog(context, version);
      return;
    }
    if (version == null || (!manual && (!shouldRemind || _optionalShown))) {
      await _presentAnnouncement(context);
      return;
    }
    _optionalShown = true;
    await _optionalDialog(context, version);
    if (context.mounted) await _presentAnnouncement(context);
  }

  static Future<void> _presentAnnouncement(BuildContext context) async {
    if ((Pro.isPro && Prefs.hideAnnouncement.value) || _announcementDone || _announcementBusy) return;
    final text = _announcement.trim();
    if (text.isEmpty) return;
    _announcementBusy = true;
    try {
      final hash = sha256.convert(utf8.encode(text)).toString();
      if (Prefs.announcementRead.value == hash) {
        _announcementDone = true;
        return;
      }
      if (!context.mounted) return;
      _announcementDone = true;
      final remember = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: Text(_announcementCopy(c, "公告", "公告", "Announcement", "お知らせ")),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: SingleChildScrollView(child: Text(text)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(_announcementCopy(c, "关闭", "關閉", "Close", "閉じる")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(_announcementCopy(c, "不再提醒", "不再提醒", "Don't remind me", "今後表示しない")),
            ),
          ],
        ),
      );
      if (remember == true) Prefs.announcementRead.value = hash;
    } catch (_) {
    } finally {
      _announcementBusy = false;
    }
  }

  static Future<void> _forceDialog(BuildContext context, String version) {
    final l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(l.updateTitle),
          content: Text(l.forceUpdateMessage(version)),
          actions: [
            FilledButton(onPressed: openDownload, child: Text(l.downloadUpdate)),
          ],
        ),
      ),
    );
  }

  static Future<void> _optionalDialog(BuildContext context, String version) {
    final l = AppLocalizations.of(context);
    final log = changeLog.value.trim();
    return showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.updateTitle),
        content: Text(log.isEmpty ? l.newVersionFound(version) : log),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l.updateLater)),
          FilledButton(
            onPressed: () {
              Navigator.pop(c);
              openDownload();
            },
            child: Text(l.downloadUpdate),
          ),
        ],
      ),
    );
  }

  static Future<void> openDownload() => openHttp(downloadUrl.value);

  static Future<void> openHttp(String? raw) async {
    final uri = Uri.tryParse(raw?.trim() ?? '');
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http') || uri.host.isEmpty) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

String _announcementCopy(BuildContext context, String zh, String tw, String en, String ja) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode == 'zh' &&
      (locale.countryCode == 'TW' || locale.countryCode == 'HK' || locale.scriptCode == 'Hant')) {
    return tw;
  }
  return switch (locale.languageCode) {
    'en' => en,
    'ja' => ja,
    'zh' => zh,
    _ => zh,
  };
}

bool _isNewer(String current, String latest) {
  final c = _SemVer.parse(current);
  final l = _SemVer.parse(latest);
  if (c == null || l == null) return false;
  if (l.major != c.major) return l.major > c.major;
  if (l.minor != c.minor) return l.minor > c.minor;
  return l.patch > c.patch;
}

bool _isForce(String current, String latest) {
  final c = _SemVer.parse(current);
  final l = _SemVer.parse(latest);
  if (c == null || l == null) return false;
  if (l.major != c.major) return l.major > c.major;
  if (l.minor != c.minor) return l.minor > c.minor;
  return false;
}

class _SemVer {
  final int major;
  final int minor;
  final int patch;

  const _SemVer(this.major, this.minor, this.patch);

  static _SemVer? parse(String input) {
    var s = input.trim();
    if (s.startsWith('v') || s.startsWith('V')) s = s.substring(1);
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(s);
    if (m == null) return null;
    return _SemVer(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
  }
}
