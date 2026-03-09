import 'package:flutter/material.dart';
import 'color_app.dart';

ThemeData themeApp = ThemeData(
  scaffoldBackgroundColor: Color(0xFFF5F6FA),
  primaryColor: ColorApp.primary,
  fontFamily: "cairo",

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      backgroundColor: WidgetStatePropertyAll(ColorApp.primary),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.black54)),
  ),
  cardColor: Colors.white,
  dialogTheme: DialogThemeData(backgroundColor: Colors.white),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: ColorApp.primary,
    selectionColor: ColorApp.primary.withValues(alpha: 0.3),
    selectionHandleColor: ColorApp.primary,
  ),

  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: TextStyle(color: ColorApp.primary),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: ColorApp.primary),

  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: ColorApp.primary,
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 16,
      fontFamily: "cairo",
    ),
  ),
);
ThemeData darkThemeApp = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF121212),
  primaryColor: ColorApp.primary,
  fontFamily: "cairo",
  brightness: Brightness.dark,

  cardColor: const Color(0xFF1E1E1E),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Colors.white70)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      backgroundColor: WidgetStatePropertyAll(ColorApp.primary),
    ),
  ),

  textSelectionTheme: TextSelectionThemeData(
    cursorColor: ColorApp.primary,
    selectionColor: ColorApp.primary.withValues(alpha: 0.3),
    selectionHandleColor: ColorApp.primary,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle: TextStyle(color: Colors.white),
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(color: ColorApp.primary),

  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: const Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 16,
      fontFamily: "cairo",
    ),
  ),
);
