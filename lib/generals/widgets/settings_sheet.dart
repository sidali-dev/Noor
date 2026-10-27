import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/generals/controllers/localization_controller.dart';
import 'package:noor/generals/controllers/theme_controller.dart';
import 'package:noor/generals/widgets/noor_segmented.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showNoorSheet(
    context,
    title: S.of(context).settings,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: NoorSpace.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).dark_mode,
              style: NoorText.rowTitle(context),
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
        const SizedBox(height: NoorSpace.xl),
        Text(
          S.of(context).language,
          style: NoorText.rowTitle(context),
        ),
        const SizedBox(height: NoorSpace.md),
        NoorSegmented<String>(
          items: const [
            (value: 'ar', label: 'العربية'),
            (value: 'en', label: 'English'),
            (value: 'fr', label: 'Français'),
          ],
          value: _currentLang,
          onChanged: (val) async {
            if (val == _currentLang) return;
            setState(() => _currentLang = val);
            await _localizationController.setLanguage(val);
            try {
              await AdhanController.scheduleAdhans();
            } catch (_) {}
            try {
              if (Get.isRegistered<SoundPickerController>()) {
                Get.find<SoundPickerController>().updateAdhanName();
              } else {
                Get.put(SoundPickerController()).updateAdhanName();
              }
            } catch (_) {}
          },
        ),
        const SizedBox(height: NoorSpace.md),
      ],
    );
  }
}
