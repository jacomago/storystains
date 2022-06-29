import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class ReviewUsername extends StatelessWidget {
  const ReviewUsername({Key? key, required this.username}) : super(key: key);
  final String username;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "@$username",
          style: context.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          overflow: TextOverflow.fade,
          semanticsLabel: 'Username',
        ),
      ],
    );
  }
}
