import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../common/utils/utils.dart';
import '../story.dart';

/// Widget for displaying a [Story] without editing
class StoryWidget extends StatelessWidget {
  /// Widget for displaying a [Story] without editing
  const StoryWidget({Key? key, required this.story}) : super(key: key);

  ///The [Story] to display
  final Story? story;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${story?.title}',
                style: context.headlineMedium,
                semanticsLabel: AppLocalizations.of(context)!.title,
              ),
              Text(
                '(${story?.medium.name})',
                style: context.headlineSmall,
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.byCreator(story?.creator ?? ''),
            style: context.headlineSmall!.copyWith(
              fontStyle: FontStyle.italic,
            ),
            semanticsLabel: AppLocalizations.of(context)!.creator,
          ),
        ],
      );
}
