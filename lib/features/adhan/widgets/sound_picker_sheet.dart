import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/adhan/services/adhan_scheduler.dart';
import 'package:noor/features/adhan/widgets/sound_picker_controller.dart';
import 'package:noor/generals/widgets/noor_button.dart';
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

class SoundPickerSheet extends StatefulWidget {
  const SoundPickerSheet({super.key});

  @override
  State<SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<SoundPickerSheet> {
  final _sound = Get.find<SoundPickerController>();
  String _selected = AppPrefs.adhanSoundPath;

  Future<void> _save() async {
    final option = kAdhanSoundOptions.firstWhere((o) => o.path == _selected);
    final title = option.titleBuilder(context);
    await AppPrefs.setAdhanSoundPath(option.path);
    await AppPrefs.setAdhanSoundName(title);
    _sound.updateAdhanName();
    await _sound.stopPreview();
    try {
      await AdhanScheduler.sync();
    } catch (_) {}
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: _selected,
      onChanged: (v) {
        if (v == null || v == _selected) return;
        _sound.stopPreview();
        setState(() => _selected = v);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final o in kAdhanSoundOptions)
            _SoundRow(
              option: o,
              selected: o.path == _selected,
              onTap: () {
                if (o.path == _selected) return;
                _sound.stopPreview();
                setState(() => _selected = o.path);
              },
            ),
          const SizedBox(height: NoorSpace.xl),
          NoorButton(label: S.of(context).save, onPressed: _save),
        ],
      ),
    );
  }
}

class _SoundRow extends StatelessWidget {
  final SoundOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SoundRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final sound = Get.find<SoundPickerController>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NoorRadius.tile),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Radio<String>(value: option.path, activeColor: n.primary),
            Expanded(
              child: Text(
                option.titleBuilder(context),
                style: NoorText.rowTitle(context).copyWith(
                  color: selected ? n.ink : n.body,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected)
              Obx(() {
                final playing = sound.playingPath.value == option.path;
                return IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: n.tintBg(NoorTint.sage),
                    minimumSize: const Size(48, 48),
                  ),
                  icon: Icon(
                    playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: n.primary,
                  ),
                  onPressed: () => sound.togglePreview(option.path),
                );
              }),
          ],
        ),
      ),
    );
  }
}
