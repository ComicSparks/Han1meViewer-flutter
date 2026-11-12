import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../webview/web_auth.dart';

/// 第一次进入时的浏览器。地址栏输入激活地址后才进入应用。
class UnlockBrowserPage extends StatefulWidget {
  final VoidCallback onUnlocked;
  const UnlockBrowserPage({super.key, required this.onUnlocked});

  @override
  State<UnlockBrowserPage> createState() => _UnlockBrowserPageState();
}

class _UnlockBrowserPageState extends State<UnlockBrowserPage> {
  static const _activation = 'ha://start';
  static const _defaultUrl = 'https://www.bing.com/';

  final _address = TextEditingController(text: _defaultUrl);
  final _addressFocus = FocusNode();
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _unlocking = false;

  @override
  void dispose() {
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  bool _isActivation(String url) {
    final normalized = url.trim().toLowerCase();
    return normalized == _activation ||
        normalized == '$_activation/' ||
        normalized.startsWith('$_activation?') ||
        normalized.startsWith('$_activation#');
  }

  Uri _toUri(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return Uri.parse('about:blank');
    final uri = Uri.tryParse(raw);
    if (uri == null) return Uri.parse('about:blank');
    if (uri.hasScheme) return uri;
    return Uri.parse('https://$raw');
  }

  void _unlock() {
    if (_unlocking) return;
    _unlocking = true;
    widget.onUnlocked();
  }

  Future<void> _loadFromAddressBar(String value) async {
    if (_isActivation(value)) {
      _unlock();
      return;
    }
    final uri = _toUri(value);
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(uri.toString())));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showWebView = !Platform.isLinux && WebAuth.available;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 8,
          title: TextField(
            controller: _address,
            focusNode: _addressFocus,
            textInputAction: TextInputAction.go,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.url,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: l.browserAddressHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              isDense: true,
            ),
            onSubmitted: _loadFromAddressBar,
          ),
          actions: [
            if (showWebView) ...[
              IconButton(
                tooltip: l.browserBack,
                onPressed: () async {
                  if (await _controller?.canGoBack() == true) await _controller?.goBack();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                tooltip: l.browserForward,
                onPressed: () async {
                  if (await _controller?.canGoForward() == true) await _controller?.goForward();
                },
                icon: const Icon(Icons.arrow_forward),
              ),
              IconButton(
                tooltip: l.refresh,
                onPressed: () => _controller?.reload(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            if (_progress > 0 && _progress < 1) LinearProgressIndicator(value: _progress),
            Expanded(
              child: showWebView
                  ? InAppWebView(
                      webViewEnvironment: WebAuth.environment,
                      initialUrlRequest: URLRequest(url: WebUri(_defaultUrl)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: true,
                        allowsInlineMediaPlayback: true,
                        isInspectable: false,
                      ),
                      onWebViewCreated: (controller) => _controller = controller,
                      shouldOverrideUrlLoading: (controller, action) async {
                        final url = action.request.url?.toString() ?? '';
                        if (_isActivation(url)) {
                          unawaited(Future<void>(() => _unlock()));
                          return NavigationActionPolicy.CANCEL;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStart: (controller, url) {
                        final next = url?.toString() ?? '';
                        if (next.isEmpty || !mounted) return;
                        setState(() => _address.text = next);
                      },
                      onLoadStop: (controller, url) {
                        if (!mounted) return;
                        final next = url?.toString() ?? '';
                        setState(() {
                          if (next.isNotEmpty) _address.text = next;
                          _progress = 0;
                        });
                      },
                      onProgressChanged: (controller, progress) {
                        if (!mounted) return;
                        setState(() => _progress = progress / 100);
                      },
                    )
                  : const ColoredBox(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
