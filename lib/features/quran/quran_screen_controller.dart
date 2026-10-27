import 'package:get/get.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/text_normalize.dart';
import 'package:quran/quran.dart' as quran;

class QuranScreenController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxInt lastReadPageNumber = 1.obs;
  final RxInt progressRevision = 0.obs;

  late final RxString lastReadSurah;
  late final RxString lastReadSurahArabic;

  @override
  void onInit() {
    super.onInit();
    final page = AppPrefs.lastReadPage;
    lastReadPageNumber.value = page;

    final initialSurah = quran.getPageData(page).first["surah"] as int;
    lastReadSurah = quran.getSurahName(initialSurah).obs;
    lastReadSurahArabic = quran.getSurahNameArabic(initialSurah).obs;
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  void setQuery(String q) {
    searchQuery.value = q;
  }

  void refreshProgress() {
    final page = AppPrefs.lastReadPage;
    lastReadPageNumber.value = page;

    final surah = quran.getPageData(page).first["surah"] as int;
    lastReadSurah.value = quran.getSurahName(surah);
    lastReadSurahArabic.value = quran.getSurahNameArabic(surah);

    progressRevision.value++;
  }

  void updateLastSurahRead() => refreshProgress();
  void updateLastPageRead() => refreshProgress();

  List<int> get filteredSurahs {
    final q = searchQuery.value.trim();
    if (q.isEmpty) {
      return List<int>.generate(114, (i) => i + 1);
    }
    return [
      for (var s = 1; s <= 114; s++)
        if (matchesQuery(quran.getSurahNameArabic(s), q) ||
            matchesQuery(quran.getSurahName(s), q) ||
            matchesQuery(s.toString(), q))
          s,
    ];
  }

  List<int> get filteredHizbs {
    final q = searchQuery.value.trim();
    if (q.isEmpty) {
      return List<int>.generate(60, (i) => i + 1);
    }
    return [
      for (var h = 1; h <= 60; h++)
        if (matchesQuery(h.toString(), q)) h,
    ];
  }
}
