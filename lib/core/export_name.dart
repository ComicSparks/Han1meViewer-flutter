import 'dart:convert';
import 'dart:io';

class ExportName {
  final String fileName;
  final bool shortened;
  const ExportName(this.fileName, this.shortened);
}

String _clean(String title) {
  final t = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  return t.isEmpty ? 'video' : t;
}

ExportName safeExportName(String title, String quality, String ext) {
  final base = _clean(title);
  String nameFor(String b) {
    final q = quality.isEmpty ? '' : ' [$quality]';
    final suffix = ext.isEmpty ? '' : '.$ext';
    return '$b$q$suffix';
  }

  if (utf8.encode(nameFor(base)).length <= 255) return ExportName(nameFor(base), false);
  var lo = 1;
  var hi = base.length;
  var best = 1;
  while (lo <= hi) {
    final mid = (lo + hi) >> 1;
    if (utf8.encode(nameFor(base.substring(0, mid))).length <= 255) {
      best = mid;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }
  return ExportName(nameFor(base.substring(0, best)), true);
}

bool pathTooLong(String path) {
  if (Platform.isWindows) return path.length > 240;
  return utf8.encode(path).length > 1024;
}

/// 在已经选好的目录里继续缩短文件名，直到完整路径放得下。
String? shrinkFileName(String directory, String fileName) {
  final sep = Platform.pathSeparator;
  String join(String name) => directory.isEmpty ? name : '$directory$sep$name';
  if (!pathTooLong(join(fileName))) return fileName;
  final dot = fileName.lastIndexOf('.');
  final ext = dot >= 0 ? fileName.substring(dot) : '';
  var stem = dot >= 0 ? fileName.substring(0, dot) : fileName;
  while (stem.isNotEmpty && pathTooLong(join('$stem$ext'))) {
    stem = stem.substring(0, stem.length - 1);
  }
  final name = '$stem$ext';
  if (stem.isEmpty || pathTooLong(join(name))) return null;
  return name;
}
