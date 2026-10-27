import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/sound_string.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class SoundOption {
  final String path;
  final String Function(BuildContext) titleBuilder;

  const SoundOption({
    required this.path,
    required this.titleBuilder,
  });
}

const List<SoundOption> kAdhanSoundOptions = [
  SoundOption(
    path: SSoundString.adhanAhmadAlNafees,
    titleBuilder: _titleNafees,
  ),
  SoundOption(
    path: SSoundString.adhanAlafasy1,
    titleBuilder: _titleAlafasy1,
  ),
  SoundOption(
    path: SSoundString.adhanAlafasy2,
    titleBuilder: _titleAlafasy2,
  ),
  SoundOption(
    path: SSoundString.adhanAhmedElKourdi,
    titleBuilder: _titleElKourdi,
  ),
  SoundOption(
    path: SSoundString.adhanHamzaElMajali,
    titleBuilder: _titleElMajali,
  ),
];

String _titleNafees(BuildContext c) => S.of(c).chikh_nafees;
String _titleAlafasy1(BuildContext c) => S.of(c).chikh_afassy_1;
String _titleAlafasy2(BuildContext c) => S.of(c).chilh_afassy_2;
String _titleElKourdi(BuildContext c) => S.of(c).chikh_elkourdi;
String _titleElMajali(BuildContext c) => S.of(c).chikh_elmajali;

Future<void> showAdhanSoundPickerSheet(BuildContext context) async {
  final soundController = Get.find<SoundPickerController>();
  await showNoorSheet(
    context,
    title: S.of(context).pick_adhan,
    builder: (sheetContext) => const SoundPickerSheet(),
  );
  await soundController.stopPreview();
}

class SoundPickerSheet extends StatelessWidget {
  const SoundPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final soundController = Get.find<SoundPickerController>();
    final n = context.noor;
    final selectedPath = AppPrefs.adhanSoundPath;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kAdhanSoundOptions.length; i++) ...[
          if (i > 0)
            Divider(
              color: n.line,
              height: 1,
              thickness: 1,
              indent: NoorSpace.md,
              endIndent: NoorSpace.md,
            ),
          _SoundRow(
            option: kAdhanSoundOptions[i],
            isSelected: selectedPath == kAdhanSoundOptions[i].path,
            onSelect: () async {
              final title = kAdhanSoundOptions[i].titleBuilder(context);
              await AppPrefs.setAdhanSoundPath(kAdhanSoundOptions[i].path);
              await AppPrefs.setAdhanSoundName(title);
              soundController.updateAdhanName();
              try {
                await soundController.stopPreview();
              } catch (_) {}
              try {
                await AdhanScheduler.sync();
              } catch (_) {}
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ],
    );
  }
}

class _SoundRow extends StatelessWidget {
  final SoundOption option;
  final bool isSelected;
  final VoidCallback onSelect;

  const _SoundRow({
    required this.option,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final soundController = Get.find<SoundPickerController>();
    final title = option.titleBuilder(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(NoorRadius.tile),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NoorSpace.md,
            vertical: NoorSpace.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? n.primary : n.muted,
                size: 22,
              ),
              const SizedBox(width: NoorSpace.md),
              Expanded(
                child: Text(
                  title,
                  style: NoorText.rowTitle(context).copyWith(
                    color: isSelected ? n.ink : n.body,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() {
                final isPlayingThis =
                    soundController.playingPath.value == option.path;
                return IconButton(
                  icon: Icon(
                    isPlayingThis ? Iconsax.pause_circle : Iconsax.play_circle,
                    color: isPlayingThis ? n.primary : n.muted,
                    size: 24,
                  ),
                  tooltip: isPlayingThis ? 'Pause' : 'Play',
                  onPressed: () => soundController.togglePreview(option.path),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
