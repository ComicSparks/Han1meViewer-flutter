import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../src/rust/api/app.dart' as rapi;

const _redirects = {301, 302, 303, 307, 308};

class MediaText {
  final String finalUrl;
  final String text;
  final bool truncated;
  const MediaText(this.finalUrl, this.text, this.truncated);
}

class OpenedMedia {
  final HttpClient client;
  final HttpClientResponse response;
  final String finalUrl;
  const OpenedMedia(this.client, this.response, this.finalUrl);

  Future<void> close() async {
    try {
      await response.drain<void>();
    } catch (_) {}
    client.close(force: true);
  }
}

/// 每个跳转都重新带上 UA / Referer，并按最终主机附上 Cookie。
Future<OpenedMedia?> openMedia(
  String url,
  Map<String, String>? headers, {
  String? range,
}) async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 15);
  try {
    var current = Uri.parse(url);
    for (var hop = 0; hop < 5; hop++) {
      final req = await client.getUrl(current).timeout(const Duration(seconds: 15));
      req.followRedirects = false;
      _apply(req, current.toString(), headers);
      if (range != null && range.isNotEmpty) {
        req.headers.set(HttpHeaders.rangeHeader, range);
      }
      final resp = await req.close().timeout(const Duration(seconds: 20));
      if (_redirects.contains(resp.statusCode)) {
        final loc = resp.headers.value(HttpHeaders.locationHeader);
        await resp.drain<void>();
        if (loc == null || loc.isEmpty) break;
        current = current.resolve(loc);
        continue;
      }
      return OpenedMedia(client, resp, current.toString());
    }
  } catch (_) {}
  client.close(force: true);
  return null;
}

Future<MediaText?> readMediaText(
  String url,
  Map<String, String>? headers, {
  int maxBytes = 8 * 1024 * 1024,
}) async {
  final opened = await openMedia(url, headers);
  if (opened == null) return null;
  try {
    if (opened.response.statusCode >= 400) return null;
    final bytes = <int>[];
    var truncated = false;
    await for (final chunk in opened.response.timeout(const Duration(seconds: 20))) {
      bytes.addAll(chunk);
      if (bytes.length > maxBytes) {
        truncated = true;
        break;
      }
    }
    return MediaText(opened.finalUrl, utf8.decode(bytes, allowMalformed: true), truncated);
  } catch (_) {
    return null;
  } finally {
    await opened.close();
  }
}

void _apply(HttpClientRequest req, String url, Map<String, String>? headers) {
  headers?.forEach((name, value) {
    if (name.toLowerCase() == 'cookie' || value.isEmpty) return;
    try {
      req.headers.set(name, value);
    } catch (_) {}
  });
  try {
    final cookie = rapi.cookieHeader(url: url);
    if (cookie.isNotEmpty) req.headers.set(HttpHeaders.cookieHeader, cookie);
  } catch (_) {}
}
