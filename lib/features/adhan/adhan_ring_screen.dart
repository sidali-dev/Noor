import 'dart:async';
import 'dart:math' as math;

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Latin and Arabic name of each prayer, keyed by [Prayer.key]. Both show in
/// every locale, stacked at equal weight.
const _names = {
  'fajr': ('Fajr', 'الفجر'),
  'chourouk': ('Chourouk', 'الشروق'),
  'dhuhr': ('Dhuhr', 'الظهر'),
  'asr': ('Asr', 'العصر'),
  'maghrib': ('Maghrib', 'المغرب'),
  'isha': ('Isha', 'العشاء'),
};

class AdhanRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AdhanRingScreen({super.key, required this.alarmSettings});

  @override
  State<AdhanRingScreen> createState() => _AdhanRingScreenState();
}

class _AdhanRingScreenState extends State<AdhanRingScreen> {
  /// Below this the screen scrolls: room for the sky, the niche, a note and two
  /// buttons.
  static const double _minHeight = 640;
  static const double _maxNoteHeight = 120;

  StreamSubscription<dynamic>? _ringing;
  bool _wasRinging = false;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    // The audio of a non-looping adhan ends by itself, and a stop from the
    // notification bypasses these buttons: either way this screen should go.
    _ringing = Alarm.ringing.listen((set) {
      final ringing = set.containsId(widget.alarmSettings.id);
      if (ringing) {
        _wasRinging = true;
      } else if (_wasRinging) {
        _leave();
      }
    });
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _ringing?.cancel();
    Alarm.stop(widget.alarmSettings.id);
    super.dispose();
  }

  Prayer? _prayerFromBaseId(int baseId) {
    for (final prayer in Prayer.all) {
      if (prayer.adhanId == baseId ||
          prayer.alarmId1 == baseId ||
          prayer.alarmId2 == baseId) {
        return prayer;
      }
    }
    return null;
  }

  void _openAdhkar() {
    Alarm.stop(widget.alarmSettings.id).then((_) {
      Get.offAll(() => const SBottomNavigation(pageIndex: 2));
    });
  }

  void _close() {
    // Pushed over the app (bottom_navigation), so pop back instead of exiting.
    Alarm.stop(widget.alarmSettings.id).then((_) => _leave());
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final baseId = AdhanScheduler.baseOf(widget.alarmSettings.id);
    final prayer = _prayerFromBaseId(baseId);
    final names = prayer == null ? null : _names[prayer.key];

    final title = widget.alarmSettings.notificationSettings.title;
    final body = widget.alarmSettings.notificationSettings.body;
    // 'en' keeps Western digits 0-9 in every locale.
    final formattedTime =
        DateFormat('HH:mm', 'en').format(widget.alarmSettings.dateTime);
    final inset = MediaQuery.paddingOf(context);

    // The ground is the night sky in both themes, so the system bars take
    // light icons whatever the theme.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: noorSystemOverlay(Brightness.dark),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: n.window,
          // Short phones and large text scroll the whole screen rather than
          // squeeze the niche to nothing or push the buttons off it.
          body: LayoutBuilder(
            builder: (context, view) {
              final height = math.max(view.maxHeight, _minHeight);
              final skyHeight = inset.top + (height * .22).clamp(100.0, 190.0);
              return SingleChildScrollView(
                child: SizedBox(
                  height: height,
                  // The active alarm screen is one of the loops Hilal allows:
                  // the stars twinkle and the moon breathes.
                  child: NoorTwinkle(
                    builder: (context, twinkle) => Stack(
                      children: [
                        // Each animated painter gets its own layer, so a
                        // frame of twinkle repaints it and not the panel.
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter:
                                  _SkyPainter(n, twinkle, inset.top, skyHeight),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          top: skyHeight,
                          child: _Crest(
                            side: NoorLayout.gutter(context),
                            bottom: math.max(inset.bottom, NoorSpace.s4) +
                                NoorSpace.s2,
                            twinkle: twinkle,
                            niche: _NicheContent(
                              names: names,
                              title: title,
                              time: formattedTime,
                            ),
                            // Reminders say how long until the prayer; a long
                            // one scrolls in its own box.
                            note: body.isEmpty
                                ? null
                                : ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxHeight: _maxNoteHeight),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        body,
                                        style: NoorText.bodySm(context),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                            buttons: [
                              NoorButton(
                                label: S.of(context).stop_adhan,
                                onPressed: _close,
                              ),
                              NoorButton(
                                label: S.of(context).open_adhkar,
                                onPressed: _openAdhkar,
                                variant: NoorButtonVariant.outline,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A four-point star, the same cut as the hero art's.
Path _star(Offset c, double r) => Path()
  ..moveTo(c.dx, c.dy - r)
  ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
  ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
  ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
  ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
  ..close();

/// How much of star [i] shows at cycle position [t]: two flickers a cycle,
/// each star out of step with the next. Deeper than the hero's glint, since
/// this sky is the whole screen's picture.
double _glint(double t, int i) =>
    .3 + .7 * math.pow(math.sin(math.pi * ((t * 2 + i * .37) % 1)), 2);

/// A pointed arch: straight legs up to the springing line [rise] below
/// `r.top`, then an ogee to the apex at the centre of `r.top`.
Path _ogee(Rect r, double rise, {bool close = true}) {
  final cx = r.center.dx;
  final spring = r.top + rise;
  final path = Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, spring)
    ..cubicTo(r.left, spring - rise * .55, cx - r.width * .12,
        r.top + rise * .22, cx, r.top)
    ..cubicTo(cx + r.width * .12, r.top + rise * .22, r.right,
        spring - rise * .55, r.right, spring)
    ..lineTo(r.right, r.bottom);
  return close ? (path..close()) : path;
}

/// The sky above the crest: stars, and the crescent that crowns the arch like
/// a finial, in its glow.
class _SkyPainter extends CustomPainter {
  _SkyPainter(this.n, this.twinkle, this.top, this.skyHeight)
      : super(repaint: twinkle);

  final NoorColors n;
  final Animation<double>? twinkle;
  final double top;
  final double skyHeight;

  // x as a share of the width, y in dp below the status bar; clear of the moon.
  static const _stars = [
    (.14, 26.0, 2.6), (.32, 12.0, 2.6), (.68, 20.0, 2.6), (.86, 40.0, 2.6), //
    (.07, 60.0, 4.6), (.27, 46.0, 4.6), (.91, 12.0, 4.6), //
    (.05, 22.0, 1.8), (.40, 34.0, 1.8), (.60, 8.0, 1.8), (.78, 58.0, 1.8),
    (.95, 70.0, 2.6), (.19, 84.0, 1.8), (.35, 70.0, 2.6), (.62, 52.0, 1.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = twinkle?.value;
    final moon = Offset(size.width / 2, skyHeight - 34);
    // The glow breathes once a cycle; still under Reduce Motion.
    final breath = t == null ? 0.0 : math.sin(t * 2 * math.pi);
    final glow = 70 + 8 * breath;
    canvas.drawCircle(
      moon,
      glow,
      Paint()
        ..shader = RadialGradient(colors: [
          n.onWindow
              .withValues(alpha: (n.isDark ? .12 : .16) * (1 + .25 * breath)),
          n.onWindow.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: moon, radius: glow)),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: moon, radius: 17)),
        Path()
          ..addOval(
              Rect.fromCircle(center: moon.translate(7, -4), radius: 14.5)),
      ),
      Paint()..color = n.onWindow,
    );

    for (var i = 0; i < _stars.length; i++) {
      final (x, y, r) = _stars[i];
      final g = t == null ? 1.0 : _glint(t, i);
      canvas.drawPath(
        _star(Offset(x * size.width, top + y), r * (.8 + .25 * g)),
        Paint()..color = n.onWindow.withValues(alpha: g),
      );
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.n != n || old.top != top || old.skyHeight != skyHeight;
}

/// The mosque's entrance: a carved ivory arch standing on a panel, a night
/// niche cut into it. The name and time sit in the niche; the note and the two
/// buttons sit on the panel below it.
class _Crest extends StatelessWidget {
  const _Crest({
    required this.side,
    required this.bottom,
    required this.twinkle,
    required this.niche,
    required this.note,
    required this.buttons,
  });

  final double side;
  final double bottom;
  final Animation<double>? twinkle;
  final Widget niche;
  final Widget? note;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    final c = _Ivory(context.noor);
    return LayoutBuilder(
      builder: (context, box) {
        final g = _CrestGeometry(box.maxWidth, side);
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _CrestPainter(c, g)),
                    ),
                  ),
                  Positioned(
                    left: g.nicheLeft,
                    right: g.nicheLeft,
                    top: g.nicheTop,
                    bottom: 0,
                    child: _Niche(
                      rise: g.nicheRise,
                      twinkle: twinkle,
                      child: niche,
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.face,
                border: Border(top: BorderSide(color: c.carve)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  g.nicheLeft,
                  NoorSpace.s3,
                  g.nicheLeft,
                  bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (note != null) ...[
                      note!,
                      const SizedBox(height: NoorSpace.s3),
                    ],
                    for (var i = 0; i < buttons.length; i++) ...[
                      if (i > 0) const SizedBox(height: NoorSpace.s2),
                      buttons[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The stone: ivory in Paper, the night card in Night. The shade behind it and
/// the carving's tone derive from the face.
class _Ivory {
  _Ivory(NoorColors n)
      : face = n.isDark ? n.card : const Color(0xFFF3EFE6),
        shadow = n.depthShadow,
        back = Color.lerp(n.isDark ? n.card : const Color(0xFFF3EFE6),
            Colors.black, n.isDark ? .35 : .07)!,
        carve = Color.lerp(n.isDark ? n.card : const Color(0xFFF3EFE6),
            n.isDark ? Colors.white : Colors.black, n.isDark ? .12 : .17)!;

  final Color face;
  final Color back;
  final Color carve;
  final Color shadow;
}

/// Where the arches sit, from the width alone. Each arch is the outer one
/// inset, sharing its springing line, so the carved band keeps its thickness
/// on the legs and thins toward the apex in proportion.
class _CrestGeometry {
  _CrestGeometry(this.width, double side)
      : outerLeft = side,
        outerRight = width - side;

  static const ratio = .9;
  static const step = 9.0;
  static const wall = 26.0;

  final double width;
  final double outerLeft;
  final double outerRight;

  double riseAt(double inset) => ((outerRight - outerLeft) / 2 - inset) * ratio;

  Path archAt(double inset, double bottom, {bool close = true}) => _ogee(
        Rect.fromLTRB(
            outerLeft + inset, inset * ratio, outerRight - inset, bottom),
        riseAt(inset),
        close: close,
      );

  double get nicheLeft => outerLeft + step + wall;
  double get nicheTop => (step + wall) * ratio;
  double get nicheRise => riseAt(step + wall);
}

class _CrestPainter extends CustomPainter {
  _CrestPainter(this.c, this.g);

  final _Ivory c;
  final _CrestGeometry g;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final front = g.archAt(_CrestGeometry.step, h);
    canvas.drawPath(g.archAt(0, h), Paint()..color = c.back);
    // The front arch's shadow on the back one: a wide soft one, a tight one.
    for (final (dy, sigma, alpha) in const [(5.0, 6.0, .5), (2.0, 1.5, 1.0)]) {
      canvas.drawPath(
        front.shift(Offset(0, dy)),
        Paint()
          ..color = c.shadow.withValues(alpha: c.shadow.a * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      );
    }
    canvas.drawPath(front, Paint()..color = c.face);
    _carve(canvas, h);
    _capital(canvas, g.outerLeft, 1, h);
    _capital(canvas, g.outerRight, -1, h);
  }

  /// The carved band: a hairline each side and, between them, two vines that
  /// cross at every rosette.
  void _carve(Canvas canvas, double h) {
    const step = _CrestGeometry.step, wall = _CrestGeometry.wall;
    final line = Paint()
      ..color = c.carve
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final inset in [step + 3, step + wall - 3]) {
      canvas.drawPath(g.archAt(inset, h, close: false), line);
    }
    final metric =
        g.archAt(step + wall / 2, h, close: false).computeMetrics().first;
    final count = (metric.length / 24).round();
    final pitch = metric.length / count;
    final vine = Paint()
      ..color = c.carve
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final phase in [0.0, math.pi]) {
      final path = Path();
      for (var s = 0.0; s <= metric.length; s += 2) {
        final t = metric.getTangentForOffset(s)!;
        final p = t.position +
            Offset(-t.vector.dy, t.vector.dx) *
                (4.5 * math.sin(2 * math.pi * s / pitch + phase));
        s == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, vine);
    }
    for (var i = 0; i < count; i++) {
      final p = metric.getTangentForOffset(i * pitch + pitch / 4)!.position;
      canvas
        ..drawCircle(p, 3.2, Paint()..color = c.face)
        ..drawCircle(p, 3.2, line)
        ..drawCircle(p, 1.2, Paint()..color = c.carve);
    }
  }

  /// The block each leg stands on, with a diamond cut in it. [inward] is +1
  /// when the arch lies to the right of [legX].
  void _capital(Canvas canvas, double legX, double inward, double h) {
    const reach = _CrestGeometry.step + _CrestGeometry.wall;
    final block = Rect.fromPoints(
      Offset(legX - inward * 5, h - 14),
      Offset(legX + inward * (reach + 5), h),
    );
    canvas
      ..drawRect(block, Paint()..color = c.face)
      ..drawRect(
          block,
          Paint()
            ..color = c.carve
            ..style = PaintingStyle.stroke);
    final m = block.center;
    canvas.drawPath(
      Path()
        ..moveTo(m.dx, m.dy - 4)
        ..lineTo(m.dx + 6, m.dy)
        ..lineTo(m.dx, m.dy + 4)
        ..lineTo(m.dx - 6, m.dy)
        ..close(),
      Paint()..color = c.carve,
    );
  }

  @override
  bool shouldRepaint(_CrestPainter old) =>
      old.c.face != c.face || old.g.width != g.width;
}

/// The niche: a night window cut into the stone, shaded at its head so it
/// reads as hollow; its stars twinkle with the sky's.
class _Niche extends StatelessWidget {
  const _Niche(
      {required this.rise, required this.twinkle, required this.child});

  final double rise;
  final Animation<double>? twinkle;
  final Widget child;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _NichePainter(
              context.noor.window, context.noor.onWindow, rise, twinkle),
          child: Padding(
            padding: EdgeInsets.only(top: rise * .4),
            child: child,
          ),
        ),
      );
}

class _NichePainter extends CustomPainter {
  _NichePainter(this.window, this.star, this.rise, this.twinkle)
      : super(repaint: twinkle);

  final Color window;
  final Color star;
  final double rise;
  final Animation<double>? twinkle;

  // Share of the niche's width and height, and the star's radius; clear of
  // the name and the time in the middle.
  static const _stars = [
    (.5, .1, 2.6), (.2, .3, 2.6), (.82, .26, 2.6), (.1, .6, 2.6),
    (.9, .66, 2.6), (.17, .84, 4.6), (.84, .88, 4.6), //
    (.36, .2, 1.8), (.66, .18, 1.8), (.07, .42, 1.8), (.93, .46, 1.8),
    (.28, .94, 1.8), (.62, .92, 1.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final niche = _ogee(Rect.fromLTWH(0, 0, w, h), rise);
    canvas.drawPath(niche, Paint()..color = window);
    canvas
      ..save()
      ..clipPath(niche);
    final t = twinkle?.value;
    for (var i = 0; i < _stars.length; i++) {
      final (x, y, r) = _stars[i];
      // Offset from the sky's own indices, so the two never flash in step.
      final g = t == null ? 1.0 : _glint(t, i + 5);
      canvas.drawPath(
        _star(Offset(x * w, y * h), r * (.8 + .25 * g)),
        Paint()..color = star.withValues(alpha: .8 * g),
      );
    }
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(-20, -20, w + 40, h + 40)),
        niche.shift(const Offset(0, 6)),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_NichePainter old) =>
      old.window != window || old.star != star || old.rise != rise;
}

/// The names, then the time: Latin and Arabic at equal weight, as the largest
/// thing on the screen. Scaled down as a block when a large text scale would
/// not fit the niche, never clipped.
class _NicheContent extends StatelessWidget {
  const _NicheContent({
    required this.names,
    required this.title,
    required this.time,
  });

  final (String, String)? names;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final names = this.names;
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (names != null) ...[
              Text(
                names.$1,
                textDirection: TextDirection.ltr,
                style: NoorText.displayLg(context).copyWith(color: n.onWindow),
              ),
              Text(
                names.$2,
                textDirection: TextDirection.rtl,
                style:
                    NoorText.arabicDisplay(context).copyWith(color: n.onWindow),
              ),
            ] else
              Text(
                title,
                textAlign: TextAlign.center,
                style: NoorText.display(context).copyWith(color: n.onWindow),
              ),
            const SizedBox(height: NoorSpace.s2),
            Text(
              time,
              textDirection: TextDirection.ltr,
              style: NoorText.numeral(context, size: 72, color: n.onWindow),
            ),
          ],
        ),
      ),
    );
  }
}
