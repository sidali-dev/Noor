import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/features/quran/hizb_pages.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/features/quran/widgets/bookmarks_sheet.dart';
import 'package:noor/features/quran/widgets/surah_line.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_progress_bar.dart';
import 'package:noor/generals/widgets/noor_search_field.dart';
import 'package:noor/generals/widgets/noor_segmented.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranScreenController());
    final n = context.noor;
    final gutter = NoorLayout.gutter(context);

    return Scaffold(
      backgroundColor: n.paper,
      body: Obx(() {
        // Track progressRevision and query so CustomScrollView rebuilds lazily
        controller.progressRevision.value;
        controller.searchQuery.value;
        final tabIndex = controller.currentIndex.value;

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
                        // Without a last-read page and any dwelled page there is
                        // nothing to continue from.
                        if (controller.lastReadPageNumber.value > 1 ||
                            QuranProgress.readCount > 0) ...[
                          const SizedBox(height: NoorSpace.s4),
                          _buildContinueReadingCard(context, controller),
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
                  )),
                ],
              ),
            ),
            SliverPadding(
              // extendBody: the shell reports the floating nav bar as bottom padding.
              padding: EdgeInsets.only(
                left: gutter,
                right: gutter,
                bottom: MediaQuery.paddingOf(context).bottom + NoorSpace.s4,
              ),
              sliver: tabIndex == 0
                  ? _buildSurahList(context, controller)
                  : _buildHizbList(context, controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContinueReadingCard(
      BuildContext context, QuranScreenController controller) {
    final n = context.noor;
    final page = controller.lastReadPageNumber.value;
    final surahId = quran.getPageData(page).first["surah"] as int;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final surahName =
        isAr ? quran.getSurahNameArabic(surahId) : quran.getSurahName(surahId);
    final readCount = QuranProgress.readCount;
    final overallFraction = QuranProgress.overallFraction;

    // A window into the sky, like the next-prayer card: what it holds is drawn
    // in moon-white, and the styles here resolve above the card.
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
          Text(S.of(context).last_read, style: muted),
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
          Row(
            children: [
              Expanded(
                child: NoorButton(
                  label: S.of(context).continue_reading,
                  variant: NoorButtonVariant.onWindow,
                  onPressed: () {
                    Get.to(() => ReadQuranScreen(pageIndex: page - 1));
                  },
                ),
              ),
              const SizedBox(width: NoorSpace.s2),
              NoorCloudButton(
                // The puff is paper; the card's own ink would be moon-white.
                icon: NoorIcon(NoorGlyph.bookmark, color: n.ink),
                tooltip: S.of(context).bookmarks,
                onTap: () => showBookmarksSheet(context),
              ),
              const SizedBox(width: NoorSpace.s2),
              NoorCloudButton(
                icon: NoorIcon(NoorGlyph.reset, color: n.ink),
                tooltip: S.of(context).reset_progress,
                onTap: () => _showResetProgressSheet(context, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetProgressSheet(
      BuildContext context, QuranScreenController controller) {
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
      BuildContext context, QuranScreenController controller) {
    final surahs = controller.filteredSurahs;
    if (surahs.isEmpty) {
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
        return SurahLine(
          number: surahNumber,
          onTap: () {
            final firstPage = quran.getSurahPages(surahNumber).first;
            AppPrefs.setLastReadPage(firstPage);
            controller.refreshProgress();
            Get.to(() => ReadQuranScreen(pageIndex: firstPage - 1));
          },
        );
      },
    );
  }

  Widget _buildHizbList(
      BuildContext context, QuranScreenController controller) {
    final hizbs = controller.filteredHizbs;
    if (hizbs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: NoorSpace.s5),
          child: EmptyState.noResults(context),
        ),
      );
    }
    return NoorListGroup.sliver(
      context,
      itemCount: hizbs.length,
      itemBuilder: (context, index) {
        final hizbNumber = hizbs[index];
        final startPage = hizbStartPage(hizbNumber);

        return NoorListRow(
          leading: IndexNumber(hizbNumber),
          title: "${S.of(context).hizb} $hizbNumber",
          meta: "${S.of(context).page} $startPage",
          onTap: () {
            AppPrefs.setLastReadPage(startPage);
            controller.refreshProgress();
            Get.to(() => ReadQuranScreen(pageIndex: startPage - 1));
          },
        );
      },
    );
  }
}
