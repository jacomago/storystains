import 'package:flutter/material.dart';
import '../utils/utils.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle(
    this.title, {
    Key? key,
  }) : super(key: key);
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
