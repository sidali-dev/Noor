import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

typedef SStringGetter = String Function(S s);

class AdhkarCategory {
  final int id;
  final SStringGetter title;
  final String svgAsset;
  final NoorTint tint;

  const AdhkarCategory({
    required this.id,
    required this.title,
    required this.svgAsset,
    required this.tint,
  });
}

const List<AdhkarCategory> adhkarCategories = [
  AdhkarCategory(
    id: 1,
    title: _morningTitle,
    svgAsset: SImageString.sunrise,
    tint: NoorTint.sage,
  ),
  AdhkarCategory(
    id: 2,
    title: _eveningTitle,
    svgAsset: SImageString.sunset,
    tint: NoorTint.amber,
  ),
  AdhkarCategory(
    id: 3,
    title: _prayerTitle,
    svgAsset: SImageString.prayingMan,
    tint: NoorTint.blue,
  ),
  AdhkarCategory(
    id: 4,
    title: _mosqueTitle,
    svgAsset: SImageString.masjid,
    tint: NoorTint.sage,
  ),
  AdhkarCategory(
    id: 5,
    title: _wakeUpTitle,
    svgAsset: SImageString.alarm,
    tint: NoorTint.amber,
  ),
  AdhkarCategory(
    id: 6,
    title: _sleepTitle,
    svgAsset: SImageString.night,
    tint: NoorTint.lilac,
  ),
  AdhkarCategory(
    id: 7,
    title: _afterPrayerTitle,
    svgAsset: SImageString.prayingMan,
    tint: NoorTint.blue,
  ),
  AdhkarCategory(
    id: 8,
    title: _tasbeehTitle,
    svgAsset: SImageString.tasbih,
    tint: NoorTint.mint,
  ),
  AdhkarCategory(
    id: 9,
    title: _prophetDuaTitle,
    svgAsset: SImageString.prophetName,
    tint: NoorTint.lilac,
  ),
  AdhkarCategory(
    id: 10,
    title: _quranDuaTitle,
    svgAsset: SImageString.quran,
    tint: NoorTint.mint,
  ),
  AdhkarCategory(
    id: 11,
    title: _prophetsDuaTitle,
    svgAsset: SImageString.group,
    tint: NoorTint.sage,
  ),
  AdhkarCategory(
    id: 12,
    title: _generalAdhkarTitle,
    svgAsset: SImageString.group,
    tint: NoorTint.amber,
  ),
  AdhkarCategory(
    id: 13,
    title: _adhanAdhkarTitle,
    svgAsset: SImageString.adhan,
    tint: NoorTint.blue,
  ),
  AdhkarCategory(
    id: 14,
    title: _comprehensiveDuaTitle,
    svgAsset: SImageString.list,
    tint: NoorTint.lilac,
  ),
  AdhkarCategory(
    id: 15,
    title: _wuduAdhkarTitle,
    svgAsset: SImageString.wudu,
    tint: NoorTint.mint,
  ),
  AdhkarCategory(
    id: 16,
    title: _homeAdhkarTitle,
    svgAsset: SImageString.home,
    tint: NoorTint.sage,
  ),
  AdhkarCategory(
    id: 17,
    title: _wcAdhkarTitle,
    svgAsset: SImageString.wc,
    tint: NoorTint.amber,
  ),
  AdhkarCategory(
    id: 18,
    title: _mealAdhkarTitle,
    svgAsset: SImageString.meal,
    tint: NoorTint.blue,
  ),
  AdhkarCategory(
    id: 19,
    title: _hajjAdhkarTitle,
    svgAsset: SImageString.kaaba,
    tint: NoorTint.lilac,
  ),
];

String _morningTitle(S s) => s.morning_adhkar;
String _eveningTitle(S s) => s.evening_adhkar;
String _prayerTitle(S s) => s.prayer_adhkar;
String _mosqueTitle(S s) => s.mosque_adhkar;
String _wakeUpTitle(S s) => s.wake_up_adhkar;
String _sleepTitle(S s) => s.sleep_adhkar;
String _afterPrayerTitle(S s) => s.after_prayer_adhkar;
String _tasbeehTitle(S s) => s.tasbeeh;
String _prophetDuaTitle(S s) => s.prophet_dua;
String _quranDuaTitle(S s) => s.quran_dua;
String _prophetsDuaTitle(S s) => s.prophets_dua;
String _generalAdhkarTitle(S s) => s.general_Adhkar;
String _adhanAdhkarTitle(S s) => s.adhan_adhkar;
String _comprehensiveDuaTitle(S s) => s.comprehensive_duaa;
String _wuduAdhkarTitle(S s) => s.wudu_adhkar;
String _homeAdhkarTitle(S s) => s.home_adhkar;
String _wcAdhkarTitle(S s) => s.wc_adhkar;
String _mealAdhkarTitle(S s) => s.meal_adhkar;
String _hajjAdhkarTitle(S s) => s.hajj_adhkar;

AdhkarCategory? categoryForType(int type) {
  for (final category in adhkarCategories) {
    if (category.id == type) return category;
  }
  return null;
}
