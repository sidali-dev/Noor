import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_cartouche.dart';
import 'package:noor/generals/widgets/noor_cloud.dart';
import 'package:noor/generals/widgets/noor_tasbih.dart';
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

  // The counter rises into the card's clouds; this is how far.
  static const double _cloudHeight = 72;
  static const double _counterRise = _cloudHeight - NoorSpace.s2;
  static const double _counterFoot = NoorSpace.s3;

  @override
  Widget build(BuildContext context) {
    final n = context.noor;
    final gutter = NoorLayout.gutter(context);
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
                  Expanded(
                    child: Stack(
                      children: [
                        // Without an explicit height the carousel falls back to
                        // 16:9. It clips at its bounds, so the sheet stops short
                        // of them and keeps its whole shadow.
                        Positioned.fill(
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
                              itemBuilder: (context, index, realIndex) =>
                                  Padding(
                                padding: EdgeInsets.fromLTRB(
                                  gutter,
                                  NoorSpace.s1,
                                  gutter,
                                  TasbihCloud.standardSize -
                                      _counterRise +
                                      _counterFoot,
                                ),
                                child: _buildCard(context, index),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: gutter,
                          right: gutter,
                          bottom: _counterFoot,
                          child: _buildCounter(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// The way back on a puff and the category's name on a piece of night sky,
  /// as a surah is named in the Mushaf.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NoorLayout.gutter(context),
        NoorSpace.s2,
        NoorLayout.gutter(context),
        NoorSpace.s3,
      ),
      child: Row(
        children: [
          NoorCloudButton(
            icon: const Icon(Icons.arrow_back_rounded), // mirrors itself in RTL
            tooltip: S.of(context).back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: NoorSpace.s2),
          Expanded(child: NoorCartouche.title(widget.title)),
        ],
      ),
    );
  }

  /// One dhikr on a [NoorCard]: the opening line in bold, an ornament, then
  /// the text itself. Where the dhikr has a source or a virtue it sits last,
  /// in muted small type. The whole card counts: a tap anywhere on the words
  /// is one repetition.
  Widget _buildCard(BuildContext context, int index) {
    final item = widget.adhkar[index];
    final lines = _splitAtFirstNewLine(item.dhikrContent);
    final hasTwoLines = lines[1].trim().isNotEmpty;
    final info = item.dhikrInfo?.trim() ?? '';
    final text = NoorText.dhikr(context);

    return NoorCard(
      folio: '${index + 1} / ${widget.adhkar.length}',
      cloudHeight: _cloudHeight,
      padding: EdgeInsets.only(
        // A short window drops the clouds, but the counter still rises here.
        bottom: NoorLayout.isShort(context) ? _cloudHeight : 0,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onCounterTapped,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NoorSpace.s5,
              NoorSpace.s2,
              NoorSpace.s5,
              NoorSpace.s2,
            ),
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
                  const SizedBox(height: NoorSpace.s3),
                  const NoorOrnament(),
                  const SizedBox(height: NoorSpace.s3),
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
  Widget _buildCounter(BuildContext context) {
    final total = widget.adhkar.length;
    final asked = widget.adhkar[_currentIndex].dhikrRepetition;

    return NoorCounterRow(
      counter: TasbihCloud(
        // A new dhikr starts on a fresh string, not by unwinding the last.
        key: ValueKey(_currentIndex),
        total: asked,
        said: _isCompleted ? asked : asked - _repetition,
        label: _isCompleted ? S.of(context).done : '$_repetition',
        done: _isCompleted,
        onTap: _isCompleted ? null : _onCounterTapped,
      ),
      previousTooltip: '$_currentIndex / $total',
      nextTooltip: '${_currentIndex + 2} / $total',
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
    );
  }
}
