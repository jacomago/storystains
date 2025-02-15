import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/utils/utils.dart';

/// Widget showing a date and formatting
class ReviewDate extends StatelessWidget {
  /// Widget showing a date and formatting
  const ReviewDate({super.key, required this.date});

  /// Date to display
  final DateTime date;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMMMMEEEEd().format(date),
            style: context.labelSmall,
            overflow: TextOverflow.ellipsis,
            semanticsLabel: context.locale.modifiedDate,
          ),
        ],
      );
}
