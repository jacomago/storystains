import 'package:flutter/material.dart';
import '../utils/utils.dart';

class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CustomFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

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
