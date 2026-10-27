import 'package:flutter/material.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_progress_bar.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final arName = arabicName ?? quran.getSurahNameArabic(number);
    final latinName = englishName ?? quran.getSurahName(number);
    final verseCount = verses ?? quran.getVerseCount(number);
    final rawPlace = revelationPlace ?? quran.getPlaceOfRevelation(number);
    final place = rawPlace == 'Makkah'
        ? S.of(context).meccan
        : S.of(context).medinan;
    final metaText = "${S.of(context).verse_count(verseCount)} \u00B7 $place";

    final fraction = QuranProgress.surahFraction(number);
    final pct = (fraction * 100).round();

    final leading = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: n.tintBg(NoorTint.sage),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: NoorText.numeral(
          context,
          size: 16,
          color: n.ink,
        ),
      ),
    );

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          child: NoorProgressBar(value: fraction, height: 4),
        ),
        const SizedBox(width: NoorSpace.sm),
        SizedBox(
          width: 36,
          child: Text(
            '$pct%',
            textAlign: TextAlign.end,
            style: NoorText.numeral(
              context,
              size: 13,
              color: n.muted,
            ),
          ),
        ),
        const SizedBox(width: NoorSpace.xs),
        Icon(
          isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: n.muted,
          size: 20,
        ),
      ],
    );

    return NoorListRow(
      leading: leading,
      title: "$arName  $latinName",
      meta: metaText,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
