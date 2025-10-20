import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Theme tối sẽ được sử dụng làm mặc định
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kAdminBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: kAdminBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: kAdminPrimaryTextColor),
      titleTextStyle: TextStyle(
          color: kAdminPrimaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: kAdminCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kAdminInputBorderColor.withOpacity(0.5)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kAdminCardColor,
      labelStyle: const TextStyle(color: kAdminSecondaryTextColor),
      selectedColor: kAdminAccentColor,
      secondaryLabelStyle: const TextStyle(color: kAdminPrimaryTextColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: kAdminInputBorderColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kAdminCardColor,
      labelStyle: const TextStyle(color: kAdminSecondaryTextColor),
      hintStyle: const TextStyle(color: kAdminSecondaryTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kAdminInputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kAdminInputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kAdminAccentColor, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAdminAccentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: kAdminAccentColor,
      background: kAdminBackgroundColor,
      surface: kAdminCardColor,
      onPrimary: kAdminPrimaryTextColor,
      onBackground: kAdminPrimaryTextColor,
      onSurface: kAdminPrimaryTextColor,
      error: kAdminErrorColor,
    ),
  );

  // Theme sáng (dự phòng)
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.blue,
  );
}

