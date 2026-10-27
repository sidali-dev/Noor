import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:noor/bottom_navigation.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class AdhanRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  const AdhanRingScreen({super.key, required this.alarmSettings});

  @override
  State<AdhanRingScreen> createState() => _AdhanRingScreenState();
}

class _AdhanRingScreenState extends State<AdhanRingScreen> {
  @override
  void dispose() {
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
    Alarm.stop(widget.alarmSettings.id).then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final deep = Color.lerp(n.primary, Colors.black, 0.3)!;
    final baseId = AdhanScheduler.baseOf(widget.alarmSettings.id);
    final prayer = _prayerFromBaseId(baseId);

    final title = widget.alarmSettings.notificationSettings.title;
    final body = widget.alarmSettings.notificationSettings.body;
    final formattedTime =
        DateFormat('HH:mm').format(widget.alarmSettings.dateTime);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: n.paper,
        body: Stack(
          children: [
            // Faint backdrop: clouds and the mosque skyline. Decoration only.
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _BackdropPainter(n.primary),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    NoorSpace.xxl,
                    NoorSpace.xxl,
                    NoorSpace.xxl,
                    NoorSpace.xxl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - NoorSpace.xxl * 2,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SvgPicture.asset(
                              n.isDark ? NoorArt.emblemDark : NoorArt.emblem,
                              height: 48,
                              excludeFromSemantics: true,
                            ),
                          ),
                          const Spacer(flex: 3),
                          Center(
                            child: _Mihrab(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: n.tintBg(NoorTint.sage),
                                    ),
                                    child: Icon(
                                      prayer?.icon ?? Iconsax.sun_fog,
                                      size: 34,
                                      color: n.primary,
                                    ),
                                  ),
                                  const SizedBox(height: NoorSpace.xxl),
                                  if (title.isNotEmpty)
                                    Text(
                                      title,
                                      style: NoorText.section(context).copyWith(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: deep),
                                      textAlign: TextAlign.center,
                                    ),
                                  Text(
                                    formattedTime,
                                    style: NoorText.section(context).copyWith(
                                      fontSize: 50,
                                      height: 1.2,
                                      fontWeight: FontWeight.w500,
                                      color: deep,
                                    ),
                                  ),
                                  const SizedBox(height: NoorSpace.md),
                                  const _OrnamentDivider(),
                                  if (body.isNotEmpty) ...[
                                    const SizedBox(height: NoorSpace.md),
                                    Text(
                                      body,
                                      style: NoorText.body(context)
                                          .copyWith(color: n.muted),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const Spacer(flex: 4),
                          _PrimaryAction(
                            label: S.of(context).open_adhkar,
                            onTap: _openAdhkar,
                          ),
                          const SizedBox(height: NoorSpace.lg),
                          _CloseAction(
                            label: S.of(context).close,
                            onTap: _close,
                          ),
                        ],
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
}

/// Pointed-arch frame that fades out at its foot.
class _Mihrab extends StatelessWidget {
  final Widget child;
  const _Mihrab({required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.5;
    return CustomPaint(
      painter: _MihrabPainter(context.noor.card, context.noor.primary),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: width, maxWidth: width, minHeight: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NoorSpace.md,
            NoorSpace.xxxl + NoorSpace.xl,
            NoorSpace.md,
            NoorSpace.xxxl,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MihrabPainter extends CustomPainter {
  final Color fill;
  final Color accent;
  _MihrabPainter(this.fill, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Ogee tip, rounded shoulders, straight sides; mirrored about the centre.
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.26)
      ..quadraticBezierTo(0, h * 0.14, w * 0.2, h * 0.13)
      ..cubicTo(w * 0.36, h * 0.12, w * 0.42, h * 0.05, w * 0.5, 0)
      ..cubicTo(w * 0.58, h * 0.05, w * 0.64, h * 0.12, w * 0.8, h * 0.13)
      ..quadraticBezierTo(w, h * 0.14, w, h * 0.26)
      ..lineTo(w, h)
      ..close();

    final rect = Offset.zero & size;
    final fade = [Colors.white, Colors.white.withValues(alpha: 0)];
    LinearGradient vertical(List<Color> c, [List<double>? stops]) =>
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: c,
          stops: stops,
        );

    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withValues(alpha: 0.025)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = vertical([
          Color.lerp(fill, Colors.white, 0.4)!.withValues(alpha: 0.75),
          accent.withValues(alpha: 0.03),
          accent.withValues(alpha: 0),
        ], const [
          0,
          0.6,
          1
        ]).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = vertical(
          [fade[0].withValues(alpha: 0.95), fade[1]],
          const [0.2, 0.85],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_MihrabPainter old) =>
      old.fill != fill || old.accent != accent;
}

class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();

  @override
  Widget build(BuildContext context) {
    final c = context.noor.primary.withValues(alpha: 0.3);
    Widget line() => Container(width: 28, height: 1.5, color: c);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(),
        const SizedBox(width: NoorSpace.sm),
        Transform.rotate(
          angle: 0.785398,
          child: Container(width: 7, height: 7, color: c),
        ),
        const SizedBox(width: NoorSpace.sm),
        line(),
      ],
    );
  }
}

const _actionHeight = 62.0;
const _actionRadius = 31.0;

/// Chevron always points right, as drawn in the design, even in RTL.
Widget _chevron(Color color) => Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(Icons.chevron_right_rounded, color: color, size: 26),
    );

class _PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final radius = BorderRadius.circular(_actionRadius);
    return Container(
      height: _actionHeight,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(n.primary, Colors.white, 0.1)!,
            n.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: n.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xxl),
            child: Row(
              children: [
                _chevron(n.onPrimary),
                const Spacer(),
                Text(
                  label,
                  style: NoorText.rowTitle(context)
                      .copyWith(color: n.onPrimary, fontSize: 18),
                ),
                Container(
                  width: 1,
                  height: 26,
                  margin: const EdgeInsets.symmetric(horizontal: NoorSpace.lg),
                  color: n.onPrimary.withValues(alpha: 0.3),
                ),
                SvgPicture.asset(
                  SImageString.masjid,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(n.onPrimary, BlendMode.srcIn),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CloseAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final radius = BorderRadius.circular(_actionRadius);
    return Container(
      height: _actionHeight - 4,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: n.tintBg(NoorTint.sage).withValues(alpha: 0.7),
        border: Border.all(color: n.primary.withValues(alpha: 0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xxl),
            child: Row(
              children: [
                Icon(Icons.close_rounded, color: n.primary, size: 22),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: NoorText.rowTitle(context)
                        .copyWith(color: n.primary, fontSize: 18),
                  ),
                ),
                // Balances the close icon so the label stays centred.
                const SizedBox(width: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft clouds near the top and a pale mosque skyline above the buttons.
class _BackdropPainter extends CustomPainter {
  final Color tint;
  _BackdropPainter(this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final cloud = Paint()
      ..color = tint.withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    for (final c in [
      Offset(w * 0.02, h * 0.2),
      Offset(w * 0.17, h * 0.22),
      Offset(w * 0.09, h * 0.17),
      Offset(w * 0.96, h * 0.24),
      Offset(w * 0.85, h * 0.26),
      Offset(w * 0.93, h * 0.21),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: w * 0.34, height: h * 0.07),
        cloud,
      );
    }

    final g = h * 0.715; // ground line
    final u = w / 100; // 1 unit = 1% of width
    final cx = w / 2;
    final sil = Paint()..color = tint.withValues(alpha: 0.09);
    const pi = 3.14159;

    canvas.drawPath(
      Path()
        ..moveTo(0, g)
        ..quadraticBezierTo(w * 0.2, g - u * 7, w * 0.45, g - u * 2)
        ..quadraticBezierTo(w * 0.75, g - u * 9, w, g - u * 4)
        ..lineTo(w, g)
        ..close(),
      Paint()..color = tint.withValues(alpha: 0.05),
    );

    void dome(double dx, double base, double width, double height) =>
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx + u * dx, g - u * base),
            width: u * width,
            height: u * height,
          ),
          pi,
          pi,
          true,
          sil,
        );

    // Main dome, crescent, hall and side domes.
    canvas.drawRect(Rect.fromLTRB(cx - u * 12, g - u * 7, cx + u * 12, g), sil);
    dome(0, 7, 12, 14);
    canvas.drawCircle(Offset(cx, g - u * 15), u * 1, sil);
    for (final dx in [-9.0, 9.0, -14.0, 14.0]) {
      dome(dx, 5, 5, 6);
    }

    // Minarets: shaft, balcony, pointed cap.
    for (final dx in [-10.5, 10.5, -17.0, 17.0]) {
      final tall = dx.abs() < 12;
      final top = g - u * (tall ? 21 : 12);
      final x = cx + u * dx;
      final half = u * (tall ? 1.4 : 1.1);
      canvas.drawRect(Rect.fromLTRB(x - half, top, x + half, g), sil);
      canvas.drawRect(
        Rect.fromLTRB(x - half * 1.7, top + u * 3, x + half * 1.7, top + u * 4),
        sil,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x - half, top)
          ..lineTo(x, top - u * (tall ? 5 : 3.5))
          ..lineTo(x + half, top)
          ..close(),
        sil,
      );
    }

    // Palms and bushes.
    for (final dx in [-29.0, -32.0, 30.0]) {
      final x = cx + u * dx;
      canvas.drawLine(
        Offset(x, g),
        Offset(x, g - u * 9),
        Paint()
          ..color = sil.color
          ..strokeWidth = u * 0.8,
      );
      for (final a in [-0.9, -0.3, 0.3, 0.9]) {
        canvas
          ..save()
          ..translate(x, g - u * 9)
          ..rotate(a)
          ..drawOval(Rect.fromLTWH(-u * 0.6, -u * 4, u * 1.2, u * 4.5), sil)
          ..restore();
      }
    }
    for (final dx in [-20.0, 20.0, -34.0, 34.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + u * dx, g - u * 1.2),
          width: u * 12,
          height: u * 4.5,
        ),
        sil,
      );
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.tint != tint;
}
