import 'package:flutter/material.dart';

import '../../core/errors.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/models.dart';
import '../../src/rust/api/user.dart' as user;
import '../../widgets/common.dart';
import '../../widgets/multi_select.dart';

/// 喜欢的影片（likes）/ 稍后观看（saves）
class MyListPage extends StatefulWidget {
  final String listType;
  final String title;
  const MyListPage({super.key, required this.listType, required this.title});

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  final _grid = GlobalKey<PagedVideoGridState>();
  String? _csrf;
  String? _desc;
  bool _selecting = false;
  final Set<String> _selected = {};

  List<HanimeInfo> _picked() =>
      _grid.currentState?.items.where((e) => _selected.contains(e.videoCode)).toList() ?? const [];

  void _toggle(HanimeInfo info) {
    setState(() {
      if (!_selected.add(info.videoCode)) _selected.remove(info.videoCode);
    });
  }

  void _exitSelect() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  Future<void> _removeOne(HanimeInfo info, VoidCallback remove) async {
    final l = AppLocalizations.of(context);
    if (!await confirm(context, l.removeFromList, content: info.title)) return;
    try {
      await user.deleteMyListItem(listType: widget.listType, videoCode: info.videoCode, csrfToken: _csrf);
      remove();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _removeMany() async {
    final items = _picked();
    if (items.isEmpty) return;
    if (!await confirm(context, AppLocalizations.of(context).removeFromList)) return;
    try {
      for (final info in items) {
        await user.deleteMyListItem(listType: widget.listType, videoCode: info.videoCode, csrfToken: _csrf);
      }
      _exitSelect();
      _grid.currentState?.refresh();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting ? l.selectedCount(_selected.length) : widget.title),
        leading: _selecting ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelect) : null,
        actions: [
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
              key: _grid,
              loader: (page) => user.myListItems(listType: widget.listType, page: page),
              selecting: _selecting,
              selected: _selected,
              onToggle: _toggle,
              onFirstPage: (r) {
                _csrf = r.csrfToken;
                if (r.description != null && r.description != _desc) setState(() => _desc = r.description);
              },
              header: _desc == null || _desc!.isEmpty
                  ? null
                  : Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(_desc!)),
              onLongPress: _selecting ? null : (info, remove) => _removeOne(info, remove),
            ),
          ),
          if (_selecting)
            MultiActionBar(
              count: _selected.length,
              onRemove: _removeMany,
              onDownload: () => downloadHanimeSelection(context, _picked()),
            ),
        ],
      ),
    );
  }
}
