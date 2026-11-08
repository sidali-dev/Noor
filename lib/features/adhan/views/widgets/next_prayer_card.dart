import 'package:flutter/material.dart';
import 'package:noor/core/widgets/noor_card.dart';
import 'package:noor/core/widgets/noor_cloud.dart';
import 'package:noor/core/theme/app_theme.dart';

/// The one window of the Prayers screen: the next prayer's time and how long
/// until it, centred over the arabesque band. No art behind the time: the band
/// keeps to the foot and the text is padded clear of it at any scale.
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
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _cloudHeight,
            child: NoorMotifBand(height: _cloudHeight),
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
