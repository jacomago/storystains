import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../common/utils/utils.dart';

class ReviewUsername extends StatelessWidget {
  const ReviewUsername({Key? key, required this.username}) : super(key: key);
  final String username;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@$username',
            style: context.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            overflow: TextOverflow.fade,
            semanticsLabel: AppLocalizations.of(context)!.username,
          ),
        ],
      );
}
