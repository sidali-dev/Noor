import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:noor/core/services/language_service.dart';
import 'package:noor/core/services/location_service.dart';
import 'package:noor/core/services/theme_service.dart';
import 'package:noor/core/widgets/empty_state.dart';
import 'package:noor/core/widgets/noor_button.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_list_row.dart';
import 'package:noor/core/widgets/noor_mark.dart';
import 'package:noor/core/widgets/noor_nav_bar.dart';
import 'package:noor/core/widgets/noor_pill.dart';
import 'package:noor/core/widgets/noor_progress_bar.dart';
import 'package:noor/core/widgets/noor_search_field.dart';
import 'package:noor/core/widgets/noor_segmented.dart';
import 'package:noor/core/widgets/settings_sheet.dart';
import 'package:noor/core/widgets/wait_dialog.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/services/shared_prefs_service.dart';
import 'package:noor/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildWrapper({
  required Widget child,
  required ThemeData theme,
  required Locale locale,
  required double textScale,
}) {
  return GetMaterialApp(
    theme: theme,
    locale: locale,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefService.resetForTest();
    await SharedPrefService.init();
    Get.testMode = true;
    Get.put(ThemeService());
    Get.put(LanguageService());
    Get.put(LocationService());
  });

  tearDown(() {
    Get.reset();
  });

  final themes = [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ];

  final locales = [
    ('ar', const Locale('ar')),
    ('en', const Locale('en')),
  ];

  final textScales = [1.0, 1.3, 2.0];

  for (final (themeName, theme) in themes) {
    for (final (langName, locale) in locales) {
      for (final textScale in textScales) {
        final configDesc = '$themeName - $langName - scale $textScale';

        group('Shared widgets ($configDesc)', () {
          testWidgets('NoorMark pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: const NoorMark(size: 32),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorCard pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: NoorCard(
                  onTap: () {},
                  child: const Text('Card child'),
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorListRow pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: NoorListRow(
                  leading: const Icon(Icons.circle),
                  title: 'Al-Fatiha',
                  meta: '7 verses',
                  onTap: () {},
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorSegmented pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: NoorSegmented<String>(
                  items: const [
                    (value: 'surah', label: 'Surahs'),
                    (value: 'juz', label: 'Juz'),
                  ],
                  value: 'surah',
                  onChanged: (_) {},
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorPill pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: NoorPill(
                  icon: const Icon(Icons.place),
                  label: 'Algeria, Algiers',
                  onTap: () {},
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorButton 3 variants pump without exception',
              (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NoorButton(
                      label: 'Primary',
                      onPressed: () {},
                      variant: NoorButtonVariant.primary,
                    ),
                    const SizedBox(height: 8),
                    NoorButton(
                      label: 'Tonal',
                      onPressed: () {},
                      variant: NoorButtonVariant.tonal,
                    ),
                    const SizedBox(height: 8),
                    NoorButton(
                      label: 'Outline',
                      onPressed: () {},
                      variant: NoorButtonVariant.outline,
                    ),
                  ],
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorSearchField pumps without exception',
              (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: const NoorSearchField(hint: 'Search...'),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorProgressBar pumps without exception',
              (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: const NoorProgressBar(value: 0.65),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('EmptyState pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: EmptyState(
                  icon: Icons.search_off,
                  message: 'No results found',
                  actionLabel: 'Clear',
                  onAction: () {},
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('NoorNavBar pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: NoorNavBar(
                  selectedIndex: 0,
                  onItemSelected: (_) {},
                ),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('WaitDialog pumps without exception', (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: const WaitDialog(),
              ),
            );
            expect(tester.takeException(), isNull);
          });

          testWidgets('showNoorSheet & settings_sheet pump without exception',
              (tester) async {
            await tester.pumpWidget(
              _buildWrapper(
                theme: theme,
                locale: locale,
                textScale: textScale,
                child: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => showSettingsSheet(ctx),
                    child: const Text('Open Settings'),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('Open Settings'));
            await tester.pump();
            expect(tester.takeException(), isNull);
          });
        });
      }
    }
  }
}
