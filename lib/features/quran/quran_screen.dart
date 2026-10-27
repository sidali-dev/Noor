import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noor/features/quran/data/quran_progress.dart';
import 'package:noor/features/quran/hizb_pages.dart';
import 'package:noor/features/quran/quran_screen_controller.dart';
import 'package:noor/features/quran/screens/read_quran_screen.dart';
import 'package:noor/features/quran/widgets/bookmarks_sheet.dart';
import 'package:noor/features/quran/widgets/surah_line.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_button.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_header.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_progress_bar.dart';
import 'package:noor/generals/widgets/noor_search_field.dart';
import 'package:noor/generals/widgets/noor_segmented.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/local_storage/app_prefs.dart';
import 'package:noor/utils/theme/noor_theme.dart';
import 'package:quran/quran.dart' as quran;

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranScreenController());
    final n = context.noor;

    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
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
                    const NoorHeader(),
                    const SizedBox(height: NoorSpace.lg),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).quran_title,
                                  style: NoorText.display(context),
                                ),
                                const SizedBox(height: NoorSpace.xs),
                                Text(
                                  S.of(context).quran_subtitle,
                                  style: NoorText.meta(context)
                                      .copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: NoorSpace.md),
                          const IconTile(
                            svg: SImageString.quran,
                            tint: NoorTint.sage,
                            size: 56,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NoorSpace.lg),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
                      child: NoorSearchField(
                        hint: S.of(context).search_surah,
                        onChanged: controller.setQuery,
                      ),
                    ),
                    const SizedBox(height: NoorSpace.lg),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
                      child: _buildContinueReadingCard(context, controller),
                    ),
                    const SizedBox(height: NoorSpace.lg),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
                      child: NoorSegmented<int>(
                        items: [
                          (value: 0, label: S.of(context).surah),
                          (value: 1, label: S.of(context).hizb),
                        ],
                        value: tabIndex,
                        onChanged: controller.changeIndex,
                      ),
                    ),
                    const SizedBox(height: NoorSpace.md),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: NoorSpace.xl,
                  right: NoorSpace.xl,
                  bottom: 96,
                ),
                sliver: tabIndex == 0
                    ? _buildSurahList(context, controller)
                    : _buildHizbList(context, controller),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildContinueReadingCard(
      BuildContext context, QuranScreenController controller) {
    final n = context.noor;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final page = controller.lastReadPageNumber.value;
    final surahId = quran.getPageData(page).first["surah"] as int;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final surahName = isAr
        ? quran.getSurahNameArabic(surahId)
        : quran.getSurahName(surahId);
    final subtitle = "$surahName \u00B7 ${S.of(context).page} $page";
    final readCount = QuranProgress.readCount;
    final overallFraction = QuranProgress.overallFraction;

    return NoorCard(
      padding: const EdgeInsets.all(NoorSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context).last_read,
                style: NoorText.meta(context),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showResetProgressSheet(context, controller),
                child: Text(
                  S.of(context).reset_progress,
                  style: NoorText.meta(context).copyWith(
                    color: n.muted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NoorSpace.xs),
          Text(
            subtitle,
            style: NoorText.rowTitle(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: NoorSpace.md),
          Row(
            children: [
              Expanded(
                child: NoorProgressBar(
                  value: overallFraction,
                  height: 5,
                ),
              ),
              const SizedBox(width: NoorSpace.md),
              Text(
                S.of(context).pages_read(readCount, 604),
                style: NoorText.meta(context).copyWith(
                  fontFamily: 'Spectral',
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: NoorSpace.lg),
          Row(
            children: [
              Expanded(
                child: NoorButton(
                  label: S.of(context).continue_reading,
                  icon: Transform.flip(
                    flipX: isRtl,
                    child: const Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                  onPressed: () {
                    Get.to(() => ReadQuranScreen(pageIndex: page - 1));
                  },
                ),
              ),
              const SizedBox(width: NoorSpace.sm),
              Material(
                color: n.tintBg(NoorTint.sage),
                borderRadius: BorderRadius.circular(NoorRadius.tile),
                child: InkWell(
                  borderRadius: BorderRadius.circular(NoorRadius.tile),
                  onTap: () => showBookmarksSheet(context),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.bookmark_rounded,
                      color: n.primary,
                      size: 24,
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
          const SizedBox(height: NoorSpace.xl),
          NoorButton(
            label: S.of(sheetContext).confirm,
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await QuranProgress.reset();
              controller.refreshProgress();
            },
            variant: NoorButtonVariant.primary,
          ),
          const SizedBox(height: NoorSpace.sm),
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
          padding: const EdgeInsets.symmetric(vertical: NoorSpace.xxl),
          child: EmptyState(message: S.of(context).no_results),
        ),
      );
    }
    return SliverList.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surahNumber = surahs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: NoorSpace.md),
          child: SurahLine(
            number: surahNumber,
            onTap: () {
              final firstPage = quran.getSurahPages(surahNumber).first;
              AppPrefs.setLastReadPage(firstPage);
              controller.refreshProgress();
              Get.to(() => ReadQuranScreen(pageIndex: firstPage - 1));
            },
          ),
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
          padding: const EdgeInsets.symmetric(vertical: NoorSpace.xxl),
          child: EmptyState(message: S.of(context).no_results),
        ),
      );
    }
    return SliverList.builder(
      itemCount: hizbs.length,
      itemBuilder: (context, index) {
        final hizbNumber = hizbs[index];
        final startPage = hizbStartPage(hizbNumber);
        final leading = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.noor.tintBg(NoorTint.sage),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            hizbNumber.toString(),
            style: NoorText.numeral(
              context,
              size: 16,
              color: context.noor.ink,
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: NoorSpace.md),
          child: NoorListRow(
            leading: leading,
            title: "${S.of(context).hizb} $hizbNumber",
            meta: "${S.of(context).page} $startPage",
            onTap: () {
              AppPrefs.setLastReadPage(startPage);
              controller.refreshProgress();
              Get.to(() => ReadQuranScreen(pageIndex: startPage - 1));
            },
          ),
        );
      },
    );
  }
}
