import 'package:flutter/material.dart';

import '../pages/video/video_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
final routeObserver = RouteObserver<ModalRoute<void>>();

/// 等待根 Navigator 就绪（启动早期就可能收到 CF 挑战）
Future<BuildContext?> waitNavigatorContext() async {
  for (var i = 0; i < 100; i++) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) return ctx;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return null;
}

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

Future<void> openVideo(BuildContext context, String code, {String? localPath, String? localTitle}) =>
    push(context, VideoPage(videoCode: code, localPath: localPath, localTitle: localTitle));
