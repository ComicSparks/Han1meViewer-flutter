import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/nav.dart';
import '../../core/pro.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';
import '../downloads/downloads_page.dart';
import '../login_page.dart';
import '../pro/pro_page.dart';
import '../settings/settings_page.dart';
import 'account_page.dart';
import 'keyframes_page.dart';
import 'local_history_page.dart';
import 'my_list_page.dart';
import 'online_history_page.dart';
import 'playlists_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.mine),
        actions: [
          SignalBuilder(
            builder: (context) {
              final powered = Pro.powered.value;
              return IconButton(
                tooltip: powered ? l.proPowered : l.proTitle,
                icon: Icon(powered ? Icons.offline_bolt : Icons.offline_bolt_outlined),
                onPressed: () async {
                  await push(context, const ProPage());
                  Pro.refresh();
                },
              );
            },
          ),
        ],
      ),
      body: SignalBuilder(
        builder: (context) {
          final s = Session.state.value;
          Widget tile(IconData icon, String title, Widget page, {bool needLogin = false}) => ListTile(
                leading: Icon(icon),
                title: Text(title),
                trailing: const Icon(Icons.chevron_right),
                enabled: !needLogin || s.loggedIn,
                onTap: () => push(context, page),
              );
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 28,
                      child: s.avatarUrl == null
                          ? const Icon(Icons.person)
                          : ClipOval(child: NetImage(s.avatarUrl, width: 56, height: 56)),
                    ),
                    title: Text(s.loggedIn ? (s.username ?? '-') : l.notLoggedIn),
                    subtitle: Text(s.loggedIn ? l.tapToManageAccount : l.tapToLogin),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => push(context, s.loggedIn ? const AccountPage() : const LoginPage()),
                  ),
                ),
              ),
              tile(Icons.history, l.localHistory, const LocalHistoryPage()),
              tile(Icons.cloud_sync_outlined, l.onlineHistory, const OnlineHistoryPage(), needLogin: true),
              tile(Icons.favorite_border, l.favorites, MyListPage(listType: 'likes', title: l.favorites), needLogin: true),
              tile(Icons.watch_later_outlined, l.watchLater, MyListPage(listType: 'saves', title: l.watchLater),
                  needLogin: true),
              tile(Icons.playlist_play, l.playlists, const PlaylistsPage(), needLogin: true),
              tile(Icons.download_outlined, l.downloads, const DownloadsPage()),
              const Divider(),
              tile(Icons.bookmarks_outlined, l.hKeyframes, const KeyframesPage()),
              tile(Icons.settings_outlined, l.settings, const SettingsPage()),
              if (s.loggedIn)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l.logout),
                  onTap: () async {
                    if (await confirm(context, l.logoutConfirm)) await Session.logout();
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
