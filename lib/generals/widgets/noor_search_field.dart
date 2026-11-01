import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/generals/widgets/noor_icon.dart';
import 'package:noor/generals/widgets/noor_well.dart';
import 'package:noor/utils/theme/noor_theme.dart';

const double _ringWidth = 2;
const double _ringGap = 2;

/// A `surface-sunken` well (inset shadow, `line-strong` border) 48 dp tall with
/// the search icon at the start and a 48 dp clear button once there is text.
/// The hint is the only label; the hero overlap slot has no room for another.
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

    // Fixed at 48 dp: the hero's overlap slot is 56, so the ring fits in it.
    return SizedBox(
      height: 48,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (v) => setState(() => _focused = v),
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            NoorWell(
              radius: NoorRadius.sm,
              border: true,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: NoorSpace.s3,
                      end: NoorSpace.s2,
                    ),
                    child: NoorIcon(NoorGlyph.search, color: n.muted, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _effectiveController,
                      onChanged: widget.onChanged,
                      style: NoorText.body(context),
                      cursorColor: n.brass,
                      decoration: InputDecoration.collapsed(
                        hintText: widget.hint,
                        hintStyle: NoorText.body(context).copyWith(
                          color: n.muted,
                        ),
                      ),
                    ),
                  ),
                  if (_hasText)
                    IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).clearButtonTooltip,
                      icon:
                          Icon(Iconsax.close_circle, color: n.muted, size: 22),
                      onPressed: _clear,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 48, height: 48),
                    ),
                ],
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

/// The brass focus ring: 2 dp, 2 dp outside the well, painted over nothing.
class _FocusRing extends StatelessWidget {
  const _FocusRing();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            NoorRadius.sm + _ringWidth + _ringGap,
          ),
          border: Border.all(color: context.noor.brass, width: _ringWidth),
        ),
      ),
    );
  }
}
