import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor/features/adhan/controllers/adhan_line_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<void> showAdhanRemindersSheet(
  BuildContext context, {
  required Prayer prayer,
  required String time,
}) =>
    showNoorSheet(
      context,
      titleOf: prayer.localizedTitle,
      builder: (_) => AdhanRemindersSheet(prayer: prayer, time: time),
    );

/// A prayer's extra alarms: the ones set, each with Remove, and a stepper with
/// Set new alarm while a slot is free. A prayer has two slots, each with its
/// own persisted alarm ID.
///
/// The stepper's value is also a field: a bare number keeps the direction, and
/// a leading minus or plus means before or after the adhan.
class AdhanRemindersSheet extends StatefulWidget {
  final Prayer prayer;
  final String time;

  const AdhanRemindersSheet({
    super.key,
    required this.prayer,
    required this.time,
  });

  @override
  State<AdhanRemindersSheet> createState() => _AdhanRemindersSheetState();
}

class _AdhanRemindersSheetState extends State<AdhanRemindersSheet> {
  static const _limit = 60;

  /// Negative is before the adhan, positive after; never zero. What the field
  /// holds replaces it when the field loses focus.
  int _minutes = 10;

  late final _field = TextEditingController(text: '${_minutes.abs()}');
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
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

  static TextEditingValue _format(TextEditingValue old, TextEditingValue next) {
    if (!RegExp(r'^[-+]?[0-9٠-٩]*$').hasMatch(next.text)) return old;
    if (_amountOf(next.text) <= _limit) return next;
    final sign = next.text.startsWith(RegExp('[-+]')) ? next.text[0] : '';
    return TextEditingValue(
      text: '$sign$_limit',
      selection: TextSelection.collapsed(offset: sign.length + 2),
    );
  }

  /// An empty field falls back to the last value.
  void _commit() {
    setState(() {
      if (_typedMinutes != 0) _minutes = _typedMinutes;
      _field.text = '${_minutes.abs()}';
    });
  }

  void _step(int by) {
    _commit();
    setState(() {
      _minutes += by;
      if (_minutes == 0) _minutes += by;
      _field.text = '${_minutes.abs()}';
    });
  }

  void _selectAll() {
    _field.selection =
        TextSelection(baseOffset: 0, extentOffset: _field.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    final reminders = AdhanScheduler.reminders(widget.prayer);
    final typed = _typedMinutes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.time,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: NoorText.numeral(context, size: 28, color: n.muted),
        ),
        const SizedBox(height: NoorSpace.s4),
        for (final reminder in reminders) ...[
          NoorWell(
            radius: NoorRadius.md,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: NoorSpace.s3,
                end: NoorSpace.s1,
              ),
              child: Row(
                children: [
                  const NoorCloudIcon(NoorIcon(NoorGlyph.bell)),
                  const SizedBox(width: NoorSpace.s2),
                  Expanded(
                    child: Text(
                      getAlarmText(context, reminder.minutes),
                      style: NoorText.bodySm(context).copyWith(color: n.ink),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () async {
                      await AdhanScheduler.removeReminder(
                        widget.prayer,
                        reminder.slot,
                      );
                      if (mounted) setState(() {});
                    },
                    child: Text(
                      s.remove,
                      style: NoorText.bodySm(context).copyWith(color: n.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NoorSpace.s2),
        ],
        if (reminders.length < 2) ...[
          NoorWell(
            radius: NoorRadius.md,
            child: Row(
              children: [
                NoorCloudButton(
                  size: 40,
                  tooltip: s.before_adhan,
                  icon: const NoorIcon(NoorGlyph.minus),
                  onTap: _minutes > -_limit ? () => _step(-1) : null,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.textScalerOf(context).scale(56),
                        child: TextField(
                          controller: _field,
                          focusNode: _focus,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: NoorText.label(context),
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: const [
                            TextInputFormatter.withFunction(_format),
                          ],
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: NoorSpace.s1,
                              vertical: NoorSpace.s2,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          onTap: _selectAll,
                          onTapOutside: (_) => _focus.unfocus(),
                        ),
                      ),
                      const SizedBox(width: NoorSpace.s2),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            _focus.requestFocus();
                            _selectAll();
                          },
                          child: Text(
                            '${s.minute_short} '
                            '${_typedSign > 0 ? s.after_adhan : s.before_adhan}',
                            style: NoorText.label(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                NoorCloudButton(
                  size: 40,
                  tooltip: s.after_adhan,
                  icon: const NoorIcon(NoorGlyph.plus),
                  onTap: _minutes < _limit ? () => _step(1) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: NoorSpace.s3),
          NoorButton(
            label: s.set_new_alarm,
            onPressed: typed == 0
                ? null
                : () async {
                    await AdhanScheduler.addReminder(widget.prayer, typed);
                    if (mounted) setState(() {});
                  },
          ),
        ],
      ],
    );
  }
}
