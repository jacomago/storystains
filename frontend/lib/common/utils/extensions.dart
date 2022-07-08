import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extension to quick get font styles from context
extension TypographyUtils on BuildContext {
  /// Theme helper
  ThemeData get theme => Theme.of(this);

  /// main text theme
  TextTheme get textTheme => theme.textTheme;

  /// main  colors
  ColorScheme get colors => theme.colorScheme;

  /// Large display
  TextStyle? get displayLarge => textTheme.displayLarge?.copyWith(
        color: colors.onSurface,
      );

  /// Medium display
  TextStyle? get displayMedium => textTheme.displayMedium?.copyWith(
        color: colors.onSurface,
      );

  /// Small display
  TextStyle? get displaySmall => textTheme.displaySmall?.copyWith(
        color: colors.onSurface,
      );

  /// Large headline
  TextStyle? get headlineLarge => textTheme.headlineLarge?.copyWith(
        color: colors.onSurface,
      );

  /// Medium headline
  TextStyle? get headlineMedium => textTheme.headlineMedium?.copyWith(
        color: colors.onSurface,
      );

  /// Small headline
  TextStyle? get headlineSmall => textTheme.headlineSmall?.copyWith(
        color: colors.onSurface,
      );

  /// Large title
  TextStyle? get titleLarge => textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
      );

  /// Medium title
  TextStyle? get titleMedium => textTheme.titleMedium?.copyWith(
        color: colors.onSurface,
      );

  /// Small title
  TextStyle? get titleSmall => textTheme.titleSmall?.copyWith(
        color: colors.onSurface,
      );

  /// Large label
  TextStyle? get labelLarge => textTheme.labelLarge?.copyWith(
        color: colors.onSurface,
      );

  /// Medium label
  TextStyle? get labelMedium => textTheme.labelMedium?.copyWith(
        color: colors.onSurface,
      );

  /// Small label
  TextStyle? get labelSmall => textTheme.labelSmall?.copyWith(
        color: colors.onSurface,
      );

  /// Large body
  TextStyle? get bodyLarge => textTheme.bodyLarge?.copyWith(
        color: colors.onSurface,
      );

  /// Medium body
  TextStyle? get bodyMedium => textTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
      );

  /// small body
  TextStyle? get bodySmall => textTheme.bodySmall?.copyWith(
        color: colors.onSurface,
      );

  /// button font style
  TextStyle? get button => GoogleFonts.specialEliteTextTheme().button?.copyWith(
        color: colors.onSurface,
      );
  /// titleBar font style
  TextStyle? get titleBar => GoogleFonts.specialEliteTextTheme().titleLarge?.copyWith(
        color: colors.onSurface,
        fontSize: 32,
      );

  /// caption font style
  TextStyle? get caption => textTheme.caption?.copyWith(
        color: colors.onSurface,
      );

  /// overline font style
  TextStyle? get overline => textTheme.overline?.copyWith(
        color: colors.onSurface,
      );
}

/// Helper to create a [Duration] from a [String]
extension DurationString on String {
  /// Assumes a string (roughly) of the format '\d{1,2}:\d{2}'
  Duration toDuration() {
    final chunks = split(':');
    if (chunks.length == 1) {
      throw Exception('Invalid duration string: $this');
    } else if (chunks.length == 2) {
      return Duration(
        minutes: int.parse(chunks[0].trim()),
        seconds: int.parse(chunks[1].trim()),
      );
    } else if (chunks.length == 3) {
      return Duration(
        hours: int.parse(chunks[0].trim()),
        minutes: int.parse(chunks[1].trim()),
        seconds: int.parse(chunks[2].trim()),
      );
    } else {
      throw Exception('Invalid duration string: $this');
    }
  }
}

/// Helper to create a pretty string from a [Duration]
extension HumanizedDuration on Duration {
  /// Helper to create a pretty string from a [Duration]
  String toHumanizedString() {
    final seconds = '${inSeconds % 60}'.padLeft(2, '0');
    var minutes = '${inMinutes % 60}';
    if (inHours > 0 || inMinutes == 0) {
      minutes = minutes.padLeft(2, '0');
    }
    var value = '$minutes:$seconds';
    if (inHours > 0) {
      value = '$inHours:$minutes:$seconds';
    }

    return value;
  }
}
