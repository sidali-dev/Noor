import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_list_row.dart';
import 'package:noor/core/widgets/noor_pill.dart';
import 'package:noor/core/widgets/noor_progress_bar.dart';
import 'package:noor/core/widgets/noor_radio.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/models/hizb_pages.dart';
import 'package:noor/features/quran/views/widgets/mushaf_frame.dart';
import 'package:noor/features/quran/views/widgets/reciter_picker_sheet.dart';
import 'package:noor/features/quran/views/widgets/surah_line.dart';
import 'package:noor/features/quran/views/widgets/surah_picker_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:quran/quran.dart' as quran;

/// Opens the full-screen collapsible Surah Audio Player.
/// If [surah] is provided and not already playing that surah, playback starts
/// at [startAyah].
Future<void> openSurahPlayer(
  BuildContext context, {
  int? surah,
  int startAyah = 1,
}) async {
  final audio = QuranAudioController.instance;
  if (surah != null) {
    final current = audio.playingAyah.value;
    if (current == null || current.surah != surah) {
      audio.playSurah(surah, startAyah: startAyah);
    } else if (!audio.isPlaying.value) {
      audio.resume();
    }
  } else if (audio.playingAyah.value == null) {
    audio.playSurah(1, startAyah: 1);
  }

  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, animation, secondaryAnimation) =>
          const SurahPlayerView(),
      transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    ),
  );
}

/// Full-screen collapsible Quran audio player:
/// - Swipe down (or tap collapse chevron) to smoothly curve the top edge and
///   collapse into [QuranMiniPlayerBar]
/// - Top center: Surah name + Juz/Page/Reciter metadata
/// - Center (album cover area): Current verse being read with smooth animated
///   transitions between verses + Quick Surah switcher pill
/// - Bottom: Full-surah progress scrubber, -5s / +5s, prev/next verse, and
///   play/pause controls.
class SurahPlayerView extends StatefulWidget {
  const SurahPlayerView({super.key});

  @override
  State<SurahPlayerView> createState() => _SurahPlayerViewState();
}

class _SurahPlayerViewState extends State<SurahPlayerView>
    with SingleTickerProviderStateMixin {
  double _dragOffsetY = 0;
  late final AnimationController _snapBackController;
  Animation<double>? _snapBackAnim;

  @override
  void initState() {
    super.initState();
    _snapBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final anim = _snapBackAnim;
        if (anim != null) {
          setState(() => _dragOffsetY = anim.value);
        }
      });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds.clamp(0, 35999);
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _ayahCounterLabel(BuildContext context, int ayah, int total) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'الآية $ayah من $total';
    if (code == 'fr') return 'Verset $ayah sur $total';
    return 'Verse $ayah of $total';
  }

  String _juzLabel(BuildContext context, int juz) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'ar' ? 'الجزء $juz' : 'Juz $juz';
  }

  String _changeSurahLabel(BuildContext context, int surah) {
    final code = Localizations.localeOf(context).languageCode;
    final ar = 'سورة ${quran.getSurahNameArabic(surah)}';
    final en = quran.getSurahName(surah);
    if (code == 'ar') return '$ar · تغيير السورة';
    if (code == 'fr') return '$en · Changer de sourate';
    return '$en · Change Surah';
  }

  IconData _playModeIcon(QuranPlayMode mode) {
    switch (mode) {
      case QuranPlayMode.continuous:
        return Icons.repeat_rounded;
      case QuranPlayMode.loop:
        return Icons.repeat_one_rounded;
      case QuranPlayMode.stopAtEnd:
        return Icons.stop_circle_outlined;
    }
  }

  String _playModeSheetTitle(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'نمط التشغيل';
    if (code == 'fr') return 'Mode de lecture';
    return 'Playback Mode';
  }

  Future<void> _showPlayModeSheet(
    BuildContext context,
    QuranAudioController audio,
  ) {
    return showNoorSheet(
      context,
      title: _playModeSheetTitle(context),
      builder: (sheetCtx) => Obx(() {
        final active = audio.playMode.value;
        final n = sheetCtx.noor;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < QuranPlayMode.values.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: n.line),
              Builder(builder: (ctx) {
                final mode = QuranPlayMode.values[i];
                final selected = mode == active;
                return NoorListRow(
                  leading: Icon(
                    _playModeIcon(mode),
                    color: selected ? n.brass : n.ink,
                    size: 22,
                  ),
                  title: mode.label(ctx),
                  trailing: NoorRadioMark(selected: selected),
                  onTap: () {
                    audio.setPlayMode(mode);
                    Navigator.of(sheetCtx).pop();
                  },
                );
              }),
            ],
          ],
        );
      }),
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _snapBackController.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final next = (_dragOffsetY + details.delta.dy).clamp(0.0, 650.0);
    setState(() => _dragOffsetY = next);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffsetY > 95 || velocity > 280) {
      Navigator.of(context).pop();
    } else {
      _snapBackAnim = Tween<double>(
        begin: _dragOffsetY,
        end: 0,
      ).animate(
        CurvedAnimation(
          parent: _snapBackController,
          curve: Curves.easeOutCubic,
        ),
      );
      _snapBackController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = QuranAudioController.instance;
    final n = context.noor;
    final outerTheme = Theme.of(context);
    final gutter = NoorLayout.gutter(context);
    // Smoothly curve the top corners as the sheet is dragged downward.
    final topRadius = (_dragOffsetY * 0.38).clamp(0.0, 32.0);

    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: Transform.translate(
        offset: Offset(0, _dragOffsetY),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(topRadius),
            ),
            boxShadow: topRadius > 0.5
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ]
                : const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(topRadius),
            ),
            child: Scaffold(
              backgroundColor: n.paper,
              body: SafeArea(
                child: Obx(() {
                  final current =
                      audio.playingAyah.value ?? (surah: 1, ayah: 1);
                  final surah = current.surah;
                  final ayah = current.ayah;
                  final totalAyahs = quran.getVerseCount(surah);
                  final page = quran.getPageNumber(surah, ayah);
                  final juz = juzOfPage(page);
                  final playing = audio.isPlaying.value;
                  final pos = audio.position.value;
                  final dur = audio.duration.value;
                  final mode = audio.playMode.value;
                  final reciter = reciterByFolder(audio.reciterFolder.value);
                  final verseText =
                      quran.getVerse(surah, ayah, verseEndSymbol: true);
                  final surahAr = 'سورة ${quran.getSurahNameArabic(surah)}';

                  final durMs = dur.inMilliseconds;
                  final posMs =
                      pos.inMilliseconds.clamp(0, durMs > 0 ? durMs : 1);
                  final timeFraction = durMs > 0
                      ? (posMs / durMs).clamp(0.0, 1.0)
                      : (ayah / totalAyahs).clamp(0.0, 1.0);

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: gutter,
                      vertical: NoorSpace.s3,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Bar: Collapse button | Centered Surah Name | Reciter Preferences
                        Row(
                          children: [
                            NoorCloudButton(
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: n.ink,
                                size: 24,
                              ),
                              tooltip: 'Collapse player',
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: NoorSpace.s2),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    surahAr,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: n.ink,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${reciter.label(context)} · ${_juzLabel(context, juz)} · ${S.of(context).page} $page',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: NoorText.bodySm(context),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: NoorSpace.s2),
                            NoorCloudButton(
                              icon: Icon(
                                Icons.record_voice_over_outlined,
                                color: n.ink,
                                size: 20,
                              ),
                              tooltip: 'Reciter preferences',
                              onTap: () =>
                                  showReciterPickerSheet(context, audio),
                            ),
                          ],
                        ),
                        const SizedBox(height: NoorSpace.s4),

                        // Center (Album Cover Area): Animated Verse Card + Quick Surah Switcher Bar
                        Expanded(
                          child: NoorCard(
                            tone: NoorCardTone.night,
                            padding: const EdgeInsets.all(NoorSpace.s5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _ayahCounterLabel(
                                          context, ayah, totalAyahs),
                                      style: NoorText.bodySm(context)
                                          .copyWith(color: n.onWindowMuted),
                                    ),
                                    AyahMarker(ayah),
                                  ],
                                ),
                                const SizedBox(height: NoorSpace.s3),
                                Container(
                                  height: 1,
                                  color: n.brass.withValues(alpha: 0.35),
                                ),
                                Expanded(
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 420),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        final slide = Tween<Offset>(
                                          begin: const Offset(0, 0.12),
                                          end: Offset.zero,
                                        ).animate(animation);
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: slide,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: SingleChildScrollView(
                                        key: ValueKey<String>(
                                            'verse-$surah-$ayah'),
                                        physics: const BouncingScrollPhysics(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: NoorSpace.s4,
                                          ),
                                          child: Text(
                                            verseText,
                                            textAlign: TextAlign.center,
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              fontFamily: 'Quran',
                                              fontSize: 28,
                                              height: 1.85,
                                              color: n.onWindow,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  color: n.brass.withValues(alpha: 0.35),
                                ),
                                const SizedBox(height: NoorSpace.s3),
                                // Restore outerTheme so NoorPill & NoorCloudButton
                                // use dark n.ink on n.card in Light mode instead
                                // of NoorCard.night's overridden white n.onWindow.
                                Theme(
                                  data: outerTheme,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: NoorPill(
                                          label:
                                              _changeSurahLabel(context, surah),
                                          onTap: () => showSurahPickerSheet(
                                              context, audio),
                                          icon: NoorIcon(
                                            NoorGlyph.book,
                                            size: 18,
                                            color: n.ink,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: NoorSpace.s2),
                                      NoorCloudButton(
                                        icon: Icon(
                                          _playModeIcon(mode),
                                          color: n.brass,
                                          size: 20,
                                        ),
                                        tooltip: mode.label(context),
                                        onTap: () =>
                                            _showPlayModeSheet(context, audio),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: NoorSpace.s4),

                        // Scrubber / Progress Bar + Timestamps
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: n.brass,
                            inactiveTrackColor: n.line,
                            thumbColor: n.brass,
                          ),
                          child: Slider(
                            value: timeFraction,
                            onChanged: durMs > 0
                                ? (v) {
                                    final targetMs = (v * durMs).round();
                                    audio.seekTo(
                                        Duration(milliseconds: targetMs));
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: NoorSpace.s2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(pos),
                                style: NoorText.numeral(context, size: 13)
                                    .copyWith(color: n.muted),
                              ),
                              Text(
                                '$ayah / $totalAyahs',
                                style: NoorText.numeral(context, size: 13)
                                    .copyWith(color: n.muted),
                              ),
                              Text(
                                _formatDuration(dur),
                                style: NoorText.numeral(context, size: 13)
                                    .copyWith(color: n.muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NoorSpace.s3),

                        // Transport Controls: Prev Verse | -5s | Play/Pause | +5s | Next Verse
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              NoorCloudButton(
                                icon: Icon(
                                  Icons.skip_previous_rounded,
                                  color: n.ink,
                                  size: 22,
                                ),
                                tooltip: 'Previous verse',
                                onTap: audio.previousVerse,
                              ),
                              NoorCloudButton(
                                icon: Icon(
                                  Icons.replay_5_rounded,
                                  color: n.ink,
                                  size: 22,
                                ),
                                tooltip: '-5 seconds',
                                onTap: () =>
                                    audio.seekBy(const Duration(seconds: -5)),
                              ),
                              GestureDetector(
                                onTap: audio.togglePlayPause,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: n.brass,
                                    boxShadow: [
                                      BoxShadow(
                                        color: n.brass.withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: n.paper,
                                    size: 34,
                                  ),
                                ),
                              ),
                              NoorCloudButton(
                                icon: Icon(
                                  Icons.forward_5_rounded,
                                  color: n.ink,
                                  size: 22,
                                ),
                                tooltip: '+5 seconds',
                                onTap: () =>
                                    audio.seekBy(const Duration(seconds: 5)),
                              ),
                              NoorCloudButton(
                                icon: Icon(
                                  Icons.skip_next_rounded,
                                  color: n.ink,
                                  size: 22,
                                ),
                                tooltip: 'Next verse',
                                onTap: audio.nextVerse,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: NoorSpace.s2),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Collapsed MP3-style audio card positioned right above the bottom nav bar.
/// Leading icon shows the Surah number ([IndexNumber]), and title shows only
/// the Surah name (no `surah:ayah` numbers).
class QuranMiniPlayerBar extends StatelessWidget {
  const QuranMiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = QuranAudioController.instance;
    final n = context.noor;

    return Obx(() {
      final current = audio.playingAyah.value;
      if (current == null || !audio.isFullSurahMode.value) {
        return const SizedBox.shrink();
      }

      final surah = current.surah;
      final ayah = current.ayah;
      final totalAyahs = quran.getVerseCount(surah);
      final playing = audio.isPlaying.value;
      final pos = audio.position.value;
      final dur = audio.duration.value;
      final reciter = reciterByFolder(audio.reciterFolder.value);
      final isAr = Localizations.localeOf(context).languageCode == 'ar';
      final surahName = isAr
          ? 'سورة ${quran.getSurahNameArabic(surah)}'
          : quran.getSurahName(surah);
      final durMs = dur.inMilliseconds;
      final progress = durMs > 0
          ? (pos.inMilliseconds / durMs).clamp(0.0, 1.0)
          : (ayah / totalAyahs).clamp(0.0, 1.0);

      return Material(
        color: n.window,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openSurahPlayer(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NoorProgressBar(
                value: progress,
                showPercent: false,
                onWindow: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NoorSpace.s3,
                  NoorSpace.s2,
                  NoorSpace.s2,
                  NoorSpace.s2,
                ),
                child: Row(
                  children: [
                    IndexNumber(surah),
                    const SizedBox(width: NoorSpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            surahName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NoorText.body(context).copyWith(
                              color: n.onWindow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            reciter.label(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NoorText.bodySm(context)
                                .copyWith(color: n.onWindowMuted),
                          ),
                        ],
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniActionBtn(
                            icon: Icons.replay_5_rounded,
                            color: n.onWindow,
                            tooltip: '-5s',
                            onTap: () =>
                                audio.seekBy(const Duration(seconds: -5)),
                          ),
                          _MiniActionBtn(
                            icon: playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: n.brass,
                            size: 26,
                            tooltip: playing ? 'Pause' : 'Play',
                            onTap: audio.togglePlayPause,
                          ),
                          _MiniActionBtn(
                            icon: Icons.forward_5_rounded,
                            color: n.onWindow,
                            tooltip: '+5s',
                            onTap: () =>
                                audio.seekBy(const Duration(seconds: 5)),
                          ),
                          _MiniActionBtn(
                            icon: Icons.close_rounded,
                            color: n.onWindowMuted,
                            size: 20,
                            tooltip: 'Close player',
                            onTap: audio.stop,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MiniActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final String tooltip;
  final VoidCallback onTap;

  const _MiniActionBtn({
    required this.icon,
    required this.color,
    this.size = 22,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}
