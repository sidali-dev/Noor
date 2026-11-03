import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:noor/generals/preload_svgs.dart';
import 'package:noor/generals/widgets/arch_frame.dart';
import 'package:noor/generals/widgets/noor_mark.dart';
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
  static const _fadeOut = Duration(milliseconds: 240);
  // Paper-settle: the frame fades and rises over 220 ms, the words follow 80 ms
  // behind. Played once.
  static const _settleFrame = 220;
  static const _settleWords = 80;
  static const _rise = NoorSpace.s2 - NoorSpace.s1 / 2;

  late final _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _settleFrame + _settleWords),
  );
  // Star twinkle, 4 s each way. Off under Reduce Motion.
  late final _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

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
    _settle.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final ctx = context;
    final reduce = MediaQuery.disableAnimationsOf(ctx);

    if (!reduce) _twinkle.repeat();

    // The mark settles in once it is decoded, so it never pops.
    final markArt = precacheImage(
      AssetImage(ctx.noor.isDark ? NoorArt.markNight : NoorArt.markPaper),
      ctx,
      onError: (_, __) {},
    ).then((_) {
      if (!mounted) return;
      reduce ? _settle.value = 1 : _settle.forward();
    });

    await Future.wait([
      widget.ready.catchError((Object e, StackTrace s) {
        // Startup used to abort main(); the shell now opens and reports it.
        FlutterError.reportError(FlutterErrorDetails(exception: e, stack: s));
      }),
      markArt,
      preloadSvgs(ctx),
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

  Widget _settled({
    required int from,
    required int to,
    required Widget child,
  }) {
    const total = _settleFrame + _settleWords;
    final t = CurvedAnimation(
      parent: _settle,
      curve: Interval(from / total, to / total, curve: Curves.easeOutCubic),
    );
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
    // space-7 of ground each side so the shadows have room.
    final frame = (size.width - NoorSpace.s7 * 2).clamp(220.0, 320.0);

    // First frame is the native splash colour; the hero settles in on top.
    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NoorSpace.s8),
          child: Center(
            child: MediaQuery(
              // Brand lockup: fixed size, like the artwork around it.
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: _settled(
                        from: 0,
                        to: _settleFrame,
                        child: ArchFrame(
                          width: frame,
                          twinkle: _twinkle,
                          child: NoorMark(size: frame * 0.42),
                        ),
                      ),
                    ),
                    const SizedBox(height: NoorSpace.s6),
                    _settled(
                      from: _settleWords,
                      to: _settleFrame + _settleWords,
                      child: _wordmark(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "FAITH": Latin stays LTR inside an RTL app.
  Widget _wordmark(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('FAITH', style: NoorText.title(context)),
      );
}
