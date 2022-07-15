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

  void _navigate(StoryQuery query, BuildContext context) {
    Navigator.of(context)
        .push(
          query.route(
            Routes.reviews,
            (q) => StoryFilterPage(
              query: q,
            ),
          ),
        )
        .then((value) => context.pop());
  }

  void _onTapTitle(BuildContext context) {
    _navigate(StoryQuery(title: story.title), context);
  }

  void _onTapCreator(BuildContext context) {
    _navigate(StoryQuery(creator: story.creator), context);
  }

  void _onTapMedium(BuildContext context) {
    _navigate(StoryQuery(medium: story.medium), context);
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
            children: [
              GestureDetector(
                onTap: () => _onTapTitle(context),
                child: Text(
                  story.title,
                  style: context.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
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
