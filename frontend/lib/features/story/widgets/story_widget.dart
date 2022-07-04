import 'package:flutter/material.dart';
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
              semanticsLabel: 'Title',
            ),
            Text(
              '(${story?.medium.name})',
              style: context.headlineSmall,
            ),
          ],
        ),
        Text(
          "by ${story?.creator ?? ""}",
          style: context.headlineSmall!.copyWith(
            fontStyle: FontStyle.italic,
          ),
          semanticsLabel: 'Creator',
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Title',
        hintText: 'Review title',
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Creator',
        hintText: 'Creator Name',
      ),
      style: context.titleMedium,
      controller: creatorController,
    );
}
