import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/core/services/app_prefs.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/widgets/noor_icon.dart';
import 'package:noor/core/widgets/noor_pill.dart';
import 'package:noor/core/widgets/noor_sheet.dart';
import 'package:noor/features/quran/controllers/quran_audio_controller.dart';
import 'package:noor/features/quran/controllers/quran_controller.dart';
import 'package:noor/features/quran/models/hizb_pages.dart';
import 'package:noor/features/quran/views/widgets/mushaf_frame.dart';
import 'package:noor/features/quran/views/widgets/reciter_picker_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:quran/quran.dart' as quran;

Future<void> showAyahActionSheet(
  BuildContext context, {
  required int surah,
  required int ayah,
  required QuranAudioController audio,
  VoidCallback? onBookmarkChanged,
}) {
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final surahName =
      isAr ? quran.getSurahNameArabic(surah) : quran.getSurahName(surah);
  final title = '$surahName · $surah:$ayah';

  return showNoorSheet(
    context,
    title: title,
    builder: (sheetContext) => _AyahActionSheetContent(
      surah: surah,
      ayah: ayah,
      audio: audio,
      onBookmarkChanged: onBookmarkChanged,
    ),
  );
}

class _AyahActionSheetContent extends StatefulWidget {
  final int surah;
  final int ayah;
  final QuranAudioController audio;
  final VoidCallback? onBookmarkChanged;

  const _AyahActionSheetContent({
    required this.surah,
    required this.ayah,
    required this.audio,
    this.onBookmarkChanged,
  });

  @override
  State<_AyahActionSheetContent> createState() =>
      _AyahActionSheetContentState();
}

class _AyahActionSheetContentState extends State<_AyahActionSheetContent> {
  bool _showTranslation = false;
  bool _copied = false;

  bool get _isBookmarked {
    return AppPrefs.ayahBookmarks.any(
      (b) => b.surah == widget.surah && b.ayah == widget.ayah,
    );
  }

  Future<void> _toggleAyahBookmark() async {
    final list = List<({int surah, int ayah})>.from(AppPrefs.ayahBookmarks);
    final idx = list.indexWhere(
      (b) => b.surah == widget.surah && b.ayah == widget.ayah,
    );
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.add((surah: widget.surah, ayah: widget.ayah));
    }
    await AppPrefs.setAyahBookmarks(list);
    setState(() {});
    widget.onBookmarkChanged?.call();
    if (Get.isRegistered<QuranController>()) {
      Get.find<QuranController>().refreshProgress();
    }
  }

  Future<void> _copyAyah() async {
    final arabic = quran.getVerse(widget.surah, widget.ayah, verseEndSymbol: true);
    final surahAr = quran.getSurahNameArabic(widget.surah);
    await Clipboard.setData(
      ClipboardData(text: '$arabic [سورة $surahAr: ${widget.ayah}]'),
    );
    if (!mounted) return;
    setState(() => _copied = true);
  }

  String _playLabel(BuildContext context, bool playing) {
    final code = Localizations.localeOf(context).languageCode;
    if (playing) {
      if (code == 'ar') return 'إيقاف التلاوة';
      if (code == 'fr') return 'Pause';
      return 'Pause recitation';
    }
    if (code == 'ar') return 'استماع للآية';
    if (code == 'fr') return 'Écouter le verset';
    return 'Listen to verse';
  }

  String _translationLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return 'الترجمة';
    if (code == 'fr') return 'Traduction';
    return 'Translation';
  }

  String _juzLabel(BuildContext context, int juz, int hizb) {
    final code = Localizations.localeOf(context).languageCode;
    final hLabel = S.of(context).hizb;
    final jLabel = code == 'ar' ? 'الجزء' : 'Juz';
    return '$jLabel $juz · $hLabel $hizb';
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final lang = Localizations.localeOf(context).languageCode;
    final page = quran.getPageNumber(widget.surah, widget.ayah);
    final juz = juzOfPage(page);
    final hizb = hizbOfPage(page);
    final isSajdah = quran.isSajdahVerse(widget.surah, widget.ayah);
    final verseText = quran.getVerse(widget.surah, widget.ayah);
    final translation = quran.getVerseTranslation(
      widget.surah,
      widget.ayah,
      translation: lang == 'fr'
          ? quran.Translation.frHamidullah
          : quran.Translation.enSaheeh,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Metadata line: Juz · Hizb · Page (and Sajdah if applicable)
        Text(
          '${_juzLabel(context, juz, hizb)} · ${S.of(context).page} $page${isSajdah ? ' · ${quran.sajdah}' : ''}',
          textAlign: TextAlign.center,
          style: NoorText.bodySm(context),
        ),
        const SizedBox(height: NoorSpace.s3),
        // Arabic verse text
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            '$verseText ${quran.getVerseEndSymbol(widget.ayah)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Quran',
              fontSize: 22,
              height: 1.9,
              color: n.ink,
            ),
          ),
        ),
        if (_showTranslation) ...[
          const SizedBox(height: NoorSpace.s3),
          Center(
            child: SizedBox(
              width: 160,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(height: 1, child: ColoredBox(color: n.line)),
                  ),
                  const SizedBox(width: NoorSpace.s2),
                  MushafStar(size: 14, color: n.line),
                  const SizedBox(width: NoorSpace.s2),
                  Expanded(
                    child: SizedBox(height: 1, child: ColoredBox(color: n.line)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NoorSpace.s3),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              translation,
              textAlign: TextAlign.center,
              style: NoorText.body(context).copyWith(color: n.muted),
            ),
          ),
        ],
        const SizedBox(height: NoorSpace.s4),
        // Reciter selector pill
        Obx(() {
          final reciter = reciterByFolder(widget.audio.reciterFolder.value);
          return Center(
            child: NoorPill(
              icon: Icon(Iconsax.microphone_2, size: 16),
              label: reciter.label(context),
              trailing: Icon(Iconsax.arrow_down_1, size: 16),
              onTap: () => showReciterPickerSheet(context, widget.audio),
            ),
          );
        }),
        const SizedBox(height: NoorSpace.s3),
        // Primary action row: Play/Pause + Bookmark + Translation toggle + Copy
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final active = widget.audio.playingAyah.value;
                final isThisPlaying = widget.audio.isPlaying.value &&
                    active != null &&
                    active.surah == widget.surah &&
                    active.ayah == widget.ayah;
                return NoorButton(
                  label: _playLabel(context, isThisPlaying),
                  icon: Icon(
                    isThisPlaying ? Iconsax.pause : Iconsax.play,
                    size: 18,
                  ),
                  onPressed: () =>
                      widget.audio.toggleVerse(widget.surah, widget.ayah),
                );
              }),
            ),
            const SizedBox(width: NoorSpace.s2),
            NoorCloudButton(
              tooltip: S.of(context).bookmark,
              icon: DecoratedBox(
                decoration: BoxDecoration(
                  color: _isBookmarked ? n.brassSoft : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 28,
                  child: Center(
                    child: NoorIcon(
                      NoorGlyph.bookmark,
                      color: _isBookmarked ? n.brass : n.ink,
                    ),
                  ),
                ),
              ),
              onTap: _toggleAyahBookmark,
            ),
            const SizedBox(width: NoorSpace.s1),
            NoorCloudButton(
              tooltip: _translationLabel(context),
              icon: Icon(
                Iconsax.translate,
                size: 18,
                color: _showTranslation ? n.brass : n.ink,
              ),
              onTap: () => setState(() => _showTranslation = !_showTranslation),
            ),
            const SizedBox(width: NoorSpace.s1),
            NoorCloudButton(
              tooltip: S.of(context).done,
              icon: _copied
                  ? NoorIcon(NoorGlyph.check, color: n.success)
                  : Icon(Iconsax.copy, size: 18, color: n.ink),
              onTap: _copyAyah,
            ),
          ],
        ),
      ],
    );
  }
}
