import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart' show defaultEnterNativeFullscreen, defaultExitNativeFullscreen;
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/downloads.dart';
import '../../core/errors.dart';
import '../../core/keyframes.dart';
import '../../core/nav.dart';
import '../../core/prefs.dart';
import '../../core/session.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../player/player.dart';
import '../../player/player_view.dart';
import '../../src/rust/api/app.dart' as rapi;
import '../../src/rust/api/hanime.dart' as hanime;
import '../../src/rust/api/local.dart' as local;
import '../../src/rust/api/models.dart';
import '../../widgets/common.dart';
import '../../widgets/net_image.dart';
import '../login_page.dart';
import '../search/search_page.dart';
import 'comments_view.dart';
import 'user_videos_page.dart';

class VideoPage extends StatefulWidget {
  final String videoCode;
  final String? localPath;
  final String? localTitle;
  const VideoPage({super.key, required this.videoCode, this.localPath, this.localTitle});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with RouteAware {
  final HPlayer _player = HPlayer.create();
  final _playerKey = GlobalKey<PlayerViewState>();
  HanimeVideo? _video;
  Object? _error;
  String? _quality;
  bool _fullscreen = false;
  HKeyframes? _keyframes;
  Timer? _progressTimer;
  bool _opened = false;
  bool _suspendAutoplay = false;
  bool _covered = false;
  ModalRoute<void>? _route;
  Duration? _resumeAt;

  // 可变状态（FRB 模型不可变）
  bool _isFav = false;
  int _favTimes = 0;
  bool _watchLater = false;
  Map<String, bool> _lists = {};
  bool? _subscribed;

  String get _title => _video?.title ?? widget.localTitle ?? widget.videoCode;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {});
    _player.resumeHook = _resumeIfNeeded;
    _player.value.addListener(_onPlayback);
    _init();
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) => _saveProgress());
  }

  Future<void> _init() async {
    if (Prefs.resumePlayback.value) {
      try {
        final h = await local.historyGet(videoCode: widget.videoCode);
        if (h != null && h.progress > 5000 && (h.duration == 0 || h.progress < h.duration - 10000)) {
          _resumeAt = Duration(milliseconds: h.progress);
        }
      } catch (_) {}
    }
    if (widget.localPath != null) {
      _opened = true;
      _player.open(widget.localPath!, isFile: true, start: _resumeAt).then((_) {
        if (_covered) _player.pause();
      });
    }
    _loadKeyframes();
    await _load();
  }

  Future<void> _loadKeyframes() async {
    final k = await KeyframeStore.resolve(widget.videoCode);
    if (mounted) setState(() => _keyframes = k);
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final v = await hanime.video(videoCode: widget.videoCode);
      if (!mounted) return;
      setState(() {
        _video = v;
        _isFav = v.isFav;
        _favTimes = v.favTimes ?? 0;
        _watchLater = v.isWatchLater;
        _lists = {for (final m in v.myLists) m.code: m.selected};
        _subscribed = v.artist?.post?.subscribed;
      });
      local.historyUpsert(
        item: WatchHistory(
          videoCode: v.videoCode,
          title: v.title,
          coverUrl: v.coverUrl,
          releaseDate: v.uploadTime,
          watchDate: DateTime.now().millisecondsSinceEpoch,
          progress: _resumeAt?.inMilliseconds ?? 0,
          duration: 0,
        ),
      );
      if (!_opened && !_suspendAutoplay && v.links.isNotEmpty) {
        final pref = Prefs.defaultQuality.value;
        final link = v.links.where((e) => e.quality == pref).firstOrNull ?? v.links.first;
        _openLink(link, _resumeAt);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Map<String, String> get _headers => {
        'User-Agent': rapi.effectiveUserAgent(),
        'Referer': rapi.baseUrl(),
      };

  void _openLink(VideoLink link, Duration? start) {
    _opened = true;
    setState(() => _quality = link.quality);
    _player.open(link.url, headers: _headers, start: start).then((_) {
      if (_covered) _player.pause();
    });
  }

  Future<void> _resumeIfNeeded() async {
    if (_player.hasSource) return;
    final start = _player.value.value.position > Duration.zero ? _player.value.value.position : _resumeAt;
    if (widget.localPath != null) {
      _opened = true;
      await _player.open(widget.localPath!, isFile: true, start: start);
      return;
    }
    final v = _video;
    if (v == null || v.links.isEmpty) return;
    final pref = _quality ?? Prefs.defaultQuality.value;
    final link = v.links.where((e) => e.quality == pref).firstOrNull ?? v.links.first;
    _openLink(link, start);
  }

  void _onPlayback() {
    if (_player.value.value.playing) WakelockPlus.enable().catchError((_) {});
  }

  /// 上面那一层是另一个页面。本页在 [didPushNext] 里暂停，会话和缓存留着。
  Future<void> _leaveFor(Future<void> Function() go) => go();

  void _switchQuality(String q) {
    final link = _video?.links.where((e) => e.quality == q).firstOrNull;
    if (link == null || q == _quality) return;
    _openLink(link, _player.value.value.position);
  }

  void _retry() {
    if (widget.localPath != null) {
      _player.open(widget.localPath!, isFile: true, start: _player.value.value.position);
      return;
    }
    final link = _video?.links.where((e) => e.quality == _quality).firstOrNull;
    if (link != null) {
      _openLink(link, _player.value.value.position);
    } else {
      _load();
    }
  }

  void _saveProgress() {
    final v = _player.value.value;
    if (!v.initialized || v.duration == Duration.zero) return;
    local
        .historyUpdateProgress(
          videoCode: widget.videoCode,
          progress: v.position.inMilliseconds,
          duration: v.duration.inMilliseconds,
        )
        .catchError((_) {});
  }

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
  void didPushNext() {
    _suspendAutoplay = true;
    _covered = true;
    _saveProgress();
    _player.pause();
    WakelockPlus.disable().catchError((_) {});
  }

  @override
  void didPopNext() {
    _covered = false;
    _playerKey.currentState?.showControls();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _player.value.removeListener(_onPlayback);
    _progressTimer?.cancel();
    _saveProgress();
    _player.dispose();
    WakelockPlus.disable().catchError((_) {});
    if (_fullscreen) _exitFullscreenSystem();
    super.dispose();
  }

  // ---------- 全屏 ----------

  Future<void> _toggleFullscreen() async {
    if (_fullscreen) {
      await _exitFullscreenSystem();
      setState(() => _fullscreen = false);
    } else {
      setState(() => _fullscreen = true);
      if (Platform.isAndroid || Platform.isIOS) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        final landscape = Prefs.autoFullscreenLandscape.value && _player.value.value.aspectRatio >= 1;
        await SystemChrome.setPreferredOrientations(
          landscape
              ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
              : [DeviceOrientation.portraitUp],
        );
      } else {
        await defaultEnterNativeFullscreen();
      }
    }
  }

  Future<void> _exitFullscreenSystem() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      await defaultExitNativeFullscreen();
    }
  }

  // ---------- 关键帧 ----------

  Future<void> _addKeyframe() async {
    final l = AppLocalizations.of(context);
    final pos = _player.value.value.position.inMilliseconds;
    final prompt = await inputText(context, l.addKeyframeAt(formatDuration(Duration(milliseconds: pos))), hint: l.keyframePromptHint);
    if (prompt == null) return;
    final base = (_keyframes != null && !_keyframes!.shared) ? _keyframes!.keyframes : <Keyframe>[];
    await KeyframeStore.save(widget.videoCode, _title, [
      ...base,
      Keyframe(position: pos, prompt: prompt.trim().isEmpty ? null : prompt.trim()),
    ]);
    await _loadKeyframes();
    if (mounted) toast(context, l.keyframeAdded);
  }

  void _showKeyframes() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final k = _keyframes;
          final list = k?.keyframes ?? const <Keyframe>[];
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l.hKeyframes),
                  subtitle: Text(k == null
                      ? l.keyframesEmptyHint
                      : (k.shared ? l.sharedBy(k.author ?? '-') : l.localKeyframes)),
                  trailing: FilledButton.tonalIcon(
                    icon: const Icon(Icons.add),
                    label: Text(l.add),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _addKeyframe();
                    },
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (var i = 0; i < list.length; i++)
                        ListTile(
                          leading: Text('#${i + 1}'),
                          title: Text(formatDuration(Duration(milliseconds: list[i].position))),
                          subtitle: list[i].prompt == null ? null : Text(list[i].prompt!),
                          onTap: () {
                            _player.seek(Duration(milliseconds: list[i].position));
                            Navigator.pop(ctx);
                          },
                          trailing: k!.shared
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final rest = [...list]..removeAt(i);
                                    if (rest.isEmpty) {
                                      await local.keyframesDelete(videoCode: widget.videoCode);
                                    } else {
                                      await KeyframeStore.save(widget.videoCode, _title, rest);
                                    }
                                    await _loadKeyframes();
                                    setSheet(() {});
                                  },
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- 操作 ----------

  Future<bool> _requireLogin() async {
    if (Session.loggedIn) return true;
    final ok = await push<bool>(context, const LoginPage());
    if (ok == true) _load();
    return false;
  }

  Future<void> _toggleFav() async {
    if (!await _requireLogin()) return;
    final v = _video!;
    try {
      final now = await hanime.toggleFav(
        videoCode: v.videoCode,
        currentlyFav: _isFav,
        currentUserId: v.currentUserId,
        csrfToken: v.csrfToken,
      );
      setState(() {
        _favTimes += now ? 1 : -1;
        _isFav = now;
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _toggleWatchLater() async {
    if (!await _requireLogin()) return;
    final v = _video!;
    try {
      await hanime.setInMyList(listCode: 'save', videoCode: v.videoCode, checked: !_watchLater, csrfToken: v.csrfToken);
      setState(() => _watchLater = !_watchLater);
      if (mounted) toast(context, _watchLater ? AppLocalizations.of(context).addedToWatchLater : AppLocalizations.of(context).removed);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _playlists() async {
    if (!await _requireLogin()) return;
    if (!mounted) return;
    final v = _video!;
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(l.addToPlaylist),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.newPlaylist),
                  onPressed: () async {
                    final title = await inputText(ctx, l.newPlaylist, hint: l.playlistTitle);
                    if (title == null || title.trim().isEmpty) return;
                    try {
                      await hanime.createPlaylist(
                        videoCode: v.videoCode,
                        title: title.trim(),
                        description: '',
                        csrfToken: v.csrfToken,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) toast(context, l.playlistCreated);
                      _load();
                    } catch (e) {
                      if (mounted) showError(context, e);
                    }
                  },
                ),
              ),
              for (final m in v.myLists)
                CheckboxListTile(
                  title: Text(m.title),
                  value: _lists[m.code] ?? false,
                  onChanged: (c) async {
                    try {
                      await hanime.setInMyList(
                        listCode: m.code,
                        videoCode: v.videoCode,
                        checked: c ?? false,
                        csrfToken: v.csrfToken,
                      );
                      setState(() => _lists[m.code] = c ?? false);
                      setSheet(() {});
                    } catch (e) {
                      if (mounted) showError(context, e);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _download() async {
    final v = _video!;
    final l = AppLocalizations.of(context);
    final link = await showDialog<VideoLink>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l.chooseQuality),
        children: [
          for (final k in v.links)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(c, k),
              child: Text('${k.quality}  ·  ${k.suffix}'),
            ),
        ],
      ),
    );
    if (link == null) return;
    try {
      await Downloads.add(videoCode: v.videoCode, title: v.title, coverUrl: v.coverUrl, link: link);
      if (mounted) toast(context, l.downloadAdded);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _subscribe() async {
    if (!await _requireLogin()) return;
    final post = _video?.artist?.post;
    if (post == null) return;
    try {
      final now = await hanime.subscribeArtist(
        csrfToken: _video!.csrfToken,
        userId: post.userId,
        artistId: post.artistId,
        targetSubscribed: !(_subscribed ?? false),
      );
      setState(() => _subscribed = now);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _share() {
    final url = '${rapi.baseUrl()}watch?v=${widget.videoCode}';
    if (Platform.isAndroid || Platform.isIOS) {
      SharePlus.instance.share(ShareParams(text: '$_title\n$url'));
    } else {
      Clipboard.setData(ClipboardData(text: url));
      toast(context, AppLocalizations.of(context).linkCopied);
    }
  }

  void _searchTag(String tag) {
    push(context, SearchPage(initialTags: [tag]));
  }

  // ---------- 布局 ----------

  Widget _playerView() => PlayerView(
        key: _playerKey,
        player: _player,
        title: _title,
        fullscreen: _fullscreen,
        onToggleFullscreen: _toggleFullscreen,
        onBack: () => _fullscreen ? _toggleFullscreen() : Navigator.of(context).maybePop(),
        qualities: widget.localPath != null ? const [] : (_video?.links.map((e) => e.quality).toList() ?? const []),
        quality: _quality,
        onQuality: _switchQuality,
        keyframes: Prefs.hKeyframesEnabled.value ? (_keyframes?.keyframes ?? const []) : null,
        onKeyframes: _showKeyframes,
        onAddKeyframe: _addKeyframe,
        onRetry: _retry,
        pageFailed: _error != null && _video == null,
        placeholder: _video == null ? null : NetImage(_video!.coverUrl, fit: BoxFit.contain),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_fullscreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _toggleFullscreen();
        },
        child: Scaffold(backgroundColor: Colors.black, body: _playerView()),
      );
    }
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 960;
    final showComments = !Prefs.hideComments.value;
    final player = ColoredBox(
      color: Colors.black,
      child: SafeArea(bottom: false, child: AspectRatio(aspectRatio: 16 / 9, child: _playerView())),
    );
    final intro = _IntroView(state: this);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  player,
                  Expanded(child: intro),
                ],
              ),
            ),
            if (showComments) ...[
              const VerticalDivider(width: 1),
              SizedBox(
                width: 400,
                child: SafeArea(
                  child: Column(
                    children: [
                      ListTile(title: Text(l.comments)),
                      Expanded(child: CommentsView(videoCode: widget.videoCode)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return Scaffold(
      body: DefaultTabController(
        length: showComments ? 2 : 1,
        child: Column(
          children: [
            player,
            TabBar(tabs: [Tab(text: l.intro), if (showComments) Tab(text: l.comments)]),
            Expanded(
              child: TabBarView(
                children: [
                  intro,
                  if (showComments) CommentsView(videoCode: widget.videoCode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  toast(context, AppLocalizations.of(context).copied);
}

Widget _copyText(BuildContext context, String text, TextStyle? style) {
  return GestureDetector(onLongPress: () => _copy(context, text), child: Text(text, style: style));
}

class _IntroView extends StatelessWidget {
  final _VideoPageState state;
  const _IntroView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = state._video;
    final theme = Theme.of(context);
    if (v == null) {
      if (state._error != null) return ErrorView(error: state._error!, onRetry: state._load);
      return const Center(child: CircularProgressIndicator());
    }
    final meta = [v.views, v.uploadTime].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final downloaded = Downloads.finishedFor(v.videoCode) != null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _copyText(context, v.title, theme.textTheme.titleMedium),
        if (v.chineseTitle != null && v.chineseTitle!.isNotEmpty && v.chineseTitle != v.title)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _copyText(context, v.chineseTitle!, theme.textTheme.bodyMedium),
          ),
        if (meta.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          ),
        if (v.artist != null) ...[
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipOval(child: NetImage(v.artist!.avatarUrl, width: 40, height: 40)),
            title: Text(v.artist!.name),
            subtitle: Text(v.artist!.genre),
            onTap: () => state._openArtist(v.artist!),
            onLongPress: () => _copy(context, v.artist!.name),
            trailing: v.artist!.post == null
                ? null
                : (state._subscribed ?? false)
                    ? OutlinedButton(onPressed: state._subscribe, child: Text(l.subscribed))
                    : FilledButton(onPressed: state._subscribe, child: Text(l.subscribe)),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            _Action(
              icon: state._isFav ? Icons.favorite : Icons.favorite_border,
              label: state._favTimes > 0 ? '${state._favTimes}' : l.favorite,
              active: state._isFav,
              onTap: state._toggleFav,
            ),
            _Action(
              icon: state._watchLater ? Icons.watch_later : Icons.watch_later_outlined,
              label: l.watchLater,
              active: state._watchLater,
              onTap: state._toggleWatchLater,
            ),
            _Action(icon: Icons.playlist_add, label: l.playlist, onTap: state._playlists),
            _Action(
              icon: downloaded ? Icons.download_done : Icons.download_outlined,
              label: downloaded ? l.downloaded : l.download,
              onTap: v.links.isEmpty ? null : state._download,
            ),
            _Action(icon: Icons.share_outlined, label: l.share, onTap: state._share),
          ],
        ),
        if (v.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in v.tags)
                ActionChip(label: Text(t), visualDensity: VisualDensity.compact, onPressed: () => state._searchTag(t)),
            ],
          ),
        ],
        if (v.introduction != null && v.introduction!.isNotEmpty) ...[
          const SizedBox(height: 12),
          SelectableText(v.introduction!, style: theme.textTheme.bodyMedium),
        ],
        if (v.playlist != null && v.playlist!.videos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(v.playlist!.name ?? l.playlist, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: v.playlist!.videos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final info = v.playlist!.videos[i];
                return VideoCard(
                  info,
                  width: 200,
                  onTap: info.isPlaying
                      ? null
                      : () {
                          final code = info.videoCode;
                          state._leaveFor(() => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => VideoPage(videoCode: code)),
                              ));
                        },
                );
              },
            ),
          ),
        ],
        if (v.related.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l.related, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: videoGridDelegate(simplified: v.related.every((e) => e.simplified)),
            itemCount: v.related.length,
            itemBuilder: (context, i) {
              final info = v.related[i];
              return VideoCard(
                info,
                onTap: () {
                  final code = info.videoCode;
                  state._leaveFor(() => openVideo(context, code));
                },
              );
            },
          ),
        ],
      ],
    );
  }
}

extension on _VideoPageState {
  void _openArtist(Artist artist) {
    final id = artist.userId;
    if (id == null || id.isEmpty) {
      _searchArtist(artist.name);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserVideosPage(userId: id, name: artist.name)));
  }

  void _searchArtist(String name) {
    push(context, SearchPage(initialQuery: name));
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _Action({required this.icon, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : null;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
