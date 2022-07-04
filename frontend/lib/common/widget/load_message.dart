import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: onRefresh,
              style: homeButtonStyle,
              child: Text(
                AppLocalizations.of(context)!.refresh,
                style: context.button,
              ),
            ),
          ],
        ),
      );
}
