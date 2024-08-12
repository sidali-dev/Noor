import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:noor/utils/constants/colors.dart';
import 'package:noor/utils/helpers/helper_functions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:noor/features/duaa/adhkar_display_controller.dart';
import 'package:noor/utils/constants/image_strings.dart';
import 'package:noor/utils/device/device_utility.dart';

import '../../generated/l10n.dart';
import 'model/adhkar_model.dart';

class AdhkarDisplayScreen extends StatelessWidget {
  final String title;
  final List<AdhkarModel> adhkar;
  AdhkarDisplayScreen({super.key, required this.title, required this.adhkar});

  final CarouselController carouselController = CarouselController();
  final List<CarouselCards> cards = [];

  @override
  Widget build(BuildContext context) {
    final AdhkarDisplayController controller =
        Get.put(AdhkarDisplayController());

    int cardIndex = 0;

    for (AdhkarModel adhkarModel in adhkar) {
      cardIndex++;
      cards.add(CarouselCards(
          splitText: splitAtFirstNewLine(adhkarModel.dhikrContent),
          hasTwoLine: hasTwoLines(adhkarModel.dhikrContent),
          controller: controller,
          index: cardIndex,
          info: adhkarModel.dhikrInfo,
          hasNotice: adhkarModel.dhikrInfo != null));
    }
    final bool isDark = SHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            isDark
                ? SImageString.duaaBackgroundImage2
                : SImageString.duaaBackgroundImage1,
            height: SDeviceUtils.getScreenHeight(context),
            width: SDeviceUtils.getScreenWidth(context),
            fit: BoxFit.fitHeight,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w600)),
              CarouselSlider(
                  carouselController: carouselController,
                  items: cards,
                  options: CarouselOptions(
                      onPageChanged: (index, reason) {
                        controller.updatePageIndex(index);
                        controller
                            .updateRepetition(adhkar[index].dhikrRepetition);
                      },
                      height: SDeviceUtils.getScreenHeight(context) * 0.55,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.15,
                      enlargeCenterPage: true)),
              const SizedBox(height: 24),
              Obx(
                () => AnimatedSmoothIndicator(
                  activeIndex: controller.pageIndex.value - 1,
                  count: adhkar.length,
                  effect: ScrollingDotsEffect(
                      dotColor: isDark ? SColors.dark : Colors.white,
                      activeDotColor:
                          isDark ? SColors.secondary : Colors.lightBlue,
                      spacing: 12.0),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => GestureDetector(
                    onTap: () {
                      controller.decrementRepetition();

                      if (controller.repetition.value == 0) {
                        carouselController.nextPage();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: isDark ? SColors.black : Colors.lightBlue,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        "${S.of(context).repetition} ${controller.repetition.value.toString()}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: isDark ? SColors.secondary : Colors.white),
                      ),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }

  List<String> splitAtFirstNewLine(String text) {
    RegExp regex = RegExp(r'(.+?)\n(.+)', dotAll: true);
    Match? match = regex.firstMatch(text);

    if (match != null) {
      return [match.group(1)!, match.group(2)!];
    } else {
      return [text, ''];
    }
  }

  bool hasTwoLines(String text) {
    RegExp regex = RegExp(r'(.+?)\n(.+)', dotAll: true);
    Match? match = regex.firstMatch(text);

    if (match != null) {
      return true;
    } else {
      return false;
    }
  }
}

class CarouselCards extends StatelessWidget {
  const CarouselCards({
    super.key,
    required this.splitText,
    required this.hasTwoLine,
    required this.controller,
    required this.hasNotice,
    required this.index,
    required this.info,
  });

  final List<String> splitText;
  final bool hasTwoLine;
  final AdhkarDisplayController controller;
  final bool hasNotice;
  final int index;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final isDark = SHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                    child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Text(splitText[0].trim().replaceAll(".", ".\n"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: hasTwoLine ? 26 : 24,
                                    fontWeight: hasTwoLine
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontFamily: "Poppins",
                                    color: hasTwoLine
                                        ? isDark
                                            ? SColors.secondary
                                            : Colors.lightBlue
                                        : isDark
                                            ? SColors.white
                                            : Colors.black)),
                            Visibility(
                              visible: hasTwoLine,
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                      splitText[1]
                                          .trim()
                                          .replaceAll(".", ".\n"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? SColors.white
                                              : Colors.black)),
                                ],
                              ),
                            ),
                            Text(
                              index.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins",
                                  fontSize: 20.0,
                                  color: isDark
                                      ? SColors.secondary
                                      : Colors.lightBlue),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ))),
              ),
            ),
          ),
          Visibility(
            visible: hasNotice,
            child: Positioned(
                left: 20,
                bottom: 10,
                child: GestureDetector(
                  onTap: () {
                    Get.bottomSheet(BottomSheet(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.0))),
                      enableDrag: false,
                      showDragHandle: false,
                      onClosing: () {},
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Icon(Iconsax.information,
                                color: isDark
                                    ? SColors.secondary
                                    : Colors.lightBlue,
                                size: 56),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, bottom: 32.0),
                            child: SingleChildScrollView(
                                child: Text(
                              info!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontFamily: "Poppins",
                              ),
                            )),
                          )
                        ],
                      ),
                    ));
                  },
                  child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: isDark ? SColors.secondary : Colors.lightBlue),
                      child: Icon(Iconsax.information,
                          color: isDark ? SColors.black : Colors.white)),
                )),
          ),
        ],
      ),
    );
  }
}
