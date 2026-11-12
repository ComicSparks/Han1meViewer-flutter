import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/downloads.dart';
import 'core/native.dart';
import 'core/prefs.dart';
import 'player/playback_cache.dart';
import 'src/rust/api/app.dart' as rapi;
import 'src/rust/frb_generated.dart';
import 'webview/web_auth.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  if (Platform.isLinux && runWebViewTitleBarWidget(args)) return;

  await RustLib.init();
  if (!(Platform.isAndroid || Platform.isIOS)) MediaKit.ensureInitialized();

  final root = await getApplicationSupportDirectory();
  await rapi.init(root: root.path);
  await Native.excludeFromBackup(root.path);
  await PlaybackCache.clearAll();

  Prefs.load();
  await WebAuth.init();
  WebAuth.listen();
  Downloads.init();

  runApp(const HvfApp());
}
