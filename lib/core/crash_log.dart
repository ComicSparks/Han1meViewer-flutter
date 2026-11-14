import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 只记录 Dart 错误。播放器原生崩溃不经过这里。
class CrashLog {
  static IOSink? _sink;
  static File? _file;
  static final List<String> _pending = [];

  static void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      write('${details.exceptionAsString()}\n${details.stack}');
      previous?.call(details);
    };
    final previousPlatform = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      write('$error\n$stack');
      return previousPlatform?.call(error, stack) ?? false;
    };
  }

  static Future<void> open() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/crash.log');
    if (file.existsSync() && file.lengthSync() > 256 * 1024) {
      final bytes = await file.readAsBytes();
      final keep = bytes.sublist(bytes.length - 128 * 1024);
      await file.writeAsBytes(keep);
    }
    _file = file;
    _sink = file.openWrite(mode: FileMode.append);
    for (final line in _pending) {
      _sink!.writeln(line);
    }
    _pending.clear();
  }

  static void write(String message) {
    final line = '${DateTime.now().toIso8601String()} $message';
    final sink = _sink;
    if (sink == null) {
      _pending.add(line);
      return;
    }
    sink.writeln(line);
  }

  static File? get file => _file != null && _file!.existsSync() && _file!.lengthSync() > 0 ? _file : null;
}
