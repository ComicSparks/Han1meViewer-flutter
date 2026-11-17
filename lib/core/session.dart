import 'package:signals_flutter/signals_flutter.dart';

import '../src/rust/api/app.dart' as rapi;
import '../src/rust/api/models.dart';
import '../src/rust/api/user.dart' as user;
import '../webview/web_auth.dart';
import 'pro.dart';

class Session {
  Session._();

  static final state = signal<LoginState>(rapi.loginState());

  static bool get loggedIn => state.value.loggedIn;

  static void refresh() {
    state.value = rapi.loginState();
    Pro.refresh();
  }

  static Future<void> logout() async {
    await user.logout();
    await WebAuth.clearData();
    refresh();
  }
}
