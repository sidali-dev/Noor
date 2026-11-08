import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:noor/core/widgets/noor_pressable.dart';
import 'package:noor/core/widgets/noor_well.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/core/constants/assets/images.dart';
import 'package:noor/core/theme/noor_layout.dart';
import 'package:noor/core/theme/noor_motion.dart';
import 'package:noor/core/theme/app_theme.dart';

/// Hilal TabBar, cut like the text field ([NoorCartouche]): a capsule of raised
/// `surface-raised` paper with `shadow-2`, floating `s4` above the bottom safe
/// area and `s4` in from the sides of the content column ([NoorLayout]), holding
/// a pressed-in capsule trough ([NoorWell]). The selector is a thick cut-paper
/// capsule of night sky (`window`; moon-white `onWindow` in Night) that fills
/// its quarter of the trough edge to edge and top to bottom, and slides to the
/// chosen tab; its icon and label take the opposite colour as it arrives. The
/// others lie in the trough as `ink-muted`. Every icon is in the Kaaba's navy
/// and cream on a round plate.
///
/// Depth is pure cut paper and shadow (no gloss or gradient): a flat matte face
/// with a 1 dp cut-paper top lip, a stepped lower edge showing the slab's
/// thickness, and a multi-layered backdrop shadow cast onto the trough floor
/// beside it.
///
/// Holding the active indicator picks it up: it grows larger in size, lifts
/// slightly out of the trough with a deeper shadow, and can be dragged left and
/// right across the bar. The tab under the dragged indicator highlights as it
/// passes over, and the screen switches once the finger lets go.
///
/// The widget's own height includes the safe area and the floating gap, so
/// `Scaffold` reserves exactly the room the bar covers. Items are laid out in
/// source order and mirror with the ambient [Directionality], and the selector
/// slides the same way round.
class NoorNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NoorNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const select = Duration(milliseconds: 300);

  @override
  State<NoorNavBar> createState() => _NoorNavBarState();
}

const _pill = BorderRadius.all(Radius.circular(NoorRadius.pill));

class _NoorNavBarState extends State<NoorNavBar> {
  int? _activePointer;
  double _downX = 0;
  double _startIndex = 0;

  /// True while a finger is holding or dragging the active indicator, causing
  /// it to scale up in size.
  bool _grabbed = false;

  /// True once the held indicator has moved horizontally.
  bool _dragging = false;

  /// Continuous tab position (`0.0` .. `count - 1`) while grabbed/dragging.
  double? _dragIndex;

  void _onPointerDown(
    PointerDownEvent event,
    double troughWidth,
    int count,
    TextDirection dir,
  ) {
    if (_activePointer != null || troughWidth <= 0) return;
    final slotWidth = troughWidth / count;
    final relX = dir == TextDirection.rtl
        ? troughWidth - event.localPosition.dx
        : event.localPosition.dx;
    final touchedSlot = (relX / slotWidth).floor().clamp(0, count - 1);
    if (touchedSlot != widget.selectedIndex) return;

    _activePointer = event.pointer;
    _downX = event.localPosition.dx;
    _startIndex = widget.selectedIndex.toDouble();
    setState(() {
      _grabbed = true;
      _dragging = false;
      _dragIndex = _startIndex;
    });
  }

  void _onPointerMove(
    PointerMoveEvent event,
    double troughWidth,
    int count,
    TextDirection dir,
  ) {
    if (event.pointer != _activePointer || troughWidth <= 0) return;
    final dx = event.localPosition.dx - _downX;
    if (!_dragging && dx.abs() > 2.0) {
      _dragging = true;
    }
    if (_dragging) {
      final slotWidth = troughWidth / count;
      final signedDx = dir == TextDirection.rtl ? -dx : dx;
      final next = (_startIndex + signedDx / slotWidth)
          .clamp(0.0, (count - 1).toDouble());
      setState(() => _dragIndex = next);
    }
  }

  void _onPointerUp(PointerUpEvent event, int count) {
    if (event.pointer != _activePointer) return;
    final wasDragging = _dragging;
    final target = (_dragIndex ?? widget.selectedIndex.toDouble())
        .round()
        .clamp(0, count - 1);
    _activePointer = null;
    setState(() {
      _grabbed = false;
      _dragging = false;
      _dragIndex = null;
    });
    if (wasDragging && target != widget.selectedIndex) {
      widget.onItemSelected(target);
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    setState(() {
      _grabbed = false;
      _dragging = false;
      _dragIndex = null;
    });
  }

  @override
  void didUpdateWidget(NoorNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _activePointer != null &&
        !_dragging) {
      _activePointer = null;
      _grabbed = false;
      _dragIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    final selectedIndex = widget.selectedIndex;
    final dir = Directionality.of(context);

    final items = [
      (svg: AppImages.navQuran, label: s.nav_quran),
      (svg: AppImages.navMosque, label: s.nav_prayers),
      (svg: AppImages.navTasbih, label: s.nav_adhkar),
      (svg: AppImages.kaaba, label: s.nav_qibla),
    ];
    final count = items.length;

    final duration = noorDuration(context, NoorNavBar.select);
    final currentPos = _dragIndex ?? selectedIndex.toDouble();
    final alignX = -1 + 2 * currentPos / (count - 1);
    // Track the finger 1:1 while dragging; animate smoothly on tap or release.
    final alignDuration = _dragging ? Duration.zero : duration;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: NoorLayout.gutter(context),
        end: NoorLayout.gutter(context),
        bottom: MediaQuery.paddingOf(context).bottom + NoorSpace.s4,
      ),
      // No height here: the bar grows with the label's text scale.
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: n.card,
          borderRadius: _pill,
          boxShadow: n.shadow2,
        ),
        child: Padding(
          padding: const EdgeInsets.all(NoorSpace.s1),
          // Labels only: the icon and the tap target keep their size.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Material(
              type: MaterialType.transparency,
              animationDuration: Duration.zero,
              child: NoorWell(
                radius: NoorRadius.pill,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final troughWidth = box.maxWidth;
                    return Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: (e) =>
                          _onPointerDown(e, troughWidth, count, dir),
                      onPointerMove: (e) =>
                          _onPointerMove(e, troughWidth, count, dir),
                      onPointerUp: (e) => _onPointerUp(e, count),
                      onPointerCancel: _onPointerCancel,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        // Claim horizontal drags in the gesture arena so a drag
                        // on the indicator never triggers an inner tap or page
                        // swipe.
                        onHorizontalDragUpdate: _grabbed ? (_) {} : null,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Wide backdrop shadow cast onto the trough
                            //    floor, clipped to the trough walls so it stays
                            //    inside the groove.
                            Positioned.fill(
                              child: IgnorePointer(
                                child: ClipRRect(
                                  borderRadius: _pill,
                                  child: AnimatedAlign(
                                    duration: alignDuration,
                                    curve: Curves.easeOutCubic,
                                    alignment: AlignmentDirectional(alignX, 0),
                                    child: FractionallySizedBox(
                                      widthFactor: 1 / count,
                                      heightFactor: 1,
                                      child: _TroughBackdropShadow(
                                        grabbed: _grabbed,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 2. The cut-paper selector slab itself, unclipped
                            //    so when held and dragged it can grow larger
                            //    than the trough without its edges being cut.
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedAlign(
                                  duration: alignDuration,
                                  curve: Curves.easeOutCubic,
                                  alignment: AlignmentDirectional(alignX, 0),
                                  child: FractionallySizedBox(
                                    widthFactor: 1 / count,
                                    heightFactor: 1,
                                    child: _Selector(grabbed: _grabbed),
                                  ),
                                ),
                              ),
                            ),
                            // 3. The tab items. Equal slots, so each item is
                            //    centred on its pill.
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: NoorSpace.s1,
                              ),
                              child: Row(
                                children: [
                                  for (var i = 0; i < count; i++)
                                    Expanded(
                                      child: _Item(
                                        svg: items[i].svg,
                                        label: items[i].label,
                                        selected: i == selectedIndex,
                                        dragSelection: _dragIndex == null
                                            ? null
                                            : (1.0 - (_dragIndex! - i).abs())
                                                .clamp(0.0, 1.0),
                                        grabbed: _grabbed,
                                        duration: duration,
                                        onTap: () {
                                          if (!_dragging) {
                                            widget.onItemSelected(i);
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The wide ambient shadow cast by the selector onto the sunken trough floor,
/// kept inside the trough's `ClipRRect`.
class _TroughBackdropShadow extends StatelessWidget {
  final bool grabbed;

  const _TroughBackdropShadow({required this.grabbed});

  static const _restPaper = [
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.24),
      offset: Offset(0, 2),
      blurRadius: 9,
      spreadRadius: 1.5,
    ),
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.16),
      offset: Offset(0, 3),
      blurRadius: 20,
      spreadRadius: 3,
    ),
  ];
  static const _restNight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.65),
      offset: Offset(0, 2),
      blurRadius: 9,
      spreadRadius: 1.5,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.45),
      offset: Offset(0, 3),
      blurRadius: 20,
      spreadRadius: 3,
    ),
  ];

  static const _grabbedPaper = [
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.30),
      offset: Offset(0, 3),
      blurRadius: 14,
      spreadRadius: 3,
    ),
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.20),
      offset: Offset(0, 5),
      blurRadius: 26,
      spreadRadius: 5,
    ),
  ];
  static const _grabbedNight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.78),
      offset: Offset(0, 3),
      blurRadius: 14,
      spreadRadius: 3,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.55),
      offset: Offset(0, 5),
      blurRadius: 26,
      spreadRadius: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = context.noor.isDark;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: grabbed ? 1 : 0),
      duration: noorDuration(context, const Duration(milliseconds: 160)),
      curve: Curves.easeOutCubic,
      builder: (context, g, _) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: _pill,
          boxShadow: BoxShadow.lerpList(
            dark ? _restNight : _restPaper,
            dark ? _grabbedNight : _grabbedPaper,
            g,
          ),
        ),
      ),
    );
  }
}

/// The travelling cut-paper slab, set into the trough with a tight contact
/// shadow and a stepped paper edge. When [grabbed] is true (held/dragged), it
/// scales up in size and lifts slightly out of the trough.
class _Selector extends StatelessWidget {
  final bool grabbed;

  const _Selector({required this.grabbed});

  static const _contactPaper = [
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.34),
      offset: Offset(0, 1),
      blurRadius: 2.5,
      spreadRadius: 0.5,
    ),
  ];
  static const _contactNight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.85),
      offset: Offset(0, 1),
      blurRadius: 2.5,
      spreadRadius: 0.5,
    ),
  ];

  // Lifted shadow when the indicator is held/dragged and enlarged.
  static const _liftedPaper = [
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.32),
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0.5,
    ),
    BoxShadow(
      color: Color.fromRGBO(23, 26, 33, 0.18),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];
  static const _liftedNight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.85),
      offset: Offset(0, 3),
      blurRadius: 6,
      spreadRadius: 0.5,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.60),
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];

  // Cut-paper underside tones: opaque matte cardstock thickness, never glossy.
  static const _edgePaper = Color(0xFF0B0D12);
  static const _edgeNight = Color(0xFFCFD3DC);

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final dark = n.isDark;
    // The window and what is drawn on it swap in Night, as every window does.
    final face = dark ? n.onWindow : n.window;
    final edge = dark ? _edgeNight : _edgePaper;
    final topLip = dark ? const Color(0xFFFFFFFF) : n.windowRaised;
    final shade = n.depthShadow;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: grabbed ? 1 : 0),
      duration: noorDuration(context, const Duration(milliseconds: 160)),
      curve: Curves.easeOutCubic,
      builder: (context, g, _) => Transform.translate(
        offset: Offset(0, -1.5 * g),
        child: Transform.scale(
          scaleX: 1.0 + 0.08 * g,
          scaleY: 1.0 + 0.14 * g,
          child: DecoratedBox(
            key: const ValueKey('nav-selector'),
            decoration: BoxDecoration(
              color: face,
              borderRadius: _pill,
              boxShadow: BoxShadow.lerpList(
                dark ? _contactNight : _contactPaper,
                dark ? _liftedNight : _liftedPaper,
                g,
              ),
            ),
            child: CustomPaint(
              painter: _SelectorPaperCut(
                face: face,
                edge: edge,
                topLip: topLip,
                shade: shade,
                grab: g,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stacked cut-paper geometry for the selector slab (no gradients or gloss):
/// - [edge] is the lower cardstock thickness visible along the foot of the
///   pill (2.5 dp at rest, thickening to 3.5 dp when lifted/grabbed);
/// - [topLip] is a crisp 1 dp cut-paper rim along the upper edge;
/// - [shade] casts a soft paper-cut shadow from the front sheet onto its
///   stepped lower edge.
class _SelectorPaperCut extends CustomPainter {
  final Color face;
  final Color edge;
  final Color topLip;
  final Color shade;
  final double grab;

  _SelectorPaperCut({
    required this.face,
    required this.edge,
    required this.topLip,
    required this.shade,
    required this.grab,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final radius = Radius.circular(size.shortestSide / 2);
    final outer = RRect.fromRectAndRadius(bounds, radius);

    canvas.save();
    canvas.clipRRect(outer);

    // 1. Cut-paper bottom thickness: the full capsule is filled with the
    //    underside tone, and the front sheet sits `thickness` dp above the
    //    foot (2.5 dp at rest, 3.5 dp when lifted).
    final thickness = 2.5 + 1.0 * grab;
    canvas.drawRRect(outer, Paint()..color = edge);

    final sheetRect = Rect.fromLTRB(0, 0, size.width, size.height - thickness);
    final sheet = RRect.fromRectAndRadius(
      sheetRect,
      Radius.circular(sheetRect.shortestSide / 2),
    );

    // Subtle paper-cut shadow cast by the front sheet onto its lower cut edge.
    canvas.drawRRect(
      sheet.shift(const Offset(0, 1)),
      Paint()
        ..color = shade.withValues(alpha: shade.a * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );

    // 2. Crisp 1 dp top cut-paper lip along the upper rim, with the flat matte
    //    face below it (no gradient, no gloss).
    const lipThickness = 1.0;
    canvas.drawRRect(sheet, Paint()..color = topLip);
    final faceRect = Rect.fromLTRB(
      0,
      lipThickness,
      size.width,
      size.height - thickness,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        faceRect,
        Radius.circular(faceRect.shortestSide / 2),
      ),
      Paint()..color = face,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SelectorPaperCut old) =>
      face != old.face ||
      edge != old.edge ||
      topLip != old.topLip ||
      shade != old.shade ||
      grab != old.grab;
}

class _Item extends StatelessWidget {
  final String svg;
  final String label;
  final bool selected;

  /// Non-null (`0.0` .. `1.0`) while the indicator is being dragged, so the
  /// tab currently under the dragged pill highlights in real time.
  final double? dragSelection;
  final bool grabbed;
  final Duration duration;
  final VoidCallback onTap;

  const _Item({
    required this.svg,
    required this.label,
    required this.selected,
    required this.dragSelection,
    required this.grabbed,
    required this.duration,
    required this.onTap,
  });

  // Every icon is drawn in its own colours on a round plate, the Kaaba's way;
  // it is contained in the 22 x 18 the Kaaba takes.
  static const double _icon = 22;
  static const double _iconHeight = 18;
  static const double _slot = 28;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final labelStyle = NoorText.caption(context);
    // The window and what is drawn on it swap in Night, as every window does.
    final onPill = n.isDark ? n.window : n.onWindow;

    Widget buildContent(double t) {
      final color = Color.lerp(n.muted, onPill, t)!;
      final isHighlighted = t >= 0.5;
      return TweenAnimationBuilder<double>(
        tween: Tween(end: grabbed ? t : 0),
        duration: noorDuration(context, const Duration(milliseconds: 160)),
        curve: Curves.easeOutCubic,
        builder: (context, lift, child) => Transform.translate(
          offset: Offset(0, -1.5 * lift),
          child: Transform.scale(
            scale: 1.0 + 0.05 * lift,
            child: child,
          ),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            vertical: NoorSpace.s1,
            horizontal: NoorSpace.s1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: _slot,
                child: Center(
                  child: _Plate(
                    // Dark on dark otherwise: the art stands on paper,
                    // light enough to read on every state.
                    color: Color.lerp(
                      n.isDark ? n.onWindowMuted : n.card,
                      n.onWindow,
                      t,
                    )!,
                    child: SvgPicture.asset(
                      svg,
                      width: _icon,
                      height: _iconHeight,
                    ),
                  ),
                ),
              ),
              Text(
                label,
                style: labelStyle.copyWith(
                  color: color,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: NoorPressable(
        onPressed: onTap,
        radius: NoorRadius.pill,
        builder: (context, pressed) {
          if (dragSelection != null) {
            return buildContent(dragSelection!);
          }
          return TweenAnimationBuilder<double>(
            tween: Tween(end: selected ? 1 : 0),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => buildContent(t),
          );
        },
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  final Color color;
  final Widget child;

  const _Plate({required this.color, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: SizedBox.square(
          dimension: _Item._slot,
          child: Center(child: child),
        ),
      );
}
