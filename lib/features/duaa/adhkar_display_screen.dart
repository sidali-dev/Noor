import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/features/duaa/model/adhkar_model.dart';
import 'package:noor/generals/widgets/empty_state.dart';
import 'package:noor/generals/widgets/noor_card.dart';
import 'package:noor/generals/widgets/noor_progress_bar.dart';
import 'package:noor/generals/widgets/noor_sheet.dart';
import 'package:noor/generated/l10n.dart';
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
          duration: const Duration(milliseconds: 300),
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: n.paper,
      body: SafeArea(
        child: widget.adhkar.isEmpty
            ? Column(
                children: [
                  _buildHeader(context, isRtl),
                  Expanded(
                    child: EmptyState(message: s.no_results),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildHeader(context, isRtl),
                  const SizedBox(height: NoorSpace.sm),
                  _buildProgress(context),
                  const SizedBox(height: NoorSpace.lg),
                  Expanded(
                    child: CarouselSlider.builder(
                      carouselController: _carouselController,
                      itemCount: widget.adhkar.length,
                      options: CarouselOptions(
                        initialPage: _currentIndex,
                        viewportFraction: 0.9,
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.15,
                        onPageChanged: _onPageChanged,
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final item = widget.adhkar[index];
                        return _buildCard(context, item);
                      },
                    ),
                  ),
                  _buildCounterButton(context, s),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    final n = context.noor;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.lg,
        vertical: NoorSpace.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              color: n.ink,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: NoorText.section(context),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    final n = context.noor;
    final total = widget.adhkar.length;
    final current = total == 0 ? 0 : _currentIndex + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$current / $total',
            style: NoorText.numeral(context, size: 14, color: n.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NoorSpace.xs),
          NoorProgressBar(
            value: total == 0 ? 0.0 : current / total,
          ),
        ],
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
                      const SizedBox(height: NoorSpace.lg),
                      Text(
                        lines[1].trim(),
                        textAlign: TextAlign.center,
                        style: NoorText.dhikr(context).copyWith(
                          color: n.body,
                        ),
                      ),
                    ] else ...[
                      Text(
                        lines[0].trim(),
                        textAlign: TextAlign.center,
                        style: NoorText.dhikr(context).copyWith(
                          color: n.ink,
                        ),
                      ),
                    ],
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
                tooltip: 'Info',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                splashRadius: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(BuildContext context, S s) {
    final n = context.noor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NoorSpace.xl,
        vertical: NoorSpace.xxl,
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 64,
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
          decoration: BoxDecoration(
            color: _isCompleted ? n.card : n.primary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: noorShadow(context),
            border: _isCompleted && n.isDark
                ? Border.all(color: n.line, width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: _isCompleted ? null : _onCounterTapped,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: NoorSpace.xxl),
                child: Center(
                  child: _isCompleted
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: n.primary,
                              size: 24,
                            ),
                            const SizedBox(width: NoorSpace.sm),
                            Text(
                              s.done,
                              style: NoorText.rowTitle(context).copyWith(
                                color: n.primary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '$_repetition',
                          style: NoorText.numeral(
                            context,
                            size: 32,
                            color: n.onPrimary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
