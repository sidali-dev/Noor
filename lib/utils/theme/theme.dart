import 'package:flutter/material.dart';

import 'widget_themes/appbar_theme.dart';
import 'widget_themes/bottom_sheet_theme.dart';
import 'widget_themes/checkbox_theme.dart';
import 'widget_themes/chip_theme.dart';
import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_field_theme.dart';
import 'widget_themes/text_theme.dart';

class SAppTheme {
  SAppTheme._();

  static getLightTheme(bool isRtl) => ThemeData(
      useMaterial3: true,
      fontFamily: isRtl ? 'Amiri' : 'Poppins',
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: STextTheme.lightTextTheme,
      chipTheme: SChipTheme.lightChipTheme,
      appBarTheme: SAppBarTheme.lightAppBarTheme,
      checkboxTheme: SCheckboxTheme.lightCheckboxTheme,
      bottomSheetTheme: SBottomSheetTheme.lightBottomSheetTheme,
      elevatedButtonTheme: SElevatedButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: SOutlinedButtonTheme.lightOutlinedButtonTheme,
      inputDecorationTheme: SSextFormFieldTheme.lightInputDecorationSheme);

  static getDarkTheme(bool isRtl) => ThemeData(
      useMaterial3: true,
      fontFamily: isRtl ? 'Amiri' : 'Poppins',
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      textTheme: STextTheme.darkTextTheme,
      chipTheme: SChipTheme.darkChipTheme,
      appBarTheme: SAppBarTheme.darkAppBarTheme,
      checkboxTheme: SCheckboxTheme.darkCheckboxTheme,
      bottomSheetTheme: SBottomSheetTheme.darkBottomSheetTheme,
      elevatedButtonTheme: SElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: SOutlinedButtonTheme.darkOutlinedButtonTheme,
      inputDecorationTheme: SSextFormFieldTheme.darkInputDecorationSheme);
}
