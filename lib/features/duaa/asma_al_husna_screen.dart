import 'package:flutter/material.dart';
import 'package:noor/features/duaa/data/asma_al_husna.dart';
import 'package:noor/features/quran/widgets/surah_line.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/loading_state.dart';
import 'package:noor/generals/widgets/noor_cartouche.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_list_row.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/http/http_client.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The 99 names, set like the Quran index: a numbered medallion, the name in
/// Amiri, and under it the transliteration, with the English meaning in
/// English (the API has none in French).
class AsmaAlHusnaScreen extends StatefulWidget {
  const AsmaAlHusnaScreen({super.key});

  @override
  State<AsmaAlHusnaScreen> createState() => _AsmaAlHusnaScreenState();
}

class _AsmaAlHusnaScreenState extends State<AsmaAlHusnaScreen> {
  late Future<List<AsmaName>> _names = AsmaAlHusna.load();

  void _retry() => setState(() => _names = AsmaAlHusna.load());

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    final gutter = NoorLayout.gutter(context);
    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                NoorSpace.s2,
                gutter,
                NoorSpace.s3,
              ),
              child: Row(
                children: [
                  NoorCloudButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: s.back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: NoorSpace.s2),
                  Expanded(child: NoorCartouche.title(s.asma_al_husna)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AsmaName>>(
                future: _names,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return EmptyState(
                      danger: true,
                      icon: NoorGlyph.alert,
                      message: snapshot.error is NoInternetException
                          ? s.no_internet
                          : s.asma_failed,
                      actionLabel: s.try_again,
                      onAction: _retry,
                    );
                  }
                  final names = snapshot.data;
                  if (names == null) {
                    return LoadingState(message: s.wait_please);
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          0,
                          gutter,
                          MediaQuery.paddingOf(context).bottom + NoorSpace.s4,
                        ),
                        sliver: NoorListGroup.sliver(
                          context,
                          itemCount: names.length,
                          itemBuilder: (context, i) =>
                              _AsmaLine(name: names[i]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AsmaLine extends StatelessWidget {
  final AsmaName name;

  const _AsmaLine({required this.name});

  @override
  Widget build(BuildContext context) {
    final meta = switch (Localizations.localeOf(context).languageCode) {
      'ar' => null,
      'en' when name.meaning.isNotEmpty =>
        '${name.transliteration} · ${name.meaning}',
      _ => name.transliteration,
    };
    return NoorListRow(
      leading: IndexNumber(name.number),
      title: name.name,
      titleStyle: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: context.noor.ink,
      ),
      meta: meta,
      trailing: const SizedBox.shrink(),
    );
  }
}
