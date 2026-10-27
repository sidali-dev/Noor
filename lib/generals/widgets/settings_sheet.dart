import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generals/controllers/theme_controller.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showNoorSheet(
    context,
    titleOf: (c) => S.of(c).settings,
    builder: (sheetContext) => const _SettingsSheetContent(),
  );
}

class _SettingsSheetContent extends StatefulWidget {
  const _SettingsSheetContent();

  @override
  State<_SettingsSheetContent> createState() => _SettingsSheetContentState();
}

class _SettingsSheetContentState extends State<_SettingsSheetContent> {
  late final ThemeController _themeController;
  late final LocalizationController _localizationController;
  late bool _isDark;
  late String _currentLang;

  @override
  void initState() {
    super.initState();
    _themeController = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : Get.put(ThemeController());
    _localizationController = Get.isRegistered<LocalizationController>()
        ? Get.find<LocalizationController>()
        : Get.put(LocalizationController());

    _isDark = _themeController.isDarkMode();
    _currentLang = _localizationController.getLanguage();
  }

  Future<void> _setLang(String val) async {
    if (val == _currentLang) return;
    setState(() => _currentLang = val);
    await _localizationController.setLanguage(val);
    try {
      await AdhanScheduler.sync();
    } catch (_) {}
    try {
      if (Get.isRegistered<SoundPickerController>()) {
        Get.find<SoundPickerController>().updateAdhanName();
      } else {
        Get.put(SoundPickerController()).updateAdhanName();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: NoorSpace.sm),
        Row(
          children: [
            const IconTile(
                icon: Icons.dark_mode_outlined, tint: NoorTint.lilac),
            const SizedBox(width: NoorSpace.md),
            Expanded(
              child: Text(
                S.of(context).dark_mode,
                style: NoorText.rowTitle(context),
              ),
            ),
            Switch(
              value: _isDark,
              onChanged: (val) async {
                setState(() => _isDark = val);
                await _themeController.switchTheme();
              },
            ),
          ],
        ),
        const SizedBox(height: NoorSpace.xxl),
        Text(
          S.of(context).language,
          style: NoorText.rowTitle(context),
        ),
        const SizedBox(height: NoorSpace.md),
        Row(
          children: [
            for (final (i, l) in const [
              ('ar', 'العربية'),
              ('en', 'English'),
              ('fr', 'Français'),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: NoorSpace.sm),
              Expanded(
                  child: _LangPill(
                label: l.$2,
                selected: l.$1 == _currentLang,
                onTap: () => _setLang(l.$1),
              )),
            ],
          ],
        ),
        const SizedBox(height: NoorSpace.md),
      ],
    );
  }
}

class _LangPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    const r = BorderRadius.all(Radius.circular(999));
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? n.primary : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: r,
          side: selected
              ? BorderSide.none
              : BorderSide(color: n.line, width: 1.5),
        ),
        child: InkWell(
          borderRadius: r,
          onTap: onTap,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: NoorSpace.sm),
            child: Text(
              label,
              style: NoorText.body(context).copyWith(
                color: selected ? n.onPrimary : n.body,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
