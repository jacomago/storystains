import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// Widget to display in the title bar of the App bar
class AppBarTitle extends StatelessWidget {
  /// Widget to display in the title bar of the App bar
  const AppBarTitle(
    this.title, {
    super.key,
  });

  /// Text to display
  final String title;
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: context.titleBar,
      );
}
