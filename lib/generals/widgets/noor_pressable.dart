import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_theme.dart';

/// Press feedback shared by [NoorButton] and a tappable [NoorCard]: the paper
/// moves 1 dp down while pressed (the caller drops its shadow to `shadow-1`
/// in [builder]) and a keyboard-focused control gets a 2 dp brass ring with a
/// 2 dp gap. The ring is painted outside the box and never changes layout.
const kNoorPressDuration = Duration(milliseconds: 120);

class NoorPressable extends StatefulWidget {
  const NoorPressable({
    super.key,
    required this.onPressed,
    required this.radius,
    required this.builder,
  });

  /// Null disables press, focus and the pointer cursor.
  final VoidCallback? onPressed;

  /// Corner radius of the surface the ring hugs.
  final double radius;

  final Widget Function(BuildContext context, bool pressed) builder;

  static const _ringWidth = 2.0;
  static const _ringOffset = 2.0;

  @override
  State<NoorPressable> createState() => _NoorPressableState();
}

class _NoorPressableState extends State<NoorPressable> {
  bool _pressed = false;
  bool _focused = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final pressed = enabled && _pressed;
    const out = NoorPressable._ringWidth + NoorPressable._ringOffset;

    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          // The whole box takes the tap, not just what it paints: padding and
          // the gap between a row's icon and text are part of the tile.
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTap: widget.onPressed,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              AnimatedContainer(
                // Reduced motion: the 1 dp step still shows, without easing.
                duration: noorDuration(context, kNoorPressDuration),
                curve: Curves.ease,
                transform: Matrix4.translationValues(
                  0,
                  pressed ? kNoorPressDistance : 0,
                  0,
                ),
                child: widget.builder(context, pressed),
              ),
              if (_focused && enabled)
                Positioned(
                  left: -out,
                  top: -out,
                  right: -out,
                  bottom: -out,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.radius + out),
                        border: Border.all(
                          color: context.noor.brass,
                          width: NoorPressable._ringWidth,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
