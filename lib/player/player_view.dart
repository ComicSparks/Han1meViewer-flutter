import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

import '../core/metrics.dart';
import '../core/prefs.dart';
import '../l10n/gen/app_localizations.dart';
import '../src/rust/api/models.dart';
import '../widgets/common.dart';
import 'player.dart';

const speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0];

class PlayerView extends StatefulWidget {
  final HPlayer player;
  final String title;
  final bool fullscreen;
  final VoidCallback onToggleFullscreen;
  final VoidCallback? onBack;
  final List<String> qualities;
  final String? quality;
  final ValueChanged<String>? onQuality;
  final List<Keyframe>? keyframes;
  final VoidCallback? onKeyframes;
  final VoidCallback? onAddKeyframe;
  final VoidCallback? onRetry;
  final Widget? placeholder;

  /// 详情还没拿到。此时不要把未初始化当成正在缓冲。
  final bool pageFailed;

  const PlayerView({
    super.key,
    required this.player,
    required this.title,
    required this.fullscreen,
    required this.onToggleFullscreen,
    this.onBack,
    this.qualities = const [],
    this.quality,
    this.onQuality,
    this.keyframes,
    this.onKeyframes,
    this.onAddKeyframe,
    this.onRetry,
    this.placeholder,
    this.pageFailed = false,
  });

  @override
  State<PlayerView> createState() => PlayerViewState();
}

enum _VDrag { none, brightness, volume }

class PlayerViewState extends State<PlayerView> {
  bool _visible = false;
  bool _started = false;
  bool _notedPlay = false;
  bool _sawCompleted = false;
  Timer? _hideTimer;
  Duration? _seekPreview;
  Duration _seekBase = Duration.zero;
  double _dragDx = 0;
  bool _boosting = false;
  double _speedBeforeBoost = 1;
  _VDrag _vDrag = _VDrag.none;
  double _vValue = 0;
  final _focus = FocusNode();

  bool get _mobile => Platform.isAndroid || Platform.isIOS;
  HPlayer get _p => widget.player;

  @override
  void initState() {
    super.initState();
    _p.value.addListener(_onPlayer);
  }

  @override
  void dispose() {
    _p.value.removeListener(_onPlayer);
    _hideTimer?.cancel();
    _focus.dispose();
    if (_mobile) {
      ScreenBrightness.instance.resetApplicationScreenBrightness().catchError((_) {});
    }
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      final v = _p.value.value;
      if (mounted && v.playing && !v.completed) setState(() => _visible = false);
    });
  }

  /// 退回这一页时露出控制条，保持暂停，不自动淡出。
  void showControls() {
    if (!mounted) return;
    _reveal(fadeOut: false);
  }

  /// [fadeOut] 为真时，显示后 3 秒淡出。暂停和播放结束时留在画面上。
  void _reveal({required bool fadeOut}) {
    _hideTimer?.cancel();
    setState(() => _visible = true);
    if (fadeOut) _scheduleHide();
  }

  void _onPlayer() {
    final v = _p.value.value;
    if (v.playing) {
      _started = true;
      if (!_notedPlay) {
        _notedPlay = true;
        Metrics.note('play');
      }
    }
    if (v.completed && !_sawCompleted) {
      _sawCompleted = true;
      if (mounted) _reveal(fadeOut: false);
    } else if (!v.completed) {
      _sawCompleted = false;
    }
  }

  void _onSingleTap() {
    _focus.requestFocus();
    if (!_started && !_p.value.value.playing) return;
    if (_visible) {
      _hideTimer?.cancel();
      setState(() => _visible = false);
    } else {
      _reveal(fadeOut: _p.value.value.playing && !_p.value.value.completed);
    }
  }

  void _togglePlayback() {
    final v = _p.value.value;
    if (v.error != null || (!v.initialized && !v.playing && !v.suspended)) return;
    if (v.playing) {
      _p.pause();
      _reveal(fadeOut: false);
    } else {
      _p.play();
      _started = true;
      if (_visible) _reveal(fadeOut: true);
    }
  }

  void _seekBy(Duration d) {
    final v = _p.value.value;
    var t = v.position + d;
    if (t < Duration.zero) t = Duration.zero;
    if (v.duration > Duration.zero && t > v.duration) t = v.duration;
    _p.seek(t);
    _reveal(fadeOut: _p.value.value.playing);
  }

  // ---------- 手势 ----------

  void _hStart(DragStartDetails d) {
    if (!Prefs.gestures.value) return;
    _seekBase = _p.value.value.position;
    _dragDx = 0;
    setState(() => _seekPreview = _seekBase);
  }

  void _hUpdate(DragUpdateDetails d, double width) {
    if (_seekPreview == null) return;
    _dragDx += d.delta.dx;
    final total = _p.value.value.duration;
    // 拖满整个宽度约等于 90 秒，长视频按比例放大
    final span = total.inSeconds > 0 ? (total.inSeconds / 8).clamp(90, 600) : 90;
    var target = _seekBase + Duration(milliseconds: (_dragDx / width * span * 1000).round());
    if (target < Duration.zero) target = Duration.zero;
    if (total > Duration.zero && target > total) target = total;
    setState(() => _seekPreview = target);
  }

  void _hEnd(DragEndDetails d) {
    final t = _seekPreview;
    setState(() => _seekPreview = null);
    if (t != null) _p.seek(t);
  }

  Future<void> _vStart(DragStartDetails d, double width) async {
    if (!_mobile || !Prefs.gestures.value) return;
    final left = d.localPosition.dx < width / 2;
    _vDrag = left ? _VDrag.brightness : _VDrag.volume;
    try {
      _vValue = left
          ? await ScreenBrightness.instance.application
          : await VolumeController.instance.getVolume();
    } catch (_) {
      _vValue = 0.5;
    }
    VolumeController.instance.showSystemUI = false;
    if (mounted) setState(() {});
  }

  void _vUpdate(DragUpdateDetails d, double height) {
    if (_vDrag == _VDrag.none) return;
    _vValue = (_vValue - d.delta.dy / (height * 0.8)).clamp(0.0, 1.0);
    if (_vDrag == _VDrag.brightness) {
      ScreenBrightness.instance.setApplicationScreenBrightness(_vValue).catchError((_) {});
    } else {
      VolumeController.instance.setVolume(_vValue).catchError((_) {});
    }
    setState(() {});
  }

  void _vEnd(DragEndDetails d) => setState(() => _vDrag = _VDrag.none);

  void _longStart(LongPressStartDetails d) {
    if (!_p.value.value.playing) return;
    _speedBeforeBoost = _p.value.value.speed;
    _p.setSpeed(Prefs.longPressSpeed.value);
    setState(() => _boosting = true);
  }

  void _longEnd(LongPressEndDetails d) {
    if (!_boosting) return;
    _p.setSpeed(_speedBeforeBoost);
    setState(() => _boosting = false);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.keyK) {
      if (e is KeyDownEvent) _togglePlayback();
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _seekBy(const Duration(seconds: -10));
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _seekBy(const Duration(seconds: 10));
    } else if (k == LogicalKeyboardKey.keyF && e is KeyDownEvent) {
      widget.onToggleFullscreen();
      _reveal(fadeOut: _p.value.value.playing);
    } else if (k == LogicalKeyboardKey.escape && widget.fullscreen && e is KeyDownEvent) {
      widget.onToggleFullscreen();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ---------- 关键帧倒计时 ----------

  Widget? _countdown(PlayerValue v, TextStyle style) {
    final kfs = widget.keyframes;
    if (kfs == null || kfs.isEmpty) return null;
    final limit = Prefs.keyframeCountdownSec.value * 1000;
    final pos = v.position.inMilliseconds;
    for (var i = 0; i < kfs.length; i++) {
      final interval = kfs[i].position - pos;
      if (interval >= 0 && interval < limit) {
        final secs = interval / 1000;
        final time = secs >= 1 ? '${secs.floor() + 1}' : secs.toStringAsFixed(1);
        final prompt = kfs[i].prompt;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Prefs.keyframeShowPrompt.value)
              Text('#${i + 1}${prompt == null || prompt.isEmpty ? '' : ' $prompt'}',
                  style: style.copyWith(fontSize: 14)),
            Text(time, style: style.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Focus(
      focusNode: _focus,
      autofocus: !_mobile,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
          builder: (context, box) => ValueListenableBuilder<PlayerValue>(
            valueListenable: _p.value,
            builder: (context, v, _) {
              const white = TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)]);
              final countdown = _countdown(v, white);
              final pinBack = widget.onBack != null &&
                  (widget.pageFailed || !_started || !v.initialized || v.error != null);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onSingleTap,
                onDoubleTap: _togglePlayback,
                onHorizontalDragStart: _hStart,
                onHorizontalDragUpdate: (d) => _hUpdate(d, box.maxWidth),
                onHorizontalDragEnd: _hEnd,
                onVerticalDragStart: (d) => _vStart(d, box.maxWidth),
                onVerticalDragUpdate: (d) => _vUpdate(d, box.maxHeight),
                onVerticalDragEnd: _vEnd,
                onLongPressStart: _longStart,
                onLongPressEnd: _longEnd,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Colors.black),
                    _p.surface(),
                    if (v.suspended && widget.placeholder != null && v.error == null) widget.placeholder!,
                    if (!v.initialized && !v.suspended && widget.placeholder != null && v.error == null) widget.placeholder!,
                    if (!widget.pageFailed && v.error == null && !v.suspended && (v.buffering || !v.initialized))
                      const Center(child: CircularProgressIndicator(color: Colors.white)),
                    if (v.error != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l.playError, style: white),
                              const SizedBox(height: 8),
                              if (widget.onRetry != null)
                                FilledButton.tonal(onPressed: widget.onRetry, child: Text(l.retry)),
                            ],
                          ),
                        ),
                      ),
                    if (countdown != null) Positioned(top: 48, right: 16, child: countdown),
                    if (_seekPreview != null)
                      Center(
                        child: _Pill(
                          '${formatDuration(_seekPreview!)} / ${formatDuration(v.duration)}',
                        ),
                      ),
                    if (_vDrag != _VDrag.none)
                      Center(
                        child: _Pill(
                          '${_vDrag == _VDrag.brightness ? l.brightness : l.volume} ${(_vValue * 100).round()}%',
                        ),
                      ),
                    if (_boosting)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(child: _Pill('${Prefs.longPressSpeed.value}x ▶▶')),
                      ),
                    AnimatedOpacity(
                      opacity: _visible ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_visible,
                        child: _controls(context, v, l, includeBack: !pinBack),
                      ),
                    ),
                    if (pinBack) _backButton(),
                  ],
                ),
              );
            },
          ),
        ),
    );
  }

  Widget _backButton() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          left: widget.fullscreen,
          right: widget.fullscreen,
          top: widget.fullscreen,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              color: Colors.white,
              icon: const BackButtonIcon(),
              onPressed: widget.onBack,
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls(BuildContext context, PlayerValue v, AppLocalizations l, {required bool includeBack}) {
    const iconColor = Colors.white;
    final total = v.duration.inMilliseconds.toDouble();
    final pos = v.position.inMilliseconds.clamp(0, total > 0 ? total : 0).toDouble();
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: SafeArea(
              bottom: false,
              left: widget.fullscreen,
              right: widget.fullscreen,
              top: widget.fullscreen,
              child: Row(
                children: [
                  if (widget.onBack != null)
                    includeBack
                        ? IconButton(color: iconColor, icon: const BackButtonIcon(), onPressed: widget.onBack)
                        : const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      widget.fullscreen ? widget.title : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (widget.keyframes != null)
                    GestureDetector(
                      onLongPress: widget.onAddKeyframe,
                      child: IconButton(
                        color: iconColor,
                        tooltip: l.hKeyframes,
                        icon: const Icon(Icons.bookmarks_outlined),
                        onPressed: widget.onKeyframes,
                      ),
                    ),
                  PopupMenuButton<double>(
                    tooltip: l.speed,
                    initialValue: v.speed,
                    onSelected: _p.setSpeed,
                    itemBuilder: (_) => [
                      for (final s in speedOptions) PopupMenuItem(value: s, child: Text('${s}x')),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Text('${v.speed}x', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  if (widget.qualities.length > 1)
                    PopupMenuButton<String>(
                      tooltip: l.quality,
                      initialValue: widget.quality,
                      onSelected: widget.onQuality,
                      itemBuilder: (_) => [
                        for (final q in widget.qualities) PopupMenuItem(value: q, child: Text(q)),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Text(widget.quality ?? '', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: SafeArea(
              top: false,
              left: widget.fullscreen,
              right: widget.fullscreen,
              bottom: widget.fullscreen,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Text(formatDuration(v.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (total > 0 && widget.keyframes != null)
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: LayoutBuilder(
                                builder: (context, b) => Stack(
                                  children: [
                                    for (final k in widget.keyframes!)
                                      if (k.position <= total)
                                        Positioned(
                                          left: b.maxWidth * k.position / total - 2,
                                          top: b.maxHeight / 2 - 6,
                                          child: Container(width: 4, height: 12, color: Colors.amber),
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          ),
                          child: Slider(
                            value: _seekPreview == null ? pos : _seekPreview!.inMilliseconds.clamp(0, total).toDouble(),
                            max: total > 0 ? total : 1,
                            secondaryTrackValue: v.buffered.inMilliseconds.clamp(0, total > 0 ? total : 1).toDouble(),
                            onChangeStart: (_) => _hideTimer?.cancel(),
                            onChanged: total > 0
                                ? (x) => setState(() => _seekPreview = Duration(milliseconds: x.round()))
                                : null,
                            onChangeEnd: (x) {
                              setState(() => _seekPreview = null);
                              _p.seek(Duration(milliseconds: x.round()));
                              _scheduleHide();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(formatDuration(v.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  IconButton(
                    color: iconColor,
                    tooltip: l.fullscreen,
                    icon: Icon(widget.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
                    onPressed: widget.onToggleFullscreen,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );
}
