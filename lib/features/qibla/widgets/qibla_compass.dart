import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noor/utils/constants/sizes.dart';
import 'dart:math' show pi;

import '../../../generated/l10n.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';

class QiblaCompass extends StatelessWidget {
  final _compassSvg = SvgPicture.asset('assets/images/svg/compass.svg');
  final _needleSvg = SvgPicture.asset(
    'assets/images/svg/needle.svg',
    height: 120,
  );

  QiblaCompass({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    final isRtl = SHelperFunctions.isRtl(context);
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SpinKitThreeBounce(
                  color: isDark ? SColors.secondary : SColors.primary));
        }

        QiblahDirection qiblahDirection = snapshot.data!;

        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Transform.rotate(
                  angle: (qiblahDirection.direction * (pi / 180) * -1),
                  child: _compassSvg,
                ),
                Transform.rotate(
                  angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                  alignment: Alignment.center,
                  child: _needleSvg,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              S.of(context).qiblah_is_at,
              style: TextStyle(
                  fontSize: isRtl ? SSizes.fontSizeLgAr : SSizes.fontSizeLg),
              textAlign: TextAlign.center,
            ),
            Text(
              "${qiblahDirection.offset.toStringAsFixed(2)}°",
              style: TextStyle(
                  color: isDark ? SColors.secondary : SColors.primary,
                  fontSize: isRtl ? SSizes.fontSizeLgAr : SSizes.fontSizeLg),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
