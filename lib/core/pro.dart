import 'package:signals_flutter/signals_flutter.dart';

import '../src/rust/api/pro.dart' as api;

/// 未发电可浏览的最大页码。Rust `FREE_MAX_PAGE` 必须与这里保持一致。
const int freeMaxPage = 1;

class Pro {
  Pro._();

  static final powered = signal(api.isPro());

  static bool get isPro => powered.value;

  static void refresh() => powered.value = api.isPro();
}
