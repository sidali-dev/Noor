import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/routes/app_routes.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/widgets/empty_state.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_hero.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_list_row.dart';
import 'package:noor/core/widgets/noor_progress_bar.dart';
import 'package:noor/core/widgets/noor_search_field.dart';
import 'package:noor/core/widgets/noor_segmented.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/controllers/quran_controller.dart';
import 'package:noor/features/quran/controllers/quran_progress.dart';
import 'package:noor/features/quran/controllers/quran_search.dart';
import 'package:noor/features/quran/models/hizb_pages.dart';
import 'package:noor/features/quran/views/surah_player_view.dart';
import 'package:noor/features/quran/views/widgets/bookmarks_sheet.dart';
import 'package:noor/features/quran/views/widgets/reciter_picker_sheet.dart';
import 'package:noor/features/quran/views/widgets/surah_line.dart';
import 'package:noor/generated/l10n.dart';
import 'package:quran/quran.dart' as quran;

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  String _inQuranTextHeading(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'في آيات القرآن';
    if (code == 'fr') return 'Dans les versets';
    return 'In the verses';
  }

  String _juzWord(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return code == 'ar' ? 'الجزء' : 'Juz';
  }

  String _lastListenedLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'آخر استماع';
    if (code == 'fr') return 'Dernière écoute';
    return 'Last listened';
  }

  String _ayahWord(BuildContext context, int ayah) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'الآية $ayah';
    if (code == 'fr') return 'Verset $ayah';
    return 'Ayah $ayah';
  }

  String _continueListeningLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'متابعة الاستماع';
    if (code == 'fr') return 'Continuer l’écoute';
    return 'Continue listening';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuranController>();
    final audio = QuranAudioController.instance;
    final n = context.noor;
    final gutter = NoorLayout.gutter(context);
    final navTopOffset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: n.paper,
      body: Stack(
        children: [
          Obx(() {
            controller.progressRevision.value;
            controller.searchQuery.value;
            final tabIndex = controller.currentIndex.value;
            final hits = controller.ayahHits;
            final hasMiniPlayer =
                audio.playingAyah.value != null && audio.isFullSurahMode.value;
            final bottomPad =
                navTopOffset + (hasMiniPlayer ? 88.0 : NoorSpace.s4);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NoorHero(
                        art: NoorArt.heroQuran,
                        settings: true,
                        title: S.of(context).nav_quran,
                        subtitle: S.of(context).tagline_quran,
                        overlap: NoorSearchField(
                          hint: S.of(context).search_surah,
                          onChanged: controller.setQuery,
                        ),
                      ),
                      NoorSettle(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (controller.lastReadPageNumber.value > 1 ||
                                  QuranProgress.readCount > 0) ...[
                                const SizedBox(height: NoorSpace.s4),
                                _buildContinueReadingCard(
                                  context,
                                  controller,
                                ),
                              ],
                              if (audio.lastListened.value != null) ...[
                                const SizedBox(height: NoorSpace.s3),
                                _buildContinueListeningCard(
                                  context,
                                  audio,
                                ),
                              ],
                              if (controller.lastReadPageNumber.value <= 1 &&
                                  QuranProgress.readCount == 0 &&
                                  audio.lastListened.value == null) ...[
                                const SizedBox(height: NoorSpace.s3),
                                _buildTopQuickActions(context, audio),
                              ],
                              const SizedBox(height: NoorSpace.s4),
                              NoorSegmented<int>(
                                items: [
                                  (value: 0, label: S.of(context).surah),
                                  (value: 1, label: S.of(context).hizb),
                                ],
                                value: tabIndex,
                                onChanged: controller.changeIndex,
                              ),
                              const SizedBox(height: NoorSpace.s3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: gutter,
                    right: gutter,
                    bottom: hits.isEmpty ? bottomPad : NoorSpace.s4,
                  ),
                  sliver: tabIndex == 0
                      ? _buildSurahList(
                          context,
                          controller,
                          audio,
                          hits.isNotEmpty,
                        )
                      : _buildHizbList(context, controller, hits.isNotEmpty),
                ),
                if (hits.isNotEmpty) ...[
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: NoorSpace.s2,
                          bottom: NoorSpace.s3,
                        ),
                        child: Text(
                          _inQuranTextHeading(context),
                          style: NoorText.heading(context),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: gutter,
                      right: gutter,
                      bottom: bottomPad,
                    ),
                    sliver: _buildAyahHitList(context, controller, hits),
                  ),
                ],
              ],
            );
          }),
          // Positioned right on top of NoorNavBar with NoorSpace.s3 spacing
          Positioned(
            left: gutter,
            right: gutter,
            bottom: navTopOffset + NoorSpace.s3,
            child: const QuranMiniPlayerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopQuickActions(
    BuildContext context,
    QuranAudioController audio,
  ) {
    final n = context.noor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        NoorCloudButton(
          icon: Icon(
            Icons.record_voice_over_outlined,
            color: n.ink,
            size: 20,
          ),
          tooltip: 'Reciter preferences',
          onTap: () => showReciterPickerSheet(context, audio),
        ),
        const SizedBox(width: NoorSpace.s2),
        NoorCloudButton(
          icon: NoorIcon(NoorGlyph.bookmark, color: n.ink),
          tooltip: S.of(context).bookmarks,
          onTap: () => showBookmarksSheet(context),
        ),
      ],
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    QuranController controller,
  ) {
    final outerTheme = Theme.of(context);
    final outerNoor = context.noor;
    final n = context.noor;
    final page = controller.lastReadPageNumber.value;
    final surahId = quran.getPageData(page).first["surah"] as int;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final surahName =
        isAr ? quran.getSurahNameArabic(surahId) : quran.getSurahName(surahId);
    final readCount = QuranProgress.readCount;
    final overallFraction = QuranProgress.overallFraction;
    final juz = juzOfPage(page);
    final hizb = hizbOfPage(page);

    final muted = NoorText.bodySm(context).copyWith(color: n.onWindowMuted);

    return NoorCard(
      tone: NoorCardTone.night,
      padding: const EdgeInsets.fromLTRB(
        NoorSpace.s5,
        NoorSpace.s5,
        NoorSpace.s5,
        NoorSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${S.of(context).last_read} · ${_juzWord(context)} $juz · ${S.of(context).hizb} $hizb',
            style: muted,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  surahName,
                  style: NoorText.title(context).copyWith(color: n.onWindow),
                ),
              ),
              const SizedBox(width: NoorSpace.s3),
              Text("${S.of(context).page} $page", style: muted),
            ],
          ),
          const SizedBox(height: NoorSpace.s3),
          NoorProgressBar(
            value: overallFraction,
            showPercent: false,
            onWindow: true,
          ),
          Text(S.of(context).pages_read(readCount, 604), style: muted),
          const SizedBox(height: NoorSpace.s3),
          Theme(
            data: outerTheme,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NoorCloudButton(
                  icon: Icon(
                    Icons.menu_book_rounded,
                    color: outerNoor.ink,
                    size: 20,
                  ),
                  tooltip: S.of(context).continue_reading,
                  onTap: () {
                    Get.toNamed(Routes.READ_QURAN, arguments: page - 1);
                  },
                ),
                NoorCloudButton(
                  icon: NoorIcon(NoorGlyph.bookmark, color: outerNoor.ink),
                  tooltip: S.of(context).bookmarks,
                  onTap: () => showBookmarksSheet(context),
                ),
                NoorCloudButton(
                  icon: NoorIcon(NoorGlyph.reset, color: outerNoor.ink),
                  tooltip: S.of(context).reset_progress,
                  onTap: () => _showResetProgressSheet(context, controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueListeningCard(
    BuildContext context,
    QuranAudioController audio,
  ) {
    final outerTheme = Theme.of(context);
    final outerNoor = context.noor;
    final n = context.noor;
    final listened = audio.lastListened.value ?? (surah: 1, ayah: 1);
    final totalVerses = quran.getVerseCount(listened.surah);
    final listenFraction = totalVerses > 0
        ? (listened.ayah / totalVerses).clamp(0.0, 1.0)
        : 0.0;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final surahName = isAr
        ? quran.getSurahNameArabic(listened.surah)
        : quran.getSurahName(listened.surah);
    final reciter = reciterByFolder(audio.reciterFolder.value);
    final muted = NoorText.bodySm(context).copyWith(color: n.onWindowMuted);

    return NoorCard(
      tone: NoorCardTone.night,
      padding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.s5,
        vertical: NoorSpace.s3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  '${_lastListenedLabel(context)} · ${reciter.label(context)}',
                  style: muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: NoorSpace.s2),
              Text(
                '${_ayahWord(context, listened.ayah)} / $totalVerses',
                style: muted,
              ),
            ],
          ),
          Text(
            surahName,
            style: NoorText.heading(context).copyWith(color: n.onWindow),
          ),
          const SizedBox(height: NoorSpace.s2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: NoorProgressBar(
                  value: listenFraction,
                  showPercent: false,
                  onWindow: true,
                ),
              ),
              const SizedBox(width: NoorSpace.s3),
              Theme(
                data: outerTheme,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NoorCloudButton(
                      icon: Icon(
                        Icons.headphones_rounded,
                        color: outerNoor.ink,
                        size: 20,
                      ),
                      tooltip: _continueListeningLabel(context),
                      onTap: () {
                        openSurahPlayer(
                          context,
                          surah: listened.surah,
                          startAyah: listened.ayah,
                        );
                      },
                    ),
                    const SizedBox(width: NoorSpace.s2),
                    NoorCloudButton(
                      icon: Icon(
                        Icons.record_voice_over_outlined,
                        color: outerNoor.ink,
                        size: 20,
                      ),
                      tooltip: 'Reciter preferences',
                      onTap: () => showReciterPickerSheet(context, audio),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetProgressSheet(
      BuildContext context, QuranController controller) {
    showNoorSheet(
      context,
      title: S.of(context).reset_progress,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(sheetContext).reset_progress_body,
            style: NoorText.body(sheetContext),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NoorSpace.s4),
          NoorButton(
            label: S.of(sheetContext).confirm,
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await QuranProgress.reset();
              controller.refreshProgress();
            },
            variant: NoorButtonVariant.danger,
          ),
          const SizedBox(height: NoorSpace.s2),
          NoorButton(
            label: S.of(sheetContext).cancel,
            onPressed: () => Navigator.of(sheetContext).pop(),
            variant: NoorButtonVariant.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(
    BuildContext context,
    QuranController controller,
    QuranAudioController audio,
    bool hasAyahHits,
  ) {
    final surahs = controller.filteredSurahs;
    if (surahs.isEmpty) {
      if (hasAyahHits) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NoorSpace.s5),
          child: EmptyState.noResults(context),
        ),
      );
    }
    return NoorListGroup.sliver(
      context,
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surahNumber = surahs[index];
        return Obx(() {
          final current = audio.playingAyah.value;
          final isPlayingThisSurah = current != null &&
              current.surah == surahNumber &&
              audio.isPlaying.value;
          return SurahLine(
            number: surahNumber,
            isPlaying: isPlayingThisSurah,
            onPlayTap: () => openSurahPlayer(context, surah: surahNumber),
            onTap: () {
              final firstPage = quran.getSurahPages(surahNumber).first;
              AppPrefs.setLastReadPage(firstPage);
              controller.refreshProgress();
              Get.toNamed(Routes.READ_QURAN, arguments: firstPage - 1);
            },
          );
        });
      },
    );
  }

  Widget _buildHizbList(
    BuildContext context,
    QuranController controller,
    bool hasAyahHits,
  ) {
    final hizbs = controller.filteredHizbs;
    if (hizbs.isEmpty) {
      if (hasAyahHits) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NoorSpace.s5),
          child: EmptyState.noResults(context),
        ),
      );
    }
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final juzWord = _juzWord(context);

    return NoorListGroup.sliver(
      context,
      itemCount: hizbs.length,
      itemBuilder: (context, index) {
        final hizbNumber = hizbs[index];
        final startPage = hizbStartPage(hizbNumber);
        final juz = (hizbNumber + 1) ~/ 2;
        final surahId = quran.getPageData(startPage).first["surah"] as int;
        final surahName = isAr
            ? quran.getSurahNameArabic(surahId)
            : quran.getSurahName(surahId);

        return NoorListRow(
          leading: IndexNumber(hizbNumber),
          title: "${S.of(context).hizb} $hizbNumber",
          meta: "$juzWord $juz · $surahName · ${S.of(context).page} $startPage",
          onTap: () {
            AppPrefs.setLastReadPage(startPage);
            controller.refreshProgress();
            Get.toNamed(Routes.READ_QURAN, arguments: startPage - 1);
          },
        );
      },
    );
  }

  Widget _buildAyahHitList(
    BuildContext context,
    QuranController controller,
    List<QuranAyahHit> hits,
  ) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return NoorListGroup.sliver(
      context,
      itemCount: hits.length,
      itemBuilder: (context, index) {
        final hit = hits[index];
        final surahName = isAr
            ? quran.getSurahNameArabic(hit.surah)
            : quran.getSurahName(hit.surah);

        return NoorListRow(
          leading: IndexNumber(hit.surah),
          title: '$surahName · ${hit.surah}:${hit.ayah}',
          meta: hit.snippet,
          trailing: Text(
            '${S.of(context).page} ${hit.page}',
            style: NoorText.bodySm(context),
          ),
          onTap: () {
            AppPrefs.setLastReadPage(hit.page);
            controller.refreshProgress();
            Get.toNamed(
              Routes.READ_QURAN,
              arguments: (
                pageIndex: hit.page - 1,
                surah: hit.surah,
                ayah: hit.ayah,
              ),
            );
          },
        );
      },
    );
  }
}
