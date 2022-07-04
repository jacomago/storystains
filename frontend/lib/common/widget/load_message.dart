import 'package:flutter/material.dart';

import '../constant/app_theme.dart';
import '../utils/utils.dart';

class LoadMessage extends StatelessWidget {
  final String message;
  final void Function() onRefresh;

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
                'Refresh',
                style: context.button,
              ),
            ),
          ],
        ),
      );
}
