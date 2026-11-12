import 'package:flutter/material.dart';

import '../../core/errors.dart';
import '../../core/nav.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/models.dart';
import '../../src/rust/api/user.dart' as user;
import '../../widgets/common.dart';
import '../../widgets/multi_select.dart';
import '../../widgets/net_image.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  Playlists? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final d = await user.playlists(page: 1);
      if (mounted) setState(() => _data = d);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: Text(l.playlists)),
      body: d == null
          ? (_error != null ? ErrorView(error: _error!, onRetry: _load) : const Center(child: CircularProgressIndicator()))
          : d.playlists.isEmpty
              ? const EmptyView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: d.playlists.length,
                    itemBuilder: (context, i) {
                      final p = d.playlists[i];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(width: 96, height: 54, child: NetImage(p.coverUrl)),
                        ),
                        title: Text(p.title),
                        subtitle: Text(l.videoCount(p.total)),
                        onTap: () async {
                          await push(context, PlaylistDetailPage(playlist: p, csrf: d.csrfToken));
                          _load();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;
  final String? csrf;
  const PlaylistDetailPage({super.key, required this.playlist, this.csrf});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final _grid = GlobalKey<PagedVideoGridState>();
  late String _title = widget.playlist.title;
  String _desc = '';
  late String? _csrf = widget.csrf;
  bool _selecting = false;
  final Set<String> _selected = {};

  List<HanimeInfo> _picked() =>
      _grid.currentState?.items.where((e) => _selected.contains(e.videoCode)).toList() ?? const [];

  void _toggle(HanimeInfo info) {
    setState(() {
      if (!_selected.add(info.videoCode)) _selected.remove(info.videoCode);
    });
  }

  Future<void> _edit() async {
    final l = AppLocalizations.of(context);
    final t = TextEditingController(text: _title);
    final d = TextEditingController(text: _desc);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.editPlaylist),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: t, decoration: InputDecoration(labelText: l.playlistTitle)),
            const SizedBox(height: 8),
            TextField(controller: d, maxLines: 3, decoration: InputDecoration(labelText: l.description)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.ok)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await user.modifyPlaylist(
        listCode: widget.playlist.listCode,
        title: t.text.trim(),
        description: d.text.trim(),
        delete: false,
        csrfToken: _csrf,
      );
      setState(() {
        _title = t.text.trim();
        _desc = d.text.trim();
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (!await confirm(context, l.deletePlaylistConfirm, content: _title)) return;
    try {
      await user.modifyPlaylist(
        listCode: widget.playlist.listCode,
        title: _title,
        description: _desc,
        delete: true,
        csrfToken: _csrf,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

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
        title: Text(_selecting ? l.selectedCount(_selected.length) : _title),
        actions: [
          IconButton(
            tooltip: l.multiSelect,
            icon: const Icon(Icons.checklist),
            onPressed: () => setState(() {
              _selecting = !_selecting;
              if (!_selecting) _selected.clear();
            }),
          ),
          if (!_selecting) ...[
            IconButton(tooltip: l.edit, icon: const Icon(Icons.edit_outlined), onPressed: _edit),
            IconButton(tooltip: l.delete, icon: const Icon(Icons.delete_outline), onPressed: _delete),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PagedVideoGrid(
              key: _grid,
              loader: (page) => user.playlistItems(listCode: widget.playlist.listCode, page: page),
              selecting: _selecting,
              selected: _selected,
              onToggle: _toggle,
              onFirstPage: (r) {
                _csrf = r.csrfToken ?? _csrf;
                final desc = r.description ?? '';
                if (desc != _desc) setState(() => _desc = desc);
              },
              header: _desc.isEmpty ? null : Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Text(_desc)),
              onLongPress: _selecting
                  ? null
                  : (info, remove) async {
                      if (!await confirm(context, l.removeFromList, content: info.title)) return;
                      try {
                        await hanime.setInMyList(
                          listCode: widget.playlist.listCode,
                          videoCode: info.videoCode,
                          checked: false,
                          csrfToken: _csrf,
                        );
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
              onDownload: () => downloadHanimeSelection(context, _picked()),
            ),
        ],
      ),
    );
  }
}
