import 'package:flutter/material.dart';
import 'package:noor/features/duaa/adhkar_categories.dart';
import 'package:noor/features/duaa/adhkar_display_screen.dart';
import 'package:noor/features/duaa/data/adhkar_search.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/icon_tile.dart';
import 'package:noor/generals/widgets/noor_header.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generals/widgets/noor_search_field.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/local_storage/services/database_service.dart';
import 'package:noor/utils/text_normalize.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class DuaaScreen extends StatefulWidget {
  const DuaaScreen({super.key});

  @override
  State<DuaaScreen> createState() => _DuaaScreenState();
}

class _DuaaScreenState extends State<DuaaScreen> {
  Map<int, int>? _adhkarCounts;
  String _query = '';
  List<AdhkarHit> _textHits = const [];
  bool _isSearchingText = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() async {
    final counts = await DatabaseService.getAdhkarCounts();
    if (!mounted) return;
    setState(() {
      _adhkarCounts = counts;
    });
  }

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

  Future<void> _openCategory(
    AdhkarCategory category, {
    int initialIndex = 0,
  }) async {
    final adhkar = await DatabaseService.getAdhkar(category.id);
    if (!mounted) return;
    final s = S.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdhkarDisplayScreen(
          title: category.title(s),
          adhkar: adhkar,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Future<void> _openHit(AdhkarHit hit) async {
    final category = categoryForType(hit.type);
    if (category == null) return;
    await _openCategory(category, initialIndex: hit.indexInType);
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

    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const NoorHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: NoorSpace.xl,
                  right: NoorSpace.xl,
                  bottom: 96,
                  top: NoorSpace.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.adhkar,
                      style: NoorText.display(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: NoorSpace.xs),
                    Text(
                      s.adhkar_subtitle,
                      style: NoorText.meta(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: NoorSpace.lg),
                    NoorSearchField(
                      hint: s.search_adhkar,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: NoorSpace.xl),
                    if (showEmptyState)
                      Padding(
                        padding: const EdgeInsets.only(top: NoorSpace.xxl),
                        child: EmptyState(message: s.no_results),
                      )
                    else ...[
                      for (int i = 0; i < filteredCategories.length; i++) ...[
                        if (i > 0) const SizedBox(height: NoorSpace.md),
                        _buildCategoryRow(context, filteredCategories[i], s),
                      ],
                      if (isQueryLongEnough && _textHits.isNotEmpty) ...[
                        const SizedBox(height: NoorSpace.xxl),
                        Text(
                          s.in_adhkar_text,
                          style: NoorText.section(context),
                        ),
                        const SizedBox(height: NoorSpace.md),
                        for (int i = 0; i < _textHits.length; i++) ...[
                          if (i > 0) const SizedBox(height: NoorSpace.md),
                          _buildHitRow(context, _textHits[i], s),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
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
    final count = _adhkarCounts?[category.id];
    final metaText = count != null ? s.adhkar_count(count) : null;

    return NoorListRow(
      leading: IconTile(
        svg: category.svgAsset,
        tint: category.tint,
      ),
      title: category.title(s),
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
      leading: category != null
          ? IconTile(
              svg: category.svgAsset,
              tint: category.tint,
            )
          : null,
      title: title,
      meta: hit.snippet,
      onTap: () => _openHit(hit),
    );
  }
}
