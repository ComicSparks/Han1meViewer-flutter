import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/gen/app_localizations.dart';
import '../src/rust/api/cfg.dart' as cfg;

/// 版本和友情链接都来自 CDN 配置。没有更新时不保留、也不打开下载地址。
class AppUpdate {
  AppUpdate._();

  static final latest = signal<String?>(null);
  static final changeLog = signal('');
  static final downloadUrl = signal<String?>(null);
  static final links = signal<Map<String, String>>({});

  static String current = '';
  static Future<void>? _loading;
  static bool _loaded = false;
  static bool _forceShown = false;

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

  static Future<void> maybeForce(BuildContext context) async {
    final version = latest.value;
    if (_forceShown || version == null || !_isForce(current, version)) return;
    _forceShown = true;
    final l = AppLocalizations.of(context);
    await showDialog<void>(
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

  static Future<void> openDownload() => openHttp(downloadUrl.value);

  static Future<void> openHttp(String? raw) async {
    final uri = Uri.tryParse(raw?.trim() ?? '');
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http') || uri.host.isEmpty) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
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
