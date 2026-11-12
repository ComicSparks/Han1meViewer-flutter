import 'package:flutter/material.dart';

import '../../core/errors.dart';
import '../../core/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/models.dart';
import '../../src/rust/api/user.dart' as user;
import '../../widgets/common.dart';
import '../../widgets/multi_select.dart';

class OnlineHistoryPage extends StatefulWidget {
  const OnlineHistoryPage({super.key});

  @override
  State<OnlineHistoryPage> createState() => _OnlineHistoryPageState();
}

class _OnlineHistoryPageState extends State<OnlineHistoryPage> {
  String _sort = const {'latest', 'popular', 'oldest'}.contains(Prefs.historySort.value) ? Prefs.historySort.value : 'latest';
  String? _csrf;
  bool _selecting = false;
  final Map<String, HanimeInfo> _selected = {};

  void _toggle(HanimeInfo info) {
    setState(() {
      if (!_selected.containsKey(info.videoCode)) {
        _selected[info.videoCode] = info;
      } else {
        _selected.remove(info.videoCode);
      }
    });
  }

  void _exitSelect() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _selecting ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelect) : null,
        title: Text(_selecting ? l.selectedCount(_selected.length) : l.onlineHistory),
        actions: [
          if (!_selecting)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              initialValue: _sort,
              onSelected: (v) {
                Prefs.historySort.value = v;
                setState(() {
                  _sort = v;
                  _selecting = false;
                  _selected.clear();
                });
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'latest', child: Text(l.sortLatest)),
                PopupMenuItem(value: 'popular', child: Text(l.sortPopular)),
                PopupMenuItem(value: 'oldest', child: Text(l.sortOldest)),
              ],
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
      ),
      body: Column(
        children: [
          Expanded(
            child: PagedVideoGrid(
              key: ValueKey(_sort),
              loader: (page) => user.onlineHistory(sort: _sort, page: page),
              selecting: _selecting,
              selected: _selected.keys.toSet(),
              onToggle: _toggle,
              onFirstPage: (r) => _csrf = r.csrfToken,
              onLongPress: _selecting
                  ? null
                  : (info, remove) async {
                      if (!await confirm(context, l.deleteHistory, content: info.title)) return;
                      try {
                        await user.deleteOnlineHistory(videoCode: info.videoCode, csrfToken: _csrf);
                        remove();
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                    },
            ),
          ),
          if (_selecting)
            MultiActionBar(
              count: _selected.length,
              onDownload: () => downloadHanimeSelection(context, _selected.values.toList()),
            ),
        ],
      ),
    );
  }
}
