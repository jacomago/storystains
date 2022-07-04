import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/utils.dart';

class ReviewDate extends StatelessWidget {
  const ReviewDate({Key? key, required this.date}) : super(key: key);
  final DateTime date;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMEEEEd().format(date),
            style: context.caption,
            overflow: TextOverflow.ellipsis,
            semanticsLabel: 'Modified Date',
          ),
        ],
      );
}
