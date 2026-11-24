import 'media_http.dart';

final _extinf = RegExp(r'#EXTINF:([0-9.]+)');
final _bandwidth = RegExp(r'BANDWIDTH=(\d+)');

const _progressive = ['.mp4', '.webm', '.mkv', '.mov', '.m4v', '.avi', '.mp3', '.m4a'];

/// 路径像普通媒体文件时不去拉正文。其余地址用内容是不是 `#EXTM3U` 判断。
bool shouldProbePlaylist(String url) {
  final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
  if (path.contains('.m3u8')) return true;
  return !_progressive.any(path.endsWith);
}

bool isHlsPlaylist(String body) {
  final text = body.trimLeft().replaceFirst('\uFEFF', '');
  return text.startsWith('#EXTM3U');
}

/// 播放器还没报出时长时，把 m3u8 里的分段长度加起来。
Future<Duration?> playlistDuration(String url, Map<String, String>? headers) async {
  if (!shouldProbePlaylist(url)) return null;
  try {
    final root = await readMediaText(url, headers);
    if (root == null || !isHlsPlaylist(root.text)) return null;
    if (root.text.contains('#EXT-X-STREAM-INF')) {
      final variant = bestVariantUrl(root.text, root.finalUrl);
      if (variant == null) return null;
      final media = await readMediaText(variant, headers);
      if (media == null) return null;
      return sumPlaylist(media.text);
    }
    return sumPlaylist(root.text);
  } catch (_) {
    return null;
  }
}

Duration? sumPlaylist(String body) {
  var seconds = 0.0;
  for (final m in _extinf.allMatches(body)) {
    seconds += double.tryParse(m.group(1)!) ?? 0;
  }
  if (seconds <= 0) return null;
  return Duration(milliseconds: (seconds * 1000).round());
}

String? bestVariantUrl(String body, String base) {
  final lines = body.split(RegExp(r'\r?\n'));
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
