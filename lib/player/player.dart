import 'dart:async';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'playlist_duration.dart';

@immutable
class PlayerValue {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final bool playing;
  final bool buffering;
  final bool completed;
  final bool initialized;
  final double speed;
  final double aspectRatio;
  final String? error;

  /// 会话已关闭：画面停在封面，再次播放才会重新打开。
  final bool suspended;

  const PlayerValue({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.playing = false,
    this.buffering = false,
    this.completed = false,
    this.initialized = false,
    this.speed = 1.0,
    this.aspectRatio = 16 / 9,
    this.error,
    this.suspended = false,
  });

  PlayerValue copyWith({
    Duration? position,
    Duration? duration,
    Duration? buffered,
    bool? playing,
    bool? buffering,
    bool? completed,
    bool? initialized,
    double? speed,
    double? aspectRatio,
    String? error,
    bool? suspended,
    bool clearError = false,
  }) =>
      PlayerValue(
        position: position ?? this.position,
        duration: duration ?? this.duration,
        buffered: buffered ?? this.buffered,
        playing: playing ?? this.playing,
        buffering: buffering ?? this.buffering,
        completed: completed ?? this.completed,
        initialized: initialized ?? this.initialized,
        speed: speed ?? this.speed,
        aspectRatio: aspectRatio ?? this.aspectRatio,
        error: clearError ? null : (error ?? this.error),
        suspended: suspended ?? this.suspended,
      );
}

/// 播放内核抽象：移动端 better_player_plus（ExoPlayer / AVPlayer），桌面 media_kit（libmpv）
abstract class HPlayer {
  final ValueNotifier<PlayerValue> value = ValueNotifier(const PlayerValue());

  static bool get useBetterPlayer => Platform.isAndroid || Platform.isIOS;

  factory HPlayer.create() => useBetterPlayer ? _BetterHPlayer() : _MediaKitHPlayer();

  HPlayer._();

  /// 还没 open 过时，由详情页补上地址再打开。
  Future<void> Function()? resumeHook;

  /// 页面还在前台才自动开播。用户点播放时走 [open] 的 forcePlay。
  bool Function()? shouldPlay;

  int _openGen = 0;
  int _playlistTicket = 0;
  Timer? _durationPoll;
  Duration _reported = Duration.zero;
  Duration? _playlistDuration;

  bool get hasSource;

  void cancelPendingOpen() => _openGen++;

  int _claimOpen() => ++_openGen;

  bool _sameOpen(int gen) => gen == _openGen;

  void _resetClock() {
    _reported = Duration.zero;
    _playlistDuration = null;
    _durationPoll?.cancel();
    _playlistTicket++;
  }

  Duration _durationOf(Duration reported) {
    if (reported > Duration.zero) {
      _reported = reported;
      _durationPoll?.cancel();
      return reported;
    }
    if (_reported > Duration.zero) return _reported;
    return _playlistDuration ?? Duration.zero;
  }

  void _listenForDuration(bool Function() alive, void Function() tick) {
    _durationPoll?.cancel();
    var n = 0;
    _durationPoll = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (!alive() || ++n > 40 || _reported > Duration.zero) {
        t.cancel();
        return;
      }
      tick();
    });
  }

  void _loadPlaylistDuration(String source, Map<String, String>? headers, bool isFile, void Function() onReady) {
    if (isFile || !source.toLowerCase().contains('.m3u8')) return;
    final ticket = _playlistTicket;
    playlistDuration(source, headers).then((d) {
      if (ticket != _playlistTicket || d == null || d <= Duration.zero) return;
      _playlistDuration = d;
      if (_reported <= Duration.zero) onReady();
    });
  }

  Future<void> open(String source, {Map<String, String>? headers, bool isFile = false, Duration? start, bool forcePlay = false});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration to);
  Future<void> setSpeed(double speed);

  /// 停掉本次播放。页面还在，状态变为暂停。
  Future<void> closeSession();

  Widget surface();
  Future<void> dispose();

  Future<void> togglePlay() => value.value.playing ? pause() : play();
}

class _BetterHPlayer extends HPlayer {
  _BetterHPlayer() : super._();

  BetterPlayerController? _c;
  final _version = ValueNotifier(0);
  bool _disposed = false;
  bool _finished = false;
  bool _sessionClosed = false;
  bool _lastIsFile = false;
  String? _lastSource;
  Map<String, String>? _lastHeaders;

  @override
  bool get hasSource => _lastSource != null;

  @override
  Future<void> open(String source, {Map<String, String>? headers, bool isFile = false, Duration? start, bool forcePlay = false}) async {
    final gen = _claimOpen();
    _resetClock();
    _loadPlaylistDuration(source, headers, isFile, _sync);
    _lastSource = source;
    _lastHeaders = headers;
    _lastIsFile = isFile;
    _finished = false;
    _sessionClosed = false;
    await _release();
    if (!_sameOpen(gen) || _disposed) return;
    value.value = PlayerValue(buffering: true, position: start ?? Duration.zero);
    final c = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        startAt: start,
        fit: BoxFit.contain,
        expandToFill: true,
        autoDispose: false,
        handleLifecycle: true,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(showControls: false, enableFullscreen: false),
        errorBuilder: (context, msg) => const SizedBox.shrink(),
      ),
    );
    c.addEventsListener(_onEvent);
    _c = c;
    _version.value++;
    final ds = isFile
        ? BetterPlayerDataSource.file(source)
        : BetterPlayerDataSource.network(
            source,
            headers: headers,
            videoFormat: source.contains('.m3u8') ? BetterPlayerVideoFormat.hls : null,
          );
    try {
      await c.setupDataSource(ds);
    } catch (e) {
      if (!_sameOpen(gen) || _disposed) return;
      value.value = value.value.copyWith(error: e.toString(), buffering: false);
      return;
    }
    if (_disposed || _c != c) return;
    c.videoPlayerController?.addListener(_sync);
    _sync();
    _listenForDuration(() => !_disposed && _c == c, _sync);
    if (!_sameOpen(gen) || _sessionClosed) return;
    final wantPlay = forcePlay || (shouldPlay?.call() ?? false);
    if (!wantPlay) return;
    await c.play();
    if (!_sameOpen(gen) || _disposed || (!forcePlay && shouldPlay?.call() == false)) {
      await c.pause();
    }
  }

  void _onEvent(BetterPlayerEvent e) {
    switch (e.betterPlayerEventType) {
      case BetterPlayerEventType.finished:
        _finished = true;
        value.value = value.value.copyWith(completed: true, playing: false, buffering: false);
        _c?.pause();
      case BetterPlayerEventType.exception:
        value.value = value.value.copyWith(error: e.parameters?['exception']?.toString() ?? 'error', buffering: false);
      default:
        break;
    }
  }

  void _sync() {
    final vpc = _c?.videoPlayerController;
    if (vpc == null || _disposed || _sessionClosed) return;
    final v = vpc.value;
    final buffered = v.buffered.isEmpty ? Duration.zero : v.buffered.last.end;
    value.value = value.value.copyWith(
      position: v.position,
      duration: _durationOf(v.duration ?? Duration.zero),
      buffered: buffered,
      playing: _finished ? false : v.isPlaying,
      buffering: _finished ? false : v.isBuffering,
      initialized: v.initialized,
      speed: v.speed,
      aspectRatio: v.size == null ? null : v.aspectRatio,
      completed: _finished ? true : (v.isPlaying ? false : null),
      error: v.errorDescription,
    );
  }

  @override
  Future<void> play() async {
    if (_sessionClosed || _c == null) {
      if (_lastSource != null) {
        final start = value.value.completed ? Duration.zero : value.value.position;
        await open(_lastSource!, headers: _lastHeaders, isFile: _lastIsFile, start: start, forcePlay: true);
      } else {
        await resumeHook?.call();
      }
      return;
    }
    _finished = false;
    if (value.value.completed) await seek(Duration.zero);
    await _c?.play();
  }

  @override
  Future<void> closeSession() async {
    cancelPendingOpen();
    if (_sessionClosed && _c == null) return;
    final snap = value.value;
    _sessionClosed = true;
    await _release();
    if (_disposed) return;
    value.value = PlayerValue(
      position: snap.position,
      duration: snap.duration,
      aspectRatio: snap.aspectRatio,
      suspended: true,
      initialized: true,
    );
  }

  @override
  Future<void> pause() async => _c?.pause();

  @override
  Future<void> seek(Duration to) async {
    if (_sessionClosed || _c == null) {
      value.value = value.value.copyWith(completed: false, position: to, suspended: true, initialized: true);
      return;
    }
    value.value = value.value.copyWith(completed: false, position: to);
    await _c?.seekTo(to);
  }

  @override
  Future<void> setSpeed(double speed) async => _c?.setSpeed(speed);

  @override
  Widget surface() => ValueListenableBuilder<int>(
        valueListenable: _version,
        builder: (context, _, _) {
          final c = _c;
          if (c == null) return const ColoredBox(color: Colors.black);
          // iOS 的 Platform View 会吃掉单击。画面不参与命中后，外层单击才能显隐控制条。
          final player = BetterPlayer(key: ValueKey(c), controller: c);
          return ColoredBox(
            color: Colors.black,
            child: Center(child: Platform.isIOS ? IgnorePointer(child: player) : player),
          );
        },
      );

  Future<void> _release() async {
    final c = _c;
    _c = null;
    if (c == null) return;
    _durationPoll?.cancel();
    c.videoPlayerController?.removeListener(_sync);
    c.removeEventsListener(_onEvent);
    _version.value++;
    await WidgetsBinding.instance.endOfFrame;
    try {
      c.dispose(forceDispose: true);
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    cancelPendingOpen();
    _disposed = true;
    await _release();
  }
}

class _MediaKitHPlayer extends HPlayer {
  _MediaKitHPlayer() : super._() {
    final s = _p.stream;
    _subs.addAll([
      s.position.listen((d) => _set(value.value.copyWith(position: d))),
      s.duration.listen((d) {
        final dur = _durationOf(d);
        _set(value.value.copyWith(duration: dur, initialized: dur > Duration.zero || value.value.initialized));
      }),
      s.buffer.listen((d) => _set(value.value.copyWith(buffered: d))),
      s.playing.listen((p) {
        _set(value.value.copyWith(playing: _finished ? false : p, completed: _finished ? true : (p ? false : null)));
      }),
      s.buffering.listen((b) => _set(value.value.copyWith(buffering: _finished ? false : b))),
      s.completed.listen((c) {
        if (!c) return;
        _finished = true;
        if (_p.state.playing) _p.pause();
        _set(value.value.copyWith(completed: true, playing: false, buffering: false));
      }),
      s.rate.listen((r) => _set(value.value.copyWith(speed: r))),
      s.error.listen((e) => _set(value.value.copyWith(error: e, buffering: false))),
      s.width.listen((_) => _aspect()),
      s.height.listen((_) => _aspect()),
    ]);
  }

  final Player _p = Player(
    configuration: const PlayerConfiguration(title: 'HaVF'),
  );
  late final VideoController _vc = VideoController(_p);
  final List<StreamSubscription<dynamic>> _subs = [];
  bool _disposed = false;
  bool _finished = false;
  bool _sessionClosed = false;
  bool _lastIsFile = false;
  String? _lastSource;
  Map<String, String>? _lastHeaders;

  @override
  bool get hasSource => _lastSource != null;

  void _set(PlayerValue v) {
    if (!_disposed && !_sessionClosed) value.value = v;
  }

  void _aspect() {
    final w = _p.state.width, h = _p.state.height;
    if (w != null && h != null && w > 0 && h > 0) _set(value.value.copyWith(aspectRatio: w / h));
  }

  @override
  Future<void> open(String source, {Map<String, String>? headers, bool isFile = false, Duration? start, bool forcePlay = false}) async {
    final gen = _claimOpen();
    _resetClock();
    _loadPlaylistDuration(source, headers, isFile, () {
      final dur = _durationOf(Duration.zero);
      if (dur > Duration.zero) _set(value.value.copyWith(duration: dur, initialized: true));
    });
    _lastSource = source;
    _lastHeaders = headers;
    _lastIsFile = isFile;
    _finished = false;
    await _p.stop();
    if (!_sameOpen(gen) || _disposed) return;
    _sessionClosed = false;
    value.value = PlayerValue(buffering: true, position: start ?? Duration.zero);
    await _p.open(Media(source, httpHeaders: headers, start: start), play: false);
    if (_disposed || _sessionClosed) return;
    final fallback = _durationOf(Duration.zero);
    if (fallback > Duration.zero) _set(value.value.copyWith(duration: fallback, initialized: true));
    if (!_sameOpen(gen)) return;
    final wantPlay = forcePlay || (shouldPlay?.call() ?? false);
    if (!wantPlay) return;
    await _p.play();
    if (!_sameOpen(gen) || _disposed || (!forcePlay && shouldPlay?.call() == false)) {
      await _p.pause();
    }
  }

  @override
  Future<void> play() async {
    if (_sessionClosed) {
      if (_lastSource != null) {
        final start = value.value.completed ? Duration.zero : value.value.position;
        await open(_lastSource!, headers: _lastHeaders, isFile: _lastIsFile, start: start, forcePlay: true);
      } else {
        await resumeHook?.call();
      }
      return;
    }
    _finished = false;
    if (value.value.completed) await _p.seek(Duration.zero);
    await _p.play();
  }

  @override
  Future<void> closeSession() async {
    cancelPendingOpen();
    if (_sessionClosed) return;
    final snap = value.value;
    _sessionClosed = true;
    await _p.stop();
    if (_disposed) return;
    value.value = PlayerValue(
      position: snap.position,
      duration: snap.duration,
      aspectRatio: snap.aspectRatio,
      suspended: true,
      initialized: true,
    );
  }

  @override
  Future<void> pause() => _p.pause();

  @override
  Future<void> seek(Duration to) {
    if (_sessionClosed) {
      value.value = value.value.copyWith(completed: false, position: to, suspended: true, initialized: true);
      return Future.value();
    }
    _set(value.value.copyWith(completed: false, position: to));
    return _p.seek(to);
  }

  @override
  Future<void> setSpeed(double speed) => _p.setRate(speed);

  @override
  Widget surface() => Video(controller: _vc, controls: NoVideoControls, fit: BoxFit.contain, fill: Colors.black);

  @override
  Future<void> dispose() async {
    cancelPendingOpen();
    _durationPoll?.cancel();
    _disposed = true;
    _sessionClosed = true;
    for (final s in _subs) {
      await s.cancel();
    }
    await _p.dispose();
  }
}
