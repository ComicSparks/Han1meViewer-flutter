import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/app_update.dart';
import 'core/downloads.dart';
import 'core/metrics.dart';
import 'core/nav.dart';
import 'core/prefs.dart';
import 'core/pro.dart';
import 'l10n/gen/app_localizations.dart';
import 'pages/lock/lock_screen.dart';
import 'pages/lock/unlock_browser_page.dart';
import 'pages/shell.dart';
import 'src/rust/api/hanime.dart' as hanime;

const seedColor = Color(0xFF904A43);

class HvfApp extends StatelessWidget {
  const HvfApp({super.key});

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: b),
        visualDensity: VisualDensity.standard,
      );

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) => MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: messengerKey,
        navigatorObservers: [routeObserver],
        title: 'HaVF',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: Prefs.theme.signal.value == 'system' ? ThemeMode.system : Prefs.themeMode,
        locale: Prefs.locale.signal.value == 'system' ? null : Prefs.localeValue,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: (locales, supported) => resolveLocale(locales),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          // 三星透明导航栏常常只出现在 systemGestureInsets，padding.bottom 为 0，内容会画到栏下面。
          final bottom = mq.viewInsets.bottom > 0
              ? mq.padding.bottom
              : math.max(mq.padding.bottom, math.max(mq.viewPadding.bottom, mq.systemGestureInsets.bottom));
          return MediaQuery(
            data: mq.copyWith(
              padding: mq.padding.copyWith(bottom: bottom),
              viewPadding: mq.viewPadding.copyWith(bottom: bottom),
            ),
            child: AppGuard(child: child ?? const SizedBox.shrink()),
          );
        },
        home: HomeShell(key: homeShellKey),
      ),
    );
  }
}

Locale resolveLocale(List<Locale>? locales) {
  for (final l in locales ?? const <Locale>[]) {
    switch (l.languageCode) {
      case 'zh':
        final trad = l.scriptCode == 'Hant' || const {'TW', 'HK', 'MO'}.contains(l.countryCode);
        return trad ? const Locale('zh', 'TW') : const Locale('zh');
      case 'en':
        return const Locale('en');
      case 'ja':
        return const Locale('ja');
    }
  }
  return const Locale('en');
}

/// 隐私锁、后台模糊、剪贴板识别、深链接、下载前后台切换
class AppGuard extends StatefulWidget {
  final Widget child;
  const AppGuard({super.key, required this.child});

  @override
  State<AppGuard> createState() => _AppGuardState();
}

class _AppGuardState extends State<AppGuard> with WidgetsBindingObserver {
  bool _browserPassed = false;
  bool _locked = false;
  bool _obscured = false;
  DateTime? _backgroundAt;
  StreamSubscription<Uri>? _links;

  bool get _lockActive => Prefs.lockEnabled.value && Prefs.pinHash.value.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _browserPassed = Prefs.browserPassed.value;
    if (_browserPassed) _enterApp();
  }

  void _enterApp() {
    _locked = _lockActive;
    _obscured = false;
    _initLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Metrics.syncVersion();
      Metrics.noteApp();
      _checkClipboard();
      _checkUpdate();
    });
  }

  Future<void> _checkUpdate() async {
    Pro.refresh();
    await AppUpdate.refresh();
    if (!mounted || _locked) return;
    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) await AppUpdate.present(ctx);
  }

  void _onBrowserUnlocked() {
    Prefs.browserPassed.value = true;
    setState(() => _browserPassed = true);
    _enterApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _links?.cancel();
    super.dispose();
  }

  void _initLinks() {
    try {
      _links = AppLinks().uriLinkStream.listen(_onLink, onError: (_) {});
    } catch (_) {}
  }

  void _onLink(Uri uri) {
    final code = hanime.parseVideoCode(text: uri.toString());
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctx = await waitNavigatorContext();
      if (ctx != null && ctx.mounted) openVideo(ctx, code);
    });
  }

  Future<void> _checkClipboard() async {
    if (!_browserPassed || !Prefs.clipboardDetect.value || _locked) return;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text == null || text.isEmpty) return;
      final code = hanime.parseVideoCode(text: text);
      if (code == null || code == Prefs.lastClipboardCode.value) return;
      Prefs.lastClipboardCode.value = code;
      final ctx = navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final l = AppLocalizations.of(ctx);
      messengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(l.clipboardDetected(code)),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: l.open, onPressed: () => openVideo(ctx, code)),
      ));
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        final at = _backgroundAt;
        _backgroundAt = null;
        if (_lockActive && at != null && DateTime.now().difference(at).inSeconds >= Prefs.lockDelaySec.value) {
          _locked = true;
        }
        setState(() => _obscured = false);
        if (!_browserPassed) break;
        Downloads.onForeground();
        Metrics.flush();
        _checkClipboard();
      case AppLifecycleState.inactive:
        if (!_browserPassed) break;
        if (Prefs.blurInBackground.value || _lockActive) setState(() => _obscured = true);
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _backgroundAt ??= DateTime.now();
        if (_browserPassed && (Prefs.blurInBackground.value || _lockActive)) setState(() => _obscured = true);
        if (_browserPassed) Downloads.onBackground();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_browserPassed) {
      // builder 在 Navigator 外面，这里再套一层，地址栏和按钮才能找到 Overlay。
      return Navigator(
        pages: [
          MaterialPage<void>(
            key: const ValueKey('unlock-browser'),
            child: UnlockBrowserPage(onUnlocked: _onBrowserUnlocked),
          ),
        ],
        onDidRemovePage: (page) {},
      );
    }
    // 桌面端失焦不模糊，避免影响多窗口使用
    final allowObscure = Platform.isAndroid || Platform.isIOS;
    return Stack(
      children: [
        widget.child,
        if (_obscured && allowObscure && !_locked)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6)),
            ),
          ),
        if (_locked)
          Positioned.fill(
            child: LockScreen(
              onUnlocked: () {
                setState(() => _locked = false);
                _checkClipboard();
                _checkUpdate();
              },
            ),
          ),
      ],
    );
  }
}
