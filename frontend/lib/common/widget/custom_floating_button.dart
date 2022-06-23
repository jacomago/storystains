import 'package:flutter/material.dart';
import 'package:storystains/common/constant/app_theme.dart';
import 'package:storystains/common/utils/utils.dart';

class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CustomFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: context.colors.secondary,
      child: Icon(
        icon,
        color: context.colors.onPrimary,
      ),
    );
  }
}
