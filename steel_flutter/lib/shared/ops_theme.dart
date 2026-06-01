import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brutal gym palette aligned with steel-theraphy.vercel.app (`globals.css`).
abstract final class SteelOpsColors {
  static const background = Color(0xFF050505);
  static const surface = Color(0xFF0A0A0A);
  static const surfaceElevated = Color(0xFF111111);
  static const border = Color(0xFF1A1A1A);
  static const borderStrong = Color(0xFF333333);

  /// Forged steel / primary CTA accent (`--secondary`, `--color-forge`).
  static const orange = Color(0xFFC2410C);
  static const forge = orange;
  static const forgeHover = Color(0xFFEA580C);
  static const forgeGlow = Color(0x66C2410C);

  static const blood = Color(0xFF8B0000);
  static const rust = Color(0xFFB91C1C);

  static const green = Color(0xFF22C55E);
  static const blue = Color(0xFF3B82F6);
  static const tactical = Color(0xFF166534);

  static const inkHigh = Color(0xFFE5E5E5);
  static const inkMid = Color(0xFFC9C9C9);
  static const muted = Color(0xFFA1A1AA);
  static const inkDim = Color(0xFF737373);

  static const heroText = Color(0xFFF0F0F0);
  static const glassBg = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x14FFFFFF);
  static const taglineBorder = Color(0x66C2410C);
  static const taglineBg = Color(0x14C2410C);

  @Deprecated('Use forge or inkMid')
  static const steelBlue = Color(0xFF4A7FA5);
}

TextStyle steelHeadingStyle({
  double fontSize = 28,
  FontWeight fontWeight = FontWeight.w800,
  Color color = SteelOpsColors.heroText,
  double letterSpacing = -0.5,
  double? height,
}) {
  return GoogleFonts.barlowCondensed(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: color,
    height: height,
  );
}

TextStyle steelMonoStyle({
  double fontSize = 11,
  FontWeight fontWeight = FontWeight.w600,
  Color color = SteelOpsColors.muted,
  double letterSpacing = 1.5,
}) {
  return GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    color: color,
  );
}

TextTheme buildOpsTextTheme(TextTheme base) {
  final mono = GoogleFonts.jetBrainsMonoTextTheme(base);
  return GoogleFonts.barlowCondensedTextTheme(mono).copyWith(
    displayLarge: steelHeadingStyle(fontSize: 56, fontWeight: FontWeight.w900),
    displayMedium: steelHeadingStyle(fontSize: 42, fontWeight: FontWeight.w900),
    headlineMedium: steelHeadingStyle(fontSize: 28),
    titleLarge: steelHeadingStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: steelMonoStyle(fontSize: 12, color: SteelOpsColors.inkMid),
    bodyMedium: steelMonoStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: SteelOpsColors.muted,
      letterSpacing: 1.2,
    ),
    labelLarge: steelMonoStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: SteelOpsColors.inkHigh,
      letterSpacing: 1.0,
    ),
  );
}
