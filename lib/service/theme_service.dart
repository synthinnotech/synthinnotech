import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synthinnotech/main.dart';

class ThemeService {
  static const _prefKey = 'isDarkTheme';

  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: baseColor1,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
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
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor1, brightness: Brightness.dark),
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: const Color(0xFF1A1A2E),
    ),
    brightness: Brightness.dark,
    elevatedButtonTheme: elevatedButtonThemeData,
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final isDarkTheme = StateProvider<bool>((ref) => false);

  static Future<bool> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> toggleTheme(WidgetRef ref) async {
    final current = ref.read(isDarkTheme);
    ref.read(isDarkTheme.notifier).state = !current;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, !current);
  }
}
