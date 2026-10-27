import 'package:flutter/material.dart';
import 'package:noor/utils/theme/noor_theme.dart';

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
    final borderRadius = BorderRadius.circular(NoorRadius.input);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: borderRadius,
        boxShadow: noorShadow(context),
        border: n.isDark ? Border.all(color: n.line, width: 1) : null,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _effectiveController,
        onChanged: widget.onChanged,
        style: NoorText.body(context).copyWith(color: n.ink),
        cursorColor: n.primary,
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: widget.hint,
          hintStyle: NoorText.body(context).copyWith(color: n.muted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NoorSpace.md,
            vertical: NoorSpace.sm + 2,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: NoorSpace.md,
              end: NoorSpace.sm,
            ),
            child: Icon(
              Icons.search_rounded,
              color: n.muted,
              size: 22,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: n.muted,
                    size: 20,
                  ),
                  onPressed: _clear,
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                )
              : null,
          suffixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
