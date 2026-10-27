import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Shown right after the native splash. Stays up while [ready] (app startup)
/// and the current theme's art precache run, then fades into [next].
class SplashScreen extends StatefulWidget {
  final Future<void> ready;
  final WidgetBuilder next;

  const SplashScreen({super.key, required this.ready, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _fadeIn = Duration(milliseconds: 250);
  static const _fadeOut = Duration(milliseconds: 300);

  late final _fade = AnimationController(vsync: this, duration: _fadeIn);
  // The spinner is the only progress signal, so it turns under Reduce Motion.
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FlutterNativeSplash.remove());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  @override
  void dispose() {
    _fade.dispose();
    _spin.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final ctx = context;
    final reduce = MediaQuery.disableAnimationsOf(ctx);

    // A failed precache is skipped, never fatal.
    Future<void> image(String base) => precacheImage(
          AssetImage(NoorArt.of(ctx, base)),
          ctx,
          onError: (_, __) {},
        );
    Future<void> warm(String path) async {
      try {
        final loader = SvgAssetLoader(path);
        await svg.cache
            .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
      } catch (_) {}
    }

    final splashArt =
        Future.wait([NoorArt.splashTop, NoorArt.splashBottom].map(image))
            .then((_) {
      if (!mounted) return;
      reduce ? _fade.value = 1 : _fade.forward();
    });

    await Future.wait([
      widget.ready.catchError((Object e, StackTrace s) {
        // Startup used to abort main(); the shell now opens and reports it.
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
      }),
      splashArt,
      ...NoorArt.heroes.map(image),
      warm(NoorArt.emblem),
      warm(NoorArt.emblemDark),
    ]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      transitionDuration: reduce ? Duration.zero : _fadeOut,
      pageBuilder: (c, _, __) => widget.next(c),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
        child: child,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final width = MediaQuery.sizeOf(context).width;

    // First frame is the native splash colour; art and background fade in.
    return Scaffold(
      backgroundColor: n.paper,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: n.isDark
                            ? [
                                Color.alphaBlend(
                                    n.primary.withValues(alpha: 0.4), n.paper),
                                n.paper,
                              ]
                            // Faint diagonal light rays.
                            : [n.paper, n.paper],
                      ),
                    ),
                  ),
                  if (!n.isDark) _rays(n),
                  _art(context, NoorArt.splashTop, Alignment.topCenter),
                  _art(context, NoorArt.splashBottom, Alignment.bottomCenter),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: const Alignment(0, 0.1),
              child: MediaQuery(
                // Brand lockup: fixed size, like the artwork around it.
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      n.isDark ? NoorArt.emblemDark : NoorArt.emblem,
                      width: width * 0.38,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(height: NoorSpace.xxl),
                    Text(
                      'نور الإيمان',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: n.ink,
                      ),
                    ),
                    const SizedBox(height: NoorSpace.sm),
                    _latinLine(n),
                    const SizedBox(height: NoorSpace.xxxl + NoorSpace.lg),
                    ExcludeSemantics(child: _spinner(n)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rays(NoorColors n) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              for (final a in const [0.0, 0.5, 0.0, 0.35, 0.0, 0.25, 0.0])
                n.card.withValues(alpha: a),
            ],
            stops: const [0, 0.18, 0.3, 0.45, 0.6, 0.75, 0.9],
          ),
        ),
      );

  Widget _art(BuildContext context, String base, Alignment at) => Align(
        alignment: at,
        child: Image.asset(
          NoorArt.of(context, base),
          width: double.infinity,
          fit: BoxFit.fitWidth,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );

  /// "NOOR IMENE" between two gold hairlines that end in small diamonds.
  Widget _latinLine(NoorColors n) {
    const size = 18.0;
    const spacing = size * 0.35;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
        child: Row(
          children: [
            Expanded(child: _rule(n.gold)),
            Padding(
              // Letter-spacing trails the last glyph; balance it on the left.
              padding: const EdgeInsets.fromLTRB(
                  NoorSpace.md + spacing, 0, NoorSpace.md, 0),
              child: Text(
                'NOOR IMENE',
                style: TextStyle(
                  fontFamily: 'Spectral',
                  fontSize: size,
                  fontWeight: FontWeight.w500,
                  letterSpacing: spacing,
                  color: n.isDark ? n.gold : n.ink,
                ),
              ),
            ),
            Expanded(child: Transform.flip(flipX: true, child: _rule(n.gold))),
          ],
        ),
      ),
    );
  }

  Widget _rule(Color color) => SizedBox(
        height: 10,
        child: CustomPaint(painter: _RulePainter(color)),
      );

  Widget _spinner(NoorColors n) => RotationTransition(
        turns: _spin,
        child: CustomPaint(
          size: const Size.square(28),
          painter: _RingPainter(n.isDark ? n.ink : n.primary),
        ),
      );
}

/// Hairline with a small diamond at its end (the right edge).
class _RulePainter extends CustomPainter {
  final Color color;
  const _RulePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final y = size.height / 2;
    const d = 3.5;
    canvas.drawLine(Offset(0, y), Offset(size.width - d * 2, y), paint);
    canvas.drawPath(
      Path()
        ..moveTo(size.width - d * 2, y)
        ..lineTo(size.width - d, y - d)
        ..lineTo(size.width, y)
        ..lineTo(size.width - d, y + d)
        ..close(),
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) => old.color != color;
}

/// Faint track plus an arc that fades out behind its head.
class _RingPainter extends CustomPainter {
  final Color color;
  const _RingPainter(this.color);

  static const _stroke = 2.0;
  static const _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false,
        base..color = color.withValues(alpha: 0.14));
    canvas.drawArc(
      rect,
      0,
      _sweep,
      false,
      base
        ..shader = SweepGradient(
          endAngle: _sweep,
          colors: [color.withValues(alpha: 0), color],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.color != color;
}
