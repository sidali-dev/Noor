import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

/// One surah row of the index, to sit in a [NoorListGroup]: its number, the
/// Arabic name, then Latin name, verses and place.
class SurahLine extends StatelessWidget {
  final int number;
  final String? arabicName;
  final String? englishName;
  final int? verses;
  final String? revelationPlace;
  final VoidCallback? onTap;

  const SurahLine({
    super.key,
    required this.number,
    this.arabicName,
    this.englishName,
    this.verses,
    this.revelationPlace,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final arName = arabicName ?? quran.getSurahNameArabic(number);
    final latinName = englishName ?? quran.getSurahName(number);
    final verseCount = verses ?? quran.getVerseCount(number);
    final rawPlace = revelationPlace ?? quran.getPlaceOfRevelation(number);
    final place =
        rawPlace == 'Makkah' ? S.of(context).meccan : S.of(context).medinan;

    return NoorListRow(
      onTap: onTap,
      leading: SizedBox(
        width: NoorSpace.s6,
        child: Text(
          '$number',
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: NoorText.numeral(context, size: 16, color: n.muted),
        ),
      ),
      title: arName,
      titleStyle: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: n.ink,
      ),
      // Two fixed lines: a wrapped one would strand the separator.
      meta: '$latinName\n${S.of(context).verse_count(verseCount)} · $place',
    );
  }
}
