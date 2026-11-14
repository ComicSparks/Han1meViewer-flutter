import 'dart:async';
import 'dart:convert';
import 'dart:io';

final _extinf = RegExp(r'#EXTINF:([0-9.]+)');
final _bandwidth = RegExp(r'BANDWIDTH=(\d+)');

/// 播放器还没报出时长时，把 m3u8 里的分段长度加起来。
Future<Duration?> playlistDuration(String url, Map<String, String>? headers) async {
  try {
    final body = await _get(url, headers);
    if (body == null) return null;
    if (body.contains('#EXT-X-STREAM-INF')) {
      final variant = _bestVariant(body, url);
      if (variant != null) {
        final media = await _get(variant, headers);
        final summed = media == null ? null : _sum(media);
        if (summed != null) return summed;
      }
    }
    return _sum(body);
  } catch (_) {
    return null;
  }
}

Duration? _sum(String body) {
  var seconds = 0.0;
  for (final m in _extinf.allMatches(body)) {
    seconds += double.tryParse(m.group(1)!) ?? 0;
  }
  if (seconds <= 0) return null;
  return Duration(milliseconds: (seconds * 1000).round());
}

String? _bestVariant(String body, String base) {
  final lines = body.split('\n');
  String? best;
  var bestBw = -1;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (!line.startsWith('#EXT-X-STREAM-INF')) continue;
    final bandwidth = int.tryParse(_bandwidth.firstMatch(line)?.group(1) ?? '') ?? 0;
    String? uri;
    for (var j = i + 1; j < lines.length; j++) {
      final next = lines[j].trim();
      if (next.isEmpty) continue;
      if (next.startsWith('#')) break;
      uri = next;
      break;
    }
    if (uri != null && bandwidth >= bestBw) {
      bestBw = bandwidth;
      best = Uri.parse(base).resolve(uri).toString();
    }
  }
  return best;
}

Future<String?> _get(String url, Map<String, String>? headers) async {
  final client = HttpClient();
  try {
    client.connectionTimeout = const Duration(seconds: 8);
    final req = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 8));
    headers?.forEach((name, value) {
      try {
        req.headers.set(name, value);
      } catch (_) {}
    });
    final resp = await req.close().timeout(const Duration(seconds: 8));
    if (resp.statusCode >= 400) {
      await resp.drain<void>();
      return null;
    }
    final bytes = <int>[];
    await for (final chunk in resp.timeout(const Duration(seconds: 8))) {
      bytes.addAll(chunk);
      if (bytes.length > 512 * 1024) break;
    }
    return utf8.decode(bytes, allowMalformed: true);
  } finally {
    client.close(force: true);
  }
}
