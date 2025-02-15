import 'package:flutter/material.dart';

import '../constant/app_theme.dart';
import '../utils/utils.dart';

/// Message to display when still loading data
class LoadMessage extends StatelessWidget {
  /// The message
  final String message;

  /// What to do on refresh
  final void Function() onRefresh;

  /// Message to display when still loading data
  const LoadMessage(
    this.message, {
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: onRefresh,
              style: homeButtonStyle,
              child: Text(
                context.locale.refresh,
                style: context.labelLarge,
              ),
            ),
          ],
        ),
      );
}
