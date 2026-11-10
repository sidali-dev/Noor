import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/widgets/noor_cartouche.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_tasbih.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/controllers/quran_controller.dart';
import 'package:noor/features/quran/controllers/quran_progress.dart';
import 'package:noor/features/quran/models/hizb_pages.dart';
import 'package:noor/features/quran/models/mushaf_data.dart';
import 'package:noor/features/quran/views/widgets/ayah_action_sheet.dart';
import 'package:noor/features/quran/views/widgets/mushaf_frame.dart';
import 'package:noor/features/quran/views/widgets/reciter_picker_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:quran/quran.dart' as quran;

class ReadQuranView extends StatefulWidget {
  final int pageIndex;
  final int? initialSurah;
  final int? initialAyah;

  const ReadQuranView({
    super.key,
    int? pageIndex,
    int? surahIndex,
    this.initialSurah,
    this.initialAyah,
  }) : pageIndex = pageIndex ?? surahIndex ?? 0;

  @override
  State<ReadQuranView> createState() => _ReadQuranScreenState();
}

class _ReadQuranScreenState extends State<ReadQuranView> {
  late int _currentPage;
  late final PageController _pageController;
  late final QuranAudioController _audio;
  bool _ownsAudio = false;
  Timer? _dwellTimer;
  bool _showChrome = false;
  ({int surah, int ayah})? _selectedAyah;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.pageIndex.clamp(0, quran.totalPagesCount - 1);
    _pageController = PageController(initialPage: _currentPage);
    if (widget.initialSurah != null && widget.initialAyah != null) {
      _selectedAyah = (surah: widget.initialSurah!, ayah: widget.initialAyah!);
    }
    if (Get.isRegistered<QuranAudioController>()) {
      _audio = Get.find<QuranAudioController>();
    } else {
      _audio = Get.put(QuranAudioController());
      _ownsAudio = true;
    }
    _audio.onPageTurnRequested = (nextPage) {
      if (!mounted) return;
      final targetIndex = (nextPage - 1).clamp(0, quran.totalPagesCount - 1);
      if (targetIndex != _currentPage) {
        _goToPage(targetIndex);
      }
    };
    _startDwellTimer(_currentPage + 1);
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _audio.onPageTurnRequested = null;
    if (_ownsAudio) {
      Get.delete<QuranAudioController>();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _startDwellTimer(int page) {
    _dwellTimer?.cancel();
    _dwellTimer = Timer(const Duration(seconds: 5), () async {
      await QuranProgress.markRead(page);
      if (Get.isRegistered<QuranController>()) {
        Get.find<QuranController>().refreshProgress();
      }
    });
  }

  void _onPageChanged(int index) {
    _dwellTimer?.cancel();
    _currentPage = index;
    final page = index + 1;
    AppPrefs.setLastReadPage(page);
    if (Get.isRegistered<QuranController>()) {
      Get.find<QuranController>().refreshProgress();
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
    if (Get.isRegistered<QuranController>()) {
      Get.find<QuranController>().refreshProgress();
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

  void _onAyahTap(int surah, int ayah) {
    setState(() {
      _selectedAyah = (surah: surah, ayah: ayah);
    });
    showAyahActionSheet(
      context,
      surah: surah,
      ayah: ayah,
      audio: _audio,
      onBookmarkChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _togglePageAudio(int pageNumber) async {
    if (_audio.isPlaying.value) {
      await _audio.pause();
      return;
    }
    final active = _audio.playingAyah.value ?? _selectedAyah;
    if (active != null &&
        quran.getPageNumber(active.surah, active.ayah) == pageNumber) {
      await _audio.playVerse(active.surah, active.ayah);
      return;
    }
    final first = quran.getPageData(pageNumber).first;
    final s = first['surah'] as int;
    final v = first['start'] as int;
    setState(() {
      _selectedAyah = (surah: s, ayah: v);
    });
    await _audio.playVerse(s, v);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final pageNumber = _currentPage + 1;
    final isBookmarked = AppPrefs.bookmarks.contains(pageNumber);
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
                child: _chrome(
                  context,
                  hiddenOffset: const Offset(0, -1),
                  child: Directionality(
                    textDirection: appDirection,
                    child: _buildTopBar(context, pageNumber, isBookmarked),
                  ),
                ),
              ),
              Positioned(
                bottom: NoorSpace.s2,
                left: 0,
                right: 0,
                child: _chrome(
                  context,
                  hiddenOffset: const Offset(0, 1.2),
                  child: _buildBottomBar(context, pageNumber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Floating reader chrome: slides in from its edge while fading, and back out.
  Widget _chrome(
    BuildContext context, {
    required Offset hiddenOffset,
    required Widget child,
  }) {
    final duration = noorDuration(
      context,
      Duration(milliseconds: _showChrome ? 320 : 240),
    );
    final curve = _showChrome ? Curves.easeOutCubic : Curves.easeInCubic;
    return IgnorePointer(
      ignoring: !_showChrome,
      child: AnimatedSlide(
        offset: _showChrome ? Offset.zero : hiddenOffset,
        duration: duration,
        curve: curve,
        child: AnimatedOpacity(
          opacity: _showChrome ? 1.0 : 0.0,
          duration: duration,
          curve: curve,
          child: child,
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: NoorLayout.gutter(context),
        vertical: NoorSpace.s1,
      ),
      child: Row(
        children: [
          NoorCloudButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: S.of(context).back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: NoorSpace.s1),
          Expanded(
            child: NoorCartouche.title(
              surahName,
              onTap: () => _showHizb(context, pageNumber),
            ),
          ),
          const SizedBox(width: NoorSpace.s1),
          Obx(() {
            final playing = _audio.isPlaying.value;
            return GestureDetector(
              onLongPress: () => showReciterPickerSheet(context, _audio),
              child: NoorCloudButton(
                icon: Icon(
                  playing ? Iconsax.pause : Iconsax.volume_high,
                  size: 18,
                  color: playing ? n.brass : n.ink,
                ),
                tooltip: reciterSheetTitle(context),
                onTap: () => _togglePageAudio(pageNumber),
              ),
            );
          }),
          const SizedBox(width: NoorSpace.s1),
          NoorCloudButton(
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

  static const double _counterSize = 64;

  void _showHizb(BuildContext context, int pageNumber) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final hizb = hizbOfPage(pageNumber);
    final juz = juzOfPage(pageNumber);
    final surahId =
        quran.getPageData(hizbStartPage(hizb)).first["surah"] as int;
    final name =
        isAr ? quran.getSurahNameArabic(surahId) : quran.getSurahName(surahId);
    final juzLabel = isAr ? 'الجزء' : 'Juz';
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.only(
            left: NoorLayout.gutter(context),
            right: NoorLayout.gutter(context),
            bottom: _counterSize + 2 * NoorSpace.s4,
          ),
          content: NoorCartouche.title(
            '$juzLabel $juz · ${S.of(context).hizb} $hizb · $name',
          ),
        ),
      );
  }

  Widget _buildBottomBar(BuildContext context, int pageNumber) {
    final page = S.of(context).page;
    final hasPrev = _currentPage > 0;
    final hasNext = _currentPage < quran.totalPagesCount - 1;
    final (first, last) = juzPagesOf(pageNumber);
    return NoorCounterRow(
      counter: TasbihCloud(
        size: _counterSize,
        accent: false,
        total: last - first + 1,
        said: pageNumber - first + 1,
        label: '$pageNumber',
        onTap: () => _showHizb(context, pageNumber),
      ),
      previousTooltip: '$page ${pageNumber - 1}',
      nextTooltip: '$page ${pageNumber + 1}',
      onPrevious: hasPrev ? () => _goToPage(_currentPage - 1) : null,
      onNext: hasNext ? () => _goToPage(_currentPage + 1) : null,
    );
  }

  Widget _buildPageContent(BuildContext context, int pageNumber) {
    final pageData = MushafData.page(pageNumber);
    final isSpecialPage = pageNumber <= 2;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NoorSpace.s4,
            vertical: NoorSpace.s1,
          ),
          child: Obx(() {
            final activeAudio = _audio.playingAyah.value;
            final activeAyah = activeAudio ?? _selectedAyah;

            final lineWidgets = <Widget>[
              for (final line in pageData.lines)
                Expanded(
                  flex: line.type == MushafLineType.surahHeader ? 13 : 10,
                  child: Center(
                    child: _MushafLineWidget(
                      line: line,
                      activeAyah: activeAyah,
                      onAyahTap: _onAyahTap,
                    ),
                  ),
                ),
            ];

            if (isSpecialPage) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 15),
                  ...lineWidgets,
                  const Spacer(flex: 15),
                ],
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: lineWidgets,
            );
          }),
        ),
      ),
    );
  }
}

class _MushafLineWidget extends StatefulWidget {
  final MushafLine line;
  final ({int surah, int ayah})? activeAyah;
  final void Function(int surah, int ayah) onAyahTap;

  const _MushafLineWidget({
    required this.line,
    required this.activeAyah,
    required this.onAyahTap,
  });

  @override
  State<_MushafLineWidget> createState() => _MushafLineWidgetState();
}

class _MushafLineWidgetState extends State<_MushafLineWidget> {
  final List<LongPressGestureRecognizer> _recognizers = [];
  final GlobalKey _textKey = GlobalKey();
  final List<({int start, int end, int surah, int ayah})> _ranges = [];
  Duration? _lastTapTimeStamp;
  Offset? _lastTapPos;

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  LongPressGestureRecognizer _longPressRecognizerFor(int surah, int ayah) {
    final r = LongPressGestureRecognizer()
      ..onLongPress = () => widget.onAyahTap(surah, ayah);
    _recognizers.add(r);
    return r;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (widget.line.segments.isEmpty) return;
    final prevTs = _lastTapTimeStamp;
    final prevPos = _lastTapPos;
    if (prevTs != null && prevPos != null) {
      final dt = event.timeStamp - prevTs;
      final dist = (event.position - prevPos).distance;
      if (dt >= Duration.zero &&
          dt <= const Duration(milliseconds: 350) &&
          dist < 36) {
        _lastTapTimeStamp = null;
        _lastTapPos = null;
        final seg = _resolveSegmentAt(event.position);
        widget.onAyahTap(seg.surah, seg.ayah);
        return;
      }
    }
    _lastTapTimeStamp = event.timeStamp;
    _lastTapPos = event.position;
  }

  ({int surah, int ayah}) _resolveSegmentAt(Offset globalPos) {
    final segs = widget.line.segments;
    if (segs.length == 1) {
      return (surah: segs.first.surah, ayah: segs.first.ayah);
    }
    final ro = _textKey.currentContext?.findRenderObject();
    RenderParagraph? paragraph;
    if (ro is RenderParagraph) {
      paragraph = ro;
    } else if (ro != null) {
      void visit(RenderObject node) {
        if (paragraph != null) return;
        if (node is RenderParagraph) {
          paragraph = node;
          return;
        }
        node.visitChildren(visit);
      }

      ro.visitChildren(visit);
    }
    if (paragraph != null) {
      final local = paragraph!.globalToLocal(globalPos);
      final pos = paragraph!.getPositionForOffset(local);
      for (final r in _ranges) {
        if (pos.offset >= r.start && pos.offset <= r.end) {
          return (surah: r.surah, ayah: r.ayah);
        }
      }
    }
    return (surah: segs.first.surah, ayah: segs.first.ayah);
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    _ranges.clear();

    final n = context.noor;
    final line = widget.line;

    if (line.type == MushafLineType.surahHeader) {
      final surah = line.surah ?? 1;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: SurahCartouche(
          name: 'سورة ${quran.getSurahNameArabic(surah)}',
        ),
      );
    }

    if (line.type == MushafLineType.basmala) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          quran.basmala,
          maxLines: 1,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontFamily: 'Quran',
            fontSize: 20,
            color: n.ink,
            height: 1.2,
          ),
        ),
      );
    }

    final spans = <InlineSpan>[];
    var charOffset = 0;
    for (var i = 0; i < line.segments.length; i++) {
      final seg = line.segments[i];
      final start = charOffset;
      final isHighlighted = widget.activeAyah != null &&
          widget.activeAyah!.surah == seg.surah &&
          widget.activeAyah!.ayah == seg.ayah;
      final highlightBg = isHighlighted ? n.brassSoft : null;

      spans.add(
        TextSpan(
          text: seg.text,
          recognizer: _longPressRecognizerFor(seg.surah, seg.ayah),
          style: highlightBg != null
              ? TextStyle(backgroundColor: highlightBg)
              : null,
        ),
      );
      charOffset += seg.text.length;

      if (seg.isEnd) {
        spans.add(
          TextSpan(
            text: ' ',
            style: highlightBg != null
                ? TextStyle(backgroundColor: highlightBg)
                : null,
          ),
        );
        charOffset += 1;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => widget.onAyahTap(seg.surah, seg.ayah),
              child: AyahMarker(seg.ayah),
            ),
          ),
        );
        charOffset += 1;
      }

      _ranges.add((
        start: start,
        end: charOffset,
        surah: seg.surah,
        ayah: seg.ayah,
      ));

      if (i < line.segments.length - 1) {
        spans.add(const TextSpan(text: ' '));
        charOffset += 1;
      }
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: _handlePointerUp,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(children: spans),
          key: _textKey,
          maxLines: 1,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontFamily: 'Quran',
            fontSize: 22,
            height: 1.25,
            color: n.ink,
          ),
        ),
      ),
    );
  }
}
