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
import 'package:noor/generals/widgets/noor_pressable.dart';
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
                    title: S.of(context).nav_quran,
                    subtitle: S.of(context).tagline_quran,
                    overlap: NoorSearchField(
                      hint: S.of(context).search_surah,
                      onChanged: controller.setQuery,
                    ),
                  ),
                  NoorSettle(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Without a last-read page and any dwelled page there is
                      // nothing to continue from.
                      if (controller.lastReadPageNumber.value > 1 ||
                          QuranProgress.readCount > 0) ...[
                        const SizedBox(height: NoorSpace.s4),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          child: _buildContinueReadingCard(context, controller),
                        ),
                      ],
                      const SizedBox(height: NoorSpace.s5),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        child: NoorSegmented<int>(
                          items: [
                            (value: 0, label: S.of(context).surah),
                            (value: 1, label: S.of(context).hizb),
                          ],
                          value: tabIndex,
                          onChanged: controller.changeIndex,
                        ),
                      ),
                      const SizedBox(height: NoorSpace.s4),
                    ],
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
    final subtitle = "$surahName \u00B7 ${S.of(context).page} $page";
    final readCount = QuranProgress.readCount;
    final overallFraction = QuranProgress.overallFraction;

    return NoorCard(
      padding: const EdgeInsets.all(NoorSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).last_read,
                  style: NoorText.bodySm(context),
                ),
              ),
              Flexible(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: n.muted,
                    minimumSize: const Size(48, 48),
                    padding:
                        const EdgeInsets.symmetric(horizontal: NoorSpace.s2),
                  ),
                  onPressed: () => _showResetProgressSheet(context, controller),
                  child: Text(
                    S.of(context).reset_progress,
                    textAlign: TextAlign.end,
                    style: NoorText.bodySm(context).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: n.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(subtitle, style: NoorText.heading(context)),
              ),
              const SizedBox(width: NoorSpace.s3),
              Text(
                S.of(context).pages_read(readCount, 604),
                style: NoorText.bodySm(context),
              ),
            ],
          ),
          const SizedBox(height: NoorSpace.s3),
          NoorProgressBar(value: overallFraction, showPercent: false),
          const SizedBox(height: NoorSpace.s4),
          Row(
            children: [
              Expanded(
                child: NoorButton(
                  label: S.of(context).continue_reading,
                  // arrow_forward already mirrors in RTL.
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  onPressed: () {
                    Get.to(() => ReadQuranScreen(pageIndex: page - 1));
                  },
                ),
              ),
              const SizedBox(width: NoorSpace.s2),
              Tooltip(
                message: S.of(context).bookmarks,
                child: NoorPressable(
                  onPressed: () => showBookmarksSheet(context),
                  radius: NoorRadius.md,
                  builder: (context, pressed) => DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(NoorRadius.md),
                      border: Border.all(color: n.lineStrong),
                    ),
                    child: const SizedBox.square(
                      dimension: 52,
                      child: Center(child: NoorIcon(NoorGlyph.bookmark)),
                    ),
                  ),
                ),
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
          leading: SizedBox(
            width: NoorSpace.s6,
            child: Text(
              '$hizbNumber',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: NoorText.numeral(context,
                  size: 16, color: context.noor.muted),
            ),
          ),
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
