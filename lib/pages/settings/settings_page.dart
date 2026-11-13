import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/app_update.dart';
import '../../core/errors.dart';
import '../../core/native.dart';
import '../../core/nav.dart';
import '../../core/net_settings.dart';
import '../../core/prefs.dart';
import '../../core/pro.dart';
import '../../core/sub_updates.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/app.dart' as rapi;
import '../../src/rust/api/models.dart';
import '../../webview/web_auth.dart';
import '../../widgets/common.dart';
import '../lock/lock_screen.dart';
import '../mine/keyframes_page.dart';
import '../pro/pro_page.dart';
import 'network_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  CacheStats? _cache;
  late NetSettings _net = rapi.netSettings();
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadCache();
    PackageInfo.fromPlatform().then((p) {
      if (mounted) setState(() => _version = '${p.version} (${p.buildNumber})');
    });
  }

  Future<void> _loadCache() async {
    final c = await rapi.cacheStats();
    if (mounted) setState(() => _cache = c);
  }

  Future<void> _saveNet(NetSettings s) async {
    try {
      await rapi.setNetSettings(s: s);
      setState(() => _net = s);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<T?> _choose<T>(String title, List<(T, String)> options, T current) => showDialog<T>(
        context: context,
        builder: (c) => SimpleDialog(
          title: Text(title),
          children: [
            RadioGroup<T>(
              groupValue: current,
              onChanged: (v) => Navigator.pop(c, v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [for (final o in options) RadioListTile<T>(value: o.$1, title: Text(o.$2))],
              ),
            ),
          ],
        ),
      );

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(t, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
      );

  Future<void> _toggleLock(bool v) async {
    if (v) {
      final hash = await push<String>(context, const PinSetupPage());
      if (hash == null) return;
      Prefs.pinHash.value = hash;
      Prefs.lockEnabled.value = true;
    } else {
      final l = AppLocalizations.of(context);
      final ok = await authenticateBiometric(l.unlockReason) || await _verifyPin();
      if (!ok) return;
      Prefs.lockEnabled.value = false;
      Prefs.pinHash.value = '';
    }
  }

  Future<bool> _verifyPin() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => Dialog(
        child: SizedBox(
          width: 360,
          height: 520,
          child: LockScreen(onUnlocked: () => Navigator.pop(c, true)),
        ),
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = _cache;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: SignalBuilder(
        builder: (context) => ListView(
          padding: EdgeInsets.only(bottom: 32 + MediaQuery.paddingOf(context).bottom),
          children: [
            _header(l.general),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l.theme),
              subtitle: Text(switch (Prefs.theme.signal.value) {
                'light' => l.themeLight,
                'dark' => l.themeDark,
                _ => l.followSystem,
              }),
              onTap: () async {
                final v = await _choose(l.theme, [('system', l.followSystem), ('light', l.themeLight), ('dark', l.themeDark)],
                    Prefs.theme.value);
                if (v != null) Prefs.theme.value = v;
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.language),
              subtitle: Text(_langName(l, Prefs.locale.signal.value)),
              onTap: () async {
                final v = await _choose(
                  l.language,
                  [for (final k in ['system', 'zh', 'zh_TW', 'en', 'ja']) (k, _langName(l, k))],
                  Prefs.locale.value,
                );
                if (v != null) Prefs.locale.value = v;
              },
            ),
            ListTile(
              leading: const Icon(Icons.subtitles_outlined),
              title: Text(l.videoLanguage),
              subtitle: Text(_net.videoLanguage == 'zht' ? l.traditionalChinese : l.simplifiedChinese),
              onTap: () async {
                final v = await _choose(l.videoLanguage, [('zhs', l.simplifiedChinese), ('zht', l.traditionalChinese)],
                    _net.videoLanguage);
                if (v != null) _saveNet(_net.copyWith(videoLanguage: v));
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.comments_disabled_outlined),
              title: Text(l.hideComments),
              value: Prefs.hideComments.signal.value,
              onChanged: (v) => Prefs.hideComments.value = v,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.content_paste_search),
              title: Text(l.clipboardDetect),
              subtitle: Text(l.clipboardDetectHint),
              value: Prefs.clipboardDetect.signal.value,
              onChanged: (v) => Prefs.clipboardDetect.value = v,
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(l.networkSettings),
              subtitle: Text(rapi.baseUrl()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await push(context, const NetworkSettingsPage());
                setState(() => _net = rapi.netSettings());
              },
            ),
            _header(l.player),
            ListTile(
              leading: const Icon(Icons.high_quality_outlined),
              title: Text(l.defaultQuality),
              subtitle: Text(Prefs.defaultQuality.signal.value),
              onTap: () async {
                final v = await _choose(l.defaultQuality, [for (final q in ['1080P', '720P', '480P', '360P']) (q, q)],
                    Prefs.defaultQuality.value);
                if (v != null) Prefs.defaultQuality.value = v;
              },
            ),
            ListTile(
              leading: const Icon(Icons.fast_forward_outlined),
              title: Text(l.longPressSpeed),
              subtitle: Text('${Prefs.longPressSpeed.signal.value}x'),
              onTap: () async {
                final v = await _choose(l.longPressSpeed, [for (final s in [1.5, 2.0, 2.5, 3.0]) (s, '${s}x')],
                    Prefs.longPressSpeed.value);
                if (v != null) Prefs.longPressSpeed.value = v;
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.swipe_outlined),
              title: Text(l.gestures),
              subtitle: Text(l.gesturesHint),
              value: Prefs.gestures.signal.value,
              onChanged: (v) => Prefs.gestures.value = v,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.history_toggle_off),
              title: Text(l.resumePlayback),
              value: Prefs.resumePlayback.signal.value,
              onChanged: (v) => Prefs.resumePlayback.value = v,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.screen_rotation_outlined),
              title: Text(l.fullscreenLandscape),
              value: Prefs.autoFullscreenLandscape.signal.value,
              onChanged: (v) => Prefs.autoFullscreenLandscape.value = v,
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: Text(l.hKeyframes),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => push(context, const KeyframesPage()),
            ),
            _header(l.downloads),
            ListTile(
              leading: const Icon(Icons.call_split),
              title: Text(l.downloadConcurrency),
              subtitle: Text('${_net.downloadConcurrency}'),
              onTap: () async {
                final pro = Pro.powered.value;
                final v = await showDialog<int>(
                  context: context,
                  builder: (c) => SimpleDialog(
                    title: Text(l.downloadConcurrency),
                    children: [
                      for (final n in [1, 2, 3, 4, 5])
                        ListTile(
                          title: Text('$n', style: TextStyle(color: n > 1 && !pro ? Theme.of(c).disabledColor : null)),
                          trailing: _net.downloadConcurrency == n ? const Icon(Icons.check) : null,
                          onTap: () {
                            if (n > 1 && !Pro.isPro) {
                              Navigator.pop(c);
                              Future.microtask(() {
                                if (!context.mounted) return;
                                toast(context, l.needPro);
                                push(context, const ProPage());
                              });
                              return;
                            }
                            Navigator.pop(c, n);
                          },
                        ),
                    ],
                  ),
                );
                if (v != null) _saveNet(_net.copyWith(downloadConcurrency: v));
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.fiber_new_outlined),
              title: Text(l.subscriptionUpdates),
              subtitle: Text(l.subscriptionUpdatesHint),
              value: Prefs.subUpdates.signal.value,
              onChanged: (v) {
                Prefs.subUpdates.value = v;
                if (!v) subscriptionNewCount.value = 0;
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: Text(l.speedLimit),
              subtitle: Text(_net.downloadSpeedLimitKb == 0 ? l.unlimited : '${formatBytes(_net.downloadSpeedLimitKb * 1024)}/s'),
              onTap: () async {
                final v = await _choose(
                  l.speedLimit,
                  [for (final k in [0, 512, 1024, 2048, 5120, 10240]) (k, k == 0 ? l.unlimited : '${formatBytes(k * 1024)}/s')],
                  _net.downloadSpeedLimitKb,
                );
                if (v != null) _saveNet(_net.copyWith(downloadSpeedLimitKb: v));
              },
            ),
            _header(l.privacy),
            SwitchListTile(
              secondary: const Icon(Icons.lock_outline),
              title: Text(l.appLock),
              subtitle: Text(l.appLockHint),
              value: Prefs.lockEnabled.signal.value && Prefs.pinHash.signal.value.isNotEmpty,
              onChanged: _toggleLock,
            ),
            if (Prefs.lockEnabled.signal.value) ...[
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: Text(l.changePin),
                onTap: () async {
                  if (!await _verifyPin()) return;
                  if (!context.mounted) return;
                  final hash = await push<String>(context, const PinSetupPage());
                  if (hash != null) Prefs.pinHash.value = hash;
                },
              ),
              if (biometricPlatform)
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(l.biometric),
                  value: Prefs.biometric.signal.value,
                  onChanged: (v) => Prefs.biometric.value = v,
                ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l.lockDelay),
                subtitle: Text(_delayName(l, Prefs.lockDelaySec.signal.value)),
                onTap: () async {
                  final v = await _choose(l.lockDelay, [for (final d in [0, 60, 300]) (d, _delayName(l, d))],
                      Prefs.lockDelaySec.value);
                  if (v != null) Prefs.lockDelaySec.value = v;
                },
              ),
            ],
            SwitchListTile(
              secondary: const Icon(Icons.blur_on),
              title: Text(l.blurInBackground),
              subtitle: Text(l.blurInBackgroundHint),
              value: Prefs.blurInBackground.signal.value,
              onChanged: (v) => Prefs.blurInBackground.value = v,
            ),
            if (Native.supportsIconSwitch)
              ListTile(
                leading: const Icon(Icons.app_shortcut_outlined),
                title: Text(l.disguiseIcon),
                subtitle: Text(_iconName(l, Prefs.disguiseIcon.signal.value)),
                onTap: () async {
                  final v = await _choose(
                    l.disguiseIcon,
                    [for (final k in ['default', 'calc', 'cornhub', 'xxt']) (k, _iconName(l, k))],
                    Prefs.disguiseIcon.value,
                  );
                  if (v == null || v == Prefs.disguiseIcon.value) return;
                  if (await Native.setLauncherIcon(v)) {
                    Prefs.disguiseIcon.value = v;
                    if (context.mounted) toast(context, l.disguiseIconHint);
                  }
                },
              ),
            _header(l.storage),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(l.imageCache),
              subtitle: Text(c == null ? '…' : '${formatBytes(c.imageBytes)} / ${_net.imageCacheLimitMb} MB'),
              onTap: () async {
                final v = await _choose(l.imageCacheLimit, [for (final m in [128, 256, 512, 1024, 2048]) (m, '$m MB')],
                    _net.imageCacheLimitMb);
                if (v != null) await _saveNet(_net.copyWith(imageCacheLimitMb: v));
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l.pageCache),
              subtitle: Text(c == null ? '…' : formatBytes(c.pageBytes)),
            ),
            ListTile(
              leading: const Icon(Icons.web_outlined),
              title: Text(l.webviewData),
              subtitle: Text(c == null ? '…' : formatBytes(c.webviewBytes)),
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(l.clearCache),
              subtitle: Text(l.clearCacheHint),
              onTap: () async {
                if (!await confirm(context, l.clearCache, content: l.clearCacheHint)) return;
                await rapi.cacheClear();
                await WebAuth.clearData();
                PaintingBinding.instance.imageCache.clear();
                await _loadCache();
                if (context.mounted) toast(context, l.cleared);
              },
            ),
            _header(l.about),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.appName),
              subtitle: Text(_version),
            ),
            ListTile(
              leading: AppUpdate.showDot ? const Badge(child: Icon(Icons.system_update_alt)) : const Icon(Icons.system_update_alt),
              title: Text(l.checkUpdate),
              onTap: () async {
                toast(context, l.checkingUpdate);
                await AppUpdate.refresh();
                if (!context.mounted) return;
                if (AppUpdate.latest.value == null) {
                  toast(context, l.alreadyLatest);
                  return;
                }
                await AppUpdate.present(context, manual: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_outlined, color: Pro.isPro ? null : Theme.of(context).disabledColor),
              title: Text(l.updateRemind, style: TextStyle(color: Pro.isPro ? null : Theme.of(context).disabledColor)),
              subtitle: Text(l.updateRemindHint),
              trailing: Switch(
                value: Pro.isPro ? Prefs.updateRemind.signal.value : true,
                onChanged: Pro.isPro ? (v) => Prefs.updateRemind.value = v : null,
              ),
              onTap: () {
                if (!Pro.isPro) {
                  toast(context, l.needPro);
                  push(context, const ProPage());
                  return;
                }
                Prefs.updateRemind.value = !Prefs.updateRemind.value;
              },
            ),
            if (AppUpdate.latest.value != null)
              ListTile(
                leading: const Icon(Icons.new_releases_outlined),
                title: Text(l.newVersionFound(AppUpdate.latest.value!)),
                subtitle: Text(
                  AppUpdate.changeLog.value.isEmpty ? l.downloadUpdate : AppUpdate.changeLog.value,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: AppUpdate.openDownload,
              ),
          ],
        ),
      ),
    );
  }

  String _langName(AppLocalizations l, String k) => switch (k) {
        'zh' => '简体中文',
        'zh_TW' => '繁體中文',
        'en' => 'English',
        'ja' => '日本語',
        _ => l.followSystem,
      };

  String _delayName(AppLocalizations l, int s) => switch (s) {
        0 => l.lockImmediately,
        60 => l.lockAfter1Min,
        _ => l.lockAfter5Min,
      };

  String _iconName(AppLocalizations l, String k) => switch (k) {
        'calc' => l.iconCalc,
        'cornhub' => 'Cornhub',
        'xxt' => l.iconXxt,
        _ => l.iconDefault,
      };
}
