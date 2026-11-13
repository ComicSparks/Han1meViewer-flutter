import 'package:signals_flutter/signals_flutter.dart';

import '../src/rust/api/pro.dart' as api;
import 'prefs.dart';

/// 未发电可浏览的最大页码。Rust `FREE_MAX_PAGE` 必须与这里保持一致。
const int freeMaxPage = 1;

class Pro {
  Pro._();

  static final powered = signal(api.isPro());

  static bool get isPro => powered.value;

  static void refresh() {
    powered.value = api.isPro();
    // 发电结束后重新打开更新提醒。Prefs 在启动后才可用。
    if (!powered.value && !Prefs.updateRemind.value) {
      Prefs.updateRemind.value = true;
    }
  }
}
