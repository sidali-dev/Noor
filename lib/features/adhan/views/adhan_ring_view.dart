import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:noor/features/adhan/models/adhan_ring.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/core/services/adhan_texts.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_sky.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';

/// Latin and Arabic name of each prayer, keyed by [Prayer.key]. Both show in
/// every locale, stacked.
const _names = {
  'fajr': ('Fajr', 'الفجر'),
  'chourouk': ('Chourouk', 'الشروق'),
  'dhuhr': ('Dhuhr', 'الظهر'),
  'asr': ('Asr', 'العصر'),
  'maghrib': ('Maghrib', 'المغرب'),
  'isha': ('Isha', 'العشاء'),
};

// tool/adhan_art.py bakes the arch to this space and these rects: keep them in
// step with W, HT, SKY, MOON and STARS there.
const Size _artSize = Size(390, 600);
const Rect _skyRect = Rect.fromLTWH(45, 50, 300, 390);
const _moon = (198.0, 131.0, 16.0);
const _stars = [
  (172.0, 124.0, 2.4), (150.0, 150.0, 3.0), (196.0, 110.0, 2.0), //
  (110.0, 180.0, 2.4), (300.0, 196.0, 2.2), (100.0, 220.0, 2.0),
  (290.0, 236.0, 2.2),
];

/// Where in the art the names start: on the clouds, below the mosque.
const double _textTop = 412;

/// The window's sky for [prayer]: its own, Sunrise taking Fajr's dawn. An alarm
/// that is no prayer's gets the sky of the hour.
NoorSky adhanSkyOf(Prayer? prayer, DateTime now) => switch (prayer) {
      Prayer.fajr || Prayer.chourouk => NoorSky.fajr,
      Prayer.dhuhr => NoorSky.dhuhr,
      Prayer.asr => NoorSky.asr,
      Prayer.maghrib => NoorSky.maghrib,
      Prayer.isha => NoorSky.isha,
      null => skyFor(now, null),
    };

/// The ringing adhan, after tool/sources/adhan_screen.jpg: the prayer's sky in a
/// paper arch, its names and time, how long since (or until) it, and two
/// buttons. It does not touch the alarm itself: [onStop] and [onOpenAthkar]
/// do, as the host it runs in needs (Android's AdhanActivity, or a route in
/// the app on iOS).
class AdhanRingView extends StatefulWidget {
  final AdhanRing ring;
  final VoidCallback onStop;
  final VoidCallback onOpenAthkar;

  /// The clock, for tests.
  final DateTime Function() now;

  const AdhanRingView({
    super.key,
    required this.ring,
    required this.onStop,
    required this.onOpenAthkar,
    this.now = DateTime.now,
  });

  @override
  State<AdhanRingView> createState() => _AdhanRingScreenState();
}

class _AdhanRingScreenState extends State<AdhanRingView> {
  // The art stops growing here; wider, it would only grow taller.
  static const double _maxArtWidth = 480;
  static const double _maxButtonsWidth = 380;
  static const double _buttonHeight = 52;

  late final Timer _tick;
  bool _acted = false;

  @override
  void initState() {
    super.initState();
    // Keeps "4 min since" true while the adhan plays out.
    _tick = Timer.periodic(const Duration(seconds: 15), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  /// Runs [action] once: a second tap while the host closes does nothing.
  VoidCallback _once(VoidCallback action) => () {
        if (_acted) return;
        setState(() => _acted = true);
        action();
      };

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    final ring = widget.ring;
    final now = widget.now();
    final gutter = NoorLayout.gutter(context);
    final bottom = math.max(MediaQuery.paddingOf(context).bottom, NoorSpace.s4);

    return AnnotatedRegion(
      value: noorSystemOverlay(Theme.of(context).brightness),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: n.paper,
          body: LayoutBuilder(
            builder: (context, view) {
              final artWidth = math.min(view.maxWidth, _maxArtWidth);
              final scale = artWidth / _artSize.width;
              // Short phones and large text scroll rather than squeeze.
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        // The art runs on under the names.
                        SizedBox(
                          width: double.infinity,
                          height: _textTop * scale,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Positioned(
                                top: 0,
                                width: artWidth,
                                height: _artSize.height * scale,
                                child: _Window(
                                  sky: adhanSkyOf(ring.prayer, now),
                                  scale: scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // A tall phone's spare height goes around the heading
                        // and buttons, rather than all of it between them.
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          child: NoorSettle(
                            child: _Heading(ring: ring, now: now),
                          ),
                        ),
                        const Spacer(flex: 2),
                        Padding(
                          // Set in from the page's edges, under the heading.
                          padding: EdgeInsets.fromLTRB(
                              gutter + NoorSpace.s5,
                              NoorSpace.s5,
                              gutter + NoorSpace.s5,
                              bottom + NoorSpace.s4),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: _maxButtonsWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minHeight: _buttonHeight),
                                  child: NoorButton(
                                    label: s.stop_adhan,
                                    icon: const NoorIcon(NoorGlyph.bell),
                                    radius: NoorRadius.pill,
                                    onPressed:
                                        _acted ? null : _once(widget.onStop),
                                  ),
                                ),
                                const SizedBox(height: NoorSpace.s3 + 2),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      minHeight: _buttonHeight),
                                  child: NoorButton(
                                    label: s.open_adhkar,
                                    icon: const NoorIcon(NoorGlyph.book),
                                    variant: NoorButtonVariant.tonal,
                                    radius: NoorRadius.pill,
                                    onPressed: _acted
                                        ? null
                                        : _once(widget.onOpenAthkar),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The arch with the sky behind it, and Isha's stars twinkling in it.
class _Window extends StatelessWidget {
  const _Window({required this.sky, required this.scale});

  final NoorSky sky;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final variant = context.noor.isDark ? 'night' : 'paper';
    return ExcludeSemantics(
      child: Stack(
        children: [
          Positioned(
            left: _skyRect.left * scale,
            top: _skyRect.top * scale,
            width: _skyRect.width * scale,
            height: _skyRect.height * scale,
            child: Image.asset(
              key: const ValueKey('adhan-sky'),
              sky.asset,
              fit: BoxFit.cover,
              // Left edges together, as the art was baked: the sun and moon
              // then stand clear of the minarets.
              alignment: Alignment.centerLeft,
              gaplessPlayback: true,
            ),
          ),
          // Isha's sky has its own moon; the others get the crescent at the
          // crown.
          if (sky == NoorSky.isha)
            Positioned.fill(
              child: NoorTwinkle(
                builder: (context, twinkle) => CustomPaint(
                  painter: _StarsPainter(scale, twinkle),
                ),
              ),
            )
          else
            Positioned.fill(
              child: CustomPaint(
                key: const ValueKey('adhan-moon'),
                painter: _MoonPainter(scale),
              ),
            ),
          Positioned.fill(
            child: Image.asset(
              key: const ValueKey('adhan-frame'),
              NoorArt.adhanFrame(variant),
              fit: BoxFit.fill,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The crescent at the window's crown, cut as tool/hero_art.py cuts the sky's.
class _MoonPainter extends CustomPainter {
  _MoonPainter(this.scale);

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    final (x, y, r) = _moon;
    canvas.drawCircle(
      Offset(x, y),
      r * 1.6,
      Paint()
        ..color = const Color(0x40FFF8E6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.9),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r)),
        Path()
          ..addOval(Rect.fromCircle(
              center: Offset(x + r * .44, y - r * .22), radius: r * .82)),
      ),
      Paint()..color = const Color(0xFFFBFAF7),
    );
  }

  @override
  bool shouldRepaint(_MoonPainter old) => old.scale != scale;
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.scale, this.twinkle) : super(repaint: twinkle);

  final double scale;
  final Animation<double>? twinkle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    for (var i = 0; i < _stars.length; i++) {
      final (x, y, r) = _stars[i];
      final t = twinkle;
      canvas.drawPath(
        Path()
          ..moveTo(x, y - r)
          ..quadraticBezierTo(x, y, x + r, y)
          ..quadraticBezierTo(x, y, x, y + r)
          ..quadraticBezierTo(x, y, x - r, y)
          ..quadraticBezierTo(x, y, x, y - r)
          ..close(),
        Paint()
          ..color = const Color(0xFFF7F7F4).withValues(
              alpha: t == null ? 1 : noorTwinkleOpacity(t.value, i)),
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.scale != scale;
}

/// The names, the rule, the time and how far from it: Latin and Arabic
/// stacked, the time the largest thing on the screen.
class _Heading extends StatelessWidget {
  const _Heading({required this.ring, required this.now});

  final AdhanRing ring;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final prayer = ring.prayer;
    final names = prayer == null ? null : _names[prayer.key];
    // One line each: a large text scale shrinks a line rather than wrap it.
    Widget line(Widget child) => FittedBox(fit: BoxFit.scaleDown, child: child);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (names != null) ...[
          line(Text(
            names.$1,
            textDirection: TextDirection.ltr,
            style: NoorText.displayLg(context)
                .copyWith(fontSize: 46, height: 1.1, color: n.ink),
          )),
          line(Text(
            names.$2,
            textDirection: TextDirection.rtl,
            style: NoorText.arabicDisplay(context)
                .copyWith(fontSize: 34, height: 1.5, color: n.ink),
          )),
        ] else
          Text(
            ring.title,
            textAlign: TextAlign.center,
            style: NoorText.display(context).copyWith(color: n.ink),
          ),
        const SizedBox(height: NoorSpace.s2),
        const NoorOrnament(),
        const SizedBox(height: NoorSpace.s1),
        line(Text(
          // 'en' keeps Western digits 0-9 in every locale.
          DateFormat('HH:mm', 'en').format(ring.prayerTime),
          textDirection: TextDirection.ltr,
          style: NoorText.numeral(context, size: 86, color: n.ink)
              .copyWith(height: 1.15),
        )),
        if (prayer != null) ...[
          const SizedBox(height: NoorSpace.s3),
          _SincePill(text: _since(S.of(context), prayer)),
        ],
      ],
    );
  }

  /// "In 10 min", "time for", then "4 min since": always the prayer's own time.
  String _since(S s, Prayer prayer) {
    final name = AdhanTexts(s).prayerName(prayer);
    final seconds = now.difference(ring.prayerTime).inSeconds;
    if (seconds < 0) return s.reminder_before((-seconds / 60).ceil(), name);
    final minutes = seconds ~/ 60;
    return minutes == 0 ? s.adhan_now(name) : s.reminder_after(minutes, name);
  }
}

class _SincePill extends StatelessWidget {
  const _SincePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(NoorRadius.pill),
        border: Border.all(color: n.line),
        boxShadow: n.shadow1,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: NoorSpace.s5 + NoorSpace.s1, vertical: NoorSpace.s3 - 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NoorIcon(NoorGlyph.clock, size: 19, color: n.muted),
            const SizedBox(width: NoorSpace.s2 + 2),
            Flexible(
              child: Text(
                text,
                style: NoorText.bodySm(context)
                    .copyWith(fontSize: 15, color: n.muted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
