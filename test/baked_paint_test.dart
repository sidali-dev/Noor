import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/generals/widgets/baked_paint.dart';

void main() {
  testWidgets('bakes once per key, and disposes what it evicts', (_) async {
    // 4 x 4 px at ratio 1 is 64 bytes: room for two, not three.
    final cache = BakedPaint(maxBytes: 150);
    var draws = 0;
    void draw(Canvas c, Size s) => draws++;
    const size = Size(4, 4);

    final a = cache.bake(['a'], size, 1, 0, draw);
    expect(cache.bake(['a'], size, 1, 0, draw), same(a));
    expect(draws, 1);

    // Each input is part of the key: contents, size, ratio and padding.
    final b = cache.bake([const Color(0xFF000000), 'b'], size, 1, 0, draw);
    expect(
      cache.bake([const Color(0xFF000000), 'b'], size, 1, 0, draw),
      same(b),
    );
    expect(draws, 2);
    cache.bake(['a'], const Size(5, 4), 1, 0, draw);
    cache.bake(['a'], size, 2, 0, draw);
    cache.bake(['a'], size, 1, 3, draw);
    expect(draws, 5);

    // Over budget, the oldest go first; the newest stays however big.
    expect(a.debugDisposed, isTrue);
    expect(b.debugDisposed, isTrue);
    expect(cache.length, 1);
    cache.bake(['a'], size, 1, 0, draw);
    expect(draws, 6);
  });

  testWidgets('evicts the least recently used, not the oldest', (_) async {
    final cache = BakedPaint(maxBytes: 150); // two 64-byte images fit
    void draw(Canvas c, Size s) {}
    const size = Size(4, 4);

    final a = cache.bake(['a'], size, 1, 0, draw);
    final b = cache.bake(['b'], size, 1, 0, draw);
    cache.bake(['a'], size, 1, 0, draw); // touch a
    cache.bake(['c'], size, 1, 0, draw);

    expect(b.debugDisposed, isTrue);
    expect(a.debugDisposed, isFalse);
  });
}
