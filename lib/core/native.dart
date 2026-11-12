import 'dart:io';

import 'package:flutter/services.dart';

/// 平台原生能力：iOS 排除备份、伪装图标切换
class Native {
  Native._();

  static const _ch = MethodChannel('hvf/native');

  static bool get supportsIconSwitch => Platform.isAndroid || Platform.isIOS;

  static Future<void> excludeFromBackup(String path) async {
    if (!Platform.isIOS) return;
    try {
      await _ch.invokeMethod('excludeFromBackup', {'path': path});
    } catch (_) {}
  }

  /// name: default / calc / cornhub / xxt
  static Future<bool> setLauncherIcon(String name) async {
    if (!supportsIconSwitch) return false;
    try {
      return await _ch.invokeMethod<bool>('setLauncherIcon', {'name': name}) ?? false;
    } catch (_) {
      return false;
    }
  }
}
