import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ops_theme.dart';

const _zeroRadius = BorderRadius.zero;

ThemeData buildSteelTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: SteelOpsColors.forge,
      onPrimary: Colors.white,
      secondary: SteelOpsColors.blood,
      surface: SteelOpsColors.surface,
      onSurface: SteelOpsColors.inkHigh,
      onSurfaceVariant: SteelOpsColors.muted,
      error: SteelOpsColors.rust,
    ),
  );

  final textTheme = buildOpsTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: SteelOpsColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: SteelOpsColors.surface,
      foregroundColor: SteelOpsColors.inkHigh,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: SteelOpsColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: _zeroRadius,
        side: BorderSide(color: SteelOpsColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SteelOpsColors.forge,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: _zeroRadius),
        textStyle: GoogleFonts.barlowCondensed(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SteelOpsColors.muted,
        side: const BorderSide(color: Color(0x29FFFFFF)),
        shape: const RoundedRectangleBorder(borderRadius: _zeroRadius),
        textStyle: GoogleFonts.barlowCondensed(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SteelOpsColors.forgeHover,
        textStyle: GoogleFonts.jetBrainsMono(fontSize: 12),
      ),
    ),
    textTheme: textTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SteelOpsColors.surfaceElevated,
      border: const OutlineInputBorder(
        borderRadius: _zeroRadius,
        borderSide: BorderSide(color: SteelOpsColors.border),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: _zeroRadius,
        borderSide: BorderSide(color: SteelOpsColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: _zeroRadius,
        borderSide: BorderSide(color: SteelOpsColors.forge, width: 2),
      ),
      labelStyle: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        color: SteelOpsColors.muted,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
