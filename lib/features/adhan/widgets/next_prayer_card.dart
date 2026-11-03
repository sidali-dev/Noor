import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The one window of the Prayers screen: the next prayer's time and how long
/// until it, centred over a bank of paper clouds. No art behind the time: the
/// clouds keep to the foot and the text is padded clear of them at any scale.
class NextPrayerCard extends StatelessWidget {
  final String time;

  /// "Dhuhr in 1h 35m".
  final String countdown;

  const NextPrayerCard({
    super.key,
    required this.time,
    required this.countdown,
  });

  static const double _cloudHeight = 52;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;

    return NoorCard(
      tone: NoorCardTone.night,
      padding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _cloudHeight + CloudBankPainter.headroom,
            child: CustomPaint(
              painter: CloudBankPainter(
                back: n.isDark ? n.windowRaised : n.surfaceSunken,
                front: n.card,
                lip: n.isDark ? n.depthShadow : null,
                shade: n.depthShadow,
                pixelRatio: MediaQuery.devicePixelRatioOf(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NoorSpace.s5,
              NoorSpace.s5,
              NoorSpace.s5,
              _cloudHeight + NoorSpace.s2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  textDirection: TextDirection.ltr,
                  style: NoorText.numeral(context, size: 56, color: n.onWindow)
                      .copyWith(height: 60 / 56),
                ),
                const SizedBox(height: NoorSpace.s1),
                Text(
                  countdown,
                  textAlign: TextAlign.center,
                  style: NoorText.heading(context).copyWith(color: n.onWindow),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
