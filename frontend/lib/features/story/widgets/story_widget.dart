import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../common/utils/utils.dart';
import '../../../pages/story_filter_page.dart';
import '../../../routes/routes.dart';
import '../story.dart';
import '../story_route.dart';

/// Widget for displaying a [Story] without editing
class StoryWidget extends StatelessWidget {
  /// Widget for displaying a [Story] without editing
  const StoryWidget({Key? key, required this.story}) : super(key: key);

  void _onTapTitle(BuildContext context) {
    if (story?.title == null) {
      return;
    }
    StoryQuery(title: story!.title).navigate(context);
  }

  void _onTapCreator(BuildContext context) {
    if (story?.creator == null) {
      return;
    }
    StoryQuery(creator: story!.creator).navigate(context);
  }

  void _onTapMedium(BuildContext context) {
    if (story?.medium == null) {
      return;
    }
    StoryQuery(medium: story!.medium).navigate(context);
  }

  ///The [Story] to display
  final Story? story;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onTapTitle(context),
                  child: Text(
                    '${story?.title}',
                    style: context.headlineSmall,
                    semanticsLabel: AppLocalizations.of(context)!.title,
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _onTapMedium(context),
                child: Text(
                  '(${story?.medium.name})',
                  style: context.titleMedium,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _onTapCreator(context),
            child: Text(
              AppLocalizations.of(context)!.byCreator(story?.creator ?? ''),
              style: context.titleMedium!.copyWith(
                fontStyle: FontStyle.italic,
              ),
              semanticsLabel: AppLocalizations.of(context)!.creator,
            ),
          ),
        ],
      );
}

/// Widget for displaying a [Story] in a list
class StoryItem extends StatelessWidget {
  /// Widget for displaying a [Story] in a list
  const StoryItem({Key? key, required this.story}) : super(key: key);

  void _onTapCreator(BuildContext context) {
    StoryQuery(creator: story.creator).navigate(context);
  }

  void _onTapMedium(BuildContext context) {
    StoryQuery(medium: story.medium).navigate(context);
  }

  ///The [Story] to display
  final Story story;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  story.title,
                  style: context.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                ),
              ),
              GestureDetector(
                onTap: () => _onTapMedium(context),
                child: Text(
                  story.medium.name,
                  style: context.titleSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: context.colors.onSecondaryContainer,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _onTapCreator(context),
            child: Text(
              AppLocalizations.of(context)!.byCreator(story.creator),
              style: context.titleSmall,
              overflow: TextOverflow.fade,
            ),
          ),
          const SizedBox(height: 4),
        ],
      );
}
