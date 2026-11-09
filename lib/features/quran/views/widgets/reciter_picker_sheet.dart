import 'package:flutter/material.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_pressable.dart';
import 'package:noor/core/widgets/noor_radio.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/generated/l10n.dart';

String reciterSheetTitle(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'ar') return 'اختر القارئ';
  if (code == 'fr') return 'Choisir le récitateur';
  return 'Choose reciter';
}

Future<void> showReciterPickerSheet(
  BuildContext context,
  QuranAudioController audio,
) {
  return showNoorSheet(
    context,
    title: reciterSheetTitle(context),
    builder: (sheetContext) => _ReciterPickerSheet(audio: audio),
  );
}

class _ReciterPickerSheet extends StatefulWidget {
  final QuranAudioController audio;

  const _ReciterPickerSheet({required this.audio});

  @override
  State<_ReciterPickerSheet> createState() => _ReciterPickerSheetState();
}

class _ReciterPickerSheetState extends State<_ReciterPickerSheet> {
  late String _selected = widget.audio.reciterFolder.value;

  Future<void> _save() async {
    await widget.audio.setReciter(_selected);
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final r in kQuranReciters)
          Semantics(
            checked: r.folder == _selected,
            inMutuallyExclusiveGroup: true,
            child: NoorPressable(
              onPressed: () => setState(() => _selected = r.folder),
              radius: NoorRadius.md,
              builder: (context, pressed) => ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Row(
                  children: [
                    const SizedBox(width: NoorSpace.s2),
                    NoorRadioMark(selected: r.folder == _selected),
                    const SizedBox(width: NoorSpace.s3),
                    Expanded(
                      child: Text(
                        r.label(context),
                        style: NoorText.heading(context).copyWith(
                          fontWeight: r.folder == _selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: NoorSpace.s4),
        NoorButton(
          label: S.of(context).save,
          onPressed: _save,
        ),
      ],
    );
  }
}

