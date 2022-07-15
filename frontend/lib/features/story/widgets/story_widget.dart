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
                style: context.headlineSmall,
                semanticsLabel: AppLocalizations.of(context)!.title,
              ),
              Text(
                '(${story?.medium.name})',
                style: context.titleMedium,
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.byCreator(story?.creator ?? ''),
            style: context.titleMedium!.copyWith(
              fontStyle: FontStyle.italic,
            ),
            semanticsLabel: AppLocalizations.of(context)!.creator,
          ),
        ],
      );
}

/// Widget for displaying a [Story] without editing
class StoryItem extends StatelessWidget {
  /// Widget for displaying a [Story] without editing
  const StoryItem({Key? key, required this.story}) : super(key: key);

  ///The [Story] to display
  final Story story;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                story.title,
                style:
                    context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.fade,
              ),
              Text(
                story.medium.name,
                style: context.titleSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: context.colors.onSecondaryContainer,
                ),
                overflow: TextOverflow.fade,
              ),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.byCreator(story.creator),
            style: context.titleSmall,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 4),
        ],
      );
}
