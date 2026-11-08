import 'dart:async';

import 'package:flutter/material.dart';

// Hilal motion (hilal-design-system/README.md, "Motion"). tokens.json has no
// motion tokens, so these values come from the README.

/// "Paper settles": enter by fading from 0 and rising 4-8 dp, 180-240 ms,
/// ease-out. No bounce, no overshoot.
const kNoorSettleDistance = 6.0;
const kNoorSettleDuration = Duration(milliseconds: 200);
const kNoorSettleCurve = Curves.easeOut;

/// Set during the single frame in which the app switches between Paper and
/// Night, so implicit colour animations snap instead of trailing the rest of
/// the tree.
abstract final class NoorThemeSwitch {
  static bool active = false;
}

/// [d], or [Duration.zero] under Reduce Motion or a theme switch, for implicit
/// animations and page slides that have no softer fallback.
Duration noorDuration(BuildContext context, Duration d) =>
    NoorThemeSwitch.active || MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : d;

/// "Pressing a button moves it 1px down." Used by `NoorPressable`.
const kNoorPressDistance = 1.0;

/// Fades [child] in from 0 while it rises into place, once, when it first
/// builds. Under `MediaQuery.disableAnimationsOf` it is [child], unchanged.
/// Built off-stage (`TickerMode` off) it starts settled: nobody saw it enter,
/// and at opacity 0 its child would not paint when the shell warms the tab up.
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
      tween: Tween(begin: TickerMode.valuesOf(context).enabled ? 0 : 1, end: 1),
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

/// Owns the looping twinkle value. [builder] gets null under Reduce Motion (a
/// still sky). A 10 Hz timer steps the value, not a Ticker: a Ticker schedules
/// a frame every vsync (60 fps) for a change too slow to see. The timer runs
/// only while the screen is on-stage (`TickerMode`), the app is in the
/// foreground and Reduce Motion is off, and it is cancelled with the widget.
class NoorTwinkle extends StatefulWidget {
  const NoorTwinkle({super.key, required this.builder});

  final Widget Function(BuildContext context, Animation<double>? twinkle)
      builder;

  @override
  State<NoorTwinkle> createState() => _NoorTwinkleState();
}

class _NoorTwinkleState extends State<NoorTwinkle>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _step = Duration(milliseconds: 100);

  // Never started: only its value is set, so it is a plain Animation<double>.
  late final AnimationController _value;
  Timer? _timer;
  late bool _foreground = _isForeground(WidgetsBinding.instance.lifecycleState);

  // Inactive (a system dialog over the app) still draws; paused/hidden do not.
  static bool _isForeground(AppLifecycleState? s) =>
      s == null ||
      s == AppLifecycleState.resumed ||
      s == AppLifecycleState.inactive;

  @override
  void initState() {
    super.initState();
    _value = AnimationController(vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = _isForeground(state);
    _sync();
  }

  // Resuming continues from the current value, so the sky does not jump.
  void _sync() {
    final run = _foreground &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (!run) {
      _timer?.cancel();
      _timer = null;
    } else {
      // shortcut: steps by the nominal 100 ms, not the clock, so a stalled
      // isolate slows the twinkle a little; fine for a 8 s ambient loop.
      _timer ??= Timer.periodic(
        _step,
        (_) => _value.value = (_value.value +
                _step.inMilliseconds / kNoorTwinkleCycle.inMilliseconds) %
            1,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        MediaQuery.disableAnimationsOf(context) ? null : _value,
      );
}
