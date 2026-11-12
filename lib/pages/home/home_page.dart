import 'package:flutter/material.dart';

import '../../core/nav.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/models.dart' as m;
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';
import '../search/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  m.HomePage? _data;
  Object? _error;
  bool _loading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await hanime.homePage();
      Session.refresh();
      if (mounted) setState(() => _data = d);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context);
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [
          IconButton(
            tooltip: l.search,
            icon: const Icon(Icons.search),
            onPressed: () => push(context, const SearchPage()),
          ),
        ],
      ),
      body: data == null
          ? (_error != null
              ? ErrorView(error: _error!, onRetry: _load)
              : const Center(child: CircularProgressIndicator()))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (data.banner != null) _Banner(data.banner!),
                  for (final s in data.sections)
                    if (s.items.isNotEmpty) _Section(section: s),
                ],
              ),
            ),
    );
  }
}

class _Banner extends StatelessWidget {
  final m.HomeBanner banner;
  const _Banner(this.banner);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: banner.videoCode == null ? null : () => openVideo(context, banner.videoCode!),
          child: AspectRatio(
            aspectRatio: 21 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(banner.picUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(banner.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                      if (banner.description != null && banner.description!.isNotEmpty)
                        Text(banner.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final m.HomeSection section;
  const _Section({required this.section});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final simplified = section.items.every((e) => e.simplified);
    final cardWidth = simplified ? 130.0 : 220.0;
    final height = simplified ? 230.0 : 196.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(section.title ?? section.key, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (section.moreQuery != null)
                TextButton(
                  onPressed: () => push(context, SearchPage(initialRawQuery: section.moreQuery)),
                  child: Text(l.more),
                ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: section.items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => VideoCard(section.items[i], width: cardWidth),
          ),
        ),
      ],
    );
  }
}
