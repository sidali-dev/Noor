import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:noor/features/adhan/controllers/adhan_controller.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/core/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/views/widgets/adhan_line.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_pressable.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';

OverlayEntry? _activeAlarmToast;

/// Spawns an embossed, layered 3D Islamic paper-cut notification banner from
/// the top of the screen.
void showAlarmSnackBar(OverlayState? overlay, String message) {
  if (overlay == null || !overlay.mounted) return;
  _activeAlarmToast?.remove();
  _activeAlarmToast = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _TopPaperCutSnackBar(
      message: message,
      onDismissed: () {
        if (_activeAlarmToast == entry) {
          entry.remove();
          _activeAlarmToast = null;
        }
      },
    ),
  );
  _activeAlarmToast = entry;
  overlay.insert(entry);
}

class _TopPaperCutSnackBar extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const _TopPaperCutSnackBar({
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_TopPaperCutSnackBar> createState() => _TopPaperCutSnackBarState();
}

class _TopPaperCutSnackBarState extends State<_TopPaperCutSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: kNoorSettleCurve,
      reverseCurve: Curves.easeIn,
    ));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (mounted) widget.onDismissed();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final topInset = MediaQuery.paddingOf(context).top;
    final gutter = NoorLayout.gutter(context);

    return Positioned(
      top: topInset + NoorSpace.s3,
      left: gutter,
      right: gutter,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: NoorLayout.columnWidth,
            minHeight: 68,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Material(
              type: MaterialType.transparency,
              animationDuration: Duration.zero,
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: CustomPaint(
                    painter: _PaperCutPlaquePainter(n),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        NoorSpace.s5,
                        NoorSpace.s4 + 2,
                        NoorSpace.s5,
                        NoorSpace.s4 + 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NoorIcon(
                            NoorGlyph.check,
                            size: 22,
                            color: n.success,
                          ),
                          const SizedBox(width: NoorSpace.s3),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: NoorText.heading(context)
                                  .copyWith(color: n.ink),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Embossed, multi-layered 3D Islamic paper-cut plaque with realistic depth,
/// stepped cardstock edges, and layered cast shadows.
class _PaperCutPlaquePainter extends CustomPainter {
  final NoorColors n;

  _PaperCutPlaquePainter(this.n);

  /// Islamic cartouche silhouette: rounded plaque with scalloped side cusps.
  static Path _cartouchePath(Rect rect) {
    final r = math.min(18.0, rect.height / 2);
    final base = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));
    final cuspR = math.min(12.0, rect.height * 0.24);
    final leftCusp = Path()
      ..addOval(
        Rect.fromCircle(
            center: Offset(rect.left, rect.center.dy), radius: cuspR),
      );
    final rightCusp = Path()
      ..addOval(
        Rect.fromCircle(
            center: Offset(rect.right, rect.center.dy), radius: cuspR),
      );
    return Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, base, leftCusp),
      rightCusp,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final outerRect = Offset.zero & size;
    final outerPath = _cartouchePath(outerRect.deflate(2));

    // 1. Deep multi-layered ambient and contact shadows.
    for (final (dy, sigma, alpha) in const [
      (8.0, 12.0, 0.28),
      (3.0, 4.5, 0.38),
      (1.5, 1.5, 0.50),
    ]) {
      canvas.drawPath(
        outerPath.shift(Offset(0, dy)),
        Paint()
          ..color = n.depthShadow.withValues(alpha: n.depthShadow.a * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      );
    }

    // 2. Stepped cardstock bottom edge and outer paper frame.
    final edgeColor = n.isDark ? n.line : const Color(0xFFD0D5E0);
    final backColor = n.isDark ? n.windowRaised : n.surfaceSunken;
    final frontColor = n.card;
    final topLip = n.isDark ? n.line : const Color(0xFFFFFFFF);

    canvas.drawPath(
        outerPath.shift(const Offset(0, 2.5)), Paint()..color = edgeColor);
    canvas.drawPath(
        outerPath.shift(const Offset(0, -0.8)), Paint()..color = topLip);
    canvas.drawPath(outerPath, Paint()..color = backColor);

    // 3. Raised inner paper-cut layer casting a crisp shadow onto the back plate.
    final innerRect = outerRect.deflate(6.5);
    final innerPath = _cartouchePath(innerRect);

    canvas.drawPath(
      innerPath.shift(const Offset(0, 2.0)),
      Paint()
        ..color = n.depthShadow.withValues(alpha: n.depthShadow.a * 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawPath(
        innerPath.shift(const Offset(0, 1.2)), Paint()..color = edgeColor);
    canvas.drawPath(
        innerPath.shift(const Offset(0, -0.6)), Paint()..color = topLip);
    canvas.drawPath(innerPath, Paint()..color = frontColor);

    // 4. Inset hairline geometric rule.
    final rulePath = _cartouchePath(innerRect.deflate(4));
    canvas.drawPath(
      rulePath,
      Paint()
        ..color = n.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PaperCutPlaquePainter oldDelegate) => oldDelegate.n != n;
}

/// Duration to wait after closing one bottom sheet before opening the next so
/// both sheets have time to animate smoothly.
const Duration _kSheetSwitchDelay = Duration(milliseconds: 260);

Future<void> showAdhanRemindersSheet(
  BuildContext context, {
  required Prayer prayer,
  required String time,
  DateTime? selectedDate,
  PrayerReminder? editingReminder,
}) =>
    showNoorSheet(
      context,
      builder: (_) => AdhanRemindersSheet(
        prayer: prayer,
        time: time,
        selectedDate: selectedDate,
        editingReminder: editingReminder,
      ),
    );

Future<void> showSavedAlarmsSheet(
  BuildContext context, {
  required Prayer prayer,
  required String time,
  DateTime? selectedDate,
}) =>
    showNoorSheet(
      context,
      titleOf: (c) => S.of(c).saved_alarms,
      builder: (_) => AdhanSavedAlarmsSheet(
        prayer: prayer,
        time: time,
        selectedDate: selectedDate,
      ),
    );

/// Bottom sheet to create or edit a prayer reminder alarm.
class AdhanRemindersSheet extends StatefulWidget {
  final Prayer prayer;
  final String time;
  final DateTime? selectedDate;
  final PrayerReminder? editingReminder;

  const AdhanRemindersSheet({
    super.key,
    required this.prayer,
    required this.time,
    this.selectedDate,
    this.editingReminder,
  });

  @override
  State<AdhanRemindersSheet> createState() => _AdhanRemindersSheetState();
}

class _AdhanRemindersSheetState extends State<AdhanRemindersSheet> {
  static const _limit = 60;

  /// Negative is before the adhan, positive after; never zero.
  late int _minutes;
  late bool _everyDay;

  late final TextEditingController _field;
  final _focus = FocusNode();

  static String _signedText(int minutes) =>
      minutes > 0 ? '+$minutes' : '$minutes';

  @override
  void initState() {
    super.initState();
    _minutes = widget.editingReminder?.minutes ?? 10;
    _everyDay = widget.editingReminder?.everyDay ?? true;
    _field = TextEditingController(text: _signedText(_minutes));
    _focus.addListener(() {
      if (!_focus.hasFocus && mounted) _commit();
    });
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  DateTime get _effectiveDate {
    if (widget.selectedDate != null) return widget.selectedDate!;
    if (widget.editingReminder?.date != null) {
      return widget.editingReminder!.date!;
    }
    if (Get.isRegistered<AdhanController>()) {
      return Get.find<AdhanController>().date.value;
    }
    return DateTime.now();
  }

  /// Keyboards in Arabic may type Arabic-Indic digits.
  static int _amountOf(String text) =>
      int.tryParse(text.replaceFirst(RegExp('^[-+]'), '').replaceAllMapped(
          RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x0660}')) ??
      0;

  int get _typedSign => _field.text.startsWith('-')
      ? -1
      : _field.text.startsWith('+')
          ? 1
          : _minutes.sign;

  /// The value the field holds; zero while it holds no number.
  int get _typedMinutes => _typedSign * _amountOf(_field.text);

  TextEditingValue _formatInput(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    if (!RegExp(r'^[-+]?[0-9٠-٩]*$').hasMatch(next.text)) return old;
    if (next.text.isEmpty || next.text == '-' || next.text == '+') {
      return next;
    }
    final hasExplicitSign = next.text.startsWith(RegExp('[-+]'));
    final signChar =
        hasExplicitSign ? next.text[0] : (_minutes < 0 ? '-' : '+');
    final digits = next.text.replaceFirst(RegExp('^[-+]'), '');
    final amount = _amountOf(digits);
    final clampedDigits = amount > _limit ? '$_limit' : digits;
    final formatted = '$signChar$clampedDigits';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// An empty field falls back to the last value.
  void _commit() {
    setState(() {
      if (_typedMinutes != 0) _minutes = _typedMinutes;
      _field.text = _signedText(_minutes);
    });
  }

  void _step(int by) {
    _commit();
    setState(() {
      _minutes += by;
      if (_minutes == 0) _minutes += by;
      _field.text = _signedText(_minutes);
    });
  }

  void _selectAll() {
    _field.selection =
        TextSelection(baseOffset: 0, extentOffset: _field.text.length);
  }

  void _openSavedAlarms() {
    final nav = Navigator.of(context);
    final navContext = nav.context;
    final date = _effectiveDate;
    final delay = noorDuration(navContext, _kSheetSwitchDelay);
    if (nav.canPop()) nav.pop();
    Future.delayed(delay, () {
      if (navContext.mounted) {
        showSavedAlarmsSheet(
          navContext,
          prayer: widget.prayer,
          time: widget.time,
          selectedDate: date,
        );
      }
    });
  }

  Future<void> _onConfirm() async {
    final typed = _typedMinutes;
    if (typed == 0) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final nav = Navigator.maybeOf(context);
    final savedMsg = S.of(context).alarm_saved;
    final date = _effectiveDate;

    final bool ok;
    if (widget.editingReminder != null) {
      ok = await AdhanScheduler.updateReminder(
        widget.prayer,
        widget.editingReminder!.slot,
        typed,
        everyDay: _everyDay,
        date: _everyDay ? null : date,
      );
    } else {
      ok = await AdhanScheduler.addReminder(
        widget.prayer,
        typed,
        everyDay: _everyDay,
        date: _everyDay ? null : date,
      );
    }

    if (!ok) return;
    if (mounted && (nav?.canPop() ?? false)) {
      nav!.pop();
    } else if (mounted) {
      setState(() {});
    }
    showAlarmSnackBar(overlay, savedMsg);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    final reminders = AdhanScheduler.reminders(widget.prayer);
    final typed = _typedMinutes;
    final isEditing = widget.editingReminder != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: reminders.isNotEmpty ? 48 : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MediaQuery.withClampedTextScaling(
                    maxScaleFactor: 1.3,
                    child: Text(
                      widget.prayer.localizedTitle(context),
                      textAlign: TextAlign.center,
                      style: NoorText.title(context),
                    ),
                  ),
                  const SizedBox(height: NoorSpace.s1),
                  Text(
                    widget.time,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: NoorText.numeral(context, size: 28, color: n.muted),
                  ),
                ],
              ),
            ),
            if (reminders.isNotEmpty)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: NoorCloudButton(
                  tooltip: s.saved_alarms,
                  icon: const NoorIcon(NoorGlyph.alarm),
                  onTap: _openSavedAlarms,
                ),
              ),
          ],
        ),
        const SizedBox(height: NoorSpace.s5),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NoorCloudButton(
                  tooltip: s.before_adhan,
                  icon: const NoorIcon(NoorGlyph.minus),
                  onTap: _minutes > -_limit ? () => _step(-1) : null,
                ),
                GestureDetector(
                  onTap: () {
                    _focus.requestFocus();
                    _selectAll();
                  },
                  child: CloudMedallion(
                    size: 136,
                    face: 0.5,
                    child: SizedBox(
                      width: 84,
                      child: MediaQuery.withClampedTextScaling(
                        maxScaleFactor: 1.25,
                        child: TextField(
                          controller: _field,
                          focusNode: _focus,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: NoorText.numeral(
                            context,
                            size: 34,
                            color: n.ink,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            TextInputFormatter.withFunction(_formatInput),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                          onTap: _selectAll,
                          onTapOutside: (_) => _focus.unfocus(),
                        ),
                      ),
                    ),
                  ),
                ),
                NoorCloudButton(
                  tooltip: s.after_adhan,
                  icon: const NoorIcon(NoorGlyph.plus),
                  onTap: _minutes < _limit ? () => _step(1) : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NoorSpace.s4),
        NoorPressable(
          onPressed: () => setState(() => _everyDay = !_everyDay),
          radius: NoorRadius.md,
          builder: (context, pressed) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NoorSpace.s1,
              vertical: NoorSpace.s1,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _everyDay,
                  activeColor: n.isDark ? n.onWindow : n.window,
                  checkColor: n.isDark ? n.window : n.onWindow,
                  side: BorderSide(color: n.lineStrong, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) {
                    if (val != null) setState(() => _everyDay = val);
                  },
                ),
                const SizedBox(width: NoorSpace.s2),
                Expanded(
                  child: Text(
                    s.every_day,
                    style: NoorText.body(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NoorSpace.s3),
        NoorButton(
          label: isEditing ? s.confirm : s.set_new_alarm,
          onPressed: typed == 0 ? null : _onConfirm,
        ),
      ],
    );
  }
}

/// Bottom sheet listing the saved alarms for [prayer], with Edit and Delete
/// actions on each row.
class AdhanSavedAlarmsSheet extends StatelessWidget {
  final Prayer prayer;
  final String time;
  final DateTime? selectedDate;

  const AdhanSavedAlarmsSheet({
    super.key,
    required this.prayer,
    required this.time,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    final reminders = AdhanScheduler.reminders(prayer);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < reminders.length; i++) ...[
          if (i > 0) SizedBox(height: 1, child: ColoredBox(color: n.line)),
          _SavedAlarmRow(
            prayer: prayer,
            time: time,
            selectedDate: selectedDate,
            reminder: reminders[i],
            n: n,
            s: s,
          ),
        ],
      ],
    );
  }
}

class _SavedAlarmRow extends StatelessWidget {
  final Prayer prayer;
  final String time;
  final DateTime? selectedDate;
  final PrayerReminder reminder;
  final NoorColors n;
  final S s;

  const _SavedAlarmRow({
    required this.prayer,
    required this.time,
    required this.selectedDate,
    required this.reminder,
    required this.n,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = reminder.everyDay || reminder.date == null
        ? s.every_day
        : DateFormat('dd MMM yyyy').format(reminder.date!);

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: NoorSpace.s1,
        end: NoorSpace.s1,
        top: NoorSpace.s2,
        bottom: NoorSpace.s2,
      ),
      child: Row(
        children: [
          const NoorCloudIcon(NoorIcon(NoorGlyph.bell)),
          const SizedBox(width: NoorSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getAlarmText(context, reminder.minutes),
                  style: NoorText.heading(context).copyWith(color: n.ink),
                ),
                Text(
                  subtitle,
                  style: NoorText.caption(context),
                ),
              ],
            ),
          ),
          NoorCloudButton(
            tooltip: s.edit,
            icon: const Icon(Iconsax.edit_2),
            onTap: () {
              final nav = Navigator.of(context);
              final navContext = nav.context;
              final delay = noorDuration(navContext, _kSheetSwitchDelay);
              if (nav.canPop()) nav.pop();
              Future.delayed(delay, () {
                if (navContext.mounted) {
                  showAdhanRemindersSheet(
                    navContext,
                    prayer: prayer,
                    time: time,
                    selectedDate: selectedDate,
                    editingReminder: reminder,
                  );
                }
              });
            },
          ),
          NoorCloudButton(
            tooltip: s.remove,
            icon: Icon(Iconsax.trash, color: n.danger),
            onTap: () async {
              final overlay = Overlay.maybeOf(context, rootOverlay: true);
              final nav = Navigator.maybeOf(context);
              final deletedMsg = S.of(context).alarm_deleted;
              final ok = await AdhanScheduler.removeReminder(
                prayer,
                reminder.slot,
              );
              if (!ok) return;
              if (context.mounted && (nav?.canPop() ?? false)) {
                nav!.pop();
              }
              showAlarmSnackBar(overlay, deletedMsg);
            },
          ),
        ],
      ),
    );
  }
}
