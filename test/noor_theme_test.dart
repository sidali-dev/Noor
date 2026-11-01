import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noor/utils/theme/noor_theme.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final themes = {
    'paper': (NoorColors.light, NoorTheme.light()),
    'night': (NoorColors.dark, NoorTheme.dark()),
  };

  final tokens =
      jsonDecode(File('hilal-design-system/tokens.json').readAsStringSync())
          as Map<String, dynamic>;
  final colorTokens = {
    for (final t in (tokens['color']['tokens'] as List))
      t['name'] as String: t['value'] as Map<String, dynamic>,
  };

  for (final entry in themes.entries) {
    final id = entry.key;
    final n = entry.value.$1;
    final theme = entry.value.$2;

    group('NoorTheme.$id', () {
      test('registers the NoorColors extension', () {
        expect(theme.extension<NoorColors>(), isNotNull);
      });

      test('colours match tokens.json', () {
        final fields = {
          'surface': n.paper,
          'surface-raised': n.card,
          'surface-sunken': n.surfaceSunken,
          'line': n.line,
          'line-strong': n.lineStrong,
          'ink': n.ink,
          'ink-muted': n.muted,
          'window': n.window,
          'window-raised': n.windowRaised,
          'on-window': n.onWindow,
          'on-window-muted': n.onWindowMuted,
          'brass': n.brass,
          'brass-soft': n.brassSoft,
          'on-brass': n.onBrass,
          'paper-shade': n.paperShade,
          'sky-glow': n.skyGlow,
          'depth-shadow': n.depthShadow,
          'success': n.success,
          'success-soft': n.successSoft,
          'danger': n.danger,
          'danger-soft': n.dangerSoft,
        };
        expect(fields.keys.toSet(), colorTokens.keys.toSet());
        for (final f in fields.entries) {
          final raw = colorTokens[f.key]![id] as String;
          final Color want;
          if (raw.startsWith('#')) {
            want = Color(0xFF000000 | int.parse(raw.substring(1), radix: 16));
          } else {
            final p =
                RegExp(r'rgba\((\d+),(\d+),(\d+),([\d.]+)\)').firstMatch(raw)!;
            want = Color.fromRGBO(int.parse(p[1]!), int.parse(p[2]!),
                int.parse(p[3]!), double.parse(p[4]!));
          }
          expect(f.value, want, reason: f.key);
        }
      });

      // Text pairs documented in tokens.json: 4.5:1.
      final surfaces = {
        'surface': n.paper,
        'surface-raised': n.card,
        'surface-sunken': n.surfaceSunken,
      };
      final text = <String, (Color, Color)>{
        for (final s in surfaces.entries) ...{
          'ink on ${s.key}': (n.ink, s.value),
          'ink-muted on ${s.key}': (n.muted, s.value),
        },
        'on-window on window': (n.onWindow, n.window),
        'on-window on window-raised': (n.onWindow, n.windowRaised),
        'on-window-muted on window': (n.onWindowMuted, n.window),
        'on-window-muted on window-raised': (n.onWindowMuted, n.windowRaised),
        'brass on surface': (n.brass, n.paper),
        'brass on surface-raised': (n.brass, n.card),
        'brass on brass-soft': (n.brass, n.brassSoft),
        'on-brass on brass': (n.onBrass, n.brass),
        'success on surface-raised': (n.success, n.card),
        'success on success-soft': (n.success, n.successSoft),
        'danger on surface-raised': (n.danger, n.card),
        'danger on danger-soft': (n.danger, n.dangerSoft),
      };
      for (final p in text.entries) {
        test('${p.key} >= 4.5:1', () {
          expect(contrast(p.value.$1, p.value.$2), greaterThanOrEqualTo(4.5));
        });
      }

      // Control borders that must be seen: 3:1.
      for (final s in surfaces.entries) {
        test('line-strong on ${s.key} >= 3:1', () {
          expect(contrast(n.lineStrong, s.value), greaterThanOrEqualTo(3));
        });
      }

      test('shadow helpers are populated', () {
        expect(n.shadow1, hasLength(2));
        expect(n.shadow2, hasLength(2));
        expect(n.shadow3, hasLength(2));
        expect(n.inset, hasLength(1));
      });
    });
  }

  test('spacing and radius follow tokens.json', () {
    expect(
      [for (final t in tokens['spacing']['tokens'] as List) t['value']],
      ['4px', '8px', '12px', '16px', '24px', '32px', '48px', '64px'],
    );
    expect(
      [
        NoorSpace.s1,
        NoorSpace.s2,
        NoorSpace.s3,
        NoorSpace.s4,
        NoorSpace.s5,
        NoorSpace.s6,
        NoorSpace.s7,
        NoorSpace.s8,
      ],
      [4, 8, 12, 16, 24, 32, 48, 64],
    );
    expect([NoorRadius.sm, NoorRadius.md, NoorRadius.lg, NoorRadius.pill],
        [8, 14, 24, 999]);
  });

  testWidgets('text styles carry the Amiri fallback and tokens.json metrics',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      theme: NoorTheme.light(),
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    final styles = {
      'displayXl': NoorText.displayXl(ctx),
      'displayLg': NoorText.displayLg(ctx),
      'title': NoorText.title(ctx),
      'heading': NoorText.heading(ctx),
      'body': NoorText.body(ctx),
      'bodySm': NoorText.bodySm(ctx),
      'label': NoorText.label(ctx),
      'eyebrow': NoorText.eyebrow(ctx),
      'caption': NoorText.caption(ctx),
      'arabicDisplay': NoorText.arabicDisplay(ctx),
      'arabicBody': NoorText.arabicBody(ctx),
      'numeral': NoorText.numeral(ctx),
    };
    for (final s in styles.entries) {
      expect(s.value.fontFamilyFallback, contains('Amiri'), reason: s.key);
    }
    expect(NoorText.displayXl(ctx).fontFamily, 'Cormorant Garamond');
    expect(NoorText.displayXl(ctx).fontSize, 56);
    expect(NoorText.displayXl(ctx).height, closeTo(60 / 56, 1e-9));
    expect(NoorText.body(ctx).fontFamily, 'Jost');
    expect(NoorText.arabicBody(ctx).fontFamily, 'Amiri');
    expect(NoorText.numeral(ctx).fontFamily, 'Cormorant Garamond');
  });
}
