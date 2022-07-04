import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// Widget to display in the title bar of the App bar
class AppBarTitle extends StatelessWidget {
  /// Widget to display in the title bar of the App bar
  const AppBarTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  /// Text to display
  final String title;
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          fontFamily: 'TT2020E',
          color: context.colors.onSurface,
          fontSize: 32,
        ),
      );
}
