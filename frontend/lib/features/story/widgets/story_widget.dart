import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../common/utils/utils.dart';
import '../../mediums/medium.dart';
import '../story.dart';

class StoryEditWidget extends StatelessWidget {
  const StoryEditWidget({Key? key, required this.state}) : super(key: key);
  final StoryState state;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          StoryTitleEdit(
            titleController: state.titleController,
          ),
          const SizedBox(
            height: 10,
          ),
          StoryCreatorEdit(
            creatorController: state.creatorController,
          ),
          const SizedBox(
            height: 10,
          ),
          MediumPicker(
            mediumController: state.mediumController,
          ),
        ],
      );
}

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key, required this.story}) : super(key: key);
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

class StoryTitleEdit extends StatelessWidget {
  const StoryTitleEdit({
    Key? key,
    required this.titleController,
  }) : super(key: key);
  final TextEditingController titleController;
  @override
  Widget build(BuildContext context) => TextField(
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.title,
          hintText: AppLocalizations.of(context)!.title,
        ),
        style: context.titleMedium,
        controller: titleController,
      );
}

class StoryCreatorEdit extends StatelessWidget {
  const StoryCreatorEdit({
    Key? key,
    required this.creatorController,
  }) : super(key: key);
  final TextEditingController creatorController;

  @override
  Widget build(BuildContext context) => TextField(
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.creator,
          hintText: AppLocalizations.of(context)!.creatorHint,
        ),
        style: context.titleMedium,
        controller: creatorController,
      );
}
