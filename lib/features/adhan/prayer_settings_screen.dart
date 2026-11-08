import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/models/prayer.dart';
import 'package:noor/features/adhan/models/prayer_settings.dart';
import 'package:noor/features/adhan/widgets/adhan_line.dart';
import 'package:noor/features/adhan/widgets/adhan_reminders_sheet.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_cartouche.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/generals/widgets/noor_radio.dart';
import 'package:noor/generals/widgets/noor_segmented.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generals/widgets/wait_dialog.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The round piece of night sky beside the location pill: the same 56 dp
/// paper ring and `window` fill as [NoorCartouche], holding the sliders.
class PrayerSettingsButton extends StatelessWidget {
  const PrayerSettingsButton({super.key});

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final label = S.of(context).prayer_settings;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: NoorPressable(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrayerSettingsScreen()),
          ),
          radius: NoorRadius.pill,
          builder: (context, pressed) => AnimatedContainer(
            duration: noorDuration(context, kNoorPressDuration),
            curve: Curves.ease,
            width: size,
            height: size,
            padding: EdgeInsets.all(n.isDark ? NoorSpace.s1 - 1 : NoorSpace.s1),
            decoration: BoxDecoration(
              color: n.card,
              shape: BoxShape.circle,
              border: n.isDark ? Border.all(color: n.line) : null,
              boxShadow: pressed ? n.shadow1 : n.shadow2,
            ),
            child: DecoratedBox(
              decoration:
                  BoxDecoration(color: n.window, shape: BoxShape.circle),
              child: Icon(Iconsax.setting_4, color: n.onWindow, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// Calculation method, Asr school, high-latitude rule, minutes per prayer and
/// the Hijri calendar. Nothing is kept until Save has fetched a calendar with
/// the new settings.
class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  late final AdhanController _controller = Get.find<AdhanController>();
  late PrayerSettings _draft = _controller.settings.value;
  String? _error;

  String get _lang => Localizations.localeOf(context).languageCode;

  String _methodName(int id) =>
      calculationMethods.where((m) => m.value == id).firstOrNull?.name(_lang) ??
      '$id';

  void _update(PrayerSettings next) => setState(() {
        _draft = next;
        _error = null;
      });

  Future<void> _pickMethod() async {
    final s = S.of(context);
    final picked = await _pickOption<int?>(
      context,
      title: s.calculation_method,
      selected: _draft.method,
      options: [
        (value: null, title: s.automatic, meta: s.automatic_meta),
        for (final m in calculationMethods)
          (value: m.value, title: m.name(_lang), meta: null),
      ],
    );
    if (picked != null) _update(_draft.copyWith(method: () => picked.value));
  }

  Future<void> _pickHighLatitude() async {
    final s = S.of(context);
    final picked = await _pickOption<int?>(
      context,
      title: s.high_latitude,
      selected: _draft.highLatitude,
      options: [
        (value: null, title: s.automatic, meta: null),
        for (final (id, label) in _highLatitudeOptions(s))
          (value: id, title: label, meta: null),
      ],
    );
    if (picked != null) {
      _update(_draft.copyWith(highLatitude: () => picked.value));
    }
  }

  Future<void> _pickHijriMethod() async {
    final picked = await _pickOption<String>(
      context,
      title: S.of(context).hijri_date,
      selected: _draft.hijriMethod,
      options: [
        for (final m in hijriMethods)
          (value: m.value, title: m.name(_lang), meta: null),
      ],
    );
    if (picked != null) {
      _update(_draft.copyWith(
        hijriMethod: picked.value,
        hijriAdjustment:
            picked.value == adjustableHijriMethod ? _draft.hijriAdjustment : 0,
      ));
    }
  }

  static List<(int, String)> _highLatitudeOptions(S s) => [
        (1, s.lat_middle_night),
        (2, s.lat_one_seventh),
        (3, s.lat_angle_based),
      ];

  Future<void> _save() async {
    final s = S.of(context);
    final nav = Navigator.of(context);
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WaitDialog(),
    );
    Object? error;
    try {
      await _controller.applySettings(_draft);
    } catch (e) {
      error = e;
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
    if (!mounted) return;
    if (error != null) {
      setState(() => _error =
          error is NoInternetException ? s.no_internet : s.prayer_times_failed);
      return;
    }
    nav.pop();
    showAlarmSnackBar(overlay, s.settings_saved);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final n = context.noor;
    final gutter = NoorLayout.gutter(context);
    final saved = _controller.settings.value;

    final String methodMeta;
    if (_draft.method != null) {
      methodMeta = '';
    } else {
      // The calendar's method is the API's own pick only while the saved
      // settings leave it to the API too.
      final resolved =
          saved.method == null ? _controller.prayerTime.value?.methodId : null;
      methodMeta = resolved == null
          ? s.automatic_meta
          : s.automatic_method_meta(_methodName(resolved));
    }

    final highLatitude = _draft.highLatitude;
    final hijri = hijriMethods.firstWhere(
      (m) => m.value == _draft.hijriMethod,
      orElse: () => hijriMethods.first,
    );
    final adjustable = _draft.hijriMethod == adjustableHijriMethod;

    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                NoorSpace.s2,
                gutter,
                NoorSpace.s3,
              ),
              child: Row(
                children: [
                  NoorCloudButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: s.back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: NoorSpace.s2),
                  Expanded(child: NoorCartouche.title(s.prayer_settings)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  NoorSpace.s2,
                  gutter,
                  NoorSpace.s5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionTitle(s.calculation_method),
                    NoorListGroup(children: [
                      NoorListRow(
                        leading:
                            const NoorCloudIcon(NoorIcon(NoorGlyph.mosque)),
                        title: _draft.method == null
                            ? s.automatic
                            : _methodName(_draft.method!),
                        titleMaxLines: 2,
                        meta: methodMeta,
                        onTap: _pickMethod,
                      ),
                    ]),
                    const SizedBox(height: NoorSpace.s5),
                    _SectionTitle(s.asr_time),
                    NoorSegmented<int>(
                      items: [
                        (value: 0, label: s.asr_standard),
                        (value: 1, label: s.asr_hanafi),
                      ],
                      value: _draft.school,
                      onChanged: (v) => _update(_draft.copyWith(school: v)),
                    ),
                    _Hint(s.asr_hint),
                    const SizedBox(height: NoorSpace.s5),
                    _SectionTitle(s.high_latitude),
                    NoorListGroup(children: [
                      NoorListRow(
                        leading:
                            const NoorCloudIcon(NoorIcon(NoorGlyph.moonStars)),
                        title: highLatitude == null
                            ? s.automatic
                            : _highLatitudeOptions(s)
                                .firstWhere((o) => o.$1 == highLatitude)
                                .$2,
                        meta: s.high_latitude_hint,
                        onTap: _pickHighLatitude,
                      ),
                    ]),
                    const SizedBox(height: NoorSpace.s5),
                    _SectionTitle(s.adjust_times),
                    NoorListGroup(children: [
                      for (final prayer in Prayer.all)
                        _StepperRow(
                          leading:
                              NoorIcon(prayer.glyph, size: 26, color: n.muted),
                          title: prayer.localizedTitle(context),
                          value: _draft.tuneFor(prayer),
                          limit: PrayerSettings.tuneLimit,
                          onChanged: (v) => _update(_draft.withTune(prayer, v)),
                        ),
                    ]),
                    _Hint(s.adjust_times_hint),
                    const SizedBox(height: NoorSpace.s5),
                    _SectionTitle(s.hijri_date),
                    NoorListGroup(children: [
                      NoorListRow(
                        leading:
                            const NoorCloudIcon(NoorIcon(NoorGlyph.calendar)),
                        title: hijri.name(_lang),
                        titleMaxLines: 2,
                        meta: adjustable ? null : s.hijri_adjust_hint,
                        onTap: _pickHijriMethod,
                      ),
                      if (adjustable)
                        _StepperRow(
                          leading: NoorIcon(NoorGlyph.moon,
                              size: 24, color: n.muted),
                          title: s.hijri_adjustment,
                          value: _draft.hijriAdjustment,
                          limit: PrayerSettings.hijriAdjustmentLimit,
                          onChanged: (v) =>
                              _update(_draft.copyWith(hijriAdjustment: v)),
                        ),
                    ]),
                    const SizedBox(height: NoorSpace.s5),
                    NoorButton(
                      label: s.reset,
                      variant: NoorButtonVariant.outline,
                      onPressed: _draft.isDefault
                          ? null
                          : () => _update(const PrayerSettings()),
                    ),
                  ],
                ),
              ),
            ),
            // Save stays in reach however far down the change was made.
            DecoratedBox(
              decoration: BoxDecoration(
                color: n.paper,
                border: Border(top: BorderSide(color: n.line)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  NoorSpace.s3,
                  gutter,
                  NoorSpace.s3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: NoorText.body(context).copyWith(color: n.danger),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: NoorSpace.s2),
                    ],
                    NoorButton(
                      label: s.save,
                      onPressed: _draft == saved ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of choices on its own sheet; null when dismissed, so a null
/// [selected] ("Automatic") can still be picked.
Future<({T value})?> _pickOption<T>(
  BuildContext context, {
  required String title,
  required T selected,
  required List<({T value, String title, String? meta})> options,
}) =>
    showNoorSheet<({T value})>(
      context,
      title: title,
      builder: (sheet) => NoorListGroup(children: [
        for (final o in options)
          Semantics(
            checked: o.value == selected,
            inMutuallyExclusiveGroup: true,
            child: NoorListRow(
              title: o.title,
              titleMaxLines: 2,
              meta: o.meta,
              trailing: NoorRadioMark(selected: o.value == selected),
              onTap: () => Navigator.of(sheet).pop((value: o.value)),
            ),
          ),
      ]),
    );

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(
          start: NoorSpace.s1,
          bottom: NoorSpace.s2,
        ),
        child: Semantics(
          header: true,
          child: Text(text, style: NoorText.heading(context)),
        ),
      );
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(
          start: NoorSpace.s1,
          end: NoorSpace.s1,
          top: NoorSpace.s2,
        ),
        child: Text(text, style: NoorText.bodySm(context)),
      );
}

/// A whole number from -[limit] to [limit], signed, with a minus and a plus.
class _StepperRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final int value;
  final int limit;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.leading,
    required this.title,
    required this.value,
    required this.limit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        NoorSpace.s3,
        NoorSpace.s1,
        NoorSpace.s1,
        NoorSpace.s1,
      ),
      child: Row(
        children: [
          SizedBox.square(dimension: 40, child: Center(child: leading)),
          const SizedBox(width: NoorSpace.s3),
          Expanded(
            child: Text(
              title,
              style: NoorText.heading(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          NoorCloudButton(
            plain: true,
            tooltip: '$title −',
            icon: const NoorIcon(NoorGlyph.minus),
            onTap: value > -limit ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 44,
            child: Text(
              value > 0 ? '+$value' : '$value',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              semanticsLabel: '$title ${value > 0 ? '+' : ''}$value',
              style: NoorText.numeral(
                context,
                size: 18,
                color: value == 0 ? n.muted : n.ink,
              ),
            ),
          ),
          NoorCloudButton(
            plain: true,
            tooltip: '$title +',
            icon: const NoorIcon(NoorGlyph.plus),
            onTap: value < limit ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
