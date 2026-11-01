import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_pager_pill.dart';
import 'package:noor/generals/widgets/noor_progress_bar.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/theme/noor_motion.dart';
import 'package:noor/utils/theme/noor_layout.dart';
import 'package:noor/utils/theme/noor_theme.dart';

class AdhkarDisplayScreen extends StatefulWidget {
  final String title;
  final List<AdhkarModel> adhkar;
  final int initialIndex;

  const AdhkarDisplayScreen({
    super.key,
    required this.title,
    required this.adhkar,
    this.initialIndex = 0,
  });

  @override
  State<AdhkarDisplayScreen> createState() => _AdhkarDisplayScreenState();
}

class _AdhkarDisplayScreenState extends State<AdhkarDisplayScreen> {
  Duration get _slide =>
      noorDuration(context, const Duration(milliseconds: 240));

  late int _currentIndex;
  late int _repetition;
  bool _isCompleted = false;
  late final CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.adhkar.isEmpty ? 0 : widget.adhkar.length - 1,
    );
    if (widget.adhkar.isNotEmpty) {
      _repetition = widget.adhkar[_currentIndex].dhikrRepetition;
    } else {
      _repetition = 0;
    }
    _carouselController = CarouselSliderController();
  }

  void _onPageChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      _currentIndex = index;
      _repetition = widget.adhkar[index].dhikrRepetition;
      _isCompleted = false;
    });
  }

  void _onCounterTapped() {
    if (_isCompleted || widget.adhkar.isEmpty) return;
    HapticFeedback.selectionClick();

    if (_repetition > 1) {
      setState(() {
        _repetition--;
      });
    } else {
      // Repetition drops to 0
      if (_currentIndex < widget.adhkar.length - 1) {
        _carouselController.nextPage(
          duration: _slide,
          curve: Curves.easeOutCubic,
        );
      } else {
        setState(() {
          _repetition = 0;
          _isCompleted = true;
        });
      }
    }
  }

  List<String> _splitAtFirstNewLine(String text) {
    final regex = RegExp(r'(.+?)\n(.+)', dotAll: true);
    final match = regex.firstMatch(text);
    if (match != null) {
      return [match.group(1)!, match.group(2)!];
    } else {
      return [text, ''];
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final s = S.of(context);
    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        child: widget.adhkar.isEmpty
            ? Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: EmptyState.noResults(context),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildHeader(context),
                  _buildProgress(context),
                  const SizedBox(height: NoorSpace.s4),
                  Expanded(
                    // Without an explicit height the carousel falls back to 16:9.
                    child: LayoutBuilder(
                      builder: (context, box) => CarouselSlider.builder(
                        carouselController: _carouselController,
                        itemCount: widget.adhkar.length,
                        options: CarouselOptions(
                          height: box.maxHeight,
                          initialPage: _currentIndex,
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          onPageChanged: _onPageChanged,
                        ),
                        itemBuilder: (context, index, realIndex) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: NoorLayout.gutter(context),
                          ),
                          child: _buildCard(context, widget.adhkar[index]),
                        ),
                      ),
                    ),
                  ),
                  _buildPager(context, s),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final n = context.noor;
    final total = widget.adhkar.length;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: NoorLayout.gutter(context),
        vertical: NoorSpace.s1,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded, // mirrors itself in RTL
              color: n.ink,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: S.of(context).back,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: NoorText.title(context),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (total > 0)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_currentIndex + 1} / $total',
                      style:
                          NoorText.numeral(context, size: 16, color: n.muted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final total = widget.adhkar.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NoorLayout.gutter(context),
        NoorSpace.s2,
        NoorLayout.gutter(context),
        0,
      ),
      child: NoorProgressBar(
        showPercent: false,
        value: total == 0 ? 0.0 : (_currentIndex + 1) / total,
      ),
    );
  }

  /// One dhikr on a raised sheet: the opening line in bold, a short rule, then
  /// the text itself. Where the dhikr has a source or a virtue it sits last,
  /// in muted small type. Nothing else is drawn, so nothing competes with the
  /// words, and the sheet is the tap target for the count.
  Widget _buildCard(BuildContext context, AdhkarModel item) {
    final n = context.noor;
    final lines = _splitAtFirstNewLine(item.dhikrContent);
    final hasTwoLines = lines[1].trim().isNotEmpty;
    final info = item.dhikrInfo?.trim() ?? '';
    final text = NoorText.dhikr(context);

    // The whole card counts: a tap anywhere on the words is one repetition.
    return NoorCard(
      padding: EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onCounterTapped,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NoorSpace.s5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasTwoLines) ...[
                  Text(
                    lines[0].trim(),
                    textAlign: TextAlign.center,
                    style: text.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: NoorSpace.s4),
                  Center(
                    child: SizedBox(
                      width: NoorSpace.s8,
                      height: 1,
                      child: ColoredBox(color: n.line),
                    ),
                  ),
                  const SizedBox(height: NoorSpace.s4),
                  Text(
                    lines[1].trim(),
                    textAlign: TextAlign.center,
                    style: text,
                  ),
                ] else
                  Text(
                    lines[0].trim(),
                    textAlign: TextAlign.center,
                    style: text,
                  ),
                if (info.isNotEmpty) ...[
                  const SizedBox(height: NoorSpace.s5),
                  Text(
                    info,
                    textAlign: TextAlign.center,
                    style: NoorText.bodySm(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ponytail: the ARB files have no previous/next strings, so the chevron
  // tooltips read "i / total" of the dhikr they go to. Add keys next time the
  // l10n files are open.
  Widget _buildPager(BuildContext context, S s) {
    final total = widget.adhkar.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        NoorLayout.gutter(context),
        NoorSpace.s4,
        NoorLayout.gutter(context),
        NoorSpace.s5,
      ),
      child: NoorPagerPill(
        labelSize: 26,
        label: _isCompleted ? s.done : '$_repetition',
        onCenterTap: _isCompleted ? null : _onCounterTapped,
        onPrevious: _currentIndex > 0
            ? () => _carouselController.previousPage(
                  duration: _slide,
                  curve: Curves.easeOutCubic,
                )
            : null,
        onNext: _currentIndex < total - 1
            ? () => _carouselController.nextPage(
                  duration: _slide,
                  curve: Curves.easeOutCubic,
                )
            : null,
        previousTooltip: '$_currentIndex / $total',
        nextTooltip: '${_currentIndex + 2} / $total',
      ),
    );
  }
}
