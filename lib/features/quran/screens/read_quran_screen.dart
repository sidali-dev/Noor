import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/widgets/mushaf_frame.dart';
import 'package:noor/generals/widgets/noor_cartouche.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_tasbih.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

class ReadQuranScreen extends StatefulWidget {
  final int pageIndex;

  const ReadQuranScreen({
    super.key,
    int? pageIndex,
    int? surahIndex,
  }) : pageIndex = pageIndex ?? surahIndex ?? 0;

  @override
  State<ReadQuranScreen> createState() => _ReadQuranScreenState();
}

class _ReadQuranScreenState extends State<ReadQuranScreen> {
  late int _currentPage;
  late final PageController _pageController;
  Timer? _dwellTimer;
  bool _showChrome = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.pageIndex.clamp(0, quran.totalPagesCount - 1);
    _pageController = PageController(initialPage: _currentPage);
    _startDwellTimer(_currentPage + 1);
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startDwellTimer(int page) {
    _dwellTimer?.cancel();
    _dwellTimer = Timer(const Duration(seconds: 5), () async {
      await QuranProgress.markRead(page);
      if (Get.isRegistered<QuranScreenController>()) {
        Get.find<QuranScreenController>().refreshProgress();
      }
    });
  }

  void _onPageChanged(int index) {
    _dwellTimer?.cancel();
    _currentPage = index;
    final page = index + 1;
    AppPrefs.setLastReadPage(page);
    if (Get.isRegistered<QuranScreenController>()) {
      Get.find<QuranScreenController>().refreshProgress();
    }
    _startDwellTimer(page);
    setState(() {});
  }

  Future<void> _toggleBookmark() async {
    final page = _currentPage + 1;
    final list = List<int>.from(AppPrefs.bookmarks);
    if (list.contains(page)) {
      list.remove(page);
    } else {
      list.add(page);
      list.sort();
    }
    await AppPrefs.setBookmarks(list);
    setState(() {});
    if (Get.isRegistered<QuranScreenController>()) {
      Get.find<QuranScreenController>().refreshProgress();
    }
  }

  void _goToPage(int index) => _pageController.animateToPage(
        index,
        duration: noorDuration(context, const Duration(milliseconds: 220)),
        curve: Curves.easeOutCubic,
      );

  void _toggleChrome() {
    setState(() {
      _showChrome = !_showChrome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final pageNumber = _currentPage + 1;
    final isBookmarked = AppPrefs.bookmarks.contains(pageNumber);
    // The page and pager are always RTL; the top bar follows the app language.
    final appDirection = Directionality.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: n.paper,
        body: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleChrome,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: quran.totalPagesCount,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    return NoorColumn(
                      child: _buildPageContent(context, index + 1),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showChrome ? 1.0 : 0.0,
                  duration:
                      noorDuration(context, const Duration(milliseconds: 200)),
                  curve: Curves.easeOutCubic,
                  child: IgnorePointer(
                    ignoring: !_showChrome,
                    child: Directionality(
                      textDirection: appDirection,
                      child: _buildTopBar(context, pageNumber, isBookmarked),
                    ),
                  ),
                ),
              ),
              // The counter's top meets the page's text limit: it covers no ayah.
              Positioned(
                bottom: NoorSpace.s2,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showChrome ? 1.0 : 0.0,
                  duration:
                      noorDuration(context, const Duration(milliseconds: 200)),
                  curve: Curves.easeOutCubic,
                  child: IgnorePointer(
                    ignoring: !_showChrome,
                    child: _buildBottomBar(context, pageNumber),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int pageNumber, bool isBookmarked) {
    final n = context.noor;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final surahId = quran.getPageData(pageNumber).first["surah"] as int;
    final surahName =
        isAr ? quran.getSurahNameArabic(surahId) : quran.getSurahName(surahId);

    // The page number is on the counter below, up at the same moment. The
    // strip keeps the page's ribbon and first line out from between the puffs.
    return Container(
      decoration: BoxDecoration(color: n.card, boxShadow: n.shadow1),
      padding: EdgeInsets.symmetric(
        horizontal: NoorLayout.gutter(context),
        vertical: NoorSpace.s1,
      ),
      child: Row(
        children: [
          NoorCloudButton(
            icon: const Icon(Icons.arrow_back_rounded), // mirrors itself in RTL
            tooltip: S.of(context).back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: NoorSpace.s2),
          Expanded(child: NoorCartouche.title(surahName)),
          const SizedBox(width: NoorSpace.s2),
          NoorCloudButton(
            // Saved: brass on a brassSoft disc, so the state is not colour alone.
            icon: DecoratedBox(
              decoration: BoxDecoration(
                color: isBookmarked ? n.brassSoft : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 28,
                child: Center(
                  child: NoorIcon(
                    NoorGlyph.bookmark,
                    color: isBookmarked ? n.brass : n.muted,
                    size: 20,
                  ),
                ),
              ),
            ),
            tooltip: S.of(context).bookmark,
            onTap: _toggleBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int pageNumber) {
    final page = S.of(context).page;
    final hasPrev = _currentPage > 0;
    final hasNext = _currentPage < quran.totalPagesCount - 1;
    // The row sits in the reader's RTL Directionality, so "previous" is at
    // the start (right) and "next" at the end (left): left = next page (U7).
    // The page's brass is the bookmark, so the thread has none of its own.
    return NoorCounterRow(
      counter: TasbihCloud(
        size: 64,
        accent: false,
        total: quran.totalPagesCount,
        said: pageNumber,
        label: '$pageNumber',
      ),
      previousTooltip: '$page ${pageNumber - 1}',
      nextTooltip: '$page ${pageNumber + 1}',
      onPrevious: hasPrev ? () => _goToPage(_currentPage - 1) : null,
      onNext: hasNext ? () => _goToPage(_currentPage + 1) : null,
    );
  }

  Widget _buildPageContent(BuildContext context, int pageNumber) {
    final n = context.noor;
    final pageData = quran.getPageData(pageNumber);
    final children = <Widget>[];

    for (final data in pageData) {
      final surah = data["surah"] as int;
      final start = data["start"] as int;
      final end = data["end"] as int;

      if (start == 1) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: NoorSpace.s7));
        }
        children.add(
          SurahCartouche(name: 'سورة ${quran.getSurahNameArabic(surah)}'),
        );
        children.add(const SizedBox(height: NoorSpace.s4));
        if (surah != 1 && surah != 9) {
          children.add(
            Text(
              quran.basmala,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quran',
                fontSize: 20,
                color: n.ink,
                height: 2.0,
              ),
            ),
          );
        }
      }

      // The package's end sign is swapped for AyahMarker; the verse text
      // itself is untouched.
      children.add(
        Text.rich(
          TextSpan(
            children: [
              for (var v = start; v <= end; v++) ...[
                TextSpan(text: quran.getVerse(surah, v)),
                const TextSpan(text: ' '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: AyahMarker(v),
                ),
                if (v < end) const TextSpan(text: ' '),
              ],
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Quran',
            fontSize: 22,
            height: 2.0,
            color: n.ink,
          ),
        ),
      );
    }

    // The page sits on the ground with a small margin; the text clears the
    // hairline frame and, by the frame's own margins, the corner stars, the
    // foot and the pager pill.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NoorSpace.s2,
        NoorSpace.s2,
        NoorSpace.s2,
        NoorSpace.s2,
      ),
      child: MushafFrame(
        pageNumber: pageNumber,
        bookmarked: AppPrefs.bookmarks.contains(pageNumber),
        footVisible: !_showChrome,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NoorSpace.s5,
              NoorSpace.s4,
              NoorSpace.s5,
              NoorSpace.s4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
