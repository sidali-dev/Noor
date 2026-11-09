import 'package:flutter/material.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/core/utils/text_normalize.dart';
import 'package:noor/core/widgets/noor_radio.dart';
import 'package:noor/core/widgets/noor_list_row.dart';
import 'package:noor/core/widgets/noor_search_field.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/views/widgets/surah_line.dart';
import 'package:noor/generated/l10n.dart';
import 'package:quran/quran.dart' as quran;

String _sheetTitle(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'ar') return 'اختر السورة';
  if (code == 'fr') return 'Choisir la sourate';
  return 'Select Surah';
}

Future<void> showSurahPickerSheet(
  BuildContext context,
  QuranAudioController audio,
) {
  return showNoorSheet(
    context,
    title: _sheetTitle(context),
    builder: (sheetContext) => _SurahPickerContent(audio: audio),
  );
}

class _SurahPickerContent extends StatefulWidget {
  final QuranAudioController audio;

  const _SurahPickerContent({required this.audio});

  @override
  State<_SurahPickerContent> createState() => _SurahPickerContentState();
}

class _SurahPickerContentState extends State<_SurahPickerContent> {
  String _query = '';

  List<int> get _filteredSurahs {
    final q = _query.trim();
    if (q.isEmpty) {
      return List<int>.generate(114, (i) => i + 1);
    }
    final results = <int>[];
    for (var s = 1; s <= 114; s++) {
      final ar = quran.getSurahNameArabic(s);
      final en = quran.getSurahName(s);
      final numStr = '$s';
      if (numStr == q || matchesQuery(ar, q) || matchesQuery(en, q)) {
        results.add(s);
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final currentSurah = widget.audio.playingAyah.value?.surah ?? 1;
    final surahs = _filteredSurahs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NoorSearchField(
          hint: S.of(context).search_surah,
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: NoorSpace.s3),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.48,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: surahs.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: n.line,
            ),
            itemBuilder: (context, index) {
              final s = surahs[index];
              final ar = 'سورة ${quran.getSurahNameArabic(s)}';
              final en = quran.getSurahName(s);
              final verses = quran.getVerseCount(s);
              final selected = s == currentSurah;

              return NoorListRow(
                leading: IndexNumber(s),
                title: ar,
                titleStyle: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: n.ink,
                ),
                meta: '$en · ${S.of(context).verse_count(verses)}',
                trailing: NoorRadioMark(selected: selected),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.audio.playSurah(s, startAyah: 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
