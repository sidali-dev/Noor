import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/generated/l10n.dart';

typedef SStringGetter = String Function(S s);

class AdhkarCategory {
  final int id;
  final SStringGetter title;
  final NoorGlyph glyph;

  const AdhkarCategory({
    required this.id,
    required this.title,
    required this.glyph,
  });
}

const List<AdhkarCategory> adhkarCategories = [
  AdhkarCategory(
    id: 1,
    title: _morningTitle,
    glyph: NoorGlyph.sunrise,
  ),
  AdhkarCategory(
    id: 2,
    title: _eveningTitle,
    glyph: NoorGlyph.sunset,
  ),
  AdhkarCategory(
    id: 3,
    title: _prayerTitle,
    glyph: NoorGlyph.prayerRug,
  ),
  AdhkarCategory(
    id: 4,
    title: _mosqueTitle,
    glyph: NoorGlyph.mosque,
  ),
  AdhkarCategory(
    id: 5,
    title: _wakeUpTitle,
    glyph: NoorGlyph.alarm,
  ),
  AdhkarCategory(
    id: 6,
    title: _sleepTitle,
    glyph: NoorGlyph.moon,
  ),
  AdhkarCategory(
    id: 7,
    title: _afterPrayerTitle,
    glyph: NoorGlyph.prayerDone,
  ),
  AdhkarCategory(
    id: 8,
    title: _tasbeehTitle,
    glyph: NoorGlyph.tasbih,
  ),
  AdhkarCategory(
    id: 9,
    title: _prophetDuaTitle,
    glyph: NoorGlyph.saying,
  ),
  AdhkarCategory(
    id: 10,
    title: _quranDuaTitle,
    glyph: NoorGlyph.book,
  ),
  AdhkarCategory(
    id: 11,
    title: _prophetsDuaTitle,
    glyph: NoorGlyph.scroll,
  ),
  AdhkarCategory(
    id: 12,
    title: _generalAdhkarTitle,
    glyph: NoorGlyph.star,
  ),
  AdhkarCategory(
    id: 13,
    title: _adhanAdhkarTitle,
    glyph: NoorGlyph.minaret,
  ),
  AdhkarCategory(
    id: 14,
    title: _comprehensiveDuaTitle,
    glyph: NoorGlyph.list,
  ),
  AdhkarCategory(
    id: 15,
    title: _wuduAdhkarTitle,
    glyph: NoorGlyph.drop,
  ),
  AdhkarCategory(
    id: 16,
    title: _homeAdhkarTitle,
    glyph: NoorGlyph.home,
  ),
  AdhkarCategory(
    id: 17,
    title: _wcAdhkarTitle,
    glyph: NoorGlyph.door,
  ),
  AdhkarCategory(
    id: 18,
    title: _mealAdhkarTitle,
    glyph: NoorGlyph.meal,
  ),
  AdhkarCategory(
    id: 19,
    title: _hajjAdhkarTitle,
    glyph: NoorGlyph.kaaba,
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
