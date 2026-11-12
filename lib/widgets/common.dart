import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../core/nav.dart';
import '../core/pro.dart';
import '../l10n/gen/app_localizations.dart';
import '../pages/login_page.dart';
import '../pages/pro/pro_page.dart';
import '../pages/settings/network_settings_page.dart';
import '../src/rust/api/models.dart';
import 'net_image.dart';

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final bool compact;
  const ErrorView({super.key, required this.error, this.onRetry, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = AppError.from(error);
    final text = e.describe(l);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) Icon(e.isNetwork ? Icons.wifi_off : Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (onRetry != null) FilledButton.tonal(onPressed: onRetry, child: Text(l.retry)),
                if (e.isNetwork || e.code.startsWith('cf_') || e.code == 'ip_blocked')
                  OutlinedButton(
                    onPressed: () => push(context, const NetworkSettingsPage()),
                    child: Text(l.networkSettings),
                  ),
                if (e.needLogin)
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await push<bool>(context, const LoginPage());
                      if (ok == true) onRetry?.call();
                    },
                    child: Text(l.login),
                  ),
                if (e.code == 'need_pro')
                  OutlinedButton(
                    onPressed: () => push(context, const ProPage()),
                    child: Text(l.proGo),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String? text;
  const EmptyView({super.key, this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 8),
              Text(text ?? AppLocalizations.of(context).empty),
            ],
          ),
        ),
      );
}

/// 卡片宽度：手机两列，平板 / 桌面按宽度自适应
const double videoCardMaxWidth = 260;

SliverGridDelegate videoGridDelegate({bool simplified = false}) => SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: simplified ? 180 : videoCardMaxWidth,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: simplified ? 0.62 : 1.12,
    );

class VideoCard extends StatelessWidget {
  final HanimeInfo info;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final bool selected;
  final bool showNew;
  const VideoCard(this.info, {super.key, this.onTap, this.onLongPress, this.width, this.selected = false, this.showNew = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cover = AspectRatio(
      aspectRatio: info.simplified ? 0.7 : 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(info.coverUrl),
          if (info.duration != null && info.duration!.isNotEmpty)
            Positioned(
              right: 4,
              bottom: 4,
              child: _Badge(info.duration!),
            ),
          if (info.isPlaying)
            Positioned(
              left: 4,
              top: 4,
              child: _Badge(AppLocalizations.of(context).playing, color: theme.colorScheme.primary),
            ),
          if (showNew)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              ),
            ),
          if (selected)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: Icon(Icons.check_circle, color: Colors.white)),
            ),
        ],
      ),
    );
    final meta = [info.artist, info.views, info.uploadTime].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap ?? () => openVideo(context, info.videoCode),
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cover,
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                child: Text(
                  info.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (meta.isNotEmpty && !info.simplified)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                  child: Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color? color;
  const _Badge(this.text, {this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color ?? Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
      );
}

/// 分页加载的视频网格
class PagedVideoGrid extends StatefulWidget {
  final Future<PageResult> Function(int page) loader;
  final Widget? header;
  final void Function(HanimeInfo info, VoidCallback remove)? onLongPress;
  final ValueChanged<PageResult>? onFirstPage;
  final int firstPage;
  final bool selecting;
  final Set<String> selected;
  final ValueChanged<HanimeInfo>? onToggle;
  final Set<String> newCodes;

  const PagedVideoGrid({
    super.key,
    required this.loader,
    this.header,
    this.onLongPress,
    this.onFirstPage,
    this.firstPage = 1,
    this.selecting = false,
    this.selected = const <String>{},
    this.onToggle,
    this.newCodes = const <String>{},
  });

  @override
  State<PagedVideoGrid> createState() => PagedVideoGridState();
}

class PagedVideoGridState extends State<PagedVideoGrid> {
  final List<HanimeInfo> _items = [];
  List<HanimeInfo> get items => List.unmodifiable(_items);
  late int _page = widget.firstPage;
  bool _loading = false;
  bool _noMore = false;
  bool _needPro = false;
  Object? _error;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _loadMore();
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      _items.clear();
      _page = widget.firstPage;
      _noMore = false;
      _needPro = false;
      _error = null;
      _loading = false;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _noMore || _needPro) return;
    if (_page > freeMaxPage && !Pro.isPro) {
      setState(() => _needPro = true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.loader(_page);
      if (!mounted) return;
      if (_page == widget.firstPage) widget.onFirstPage?.call(r);
      final known = _items.map((e) => e.videoCode).toSet();
      final fresh = r.items.where((e) => known.add(e.videoCode)).toList();
      setState(() {
        _items.addAll(fresh);
        _page++;
        _noMore = r.noMore || r.items.isEmpty || (r.maxPage != null && _page > r.maxPage!) || fresh.isEmpty;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (mounted && !_noMore && !_needPro && _error == null && _scroll.hasClients && _scroll.position.maxScrollExtent < 200) {
      _loadMore();
    }
  }

  Future<void> _openPro() async {
    await push(context, const ProPage());
    if (!mounted) return;
    Pro.refresh();
    if (Pro.isPro) {
      setState(() => _needPro = false);
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final simplified = _items.isNotEmpty && _items.every((e) => e.simplified);
    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (widget.header != null) SliverToBoxAdapter(child: widget.header),
          if (_items.isEmpty && _error != null)
            SliverFillRemaining(hasScrollBody: false, child: ErrorView(error: _error!, onRetry: refresh))
          else if (_items.isEmpty && !_loading && _noMore)
            const SliverFillRemaining(hasScrollBody: false, child: EmptyView())
          else
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverGrid(
                gridDelegate: videoGridDelegate(simplified: simplified),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final info = _items[i];
                    return VideoCard(
                      info,
                      selected: widget.selected.contains(info.videoCode),
                      showNew: widget.newCodes.contains(info.videoCode),
                      onTap: widget.selecting ? () => widget.onToggle?.call(info) : null,
                      onLongPress: widget.selecting || widget.onLongPress == null
                          ? null
                          : () => widget.onLongPress!(info, () => setState(() => _items.remove(info))),
                    );
                  },
                  childCount: _items.length,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))
                : _needPro
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + MediaQuery.paddingOf(context).bottom),
                        child: Column(
                          children: [
                            Text(AppLocalizations.of(context).proPageLimit(freeMaxPage), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            FilledButton.tonal(onPressed: _openPro, child: Text(AppLocalizations.of(context).proGo)),
                          ],
                        ),
                      )
                    : (_error != null && _items.isNotEmpty)
                        ? ErrorView(error: _error!, onRetry: _loadMore, compact: true)
                        : SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}

Future<bool> confirm(BuildContext context, String title, {String? content}) async {
  final l = AppLocalizations.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: content == null ? null : Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.ok)),
      ],
    ),
  );
  return r == true;
}

Future<String?> inputText(BuildContext context, String title, {String initial = '', String? hint, int maxLines = 1}) {
  final l = AppLocalizations.of(context);
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
        onSubmitted: maxLines == 1 ? (v) => Navigator.pop(ctx, v) : null,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(l.ok)),
      ],
    ),
  );
}

String formatBytes(num bytes) {
  if (bytes < 1024) return '${bytes.toInt()} B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  double v = bytes / 1024;
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(v >= 100 ? 0 : 1)} ${units[i]}';
}

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
