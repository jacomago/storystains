import 'package:flutter/material.dart';

const seed = Color(0xFF6750A4);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF9F42ff),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDBCB),
  onPrimaryContainer: Color(0xFF3411ff),
  secondary: Color(0xFF765849),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDBCB),
  onSecondaryContainer: Color(0xFF2C160B),
  tertiary: Color(0xFF656031),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFECE4AA),
  onTertiaryContainer: Color(0xFF1F1Cff),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF41ff02),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF201A18),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF201A18),
  surfaceVariant: Color(0xFFF4DED5),
  onSurfaceVariant: Color(0xFF52443D),
  outline: Color(0xFF85736C),
  onInverseSurface: Color(0xFFFBEEE9),
  inverseSurface: Color(0xFF362F2C),
  inversePrimary: Color(0xFFFFB692),
  shadow: Color(0xFFffffff),
  surfaceTint: Color(0xFF9F42ff),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB692),
  onPrimary: Color(0xFF552ff0),
  primaryContainer: Color(0xFF7931ff),
  onPrimaryContainer: Color(0xFFFFDBCB),
  secondary: Color(0xFFE6BEAC),
  onSecondary: Color(0xFF432A1E),
  secondaryContainer: Color(0xFF5C4033),
  onSecondaryContainer: Color(0xFFFFDBCB),
  tertiary: Color(0xFFCFC890),
  onTertiary: Color(0xFF353107),
  tertiaryContainer: Color(0xFF4C481C),
  onTertiaryContainer: Color(0xFFECE4AA),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93ff0A),
  onError: Color(0xFF69ff05),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF201A18),
  onBackground: Color(0xFFEDE0DB),
  surface: Color(0xFF201A18),
  onSurface: Color(0xFFEDE0DB),
  surfaceVariant: Color(0xFF52443D),
  onSurfaceVariant: Color(0xFFD7C2B9),
  outline: Color(0xFFA08D85),
  onInverseSurface: Color(0xFF201A18),
  inverseSurface: Color(0xFFEDE0DB),
  inversePrimary: Color(0xFF9F42ff),
  shadow: Color(0xFFffffff),
  surfaceTint: Color(0xFFFFB692),
);

class ExtraColors {
  static const paper = Color(0xffded2c9);
  static const cover = Color(0xfffe7459);
  static const lighterCover = Color(0xfff37d3a);
  static const white = Color(0xffc4c4c5);
  static const purple = Color(0xff947c99);
  static const red = Color(0xffc55966);
  static const newPaper = Color(0xffc1bcc0);
  static const middleAge = Color(0xffb1aba9);
  static const pagesTogether = Color(0xffa89890);
  static const darkPagesTogether = Color(0xff9a6e53);
  static const sunsetRed = Color(0xfff56979);
  static const sunsetOrange = Color(0xfff79966);
  static const coffeeOnPaper = Color(0xff5c3e2a);
}

ButtonStyle homeButtonStyle = OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 18),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0),
  ),
);
