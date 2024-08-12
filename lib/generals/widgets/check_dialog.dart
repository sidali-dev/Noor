import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:noor/utils/constants/sizes.dart';
import 'package:noor/utils/helpers/helper_functions.dart';

class CheckDialog extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color color;

  const CheckDialog({
    super.key,
    required this.title,
    required this.imagePath,
    required this.color,
  });

  @override
  State<CheckDialog> createState() => _CheckDialogState();
}

class _CheckDialogState extends State<CheckDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        _lottieController.reset();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isRtl = SHelperFunctions.isRtl(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 35,
      child: SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Lottie.asset(
                  fit: BoxFit.contain,
                  widget.imagePath,
                  repeat: false,
                  controller: _lottieController,
                  onLoaded: (p0) {
                    _lottieController.duration = p0.duration;
                    _lottieController.forward();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                flex: 0,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: isRtl ? SSizes.fontSizeLgAr : SSizes.fontSizeLg,
                      color: widget.color,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
