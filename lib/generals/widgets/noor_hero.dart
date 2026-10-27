import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/generals/widgets/settings_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Per-screen header: illustrated sky under the status bar, title block at the
/// start, optional gear at the end, optional [overlap] straddling the bottom.
///
/// The widget is `height` plus half the overlap tall, so the content that
/// follows is not covered.
class NoorHero extends StatelessWidget {
  /// A [NoorArt] base; null draws the flat sky gradient instead.
  final String? art;
  final String title;
  final String? subtitle;

  /// Sets [title] as the LTR wordmark next to [leading].
  final bool wordmark;
  final Widget? leading;
  final bool settings;
  final double height;

  /// A 48-56 dp child that overlaps the bottom edge by half its height.
  final Widget? overlap;

  const NoorHero({
    super.key,
    this.art,
    required this.title,
    this.subtitle,
    this.wordmark = false,
    this.leading,
    this.settings = false,
    this.height = 240,
    this.overlap,
  });

  static const double _overlapHeight = 56;
  static const double _gutter = NoorSpace.xl;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final art = this.art;
    final safeTop = MediaQuery.paddingOf(context).top;
    final reserve = overlap == null ? 0.0 : _overlapHeight / 2;
    final flip = Directionality.of(context) == TextDirection.rtl &&
        (art == null || !NoorArt.noMirror.contains(art));
    final clear = n.paper.withValues(alpha: 0);

    final contentTop = safeTop + NoorSpace.xs;
    final contentBottom = height - reserve - NoorSpace.sm;

    return SizedBox(
      height: height + reserve,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height,
            child: art == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.alphaBlend(
                            n.tintFg(NoorTint.sage).withValues(alpha: 0.04),
                            n.paper,
                          ),
                          n.paper,
                        ],
                      ),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ExcludeSemantics(
                        child: Transform.flip(
                          flipX: flip,
                          child: Image.asset(
                            NoorArt.of(context, art),
                            fit: BoxFit.cover,
                            // The asset's subject sits top-right; the flip
                            // above moves it to the left in RTL.
                            alignment: Alignment.topRight,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                            frameBuilder: (_, child, frame, sync) => sync
                                ? child
                                : AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    child: child,
                                  ),
                          ),
                        ),
                      ),
                      // Keeps the title legible: calm paper at the start side
                      // and along the bottom edge.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: AlignmentDirectional.centerStart,
                            end: AlignmentDirectional.centerEnd,
                            colors: [
                              n.paper.withValues(alpha: 0.85),
                              clear,
                            ],
                            stops: const [0, 0.7],
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [clear, clear, n.paper],
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          PositionedDirectional(
            top: contentTop,
            start: _gutter,
            end: _gutter,
            height: math.max(0, contentBottom - contentTop),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: FractionallySizedBox(
                widthFactor: 0.66,
                child: _titleBlock(context),
              ),
            ),
          ),
          if (settings)
            PositionedDirectional(
              top: contentTop,
              end: NoorSpace.sm,
              child: IconButton(
                icon: Icon(Iconsax.setting_2, color: n.ink, size: 22),
                onPressed: () => showSettingsSheet(context),
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                tooltip: S.of(context).settings,
              ),
            ),
          if (overlap != null)
            PositionedDirectional(
              start: _gutter,
              end: _gutter,
              bottom: 0,
              height: _overlapHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [overlap!],
              ),
            ),
        ],
      ),
    );
  }

  Widget _titleBlock(BuildContext context) {
    final n = context.noor;
    final gap = SizedBox(width: leading == null ? 0 : NoorSpace.sm + 2);

    return Semantics(
      header: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wordmark)
            SizedBox(
              height: 48,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) leading!,
                    gap,
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: NoorText.wordmark(context),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: NoorSpace.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) leading!,
                    gap,
                    Flexible(
                      child: Text(
                        title,
                        style: NoorText.display(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (subtitle != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: NoorSpace.xs),
                child: Text(
                  subtitle!,
                  style: NoorText.meta(context).copyWith(color: n.body),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
