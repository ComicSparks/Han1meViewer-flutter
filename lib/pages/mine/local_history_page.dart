import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/nav.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/local.dart' as local;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/multi_select.dart';
import '../../widgets/net_image.dart';

class LocalHistoryPage extends StatefulWidget {
  const LocalHistoryPage({super.key});

  @override
  State<LocalHistoryPage> createState() => _LocalHistoryPageState();
}

class _LocalHistoryPageState extends State<LocalHistoryPage> {
  static const _pageSize = 50;
  final List<WatchHistory> _items = [];
  final _scroll = ScrollController();
  String _keyword = '';
  bool _loading = false;
  bool _noMore = false;
  bool _selecting = false;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _more();
    });
    _more();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    _items.clear();
    _noMore = false;
    await _more();
  }

  Future<void> _more() async {
    if (_loading || _noMore) return;
    _loading = true;
    try {
      final r = await local.historyList(
        keyword: _keyword.isEmpty ? null : _keyword,
        offset: _items.length,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(r);
        _noMore = r.length < _pageSize;
      });
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = DateFormat.yMd().add_Hm();
    return Scaffold(
      appBar: AppBar(
        leading: _selecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _selecting = false;
                  _selected.clear();
                }),
              )
            : null,
        title: Text(_selecting ? l.selectedCount(_selected.length) : l.localHistory),
        actions: [
          if (!_selecting)
            IconButton(
              tooltip: l.clear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                if (!await confirm(context, l.clearHistoryConfirm)) return;
                await local.historyClear();
                _reload();
              },
            ),
          IconButton(
            tooltip: l.multiSelect,
            icon: const Icon(Icons.checklist),
            onPressed: () => setState(() {
              _selecting = !_selecting;
              if (!_selecting) _selected.clear();
            }),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                _keyword = v.trim();
                _selected.clear();
                _reload();
              },
            ),
          ),
        ),
      ),
      body: _items.isEmpty && _noMore
          ? const EmptyView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final h = _items[i];
                      final progress = h.duration > 0 ? (h.progress / h.duration).clamp(0.0, 1.0) : 0.0;
                      final cover = ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(width: 112, height: 63, child: NetImage(h.coverUrl)),
                      );
                      final tile = ListTile(
                        leading: _selecting
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _selected.contains(h.videoCode),
                                    onChanged: (_) => _toggle(h.videoCode),
                                  ),
                                  cover,
                                ],
                              )
                            : cover,
                        title: Text(h.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fmt.format(DateTime.fromMillisecondsSinceEpoch(h.watchDate))),
                            if (progress > 0) ...[
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: progress, minHeight: 2),
                            ],
                          ],
                        ),
                        onTap: _selecting ? () => _toggle(h.videoCode) : () => openVideo(context, h.videoCode),
                      );
                      if (_selecting) return tile;
                      return Dismissible(
                        key: ValueKey(h.videoCode),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_outline),
                        ),
                        onDismissed: (_) {
                          local.historyDelete(videoCode: h.videoCode);
                          setState(() => _items.removeAt(i));
                        },
                        child: tile,
                      );
                    },
                  ),
                ),
                if (_selecting)
                  MultiActionBar(
                    count: _selected.length,
                    onDownload: () => downloadHanimeSelection(
                      context,
                      [
                        for (final h in _items)
                          if (_selected.contains(h.videoCode))
                            HanimeInfo(
                              title: h.title,
                              coverUrl: h.coverUrl,
                              videoCode: h.videoCode,
                              isPlaying: false,
                              simplified: false,
                            ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  void _toggle(String code) {
    setState(() {
      if (!_selected.add(code)) _selected.remove(code);
    });
  }
}
