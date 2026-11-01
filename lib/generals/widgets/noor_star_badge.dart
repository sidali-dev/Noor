import 'package:flutter/material.dart';

/// The star outline as one path: a square of half-extent [half] around [c]
/// united with the same square turned 45 degrees. Hilal draws 14 of 24 units
/// per square, so [half] is 7/24 of the box.
Path noorStarPath(Offset c, double half) {
  final square = Path()
    ..addRect(Rect.fromCenter(center: c, width: half * 2, height: half * 2));
  final turned = square.transform(
    (Matrix4.identity()
          ..translateByDouble(c.dx, c.dy, 0, 1)
          ..rotateZ(0.7853981633974483)
          ..translateByDouble(-c.dx, -c.dy, 0, 1))
        .storage,
  );
  return Path.combine(PathOperation.union, square, turned);
}
