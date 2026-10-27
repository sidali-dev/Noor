import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class IconTile extends StatelessWidget {
  final IconData? icon;
  final String? svg;
  final NoorTint tint;
  final double size;

  const IconTile({
    super.key,
    this.icon,
    this.svg,
    required this.tint,
    this.size = 48,
  }) : assert(
            icon != null || svg != null, 'Either icon or svg must be provided');

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final bg = n.tintBg(tint);
    final fg = n.tintFg(tint);
    final iconSize = size * 0.5;

    Widget visual;
    if (svg != null) {
      visual = SvgPicture.asset(
        svg!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
      );
    } else {
      visual = Icon(
        icon,
        size: iconSize,
        color: fg,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: visual,
    );
  }
}
