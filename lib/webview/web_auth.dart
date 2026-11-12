import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/nav.dart';
import '../l10n/gen/app_localizations.dart';
import '../src/rust/api/app.dart' as rapi;
import '../src/rust/api/models.dart';

enum WebAuthMode { challenge, login }

class WebAuthResult {
  final List<CookieItem> cookies;
  final String userAgent;
  const WebAuthResult(this.cookies, this.userAgent);
}

const _cfName = 'cf_clearance';

/// WebView 过盾与网页登录。移动端 / macOS / Windows 用 inappwebview，Linux 用独立窗口
class WebAuth {
  WebAuth._();

  static WebViewEnvironment? _env;
  static bool _available = true;
  static StreamSubscription<CfChallengeEvent>? _sub;
  static Future<void> _queue = Future.value();

  static bool get useDesktopWindow => Platform.isLinux;
  static bool get available => _available;

  static Future<void> init() async {
    if (Platform.isWindows) {
      try {
        final ver = await WebViewEnvironment.getAvailableVersion();
        if (ver == null) {
          _available = false;
        } else {
          _env = await WebViewEnvironment.create(
            settings: WebViewEnvironmentSettings(userDataFolder: await rapi.webviewDataDir()),
          );
        }
      } catch (_) {
        _available = false;
      }
    } else if (Platform.isLinux) {
      try {
        _available = await WebviewWindow.isWebviewAvailable();
      } catch (_) {
        _available = false;
      }
    }
  }

  static WebViewEnvironment? get environment => _env;

  static CookieManager get cookieManager => CookieManager.instance(webViewEnvironment: _env);

  /// 监听 Rust 发出的 CF 挑战，串行弹出验证页
  static void listen() {
    _sub ??= rapi.cfChallengeStream().listen((event) {
      _queue = _queue.then((_) => _handle(event)).catchError((_) {});
    });
  }

  static Future<void> _handle(CfChallengeEvent event) async {
    WebAuthResult? result;
    try {
      final ctx = await waitNavigatorContext();
      if (ctx != null && ctx.mounted && _available) {
        result = await open(ctx, event.url, WebAuthMode.challenge);
      }
    } catch (_) {
      result = null;
    }
    await rapi.cfFinish(
      id: event.id,
      success: result != null,
      cookies: result?.cookies ?? const [],
      userAgent: result?.userAgent ?? '',
    );
  }

  /// 打开验证 / 登录页面，成功返回 Cookie 与 WebView 的真实 UA
  static Future<WebAuthResult?> open(BuildContext context, String url, WebAuthMode mode) {
    if (useDesktopWindow) return _openLinux(context, url, mode);
    return Navigator.of(context).push<WebAuthResult>(
      MaterialPageRoute(builder: (_) => WebAuthPage(url: url, mode: mode), fullscreenDialog: true),
    );
  }

  /// 网页登录：成功后 Cookie 已经同步进 Rust
  static Future<bool> webLogin(BuildContext context) async {
    final url = '${rapi.baseUrl()}login';
    final r = await open(context, url, WebAuthMode.login);
    if (r == null) return false;
    await rapi.applyWebviewCookies(cookies: r.cookies, userAgent: r.userAgent);
    return true;
  }

  /// 主动打开站点首页做一次验证（设置页使用）
  static Future<bool> verifyManually(BuildContext context) async {
    final r = await open(context, rapi.baseUrl(), WebAuthMode.challenge);
    if (r == null) return false;
    return rapi.applyWebviewCookies(cookies: r.cookies, userAgent: r.userAgent);
  }

  static Future<void> clearData() async {
    try {
      if (useDesktopWindow) {
        await WebviewWindow.clearAll();
      } else {
        await cookieManager.deleteAllCookies();
        if (!Platform.isWindows) await InAppWebViewController.clearAllCache();
      }
    } catch (_) {}
  }

  /// Android WebView 默认 UA 带有 `; wv`、`Build/…`、`Version/4.0`，去掉后才是普通 Chrome 的样子
  static Future<String?> androidUserAgent() async {
    if (!Platform.isAndroid) return null;
    try {
      var ua = await InAppWebViewController.getDefaultUserAgent();
      ua = ua.replaceAll('; wv', '');
      ua = ua.replaceAll(RegExp(r'\s*Build/[^;)]*'), '');
      ua = ua.replaceAll(RegExp(r'\s*Version/[\d.]+'), '');
      return ua.replaceAll(RegExp(r'\s{2,}'), ' ');
    } catch (_) {
      return null;
    }
  }

  static CookieItem fromCookie(Cookie c, String host) => CookieItem(
        name: c.name,
        value: c.value?.toString() ?? '',
        domain: (c.domain == null || c.domain!.isEmpty) ? host : c.domain!,
        path: c.path ?? '/',
        expires: c.expiresDate == null ? null : (c.expiresDate! ~/ 1000),
      );

  static Future<WebAuthResult?> _openLinux(BuildContext context, String url, WebAuthMode mode) async {
    final l = AppLocalizations.of(context);
    final host = Uri.parse(url).host;
    final webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        title: mode == WebAuthMode.challenge ? l.cfVerifyTitle : l.webLogin,
        windowWidth: 900,
        windowHeight: 720,
      ),
    );
    final completer = Completer<WebAuthResult?>();
    String? baseline;
    try {
      final initial = await webview.getAllCookies();
      baseline = initial.where((c) => c.name == _cfName && _hostMatch(host, c.domain)).map((c) => c.value).firstOrNull;
    } catch (_) {}

    Future<void> finish() async {
      if (completer.isCompleted) return;
      final all = await webview.getAllCookies();
      final items = all
          .where((c) => _hostMatch(host, c.domain))
          .map((c) => CookieItem(
                name: c.name,
                value: c.value,
                domain: c.domain,
                path: c.path,
                expires: c.expires == null ? null : c.expires!.millisecondsSinceEpoch ~/ 1000,
              ))
          .toList();
      final ua = (await webview.evaluateJavaScript('navigator.userAgent'))?.replaceAll('"', '') ?? '';
      if (!completer.isCompleted) completer.complete(WebAuthResult(items, ua));
      webview.close();
    }

    Timer? timer;
    if (mode == WebAuthMode.challenge) {
      timer = Timer.periodic(const Duration(milliseconds: 800), (_) async {
        try {
          final cs = await webview.getAllCookies();
          final v = cs.where((c) => c.name == _cfName && _hostMatch(host, c.domain)).map((c) => c.value).firstOrNull;
          if (v != null && v.isNotEmpty && v != baseline) await finish();
        } catch (_) {}
      });
    } else {
      webview.setOnUrlRequestCallback((u) {
        final uri = Uri.tryParse(u);
        if (uri != null && uri.host == host && !uri.path.startsWith('/login') && !uri.path.startsWith('/register') && !uri.path.startsWith('/password')) {
          Future.delayed(const Duration(milliseconds: 600), finish);
        }
        return true;
      });
    }
    webview.onClose.then((_) {
      if (!completer.isCompleted) completer.complete(null);
    });
    webview.launch(url);
    final r = await completer.future;
    timer?.cancel();
    return r;
  }
}

bool _hostMatch(String host, String domain) {
  final d = domain.startsWith('.') ? domain.substring(1) : domain;
  return host == d || host.endsWith('.$d');
}

class WebAuthPage extends StatefulWidget {
  final String url;
  final WebAuthMode mode;
  const WebAuthPage({super.key, required this.url, required this.mode});

  @override
  State<WebAuthPage> createState() => _WebAuthPageState();
}

class _WebAuthPageState extends State<WebAuthPage> {
  InAppWebViewController? _controller;
  Timer? _timer;
  String? _ua;
  bool _ready = false;
  bool _done = false;
  double _progress = 0;
  late final WebUri _uri = WebUri(widget.url);
  late final String _host = Uri.parse(widget.url).host;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    _ua = await WebAuth.androidUserAgent();
    if (widget.mode == WebAuthMode.challenge) {
      final cm = WebAuth.cookieManager;
      for (final d in [_host, '.$_host', null]) {
        try {
          await cm.deleteCookie(url: _uri, name: _cfName, domain: d);
        } catch (_) {}
      }
      _timer = Timer.periodic(const Duration(milliseconds: 800), (_) => _poll());
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<List<Cookie>> _cookies() async {
    try {
      return await WebAuth.cookieManager.getCookies(url: _uri, webViewController: _controller);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _poll() async {
    if (_done || _controller == null) return;
    final cs = await _cookies();
    final cf = cs.where((c) => c.name == _cfName).firstOrNull;
    if (cf != null && (cf.value?.toString() ?? '').isNotEmpty) await _finish(cs);
  }

  Future<void> _finish([List<Cookie>? got]) async {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    final cs = got ?? await _cookies();
    String ua = _ua ?? '';
    try {
      final r = await _controller?.evaluateJavascript(source: 'navigator.userAgent');
      if (r is String && r.isNotEmpty) ua = r;
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop(WebAuthResult(cs.map((c) => WebAuth.fromCookie(c, _host)).toList(), ua));
  }

  void _onUrl(WebUri? url) {
    if (widget.mode != WebAuthMode.login || url == null) return;
    if (url.host != _host) return;
    final p = url.path;
    if (p.startsWith('/login') || p.startsWith('/register') || p.startsWith('/password') || p.startsWith('/cdn-cgi')) return;
    _finish();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == WebAuthMode.challenge ? l.cfVerifyTitle : l.webLogin),
        actions: [
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 2),
              )
            : null,
      ),
      body: Column(
        children: [
          if (widget.mode == WebAuthMode.challenge)
            MaterialBanner(
              content: Text(l.cfVerifyHint),
              leading: const Icon(Icons.shield_outlined),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: !_ready
                ? const Center(child: CircularProgressIndicator())
                : InAppWebView(
                    webViewEnvironment: WebAuth.environment,
                    initialUrlRequest: URLRequest(url: _uri),
                    initialSettings: InAppWebViewSettings(
                      userAgent: _ua ?? '',
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      thirdPartyCookiesEnabled: true,
                      sharedCookiesEnabled: true,
                      incognito: false,
                      isInspectable: false,
                    ),
                    onWebViewCreated: (c) => _controller = c,
                    onProgressChanged: (c, p) => setState(() => _progress = p / 100),
                    onLoadStop: (c, url) async {
                      if (widget.mode == WebAuthMode.challenge) {
                        await _poll();
                      } else {
                        _onUrl(url);
                      }
                    },
                    onUpdateVisitedHistory: (c, url, reload) => _onUrl(url),
                  ),
          ),
        ],
      ),
    );
  }
}
