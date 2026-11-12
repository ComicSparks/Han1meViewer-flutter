import 'package:flutter/material.dart';

import '../core/downloads.dart';
import '../l10n/gen/app_localizations.dart';
import 'home/home_page.dart';
import 'mine/mine_page.dart';
import 'mine/subscriptions_page.dart';

final homeShellKey = GlobalKey<HomeShellState>();

/// 手机底部导航，平板 / 桌面侧边导航
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final _pages = const <Widget>[
    HomePage(),
    SubscriptionsPage(),
    MinePage(),
  ];

  void select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Downloads.notificationTitle = l.appName;
    Downloads.notificationText = (n, title) => l.downloadingNotification(n, title);

    final dests = [
      (Icons.home_outlined, Icons.home, l.home),
      (Icons.subscriptions_outlined, Icons.subscriptions, l.subscriptions),
      (Icons.person_outline, Icons.person, l.mine),
    ];
    final body = IndexedStack(index: _index, children: _pages);
    final wide = MediaQuery.sizeOf(context).width >= 720;
    if (!wide) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: select,
          destinations: [
            for (final d in dests) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
          ],
        ),
      );
    }
    final extended = MediaQuery.sizeOf(context).width >= 1280;
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: extended,
              selectedIndex: _index,
              onDestinationSelected: select,
              labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/icon/app_icon.png', width: 40, height: 40),
                ),
              ),
              destinations: [
                for (final d in dests)
                  NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3)),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
