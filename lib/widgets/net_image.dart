import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../src/rust/api/app.dart' as rapi;

/// 经 Rust 拉取并落盘（LRU）的网络图片，走同一套 UA / Cookie / DNS / 代理
@immutable
class RustImage extends ImageProvider<RustImage> {
  final String url;
  const RustImage(this.url);

  @override
  Future<RustImage> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(RustImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1.0,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final path = await rapi.imageCacheFetch(url: url);
    final bytes = await File(path).readAsBytes();
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) => other is RustImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

class NetImage extends StatelessWidget {
  final String? url;
  final String? localPath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetImage(this.url, {super.key, this.localPath, this.fit = BoxFit.cover, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget placeholder([IconData icon = Icons.image_outlined]) => Container(
          width: width,
          height: height,
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(icon, color: scheme.outline),
        );
    final ImageProvider? provider;
    if (localPath != null && File(localPath!).existsSync()) {
      provider = FileImage(File(localPath!));
    } else if (url != null && url!.startsWith('http')) {
      provider = RustImage(url!);
    } else {
      provider = null;
    }
    if (provider == null) return placeholder();
    return Image(
      image: provider,
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, sync) {
        if (sync || frame != null) return child;
        return placeholder();
      },
      errorBuilder: (context, error, stack) => placeholder(Icons.broken_image_outlined),
    );
  }
}
