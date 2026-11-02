import 'package:flutter/material.dart';
import 'package:noor/generals/widgets/noor_cartouche.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/utils/theme/noor_theme.dart';

const double _ringWidth = 2;
const double _ringGap = 2;

/// A [NoorCartouche] to type in: the search icon at the start, a star at the end
/// that gives way to a clear button once there is text. Focus adds the brass
/// ring and settles it to `shadow-1`. The hint is the only label; the hero
/// overlap slot has no room for another.
class NoorSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const NoorSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
  });

  @override
  State<NoorSearchField> createState() => _NoorSearchFieldState();
}

class _NoorSearchFieldState extends State<NoorSearchField> {
  late TextEditingController _effectiveController;
  final FocusNode _focusNode = FocusNode();
  bool _isInternalController = false;
  bool _hasText = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    } else {
      _effectiveController = widget.controller!;
    }
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant NoorSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_isInternalController) {
        _effectiveController.removeListener(_onTextChanged);
        _effectiveController.dispose();
      }
      if (widget.controller == null) {
        _effectiveController = TextEditingController();
        _isInternalController = true;
      } else {
        _effectiveController = widget.controller!;
        _isInternalController = false;
      }
      _hasText = _effectiveController.text.isNotEmpty;
      _effectiveController.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    final nowHasText = _effectiveController.text.isNotEmpty;
    if (_hasText != nowHasText) {
      setState(() {
        _hasText = nowHasText;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _effectiveController.removeListener(_onTextChanged);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _clear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    const out = _ringWidth + _ringGap;

    // Fixed at 56 dp, the hero's overlap slot. The ring falls outside it.
    return SizedBox(
      height: 56,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (v) => setState(() => _focused = v),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            // The text line is 24 dp of a 56 dp pill: all of the pill belongs
            // to the field, for focusing it and for staying focused.
            TextFieldTapRegion(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _focusNode.requestFocus,
                child: NoorCartouche(
                  settled: _focused,
                  endInset: _hasText ? NoorSpace.s1 : NoorSpace.s4,
                  leading: NoorIcon(
                    NoorGlyph.search,
                    color: n.onWindowMuted,
                    size: 22,
                  ),
                  trailing: _hasText
                      ? NoorCloudButton(
                          size: 40,
                          tooltip: MaterialLocalizations.of(context)
                              .clearButtonTooltip,
                          icon: const Icon(Icons.close_rounded),
                          onTap: _clear,
                        )
                      : null,
                  // Brass stays off the window (design.md 6.2), and the theme's
                  // selection is pale enough to swallow the text on it.
                  child: TextSelectionTheme(
                    data: TextSelectionTheme.of(context).copyWith(
                      selectionColor: n.onWindowMuted.withValues(alpha: 0.4),
                    ),
                    child: TextField(
                      controller: _effectiveController,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      // Touch keeps focus outside the field by default, and
                      // with it the ring, once the keyboard is gone.
                      onTapOutside: (_) => _focusNode.unfocus(),
                      style: NoorText.body(context).copyWith(color: n.onWindow),
                      cursorColor: n.onWindow,
                      // Collapsed leaves these null, so the theme's would
                      // draw a second ring around the text and shift it on
                      // focus.
                      decoration: InputDecoration.collapsed(
                        hintText: widget.hint,
                        hintStyle: NoorText.body(context).copyWith(
                          color: n.onWindowMuted,
                        ),
                      ).copyWith(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_focused)
              const PositionedDirectional(
                start: -out,
                end: -out,
                top: -out,
                bottom: -out,
                child: _FocusRing(),
              ),
          ],
        ),
      ),
    );
  }
}

/// The brass focus ring: 2 dp, 2 dp outside the pill, painted over nothing.
class _FocusRing extends StatelessWidget {
  const _FocusRing();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NoorRadius.pill),
          border: Border.all(color: context.noor.brass, width: _ringWidth),
        ),
      ),
    );
  }
}
