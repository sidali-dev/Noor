import 'package:flutter/material.dart';
import 'package:noor/features/adhan/adhan_controller.dart';
import 'package:noor/generals/widgets/location_pill.dart';

class GetLocationWidget extends StatelessWidget {
  const GetLocationWidget({
    super.key,
    this.isDark = false,
    this.isRtl = false,
    this.controller,
  });

  final bool? isDark;
  final bool? isRtl;
  final AdhanController? controller;

  @override
  Widget build(BuildContext context) {
    return const LocationPill();
  }
}
