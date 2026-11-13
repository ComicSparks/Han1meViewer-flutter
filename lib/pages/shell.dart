import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../core/app_update.dart';
import '../core/downloads.dart';
import '../core/sub_updates.dart';
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

class HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  final _subscriptionsKey = GlobalKey<SubscriptionsPageState>();
  late final List<Widget> _pages = [
    const HomePage(),
    SubscriptionsPage(key: _subscriptionsKey),
    const MinePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_index != 1) return;
    if (state == AppLifecycleState.paused) {
      _subscriptionsKey.currentState?.markSeen();
    } else if (state == AppLifecycleState.resumed) {
      _subscriptionsKey.currentState?.refresh();
    }
  }

  void select(int i) {
    if (i == _index) return;
    if (_index == 1) _subscriptionsKey.currentState?.markSeen();
    setState(() => _index = i);
    if (i == 1) _subscriptionsKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Downloads.notificationTitle = l.appName;
    Downloads.notificationText = (n, title) => l.downloadingNotification(n, title);

    return SignalBuilder(builder: (context) {
    final newCount = subscriptionNewCount.value;
    final updateDot = AppUpdate.showDot;
    Widget navIcon(IconData icon, {required bool subs, required bool mine}) {
      if (subs && newCount > 0) {
        final text = newCount > 99 ? '99+' : '$newCount';
        return Badge(label: Text(text), child: Icon(icon));
      }
      if (mine && updateDot) return Badge(child: Icon(icon));
      return Icon(icon);
    }

    final dests = [
      (Icons.home_outlined, Icons.home, l.home, false),
      (Icons.subscriptions_outlined, Icons.subscriptions, l.subscriptions, true),
      (Icons.person_outline, Icons.person, l.mine, false),
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
            for (final d in dests)
              NavigationDestination(
                icon: navIcon(d.$1, subs: d.$4, mine: d.$3 == l.mine),
                selectedIcon: navIcon(d.$2, subs: d.$4, mine: d.$3 == l.mine),
                label: d.$3,
              ),
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
                  NavigationRailDestination(
                    icon: navIcon(d.$1, subs: d.$4, mine: d.$3 == l.mine),
                    selectedIcon: navIcon(d.$2, subs: d.$4, mine: d.$3 == l.mine),
                    label: Text(d.$3),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
    });
  }
}
