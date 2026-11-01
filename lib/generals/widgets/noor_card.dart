import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// `paper` is raised paper; `night` is a window into the sky, for the one
/// most time-sensitive thing on a screen.
enum NoorCardTone { paper, night }

/// Hilal PaperCard: `surface-raised`, `shadow-2`, radius 24, no border. With
/// [onTap] it presses 1 dp down and drops to `shadow-1`.
///
/// On the night tone, descendants that read `context.noor` / the text theme
/// below this card get `on-window` colours; styles a caller resolved above the
/// card keep their own colour and must use `onWindow` themselves.
class NoorCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final NoorCardTone tone;

  const NoorCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.tone = NoorCardTone.paper,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final night = tone == NoorCardTone.night;
    final radius = BorderRadius.circular(NoorRadius.lg);

    Widget body = Material(
      color: Colors.transparent,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(NoorSpace.s4),
        child: child,
      ),
    );
    if (night) {
      final theme = Theme.of(context);
      body = Theme(
        data: theme.copyWith(
          extensions: [n.copyWith(ink: n.onWindow, muted: n.onWindowMuted)],
          textTheme: theme.textTheme
              .apply(bodyColor: n.onWindow, displayColor: n.onWindow),
          iconTheme: theme.iconTheme.copyWith(color: n.onWindow),
        ),
        child: body,
      );
    }

    return NoorPressable(
      onPressed: onTap,
      radius: NoorRadius.lg,
      builder: (context, pressed) => AnimatedContainer(
        duration: kNoorPressDuration,
        curve: Curves.ease,
        decoration: BoxDecoration(
          color: night ? n.window : n.card,
          borderRadius: radius,
          boxShadow: pressed ? n.shadow1 : n.shadow2,
        ),
        // The window is nearly the Night ground (1.07:1), so in Night only the
        // contract adds a decorative 1 dp `line` seam inside its edge.
        foregroundDecoration: night && n.isDark
            ? BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: n.line),
              )
            : null,
        child: body,
      ),
    );
  }
}
