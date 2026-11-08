import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Paints a blurred drawing from a cached bitmap. A live `MaskFilter.blur`
/// re-runs on the raster thread every frame the layer is re-rastered, which
/// stalls a tab switch; the same drawing recorded once is a plain image blit.
///
/// Only for painters whose size does not animate: each new size bakes a new
/// image. The cache is bounded by bytes, least recently used out first.
class BakedPaint {
  BakedPaint({this.maxBytes = 32 << 20});

  static final shared = BakedPaint();

  final int maxBytes;
  // A map literal keeps insertion order.
  final _images = <_Key, ui.Image>{};
  int _bytes = 0;

  int get length => _images.length;

  /// Draws [draw] at [size] through the cache. [key] holds every input that
  /// changes what [draw] paints, compared by value. [pad] is the room in dp
  /// that [draw] paints outside [size], for shadows.
  void paint(
    Canvas canvas,
    Size size, {
    required List<Object?> key,
    required double ratio,
    required void Function(Canvas, Size) draw,
    double pad = 0,
  }) {
    if (size.isEmpty || ratio <= 0) return;
    final image = bake(key, size, ratio, pad, draw);
    canvas.drawImageRect(
      image,
      Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(-pad, -pad, size.width + 2 * pad, size.height + 2 * pad),
      Paint(),
    );
  }

  @visibleForTesting
  ui.Image bake(
    List<Object?> key,
    Size size,
    double ratio,
    double pad,
    void Function(Canvas, Size) draw,
  ) {
    final k = _Key([...key, size, ratio, pad]);
    // Remove then re-add: the map's order is the LRU order.
    var image = _images.remove(k);
    if (image == null) {
      final recorder = ui.PictureRecorder();
      draw(
        Canvas(recorder)
          ..scale(ratio)
          ..translate(pad, pad),
        size,
      );
      final picture = recorder.endRecording();
      image = picture.toImageSync(
        ((size.width + 2 * pad) * ratio).ceil(),
        ((size.height + 2 * pad) * ratio).ceil(),
      );
      picture.dispose();
      _bytes += _cost(image);
    }
    _images[k] = image;
    // The newest stays, however big: it is about to be drawn.
    while (_bytes > maxBytes && _images.length > 1) {
      final oldest = _images.keys.first;
      final gone = _images.remove(oldest)!;
      _bytes -= _cost(gone);
      // A picture already holding the image keeps its own reference.
      gone.dispose();
    }
    return image;
  }

  static int _cost(ui.Image i) => i.width * i.height * 4;
}

class _Key {
  _Key(this.parts);

  final List<Object?> parts;

  @override
  bool operator ==(Object other) => other is _Key && listEquals(parts, other.parts);

  @override
  int get hashCode => Object.hashAll(parts);
}
