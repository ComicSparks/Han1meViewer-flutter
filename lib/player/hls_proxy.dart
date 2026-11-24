import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../src/rust/api/app.dart' as rapi;
import 'media_http.dart';
import 'playlist_duration.dart';

class IosPlayback {
  final String url;
  final bool hls;
  final Duration? duration;

  /// 直接交给 AVPlayer 的头。走本地代理时为空，由代理自己加到每个上游请求上。
  final Map<String, String>? headers;

  const IosPlayback({required this.url, required this.hls, this.duration, this.headers});
}

final _uriAttr = RegExp(r'URI="([^"]*)"');

/// 把清单里的地址改成本地代理，点播清单补上 ENDLIST，让 AVPlayer 报出有限时长。
String rewritePlaylist(
  String body,
  String baseUrl, {
  required String Function(String absolute) mapUrl,
  bool complete = true,
}) {
  final normalized = body.replaceFirst('\uFEFF', '');
  final isMaster = normalized.contains('#EXT-X-STREAM-INF');
  final hasEnd = normalized.contains('#EXT-X-ENDLIST');
  var hasInf = false;
  final out = <String>[];
  for (final line in normalized.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      out.add('');
      continue;
    }
    if (trimmed.startsWith('#')) {
      if (trimmed.startsWith('#EXTINF')) hasInf = true;
      out.add(trimmed.replaceAllMapped(_uriAttr, (m) {
        final abs = Uri.parse(baseUrl).resolve(m.group(1)!).toString();
        return 'URI="${mapUrl(abs)}"';
      }));
      continue;
    }
    out.add(mapUrl(Uri.parse(baseUrl).resolve(trimmed).toString()));
  }
  if (complete && !isMaster && hasInf && !hasEnd) out.add('#EXT-X-ENDLIST');
  return '${out.join('\n')}\n';
}

class _Proxy {
  HttpServer? _server;
  int _seq = 0;
  Map<String, String> _headers = {};
  final Map<String, _Session> _sessions = {};

  Future<IosPlayback> prepare(String url, Map<String, String>? headers) async {
    final base = _baseHeaders(headers);
    if (!shouldProbePlaylist(url)) {
      return IosPlayback(url: url, hls: false, headers: _withCookie(url, base));
    }
    final root = await readMediaText(url, base);
    if (root == null || !isHlsPlaylist(root.text)) {
      return IosPlayback(url: url, hls: false, headers: _withCookie(url, base));
    }
    Duration? duration;
    if (root.text.contains('#EXT-X-STREAM-INF')) {
      final variant = bestVariantUrl(root.text, root.finalUrl);
      if (variant != null) {
        final media = await readMediaText(variant, base);
        duration = media == null ? null : sumPlaylist(media.text);
      }
    } else {
      duration = sumPlaylist(root.text);
    }
    try {
      await _ensure();
    } catch (_) {
      return IosPlayback(url: url, hls: true, duration: duration, headers: _withCookie(url, base));
    }
    final id = '${++_seq}';
    _headers = base;
    _sessions.removeWhere((_, s) => _seq - s.seq > 2);
    final master = root.text.contains('#EXT-X-STREAM-INF');
    _sessions[id] = _Session(
      seq: _seq,
      body: root.text,
      finalUrl: root.finalUrl,
      complete: !master && !root.truncated,
    );
    return IosPlayback(
      url: 'http://127.0.0.1:${_server!.port}/p/$id.m3u8',
      hls: true,
      duration: duration,
    );
  }

  Future<void> _ensure() async {
    if (_server != null) return;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0, shared: true);
    _server = server;
    server.listen((req) {
      unawaited(_handle(req));
    });
  }

  Future<void> _handle(HttpRequest req) async {
    try {
      final path = req.uri.path;
      if (req.method != 'GET' && req.method != 'HEAD') {
        req.response.statusCode = HttpStatus.methodNotAllowed;
        await req.response.close();
        return;
      }
      final root = RegExp(r'^/p/(\d+)\.m3u8$').firstMatch(path);
      if (root != null) {
        final session = _sessions[root.group(1)];
        if (session == null) {
          req.response.statusCode = HttpStatus.notFound;
          await req.response.close();
          return;
        }
        await _sendPlaylist(req, session.body, session.finalUrl, complete: session.complete);
        return;
      }
      if (path == '/s') {
        final upstream = req.uri.queryParameters['u'];
        if (upstream == null || !(upstream.startsWith('https://') || upstream.startsWith('http://'))) {
          req.response.statusCode = HttpStatus.badRequest;
          await req.response.close();
          return;
        }
        await _forward(req, upstream, _headers);
        return;
      }
      req.response.statusCode = HttpStatus.notFound;
      await req.response.close();
    } catch (_) {
      try {
        req.response.statusCode = HttpStatus.badGateway;
        await req.response.close();
      } catch (_) {}
    }
  }

  Future<void> _forward(HttpRequest req, String upstream, Map<String, String>? headers) async {
    final opened = await openMedia(upstream, headers, range: req.headers.value(HttpHeaders.rangeHeader));
    if (opened == null) {
      req.response.statusCode = HttpStatus.badGateway;
      await req.response.close();
      return;
    }
    try {
      if (opened.response.statusCode >= 400) {
        req.response.statusCode = opened.response.statusCode;
        await req.response.close();
        return;
      }
      final type = opened.response.headers.contentType?.mimeType ?? '';
      final namedPlaylist = upstream.toLowerCase().contains('.m3u8') || type.contains('mpegurl') || type.contains('m3u8');
      if (namedPlaylist) {
        final read = await _readBody(opened.response);
        final text = utf8.decode(read.bytes, allowMalformed: true);
        if (isHlsPlaylist(text)) {
          await _sendPlaylist(req, text, opened.finalUrl, complete: !read.truncated);
          return;
        }
        req.response.statusCode = opened.response.statusCode;
        _copyMediaHeaders(opened.response, req.response);
        if (req.method != 'HEAD') req.response.add(read.bytes);
        await req.response.close();
        return;
      }
      final iterator = StreamIterator<List<int>>(opened.response);
      try {
        if (!await iterator.moveNext()) {
          req.response.statusCode = opened.response.statusCode;
          await req.response.close();
          return;
        }
        final first = iterator.current;
        final head = utf8.decode(first, allowMalformed: true).trimLeft();
        if (head.startsWith('#EXTM3U')) {
          final read = await _rest(iterator, first);
          final text = utf8.decode(read.bytes, allowMalformed: true);
          if (isHlsPlaylist(text)) {
            await _sendPlaylist(req, text, opened.finalUrl, complete: !read.truncated);
            return;
          }
          req.response.statusCode = opened.response.statusCode;
          _copyMediaHeaders(opened.response, req.response);
          if (req.method != 'HEAD') req.response.add(read.bytes);
          await req.response.close();
          return;
        }
        req.response.statusCode = opened.response.statusCode;
        _copyMediaHeaders(opened.response, req.response);
        if (req.method != 'HEAD') {
          req.response.add(first);
          while (await iterator.moveNext()) {
            req.response.add(iterator.current);
          }
        }
        await req.response.close();
      } finally {
        await iterator.cancel();
      }
    } finally {
      opened.client.close(force: true);
    }
  }

  Future<({List<int> bytes, bool truncated})> _readBody(HttpClientResponse response) async {
    final bytes = <int>[];
    var truncated = false;
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length > 8 * 1024 * 1024) {
        truncated = true;
        break;
      }
    }
    return (bytes: bytes, truncated: truncated);
  }

  Future<({List<int> bytes, bool truncated})> _rest(StreamIterator<List<int>> iterator, List<int> first) async {
    final bytes = <int>[...first];
    var truncated = false;
    while (await iterator.moveNext()) {
      bytes.addAll(iterator.current);
      if (bytes.length > 8 * 1024 * 1024) {
        truncated = true;
        break;
      }
    }
    return (bytes: bytes, truncated: truncated);
  }

  Future<void> _sendPlaylist(
    HttpRequest req,
    String body,
    String baseUrl, {
    required bool complete,
  }) async {
    final port = _server!.port;
    final text = rewritePlaylist(
      body,
      baseUrl,
      complete: complete,
      mapUrl: (abs) => 'http://127.0.0.1:$port/s?u=${Uri.encodeQueryComponent(abs)}',
    );
    req.response.statusCode = HttpStatus.ok;
    req.response.headers.contentType = ContentType('application', 'vnd.apple.mpegurl', charset: 'utf-8');
    req.response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    if (req.method != 'HEAD') req.response.write(text);
    await req.response.close();
  }
}

class _Session {
  final int seq;
  final String body;
  final String finalUrl;
  final bool complete;
  const _Session({required this.seq, required this.body, required this.finalUrl, required this.complete});
}

Map<String, String> _baseHeaders(Map<String, String>? headers) {
  final out = <String, String>{};
  for (final name in ['User-Agent', 'Referer']) {
    final value = headers?[name];
    if (value != null && value.isNotEmpty) out[name] = value;
  }
  return out;
}

Map<String, String> _withCookie(String url, Map<String, String> base) {
  final out = Map<String, String>.from(base);
  try {
    final cookie = rapi.cookieHeader(url: url);
    if (cookie.isNotEmpty) out['Cookie'] = cookie;
  } catch (_) {}
  return out;
}

void _copyMediaHeaders(HttpClientResponse from, HttpResponse to) {
  const keep = ['content-type', 'content-length', 'content-range', 'accept-ranges'];
  from.headers.forEach((name, values) {
    if (!keep.contains(name.toLowerCase()) || values.isEmpty) return;
    try {
      to.headers.set(name, values.length == 1 ? values.single : values);
    } catch (_) {}
  });
}

final _proxy = _Proxy();

/// iOS 上把 HLS 转到本机，每个上游请求都带 UA、Referer 和该主机的 Cookie。
Future<IosPlayback> prepareIosPlayback(String url, Map<String, String>? headers) => _proxy.prepare(url, headers);
