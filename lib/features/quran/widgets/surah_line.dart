import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

/// A number on a [CloudMedallion], leading a row of the index.
class IndexNumber extends StatelessWidget {
  final int number;

  const IndexNumber(this.number, {super.key});

  @override
  Widget build(BuildContext context) {
    return CloudMedallion(
      size: 40,
      child: Text(
        '$number',
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
        style: NoorText.numeral(context, size: 16),
      ),
    );
  }
}

/// One surah row of the index, to sit in a [NoorListGroup], set like a printed
/// contents page: its number, the Arabic name over verses and place, and the
/// Latin name across from it.
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
      leading: IndexNumber(number),
      title: arName,
      titleStyle: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: n.ink,
      ),
      meta: '${S.of(context).verse_count(verseCount)} · $place',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A share of the row, so a large text scale cannot squeeze the name.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.32,
            ),
            child: Text(
              latinName,
              style: NoorText.bodySm(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: NoorSpace.s2),
          Icon(Icons.chevron_right_rounded, color: n.muted, size: 22),
        ],
      ),
    );
  }
}
