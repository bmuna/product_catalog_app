import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color _darkSurface = Color(0xFF121212);
  static const Color _darkSurfaceVariant = Color(0xFF1E1E1E);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1A1A1A),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFE8E8E8),
          onPrimaryContainer: const Color(0xFF1A1A1A),
          secondary: const Color(0xFF737373),
          onSecondary: Colors.white,
          surface: _lightSurface,
          onSurface: const Color(0xFF1A1A1A),
          surfaceContainerHighest: _lightSurfaceVariant,
          onSurfaceVariant: const Color(0xFF525252),
          outline: const Color(0xFFA3A3A3),
          error: const Color(0xFFB91C1C),
          onError: Colors.white,
          tertiary: const Color(0xFF737373),
        ),
        scaffoldBackgroundColor: _lightSurface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightSurfaceVariant,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          selectedColor: const Color(0xFFE5E5E5),
          checkmarkColor: const Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: _lightSurface,
          foregroundColor: Color(0xFF1A1A1A),
        ),
        textTheme: _textTheme(Brightness.light),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFAFAFA),
          onPrimary: const Color(0xFF121212),
          primaryContainer: const Color(0xFF2D2D2D),
          onPrimaryContainer: const Color(0xFFFAFAFA),
          secondary: const Color(0xFFA3A3A3),
          onSecondary: const Color(0xFF121212),
          surface: _darkSurface,
          onSurface: const Color(0xFFFAFAFA),
          surfaceContainerHighest: _darkSurfaceVariant,
          onSurfaceVariant: const Color(0xFFA3A3A3),
          outline: const Color(0xFF525252),
          error: const Color(0xFFEF4444),
          onError: const Color(0xFF121212),
          tertiary: const Color(0xFFA3A3A3),
        ),
        scaffoldBackgroundColor: _darkSurface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: _darkSurfaceVariant,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkSurfaceVariant,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2D2D2D)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          selectedColor: const Color(0xFF2D2D2D),
          checkmarkColor: const Color(0xFFFAFAFA),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: _darkSurface,
          foregroundColor: Color(0xFFFAFAFA),
        ),
        textTheme: _textTheme(Brightness.dark),
      );

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;
    return base.copyWith(
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
