import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';

typedef SStringGetter = String Function(S s);

class AdhkarCategory {
  final int id;
  final SStringGetter title;
  final String svgAsset;

  const AdhkarCategory({
    required this.id,
    required this.title,
    required this.svgAsset,
  });
}

const List<AdhkarCategory> adhkarCategories = [
  AdhkarCategory(
    id: 1,
    title: _morningTitle,
    svgAsset: SImageString.sunrise,
  ),
  AdhkarCategory(
    id: 2,
    title: _eveningTitle,
    svgAsset: SImageString.sunset,
  ),
  AdhkarCategory(
    id: 3,
    title: _prayerTitle,
    svgAsset: SImageString.prayingMan,
  ),
  AdhkarCategory(
    id: 4,
    title: _mosqueTitle,
    svgAsset: SImageString.masjid,
  ),
  AdhkarCategory(
    id: 5,
    title: _wakeUpTitle,
    svgAsset: SImageString.alarm,
  ),
  AdhkarCategory(
    id: 6,
    title: _sleepTitle,
    svgAsset: SImageString.night,
  ),
  AdhkarCategory(
    id: 7,
    title: _afterPrayerTitle,
    svgAsset: SImageString.prayingMan,
  ),
  AdhkarCategory(
    id: 8,
    title: _tasbeehTitle,
    svgAsset: SImageString.tasbih,
  ),
  AdhkarCategory(
    id: 9,
    title: _prophetDuaTitle,
    svgAsset: SImageString.prophetName,
  ),
  AdhkarCategory(
    id: 10,
    title: _quranDuaTitle,
    svgAsset: SImageString.quran,
  ),
  AdhkarCategory(
    id: 11,
    title: _prophetsDuaTitle,
    svgAsset: SImageString.group,
  ),
  AdhkarCategory(
    id: 12,
    title: _generalAdhkarTitle,
    svgAsset: SImageString.group,
  ),
  AdhkarCategory(
    id: 13,
    title: _adhanAdhkarTitle,
    svgAsset: SImageString.adhan,
  ),
  AdhkarCategory(
    id: 14,
    title: _comprehensiveDuaTitle,
    svgAsset: SImageString.list,
  ),
  AdhkarCategory(
    id: 15,
    title: _wuduAdhkarTitle,
    svgAsset: SImageString.wudu,
  ),
  AdhkarCategory(
    id: 16,
    title: _homeAdhkarTitle,
    svgAsset: SImageString.home,
  ),
  AdhkarCategory(
    id: 17,
    title: _wcAdhkarTitle,
    svgAsset: SImageString.wc,
  ),
  AdhkarCategory(
    id: 18,
    title: _mealAdhkarTitle,
    svgAsset: SImageString.meal,
  ),
  AdhkarCategory(
    id: 19,
    title: _hajjAdhkarTitle,
    svgAsset: SImageString.kaaba,
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
