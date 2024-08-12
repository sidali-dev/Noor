import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class SDivider extends StatelessWidget {
  final Color? color;
  final double? indent;
  final double? endIndent;
  final double? thickness;
  final double? space;

  const SDivider({
    super.key,
    this.color = SColors.accent,
    this.space = 8.0,
    this.indent = 50.0,
    this.endIndent = 50.0,
    this.thickness = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: space),
        Divider(
          color: color,
          indent: indent,
          endIndent: endIndent,
          thickness: thickness,
        ),
        SizedBox(height: space),
      ],
    );
  }
}
