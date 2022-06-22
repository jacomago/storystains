import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle(
    this.title, {
    Key? key,
  }) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'TT2020E',
        color: context.colors.onSurface,
        fontSize: 32,
      ),
    );
  }
}
