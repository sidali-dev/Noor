import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_pressable.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// [child] on the owner's arabesque ornament: stacked paper round a raised
/// disc, baked by `tool/motif_art.py`. [plain] is the disc alone, for where the
/// ornament cannot fit: an ayah marker in a line of text, a button in a pill.
class CloudMedallion extends StatelessWidget {
  final double size;
  final Widget child;
  final bool plain;

  /// How much of [size] the child may take. The disc is under half the
  /// ornament, so the default keeps it on the disc's flat face.
  final double? face;

  /// 0 to 1: how much it glows, for the one that is pressed. A soft halo of the
  /// window colour (moon-white in Night) round the disc.
  final double glow;

  const CloudMedallion({
    super.key,
    required this.size,
    required this.child,
    this.plain = false,
    this.face,
    this.glow = 0,
  });

  // In the image: tool/motif_art.py prints where the disc falls.
  static const double _ornamentFace = 0.38;
  static const double _plainFace = 0.62;

  // Strong enough to see on raised paper, soft enough not to contrast with it.
  static const double _glowAlpha = 0.32;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final variant = n.isDark ? 'night' : 'paper';

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (glow > 0)
            SizedBox.square(
              dimension: size * (plain ? 0.8 : 0.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (n.isDark ? n.onWindow : n.window)
                          .withValues(alpha: _glowAlpha * glow),
                      blurRadius: size * 0.25,
                      spreadRadius: size * 0.08,
                    ),
                  ],
                ),
              ),
            ),
          Positioned.fill(
            child: Image.asset(
              plain ? NoorArt.disc(variant) : NoorArt.ornament(variant),
              excludeFromSemantics: true,
              gaplessPlayback: true,
            ),
          ),
          SizedBox(
            width: size * (face ?? (plain ? _plainFace : _ornamentFace)),
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        ],
      ),
    );
  }
}

/// An icon button on the ornament, [size] whatever row it stands in, so the
/// icon stays readable on the disc. [plain] is 40 dp on the disc alone with a
/// 48 dp target, for the one place the ornament cannot fit: inside a 56 dp pill.
/// [icon] takes its size and colour from here unless it sets its own, and is
/// muted with no [onTap].
class NoorCloudButton extends StatelessWidget {
  final Widget icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool plain;

  const NoorCloudButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.plain = false,
  });

  static const double size = 64;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final button = NoorPressable(
      onPressed: onTap,
      radius: NoorRadius.pill,
      builder: (context, pressed) => Container(
        // Transparent, not absent: the corners of the target take taps too.
        color: Colors.transparent,
        width: plain ? 48 : size,
        height: plain ? 48 : size,
        alignment: Alignment.center,
        child: CloudMedallion(
          size: plain ? 40 : size,
          plain: plain,
          glow: pressed ? 1 : 0,
          child: IconTheme.merge(
            data: IconThemeData(
              size: plain ? 22 : 18,
              color: onTap == null ? n.line : n.ink,
            ),
            child: icon,
          ),
        ),
      ),
    );
    final message = tooltip;
    return message == null ? button : Tooltip(message: message, child: button);
  }
}

/// The leading mark of a list row: [icon] on the ornament.
class NoorCloudIcon extends StatelessWidget {
  final Widget icon;

  const NoorCloudIcon(this.icon, {super.key});

  /// Also the index number's: every row leads with the same mark.
  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    return CloudMedallion(
      size: size,
      child: IconTheme.merge(
        data: IconThemeData(size: 16, color: context.noor.ink),
        child: icon,
      ),
    );
  }
}

/// The owner's arabesque border as a seamless band: stacked paper with real
/// holes and its shadow baked in, so it sits on any paper. It keeps its light
/// from above, so a sheet's hangs from the head the same way up.
class NoorMotifBand extends StatelessWidget {
  final double height;

  const NoorMotifBand({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        NoorArt.band(context.noor.isDark ? 'night' : 'paper'),
        excludeFromSemantics: true,
        fit: BoxFit.fitHeight,
        repeat: ImageRepeat.repeatX,
        gaplessPlayback: true,
      ),
    );
  }
}
