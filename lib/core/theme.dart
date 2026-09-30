import 'package:flutter/material.dart';

/// Palette « Terre & Nature » (Tany Mena) issue du design system Linguistique Régionale.
class C {
  static const surface = Color(0xFFFDF9F2);
  static const lowest = Color(0xFFFFFFFF);
  static const low = Color(0xFFF7F3EC);
  static const container = Color(0xFFF1EDE6);
  static const high = Color(0xFFEBE8E1);
  static const highest = Color(0xFFE6E2DB);
  static const onSurface = Color(0xFF1C1C18);
  static const onVariant = Color(0xFF59413C);
  static const outline = Color(0xFF8D716A);
  static const outlineVariant = Color(0xFFE1BFB8);
  static const primary = Color(0xFF962105);
  static const primaryContainer = Color(0xFFB8391D);
  static const primaryFixed = Color(0xFFFFDAD2);
  static const onPrimaryContainer = Color(0xFFFFDDD6);
  static const secondary = Color(0xFF3A674F);
  static const secondaryContainer = Color(0xFFBCEECF);
  static const onSecondaryContainer = Color(0xFF406D55);
  static const tertiary = Color(0xFF6E4500);
  static const tertiaryFixed = Color(0xFFFFDDB6);
  static const tertiaryContainer = Color(0xFF8E5B00);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const inverseSurface = Color(0xFF31302C);
}

/// Couleur avec opacité (compatible toutes versions de Flutter).
Color a(Color c, double o) => c.withAlpha((o * 255).round());

TextStyle ts(double size, FontWeight w,
        {Color color = C.onSurface, double height = 1.4, double ls = 0}) =>
    TextStyle(
        fontSize: size, fontWeight: w, color: color, height: height, letterSpacing: ls);

const w4 = FontWeight.w400;
const w5 = FontWeight.w500;
const w6 = FontWeight.w600;
const w7 = FontWeight.w700;

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.primaryContainer,
      brightness: Brightness.light,
    ).copyWith(
      primary: C.primary,
      secondary: C.secondary,
      tertiary: C.tertiary,
      surface: C.surface,
      error: C.error,
    ),
    scaffoldBackgroundColor: C.surface,
  );
  return base.copyWith(
    textTheme: base.textTheme,
    appBarTheme: const AppBarTheme(backgroundColor: C.surface, elevation: 0, scrolledUnderElevation: 0),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.surface,
      indicatorColor: C.primaryFixed,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => ts(11, s.contains(WidgetState.selected) ? w7 : w5,
          color: s.contains(WidgetState.selected) ? C.primary : C.onVariant)),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? C.primary : C.onVariant)),
    ),
  );
}
