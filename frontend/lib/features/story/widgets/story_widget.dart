import 'package:flutter/material.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widget/link_button.dart';
import '../story.dart';
import '../story_route.dart';

/// Widget for displaying a [Story] without editing
class StoryWidget extends StatelessWidget {
  /// Widget for displaying a [Story] without editing
  const StoryWidget({super.key, required this.story});

  void _onTapTitle(BuildContext context) {
    StoryQuery(title: story.title).navigate(context);
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinkButton(
                onPressed: () => _onTapTitle(context),
                text: story.title,
                defaultStyle: context.headlineSmall!,
                semanticsLabel: context.locale.title,
                maxLines: 2,
              ),
              LinkButton(
                onPressed: () => _onTapMedium(context),
                text: '(${story.medium.name})',
                defaultStyle: context.titleMedium!,
                semanticsLabel: context.locale.medium,
              ),
            ],
          ),
          LinkButton(
            onPressed: () => _onTapCreator(context),
            text: context.locale.byCreator(story.creator),
            defaultStyle: context.titleMedium!.copyWith(
              fontStyle: FontStyle.italic,
            ),
            semanticsLabel: context.locale.creator,
          ),
        ],
      );
}

/// Widget for displaying a [Story] in a list
class StoryItem extends StatelessWidget {
  /// Widget for displaying a [Story] in a list
  const StoryItem({super.key, required this.story});

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
                  semanticsLabel: context.locale.title,
                ),
              ),
              LinkButton(
                onPressed: () => _onTapMedium(context),
                text: story.medium.name,
                defaultStyle: context.titleSmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: context.colors.onSecondaryContainer,
                ),
                semanticsLabel: context.locale.medium,
              ),
            ],
          ),
          LinkButton(
            onPressed: () => _onTapCreator(context),
            text: context.locale.byCreator(story.creator),
            defaultStyle: context.titleSmall!,
            semanticsLabel: context.locale.creator,
          ),
          const SizedBox(height: 4),
        ],
      );
}
