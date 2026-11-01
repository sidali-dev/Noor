import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/features/duaa/adhkar_categories.dart';
import 'package:noor/features/duaa/adhkar_display_screen.dart';
import 'package:noor/features/duaa/data/adhkar_data.dart';
import 'package:noor/features/duaa/data/adhkar_search.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_hero.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_search_field.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/text_normalize.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class DuaaScreen extends StatefulWidget {
  const DuaaScreen({super.key});

  @override
  State<DuaaScreen> createState() => _DuaaScreenState();
}

class _DuaaScreenState extends State<DuaaScreen> {
  final Map<int, int> _counts = AdhkarData.counts;
  String _query = '';
  List<AdhkarHit> _textHits = const [];
  bool _isSearchingText = false;

  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
    });

    final normalized = normalizeArabic(query).trim();
    if (normalized.length >= 2) {
      _performTextSearch(query, normalized);
    } else {
      setState(() {
        _textHits = const [];
        _isSearchingText = false;
      });
    }
  }

  void _performTextSearch(String query, String normalized) async {
    setState(() {
      _isSearchingText = true;
    });
    try {
      final hits = await AdhkarSearch.instance.search(query);
      if (!mounted) return;
      if (normalizeArabic(_query).trim() == normalized) {
        setState(() {
          _textHits = hits;
          _isSearchingText = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _textHits = const [];
        _isSearchingText = false;
      });
    }
  }

  void _openCategory(AdhkarCategory category, {int initialIndex = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdhkarDisplayScreen(
          title: category.title(S.of(context)),
          adhkar: AdhkarData.byType(category.id),
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _openHit(AdhkarHit hit) {
    final category = categoryForType(hit.type);
    if (category == null) return;
    _openCategory(category, initialIndex: hit.indexInType);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);

    final filteredCategories = adhkarCategories.where((category) {
      if (_query.trim().isEmpty) return true;
      return matchesQuery(category.title(s), _query);
    }).toList();

    final isQueryLongEnough = normalizeArabic(_query).trim().length >= 2;
    final showEmptyState = _query.trim().isNotEmpty &&
        filteredCategories.isEmpty &&
        (!isQueryLongEnough || (_textHits.isEmpty && !_isSearchingText));

    // The hero is the header and draws behind the status bar, so no SafeArea.
    return Scaffold(
      backgroundColor: n.paper,
      body: SingleChildScrollView(
        // extendBody: the shell reports the floating nav bar as bottom padding.
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + NoorSpace.s4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NoorHero(
              art: NoorArt.heroAthkar,
              title: s.nav_adhkar,
              subtitle: s.tagline_adhkar,
              overlap: NoorSearchField(
                hint: s.search_adhkar,
                onChanged: _onSearchChanged,
              ),
            ),
            NoorSettle(
                child: Padding(
              padding: EdgeInsets.fromLTRB(
                NoorLayout.gutter(context),
                NoorSpace.s4,
                NoorLayout.gutter(context),
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showEmptyState)
                    Padding(
                      padding: const EdgeInsets.only(top: NoorSpace.s5),
                      child: EmptyState.noResults(context),
                    )
                  else ...[
                    if (filteredCategories.isNotEmpty)
                      NoorListGroup(
                        children: [
                          for (final c in filteredCategories)
                            _buildCategoryRow(context, c, s),
                        ],
                      ),
                    if (isQueryLongEnough && _textHits.isNotEmpty) ...[
                      const SizedBox(height: NoorSpace.s5),
                      Text(
                        s.in_adhkar_text,
                        style: NoorText.heading(context),
                      ),
                      const SizedBox(height: NoorSpace.s3),
                      NoorListGroup(
                        children: [
                          for (final hit in _textHits)
                            _buildHitRow(context, hit, s),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    AdhkarCategory category,
    S s,
  ) {
    final count = _counts[category.id];
    final metaText = count != null ? s.adhkar_count(count) : null;

    return NoorListRow(
      leading: _icon(context, category.svgAsset),
      title: category.title(s),
      titleMaxLines: 2,
      meta: metaText,
      onTap: () => _openCategory(category),
    );
  }

  Widget _buildHitRow(
    BuildContext context,
    AdhkarHit hit,
    S s,
  ) {
    final category = categoryForType(hit.type);
    final title = category != null ? category.title(s) : '';

    return NoorListRow(
      leading: category != null ? _icon(context, category.svgAsset) : null,
      title: title,
      titleMaxLines: 2,
      meta: hit.snippet,
      onTap: () => _openHit(hit),
    );
  }

  // Hilal retires the icon tile: the leading is a bare ink glyph.
  Widget _icon(BuildContext context, String svg) => SvgPicture.asset(
        svg,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(context.noor.ink, BlendMode.srcIn),
      );
}
