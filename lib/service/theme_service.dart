import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthinnotech/main.dart';

class ThemeService {
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: baseColor1,
    foregroundColor: Colors.white,
  );

  static ElevatedButtonThemeData elevatedButtonThemeData =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: baseColor1,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor1, brightness: Brightness.light),
    appBarTheme: appBarTheme,
    brightness: Brightness.light,
    elevatedButtonTheme: elevatedButtonThemeData,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor1, brightness: Brightness.dark),
    appBarTheme: appBarTheme,
    brightness: Brightness.dark,
    elevatedButtonTheme: elevatedButtonThemeData,
  );

  static final isDarkTheme = StateProvider((ref) => true);
}
