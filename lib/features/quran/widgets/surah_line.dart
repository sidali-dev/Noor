import 'package:flutter/material.dart';
import 'package:noor/utils/constants/colors.dart';

import '../../../utils/helpers/helper_functions.dart';

class SurahLine extends StatelessWidget {
  final String arabicName;
  final int number;
  final String englishName;
  final int verses;
  final String revelationPlace;

  const SurahLine({
    super.key,
    required this.arabicName,
    required this.number,
    required this.englishName,
    required this.verses,
    required this.revelationPlace,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = SHelperFunctions.isDarkMode(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            const Text("\uFD3E",
                style: TextStyle(
                    fontSize: 18,
                    color: SColors.secondary,
                    fontWeight: FontWeight.w700)),
            Text("$number",
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? SColors.white : SColors.primary)),
            const Text("\uFD3F",
                style: TextStyle(
                    fontSize: 18,
                    color: SColors.secondary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(englishName,
                    style: TextStyle(
                        color: isDark ? SColors.white : SColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Text(
                  "$revelationPlace \u25CF $verses verses",
                  style: const TextStyle(
                      color: SColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                )
              ],
            ),
            const Expanded(child: SizedBox()),
            Text(
              arabicName,
              style: TextStyle(
                  color: isDark ? SColors.white : SColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
