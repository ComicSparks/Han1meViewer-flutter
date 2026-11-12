import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../core/downloads.dart';
import '../../core/errors.dart';
import '../../core/nav.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../src/rust/api/download.dart' as dl;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  int _group = -1;
  String _keyword = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.downloads),
        actions: [
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
                    (context, i) => _DoneTile(done[i], groups: groups),
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
  const _DoneTile(this.t, {required this.groups});

  Future<void> _export(BuildContext context) async {
    final l = AppLocalizations.of(context);
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (!await Gal.hasAccess()) await Gal.requestAccess();
        await Gal.putVideo(t.videoPath, album: 'HaVF');
        if (context.mounted) toast(context, l.exported);
      } else {
        final ext = t.videoPath.split('.').last;
        final safe = t.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
        final loc = await getSaveLocation(suggestedName: '$safe [${t.quality}].$ext');
        if (loc == null) return;
        await File(t.videoPath).copy(loc.path);
        if (context.mounted) toast(context, l.exported);
      }
    } catch (e) {
      if (context.mounted) toast(context, '${l.exportFailed}: $e');
    }
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
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(width: 96, height: 54, child: NetImage(t.coverUrl, localPath: t.coverPath)),
      ),
      title: Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${t.quality} · ${formatBytes(t.length > 0 ? t.length : t.downloaded)}'),
      onTap: () => openVideo(context, t.videoCode, localPath: t.videoPath, localTitle: t.title),
      trailing: PopupMenuButton<String>(
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
        itemBuilder: (_) => [
          PopupMenuItem(value: 'export', child: Text(Platform.isAndroid || Platform.isIOS ? l.saveToGallery : l.exportFile)),
          if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) PopupMenuItem(value: 'share', child: Text(l.share)),
          PopupMenuItem(value: 'move', child: Text(l.moveToGroup)),
          PopupMenuItem(value: 'delete', child: Text(l.delete)),
        ],
      ),
    );
  }
}
