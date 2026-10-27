import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_pager_pill.dart';
import 'package:noor/generals/widgets/noor_progress_bar.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
import 'package:noor/utils/constants/image_strings.dart';
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
  static const _slide = Duration(milliseconds: 300);

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

  void _showInfo(BuildContext context, String info) {
    showNoorSheet(
      context,
      title: widget.title,
      builder: (sheetContext) => Text(
        info,
        style: NoorText.body(sheetContext),
        textAlign: TextAlign.center,
      ),
    );
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
                    child: EmptyState(message: s.no_results),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildHeader(context),
                  _buildProgress(),
                  const SizedBox(height: NoorSpace.lg),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: NoorSpace.xl,
                          ),
                          child: _buildCard(context, widget.adhkar[index]),
                        ),
                      ),
                    ),
                  ),
                  _buildPager(s),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final n = context.noor;
    final total = widget.adhkar.length;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.lg,
        vertical: NoorSpace.xs,
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
                  style: NoorText.section(context),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (total > 0)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_currentIndex + 1} / $total',
                      style:
                          NoorText.numeral(context, size: 14, color: n.muted),
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

  Widget _buildProgress() {
    final total = widget.adhkar.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NoorSpace.xl,
        NoorSpace.sm,
        NoorSpace.xl,
        0,
      ),
      child: NoorProgressBar(
        height: 2,
        value: total == 0 ? 0.0 : (_currentIndex + 1) / total,
      ),
    );
  }

  Widget _buildCard(BuildContext context, AdhkarModel item) {
    final n = context.noor;
    final lines = _splitAtFirstNewLine(item.dhikrContent);
    final hasTwoLines = lines[1].trim().isNotEmpty;
    final hasInfo = item.dhikrInfo != null && item.dhikrInfo!.trim().isNotEmpty;

    return NoorCard(
      padding: const EdgeInsets.all(NoorSpace.xl),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: hasInfo ? NoorSpace.xxl : NoorSpace.xs,
                  bottom: NoorSpace.xs,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasTwoLines) ...[
                      Text(
                        lines[0].trim(),
                        textAlign: TextAlign.center,
                        style: NoorText.dhikr(context).copyWith(
                          color: n.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: NoorSpace.md),
                      ExcludeSemantics(
                        child: SvgPicture.asset(
                          NoorArt.divider,
                          height: 20,
                          colorFilter:
                              ColorFilter.mode(n.gold, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(height: NoorSpace.md),
                      Text(
                        lines[1].trim(),
                        textAlign: TextAlign.center,
                        style: NoorText.dhikr(context),
                      ),
                    ] else
                      Text(
                        lines[0].trim(),
                        textAlign: TextAlign.center,
                        style: NoorText.dhikr(context).copyWith(color: n.ink),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (hasInfo)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: IconButton(
                icon: Icon(
                  Iconsax.info_circle,
                  color: n.muted,
                  size: 22,
                ),
                onPressed: () => _showInfo(context, item.dhikrInfo!.trim()),
                tooltip: S.of(context).info,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                splashRadius: 24,
              ),
            ),
        ],
      ),
    );
  }

  // ponytail: the ARB files have no previous/next strings, so the chevron
  // tooltips read "i / total" of the dhikr they go to. Add keys next time the
  // l10n files are open.
  Widget _buildPager(S s) {
    final total = widget.adhkar.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NoorSpace.xl,
        NoorSpace.lg,
        NoorSpace.xl,
        NoorSpace.xxl,
      ),
      child: NoorPagerPill(
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
