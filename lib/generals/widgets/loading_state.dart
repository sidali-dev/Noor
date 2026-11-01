import 'package:flutter/material.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// The one loading mark: three `ink` dots that fade in turn, in place (no
/// bounce), or stand still when the system asks for reduced motion.
// ponytail: the one loop outside the Hilal list (compass, calibration guide,
// alarm screen, hero stars); a loading mark has to move to read as loading.
class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = context.noor.ink;
    final still = MediaQuery.disableAnimationsOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.all(NoorSpace.s1),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // A triangle wave 0.3..1, each dot a third of a cycle late.
                final p = (_controller.value + i / 3) % 1;
                return Opacity(
                  opacity: still ? 1 : 0.3 + 0.7 * (1 - (2 * p - 1).abs()),
                  child: child,
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
                child: const SizedBox(width: 12, height: 12),
              ),
            ),
          ),
      ],
    );
  }
}

/// Loading in place of content: [LoadingDots] and, when given, one sentence.
/// It has no button: the work cannot be cancelled. Screen readers hear
/// [message], or the generic wait sentence, as a live region.
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NoorSpace.s6),
        child: Semantics(
          liveRegion: true,
          label: message ?? S.of(context).wait_please,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingDots(),
                if (message != null) ...[
                  const SizedBox(height: NoorSpace.s4),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: NoorText.body(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
