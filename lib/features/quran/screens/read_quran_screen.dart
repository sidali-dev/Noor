import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
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
                    child: _buildTopBar(context, pageNumber, isBookmarked),
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

  Widget _buildTopBar(
      BuildContext context, int pageNumber, bool isBookmarked) {
    final n = context.noor;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final surahId = quran.getPageData(pageNumber).first["surah"] as int;
    final surahName = isAr
        ? quran.getSurahNameArabic(surahId)
        : quran.getSurahName(surahId);

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
              Icons.arrow_forward_rounded, // Mirrored back arrow in RTL
              color: n.ink,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: NoorSpace.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surahName,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: n.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${S.of(context).page} $pageNumber",
                  style: NoorText.meta(context).copyWith(fontSize: 12),
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
            onPressed: _toggleBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int pageNumber) {
    final n = context.noor;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NoorSpace.lg,
          vertical: NoorSpace.xs,
        ),
        decoration: BoxDecoration(
          color: n.card.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: n.line),
          boxShadow: noorShadow(context),
        ),
        child: Text(
          '$pageNumber',
          style: NoorText.numeral(context, size: 14, color: n.muted),
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, int pageNumber) {
    final n = context.noor;
    final pageData = quran.getPageData(pageNumber);
    final spans = <InlineSpan>[];

    for (var i = 0; i < pageData.length; i++) {
      final data = pageData[i];
      final surah = data["surah"] as int;
      final start = data["start"] as int;
      final end = data["end"] as int;

      if (start == 1) {
        if (spans.isNotEmpty) {
          spans.add(const TextSpan(text: '\n\n'));
        }
        spans.add(
          TextSpan(
            text: 'سورة ${quran.getSurahNameArabic(surah)}\n',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: n.gold,
              height: 2.2,
            ),
          ),
        );
        if (surah != 1 && surah != 9) {
          spans.add(
            TextSpan(
              text: '${quran.basmala}\n',
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

      spans.add(
        TextSpan(
          text: buf.toString(),
          style: TextStyle(
            fontFamily: 'Quran',
            fontSize: 22,
            height: 2.0,
            color: n.ink,
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NoorSpace.xl,
          vertical: 56,
        ),
        child: Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
