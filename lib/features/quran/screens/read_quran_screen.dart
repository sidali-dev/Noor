import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/widgets/mushaf_frame.dart';
import 'package:noor/generals/widgets/noor_pager_pill.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
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
        duration: const Duration(milliseconds: 250),
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
        backgroundColor: n.mushaf,
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
                    return _buildPageContent(context, index + 1);
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showChrome ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
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
              Positioned(
                bottom: NoorSpace.md,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _showChrome ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
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

    return Container(
      decoration: BoxDecoration(
        color: n.mushaf.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: n.line.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.md,
        vertical: NoorSpace.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded, // mirrors itself in RTL
              color: n.ink,
              size: 24,
            ),
            tooltip: S.of(context).back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: NoorSpace.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surahName,
                  style: NoorText.rowTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${S.of(context).page} $pageNumber",
                  style: NoorText.meta(context),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: NoorSpace.sm),
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked ? n.gold : n.muted,
              size: 24,
            ),
            tooltip: S.of(context).bookmark,
            onPressed: _toggleBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int pageNumber) {
    final page = S.of(context).page;
    final hasPrev = _currentPage > 0;
    final hasNext = _currentPage < quran.totalPagesCount - 1;
    // The pill sits in the reader's RTL Directionality, so "previous" is at
    // the start (right) and "next" at the end (left): left = next page (U7).
    return Center(
      child: NoorPagerPill(
        split: true,
        label: '$pageNumber',
        previousTooltip: '$page ${pageNumber - 1}',
        nextTooltip: '$page ${pageNumber + 1}',
        onPrevious: hasPrev ? () => _goToPage(_currentPage - 1) : null,
        onNext: hasNext ? () => _goToPage(_currentPage + 1) : null,
      ),
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
        if (children.isNotEmpty) children.add(const SizedBox(height: 44));
        children.add(
          SurahCartouche(name: 'سورة ${quran.getSurahNameArabic(surah)}'),
        );
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

      final buf = StringBuffer();
      for (int v = start; v <= end; v++) {
        buf.write(quran.getVerse(surah, v, verseEndSymbol: true));
        if (v < end) buf.write(' ');
      }

      children.add(
        Text(
          buf.toString(),
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

    // Frame margins + padding add up to the old 20 / 56 / 88, so the text
    // keeps its width and clears the top bar and the pager pill.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NoorSpace.sm,
        NoorSpace.sm,
        NoorSpace.sm,
        NoorSpace.sm,
      ),
      child: MushafFrame(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NoorSpace.md,
              48,
              NoorSpace.md,
              72,
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
