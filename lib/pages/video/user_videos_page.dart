import 'package:flutter/material.dart';

import '../../core/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/multi_select.dart';

/// 作者上传列表，对应网页 `/user/{id}/uploaded`
class UserVideosPage extends StatefulWidget {
  final String userId;
  final String name;
  const UserVideosPage({super.key, required this.userId, required this.name});

  @override
  State<UserVideosPage> createState() => _UserVideosPageState();
}

class _UserVideosPageState extends State<UserVideosPage> {
  static const _sorts = <String?>[null, 'latest', 'popular', 'oldest'];
  String? _sort = const {'latest', 'popular', 'oldest'}.contains(Prefs.userVideosSort.value) ? Prefs.userVideosSort.value : null;
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

  String _label(AppLocalizations l, String? sort) => switch (sort) {
        'latest' => l.userSortLatest,
        'popular' => l.userSortPopular,
        'oldest' => l.userSortOldest,
        _ => l.userSortDefault,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
        title: Text(_selecting ? l.selectedCount(_selected.length) : widget.name),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                for (final s in _sorts)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_label(l, s)),
                      selected: _sort == s,
                      onSelected: (_) {
                        if (_sort == s) return;
                        Prefs.userVideosSort.value = s ?? '';
                        setState(() {
                          _sort = s;
                          _selecting = false;
                          _selected.clear();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PagedVideoGrid(
              key: ValueKey(_sort ?? ''),
              loader: (page) => hanime.userVideos(userId: widget.userId, page: page, sort: _sort),
              selecting: _selecting,
              selected: _selected.keys.toSet(),
              onToggle: _toggle,
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
