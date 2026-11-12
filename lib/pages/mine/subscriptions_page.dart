import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/nav.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';
import '../login_page.dart';
import '../search/search_page.dart';
import '../video/user_videos_page.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> with RouteAware {
  final _grid = GlobalKey<PagedVideoGridState>();
  ModalRoute<void>? _route;
  List<SubscriptionArtist> _artists = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) routeObserver.unsubscribe(this);
      _route = route;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (Session.loggedIn) _grid.currentState?.refresh();
  }

  Future<PageResult> _loader(int page) async {
    final r = await hanime.mySubscriptions(page: page);
    if (page == 1 && mounted) setState(() => _artists = r.artists);
    return PageResult(
      items: r.videos,
      noMore: r.videos.isEmpty || page >= r.maxPage,
      csrfToken: null,
      description: null,
      maxPage: r.maxPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SignalBuilder(
      builder: (context) {
        final loggedIn = Session.state.value.loggedIn;
        if (!loggedIn) _artists = [];
        return Scaffold(
          appBar: AppBar(
            title: Text(l.subscriptions),
            actions: [
              if (loggedIn)
                IconButton(
                  tooltip: l.refresh,
                  onPressed: () => _grid.currentState?.refresh(),
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          body: loggedIn
              ? PagedVideoGrid(key: _grid, loader: _loader, header: _artistsHeader())
              : _loginPrompt(l),
        );
      },
    );
  }

  Widget _loginPrompt(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subscriptions_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(l.notLoggedIn, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l.tapToLogin, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => push(context, const LoginPage()), child: Text(l.login)),
          ],
        ),
      ),
    );
  }

  Widget? _artistsHeader() {
    if (_artists.isEmpty) return null;
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: _artists.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = _artists[i];
          return InkWell(
            onTap: () {
              final id = a.userId;
              if (id == null || id.isEmpty) {
                push(context, SearchPage(initialQuery: a.name));
                return;
              }
              push(context, UserVideosPage(userId: id, name: a.name));
            },
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  ClipOval(child: NetImage(a.avatar, width: 48, height: 48)),
                  const SizedBox(height: 4),
                  Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
