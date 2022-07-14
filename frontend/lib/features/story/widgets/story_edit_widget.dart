import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../common/utils/utils.dart';
import '../../mediums/medium.dart';
import '../story.dart';

/// Widget for editing a [Story]
class StoryEditWidget extends StatelessWidget {
  /// Widget for editing a [Story]
  const StoryEditWidget({Key? key, required this.state}) : super(key: key);

  /// State of the [Story]
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

/// Widget for editing a [Story] title
class StoryTitleEdit extends StatelessWidget {
  /// Widget for editing a [Story] title
  const StoryTitleEdit({
    Key? key,
    required this.titleController,
  }) : super(key: key);

  /// contoller of title
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

/// Widget for editing a [Story] creator
class StoryCreatorEdit extends StatelessWidget {
  /// Widget for editing a [Story]
  const StoryCreatorEdit({
    Key? key,
    required this.creatorController,
  }) : super(key: key);

  /// controller for changes to creator
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
