import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:noor/core/utils/preload_svgs.dart';
import 'package:noor/core/widgets/noor_mark.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/generated/l10n.dart';

/// Takes over from the native splash at once, plays its entrance, then runs
/// [startup] under the turning ring and fades into the shell.
///
/// The owner's splash: layered paper arches, clouds and the mosque as the
/// plate, the Faith mark in the arch, the wordmark and tagline under it, and
/// a brass ring turning at the foot. See DESIGN.md, `HilalSplash`.
///
/// Its first frame is the native splash redrawn: the same ground, the emblem
/// in the middle of the screen at the size the system draws it, so nothing
/// moves at the hand-off. The native splash waits for nothing but that one
/// picture. While the plate decodes the screen stays that picture; then the
/// mark grows and glides up into its place while the plate fades in around
/// it, and the words and ring follow.
///
/// What the system draws differs, and the first frame follows it. Android 12+
/// shows only the app icon (`splash_icon`: a 240 dp canvas, the emblem half of
/// it), with no say for the app in anything else, so there the first frame is
/// that icon, exactly, and the mark takes over from it under its own shadow.
/// Before Android 12 and on iOS it is an image (`splash`: a 288 dp canvas, the
/// emblem 0.8 of it), the same emblem as the mark, only smaller or larger.
///
/// [startup] starts once the entrance is over, so its work never competes with
/// the animation. The splash stays up for at least [minDuration] from then,
/// even if startup is faster, so the lockup is always seen; then the shell
/// fades in over it (see AppPages).
class SplashView extends StatefulWidget {
  final Future<void> Function() startup;

  /// How long the finished splash is held at the least.
  final Duration minDuration;

  static const defaultMinDuration = Duration(milliseconds: 1200);

  /// The Android API level, set by main() from MainActivity's entrypoint
  /// arguments; null off Android.
  static int? androidSdk;

  /// Whether the native splash was Android 12+'s icon (API 31 and later).
  final bool systemIcon;

  SplashView({
    super.key,
    required this.startup,
    this.minDuration = defaultMinDuration,
    bool? systemIcon,
  }) : systemIcon = systemIcon ?? (androidSdk ?? 0) >= 31;

  @override
  State<SplashView> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashView>
    with TickerProviderStateMixin {
  // The entrance, in ms from its start; played once, no bounce. The mark
  // starts from rest, so it eases in and out; what fades in eases out.
  //   0-1500    the mark grows and glides from the native splash's place
  //   0-500     (Android 12+) the mark's shadow fades in under the icon copy
  //   500-900   (Android 12+) the icon copy fades out over the mark
  //   300-1400  the plate fades in around it
  //   1000-1700 "Faith" fades in, rising
  //   1200-1900 the tagline, the same
  //   1500-2200 the ring
  static const _total = 2200;
  static const _rise = NoorSpace.s2 - NoorSpace.s1 / 2;

  // The emblem's centre in the mark raster, as a fraction of its height (the
  // shadow room under it is deeper than the clear space over it).
  static const _emblemCentre = 0.475;
  // The emblem's height over the raster's (902 of 1120 px).
  static const _emblemShare = 902 / 1120;

  // The emblem as each native splash draws it, in dp.
  static const _systemIconEmblem = 240 * 0.5; // Android 12+: icon canvas 240
  static const _systemIconCanvas = 240.0;
  static const _imageEmblem = 288 * 0.8; // before 12, iOS: image canvas 288

  // Where each piece of the lockup sits, as a fraction of the screen's height,
  // read off the owner's splash.jpg (the centre of each piece).
  static const _markAt = 0.405;
  static const _wordmarkAt = 0.613;
  static const _taglineAt = 0.662;
  static const _ringAt = 0.94;

  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _total),
  );
  // The ring: one turn a second. Off under Reduce Motion.
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  @override
  void dispose() {
    _enter.dispose();
    _spin.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final variant = context.noor.isDark ? 'night' : 'paper';
    final mark = variant == 'night' ? NoorArt.markNight : NoorArt.markPaper;
    Future<void> decode(String path) =>
        precacheImage(AssetImage(path), context, onError: (_, __) {});

    // The native splash (preserved by main()) waits only for the picture
    // that copies it, so it never pops; the plate decodes after it goes.
    final first =
        decode(widget.systemIcon ? NoorArt.systemIcon(variant) : mark);
    final rest = Future.wait([decode(NoorArt.splashBg(variant)), decode(mark)]);
    await first;
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    FlutterNativeSplash.remove();

    // Until the plate is ready the screen is the native splash, standing.
    await rest;
    if (!mounted) return;
    if (reduce) {
      _enter.value = 1;
    } else {
      _spin.repeat();
      await _enter.forward();
    }
    if (!mounted) return;

    // The app's work runs now, under the ring, and the hold with it.
    await Future.wait([
      widget.startup().catchError((Object e, StackTrace s) {
        // Startup used to abort main(); the shell now opens and reports it.
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
      }),
      Future<void>.delayed(widget.minDuration),
      preloadSvgs(context),
    ]);

    if (!mounted) return;
    // The shell fades in over the splash (so it fades out) over 400 ms, none
    // under Reduce Motion: see AppPages.
    Get.offNamed(Routes.MAIN);
  }

  /// The entrance's progress between [from] and [to] ms, eased out unless
  /// [curve] says otherwise.
  Animation<double> _between(int from, int to,
          [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(
        parent: _enter,
        curve: Interval(from / _total, to / _total, curve: curve),
      );

  /// [child] fades in over [from]..[to] ms, rising as it does when [rise].
  Widget _settled({
    required int from,
    required int to,
    required Widget child,
    bool rise = true,
  }) {
    final t = _between(from, to);
    if (!rise) return FadeTransition(opacity: t, child: child);
    return FadeTransition(
      opacity: t,
      child: AnimatedBuilder(
        animation: t,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, _rise * (1 - t.value)),
          child: c,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final h = size.height;
    // The mark: 0.71 of the width in the owner's splash, held off the words.
    final markH = math.min(size.width * 0.71, h * 0.33).clamp(160.0, 340.0);
    const ringSize = NoorSpace.s5;
    // The native splash centres the emblem on the screen: that is where the
    // mark starts, and it travels up to its own place.
    final markTop = h * _markAt - markH / 2;
    final glide = h / 2 - (markTop + markH * _emblemCentre);
    final glideT = _between(0, 1500, Curves.easeInOutCubic);
    // The emblem starts as large as the native splash draws it, and grows to
    // the mark's own size as it glides.
    final systemIcon = widget.systemIcon;
    final markEmblem = markH * _emblemShare;
    final startScale =
        (systemIcon ? _systemIconEmblem : _imageEmblem) / markEmblem;
    // On Android 12+ the mark's shadow grows in under the copied icon, which
    // only then fades out over the identical emblem beneath it, so the emblem
    // never thins.
    final markIn = systemIcon ? _between(0, 500) : kAlwaysCompleteAnimation;
    final iconOut = ReverseAnimation(_between(500, 900));

    // First frame is the native splash: its ground, its mark where it drew it.
    return Scaffold(
      backgroundColor: n.paper,
      body: MediaQuery(
        // Brand lockup: fixed size, like the artwork around it.
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: _settled(
                from: 300,
                to: 1400,
                rise: false,
                child: Image.asset(
                  NoorArt.splashBg(n.isDark ? 'night' : 'paper'),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
            Positioned(
              top: markTop,
              left: 0,
              right: 0,
              // Drawn from the first frame: it is the native splash's emblem.
              child: ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: glideT,
                  builder: (_, c) => Transform.translate(
                    offset: Offset(0, glide * (1 - glideT.value)),
                    child: Transform.scale(
                      scale: startScale + (1 - startScale) * glideT.value,
                      // About the emblem's centre, which is what the native
                      // splash centres on the screen.
                      alignment: const Alignment(0, 2 * _emblemCentre - 1),
                      child: c,
                    ),
                  ),
                  child: SizedBox(
                    height: markH,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        FadeTransition(
                          opacity: markIn,
                          child: NoorMark(size: markH),
                        ),
                        if (systemIcon)
                          FadeTransition(
                            opacity: iconOut,
                            // The icon's canvas, in this group's units: scaled
                            // by [startScale] it is the system's 240 dp, and
                            // its emblem is the mark's at every scale between.
                            child: Transform.translate(
                              offset: Offset(0, (_emblemCentre - 0.5) * markH),
                              child: OverflowBox(
                                maxWidth: _systemIconCanvas / startScale,
                                maxHeight: _systemIconCanvas / startScale,
                                child: Image.asset(
                                  NoorArt.systemIcon(
                                      n.isDark ? 'night' : 'paper'),
                                  width: _systemIconCanvas / startScale,
                                  height: _systemIconCanvas / startScale,
                                  excludeFromSemantics: true,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: h * _wordmarkAt - 30,
              left: 0,
              right: 0,
              child: _settled(
                from: 1000,
                to: 1700,
                child: Center(child: _wordmark(context)),
              ),
            ),
            Positioned(
              top: h * _taglineAt - 8,
              left: NoorSpace.s5,
              right: NoorSpace.s5,
              child: _settled(
                from: 1200,
                to: 1900,
                child: _tagline(context),
              ),
            ),
            Positioned(
              top: math.min(h * _ringAt, h - bottomInset - ringSize * 1.5) -
                  ringSize / 2,
              left: 0,
              right: 0,
              child: ExcludeSemantics(
                child: _settled(
                  from: 1500,
                  to: 2200,
                  rise: false,
                  child: Center(
                    child: RotationTransition(
                      turns: _spin,
                      child: CustomPaint(
                        size: const Size.square(ringSize),
                        painter: _RingPainter(n.brass),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Faith": Latin, Cormorant Garamond, in every locale (DESIGN.md 3.2); LTR
  /// inside an RTL app.
  Widget _wordmark(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          'Faith',
          style: NoorText.displayXl(context).copyWith(
            fontFamily: 'Cormorant Garamond',
            fontFamilyFallback: const ['Amiri'],
            fontSize: 56,
            height: 60 / 56,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      );

  /// A hairline either side of the line, as in the owner's splash.
  Widget _tagline(BuildContext context) {
    final rule = Container(
      width: NoorSpace.s7 - NoorSpace.s2,
      height: 1,
      color: context.noor.line,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          rule,
          const SizedBox(width: NoorSpace.s3),
          Text(S.of(context).splash_tagline, style: NoorText.eyebrow(context)),
          const SizedBox(width: NoorSpace.s3),
          rule,
        ],
      ),
    );
  }
}

/// The loading ring: a brass arc that fades to nothing behind its head, on a
/// faint full circle. The one gradient the splash has.
class _RingPainter extends CustomPainter {
  final Color color;

  _RingPainter(this.color);

  static const _stroke = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = color.withValues(alpha: 0.18),
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 1.5,
          colors: [color.withValues(alpha: 0), color],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}
