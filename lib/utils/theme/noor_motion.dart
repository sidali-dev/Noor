import 'package:flutter/material.dart';

// Hilal motion (hilal-design-system/README.md, "Motion"). tokens.json has no
// motion tokens, so these values come from the README.

/// "Paper settles": enter by fading from 0 and rising 4-8 dp, 180-240 ms,
/// ease-out. No bounce, no overshoot.
const kNoorSettleDistance = 6.0;
const kNoorSettleDuration = Duration(milliseconds: 200);
const kNoorSettleCurve = Curves.easeOut;

/// [d], or [Duration.zero] under Reduce Motion, for implicit animations and
/// page slides that have no softer fallback.
Duration noorDuration(BuildContext context, Duration d) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;

/// "Pressing a button moves it 1px down." Used by `NoorPressable`.
const kNoorPressDistance = 1.0;

/// Fades [child] in from 0 while it rises into place, once, when it first
/// builds. Under `MediaQuery.disableAnimationsOf` it is [child], unchanged.
///
/// The rise is paint-only (no relayout).
class NoorSettle extends StatelessWidget {
  const NoorSettle({
    super.key,
    required this.child,
    this.distance = kNoorSettleDistance,
    this.duration = kNoorSettleDuration,
  }) : assert(distance >= 4 && distance <= 8);

  final Widget child;

  /// How far below its resting place it starts, in dp (4-8).
  final double distance;

  /// 180-240 ms (the Hilal range; not asserted, as a `Duration` compare is
  /// not constant).
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: kNoorSettleCurve,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * distance),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// One star-twinkle cycle: 4 s from 1 down to 0.85 and 4 s back.
const kNoorTwinkleCycle = Duration(seconds: 8);

/// Opacity (0.85-1) of star [i] at cycle position [t] (0-1). Stars stagger in
/// three groups, so the sky never pulses as one.
double noorTwinkleOpacity(double t, int i) {
  final p = (t + (i % 3) * 0.325) % 1;
  return 0.85 + 0.15 * (1 - (2 * p - 1).abs());
}

/// Owns the looping twinkle controller. [builder] gets null under Reduce
/// Motion (a still sky). The ticker follows `TickerMode`, so the loop stops
/// while the screen is off-stage, and it is disposed with the widget.
class NoorTwinkle extends StatefulWidget {
  const NoorTwinkle({super.key, required this.builder});

  final Widget Function(BuildContext context, Animation<double>? twinkle)
      builder;

  @override
  State<NoorTwinkle> createState() => _NoorTwinkleState();
}

class _NoorTwinkleState extends State<NoorTwinkle>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(vsync: this, duration: kNoorTwinkleCycle);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        MediaQuery.disableAnimationsOf(context) ? null : _controller,
      );
}
