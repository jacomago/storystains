import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// Custom floating button for keeping theming consistent
class CustomFloatingButton extends StatelessWidget {
  /// Icon on floating button
  final IconData icon;

  /// Action after on press
  final VoidCallback? onPressed;

  /// Custom floating button for keeping theming consistent
  const CustomFloatingButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: context.colors.secondary,
        child: Icon(
          icon,
          color: context.colors.onPrimary,
        ),
      );
}
