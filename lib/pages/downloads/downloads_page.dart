import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/downloads.dart';
import '../../core/errors.dart';
import '../../core/export_name.dart';
import '../../core/nav.dart';
import '../../core/pro.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/download.dart' as dl;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';
import '../pro/pro_page.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  int _group = -1;
  String _keyword = '';
  bool _selecting = false;
  final Set<String> _selected = {};

  String _keyOf(DownloadTask t) => '${t.videoCode}\u0000${t.quality}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting ? l.selectedCount(_selected.length) : l.downloads),
        leading: _selecting ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelect) : null,
        actions: [
          if (_selecting) ...[
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _selected.isEmpty ? null : _deleteSelected,
            ),
            _exportButton(l),
          ] else
            IconButton(tooltip: l.multiSelect, icon: const Icon(Icons.checklist), onPressed: () => setState(() => _selecting = true)),
          PopupMenuButton<String>(
            onSelected: (v) async {
              switch (v) {
                case 'pause':
                  await Downloads.pauseAll();
                case 'resume':
                  await Downloads.resumeAll();
                case 'group':
                  await _createGroup();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'pause', child: Text(l.pauseAll)),
              PopupMenuItem(value: 'resume', child: Text(l.resumeAll)),
              PopupMenuItem(value: 'group', child: Text(l.newGroup)),
            ],
          ),
        ],
      ),
      body: SignalBuilder(
        builder: (context) {
          final all = Downloads.tasks.value;
          final groups = Downloads.groups.value;
          final active = all.where((t) => t.state != DownloadState.finished).toList();
          var done = all.where((t) => t.state == DownloadState.finished).toList();
          if (_group >= 0) done = done.where((t) => t.groupId == _group).toList();
          if (_keyword.isNotEmpty) {
            final k = _keyword.toLowerCase();
            done = done.where((t) => t.title.toLowerCase().contains(k) || t.videoCode.contains(k)).toList();
          }
          if (all.isEmpty) return const EmptyView();
          return CustomScrollView(
            slivers: [
              if (active.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ActiveTile(active[i]),
                    childCount: active.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _keyword = v.trim()),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    children: [
                      ChoiceChip(
                        label: Text(l.all),
                        selected: _group == -1,
                        onSelected: (_) => setState(() => _group = -1),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text(l.ungrouped),
                        selected: _group == 0,
                        onSelected: (_) => setState(() => _group = 0),
                      ),
                      for (final g in groups) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onLongPress: () => _editGroup(g),
                          onSecondaryTap: () => _editGroup(g),
                          child: ChoiceChip(
                            label: Text(g.name),
                            selected: _group == g.id,
                            onSelected: (_) => setState(() => _group = g.id),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (done.isEmpty)
                const SliverFillRemaining(hasScrollBody: false, child: EmptyView())
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _DoneTile(
                      done[i],
                      groups: groups,
                      selecting: _selecting,
                      selected: _selected.contains(_keyOf(done[i])),
                      onToggle: () => _toggle(done[i]),
                    ),
                    childCount: done.length,
                  ),
                ),
              SliverPadding(padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createGroup() async {
    final l = AppLocalizations.of(context);
    final name = await inputText(context, l.newGroup);
    if (name == null || name.trim().isEmpty) return;
    await dl.downloadGroupCreate(name: name.trim());
    await Downloads.reload();
  }

  Future<void> _editGroup(DownloadGroup g) async {
    final l = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit), title: Text(l.rename), onTap: () => Navigator.pop(c, 'rename')),
            ListTile(leading: const Icon(Icons.delete_outline), title: Text(l.deleteGroup), onTap: () => Navigator.pop(c, 'delete')),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'rename') {
      final name = await inputText(context, l.rename, initial: g.name);
      if (name == null || name.trim().isEmpty) return;
      await dl.downloadGroupRename(id: g.id, name: name.trim());
    } else if (action == 'delete') {
      if (!await confirm(context, l.deleteGroup, content: l.deleteGroupHint)) return;
      await dl.downloadGroupDelete(id: g.id);
      if (_group == g.id) setState(() => _group = -1);
    } else {
      return;
    }
    await Downloads.reload();
  }

  void _exitSelect() => setState(() {
        _selecting = false;
        _selected.clear();
      });

  void _toggle(DownloadTask t) {
    final key = _keyOf(t);
    setState(() {
      if (!_selected.add(key)) _selected.remove(key);
    });
  }

  List<DownloadTask> _picked() => Downloads.tasks.value
      .where((t) => t.state == DownloadState.finished && _selected.contains(_keyOf(t)))
      .toList();

  Widget _exportButton(AppLocalizations l) {
    return SignalBuilder(
      builder: (context) {
        final pro = Pro.powered.value;
        final label = Platform.isAndroid || Platform.isIOS ? l.saveToGallery : l.exportFile;
        return IconButton(
          tooltip: label,
          onPressed: () => _exportSelected(),
          icon: Icon(Icons.ios_share, color: pro ? null : Theme.of(context).disabledColor),
        );
      },
    );
  }

  Future<void> _deleteSelected() async {
    final tasks = _picked();
    if (tasks.isEmpty) return;
    if (!await confirm(context, AppLocalizations.of(context).deleteDownloadConfirm)) return;
    for (final t in tasks) {
      await Downloads.delete(t);
    }
    if (mounted) _exitSelect();
  }

  Future<void> _exportSelected() async {
    final l = AppLocalizations.of(context);
    if (!Pro.isPro) {
      toast(context, l.needPro);
      push(context, const ProPage());
      return;
    }
    final tasks = _picked();
    if (tasks.isEmpty) return;
    final needShorten = !(Platform.isAndroid || Platform.isIOS) && tasks.any((t) => _nameFor(t).shortened);
    if (needShorten && !await confirm(context, l.exportNameTooLong)) return;
    var ok = 0;
    for (final t in tasks) {
      if (!mounted) return;
      if (await exportDownload(context, t, confirmed: true)) ok++;
    }
    if (mounted && ok > 0) toast(context, l.exported);
  }
}

ExportName _nameFor(DownloadTask t) {
  final ext = t.videoPath.split('.').last;
  return safeExportName(t.title, t.quality, ext);
}

Future<bool> exportDownload(BuildContext context, DownloadTask t, {required bool confirmed}) async {
  final l = AppLocalizations.of(context);
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      if (pathTooLong(t.videoPath)) {
        toast(context, l.exportNameTooLong);
        return false;
      }
      if (!await Gal.hasAccess()) await Gal.requestAccess();
      await Gal.putVideo(t.videoPath, album: 'HaVF');
      if (context.mounted && !confirmed) toast(context, l.exported);
      return true;
    }
    final fitted = _nameFor(t);
    var asked = confirmed;
    if (fitted.shortened && !asked) {
      if (!context.mounted || !await confirm(context, l.exportNameTooLong)) return false;
      asked = true;
    }
    if (!context.mounted) return false;
    final loc = await getSaveLocation(suggestedName: fitted.fileName);
    if (loc == null || !context.mounted) return false;
    var dest = loc.path;
    if (pathTooLong(dest)) {
      final sep = Platform.pathSeparator;
      final slash = dest.lastIndexOf(sep);
      final dir = slash < 0 ? '' : dest.substring(0, slash);
      final name = slash < 0 ? dest : dest.substring(slash + 1);
      final shrunk = shrinkFileName(dir, name);
      if (shrunk == null) {
        toast(context, l.exportFailed);
        return false;
      }
      dest = dir.isEmpty ? shrunk : '$dir$sep$shrunk';
      if (!asked && !await confirm(context, l.exportNameTooLong)) return false;
    }
    if (pathTooLong(dest)) {
      if (context.mounted) toast(context, l.exportFailed);
      return false;
    }
    await File(t.videoPath).copy(dest);
    if (context.mounted && !confirmed) toast(context, l.exported);
    return true;
  } catch (e) {
    if (context.mounted) toast(context, '${l.exportFailed}: $e');
    return false;
  }
}

class _ActiveTile extends StatelessWidget {
  final DownloadTask t;
  const _ActiveTile(this.t);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final progress = t.length > 0 ? t.downloaded / t.length : null;
    final status = switch (t.state) {
      DownloadState.queued => l.queued,
      DownloadState.downloading => '${formatBytes(t.speed)}/s',
      DownloadState.paused => l.paused,
      DownloadState.failed => '${l.failed}${t.error == null ? '' : ': ${AppError.from(t.error!).describe(l)}'}',
      _ => '',
    };
    final running = t.state == DownloadState.downloading || t.state == DownloadState.queued;
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(width: 96, height: 54, child: NetImage(t.coverUrl, localPath: t.coverPath)),
      ),
      title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(value: t.state == DownloadState.queued ? null : progress, minHeight: 3),
          const SizedBox(height: 4),
          Text(
            '${t.quality} · ${formatBytes(t.downloaded)}${t.length > 0 ? ' / ${formatBytes(t.length)}' : ''} · $status',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(running ? Icons.pause : Icons.play_arrow),
            onPressed: () => running ? Downloads.pause(t) : Downloads.resume(t),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await confirm(context, l.deleteDownloadConfirm, content: t.title)) await Downloads.delete(t);
            },
          ),
        ],
      ),
    );
  }
}

class _DoneTile extends StatelessWidget {
  final DownloadTask t;
  final List<DownloadGroup> groups;
  final bool selecting;
  final bool selected;
  final VoidCallback onToggle;
  const _DoneTile(this.t, {required this.groups, required this.selecting, required this.selected, required this.onToggle});

  Future<void> _export(BuildContext context) async {
    if (!Pro.isPro) {
      toast(context, AppLocalizations.of(context).needPro);
      push(context, const ProPage());
      return;
    }
    await exportDownload(context, t, confirmed: false);
  }

  Future<void> _move(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final id = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l.moveToGroup),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(c, 0), child: Text(l.ungrouped)),
          for (final g in groups) SimpleDialogOption(onPressed: () => Navigator.pop(c, g.id), child: Text(g.name)),
        ],
      ),
    );
    if (id == null) return;
    await dl.downloadSetGroup(id: t.id, groupId: id);
    await Downloads.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(width: 96, height: 54, child: NetImage(t.coverUrl, localPath: t.coverPath)),
    );
    return ListTile(
      leading: selecting
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(value: selected, onChanged: (_) => onToggle()),
                cover,
              ],
            )
          : cover,
      title: Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${t.quality} · ${formatBytes(t.length > 0 ? t.length : t.downloaded)}'),
      onTap: selecting ? onToggle : () => openVideo(context, t.videoCode, localPath: t.videoPath, localTitle: t.title),
      trailing: selecting
          ? null
          : PopupMenuButton<String>(
              onSelected: (v) async {
                switch (v) {
                  case 'export':
                    await _export(context);
                  case 'share':
                    await SharePlus.instance.share(ShareParams(files: [XFile(t.videoPath)], title: t.title));
                  case 'move':
                    await _move(context);
                  case 'delete':
                    if (await confirm(context, l.deleteDownloadConfirm, content: t.title)) await Downloads.delete(t);
                }
              },
              itemBuilder: (c) => [
                PopupMenuItem(
                  value: 'export',
                  child: Text(
                    Platform.isAndroid || Platform.isIOS ? l.saveToGallery : l.exportFile,
                    style: Pro.isPro ? null : TextStyle(color: Theme.of(c).disabledColor),
                  ),
                ),
                if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) PopupMenuItem(value: 'share', child: Text(l.share)),
                PopupMenuItem(value: 'move', child: Text(l.moveToGroup)),
                PopupMenuItem(value: 'delete', child: Text(l.delete)),
              ],
            ),
    );
  }
}
