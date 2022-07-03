import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/mediums/medium.dart';
import 'package:storystains/features/story/story.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryState>(builder: (context, state, _) {
      return state.isEdit
          ? _buildStoryEdit(context, state)
          : _buildStoryDisplay(context, state);
    });
  }

  Widget _buildStoryDisplay(BuildContext context, StoryState state) {
    return Column(
      children: [
        Text(
          "${state.story?.title ?? (state.isFailed ? 'Not Found' : '')} (${state.story?.medium.name ?? ""})",
          style: context.headlineSmall,
          semanticsLabel: 'Title',
        ),
        Text(
          "by ${state.story?.creator ?? (state.isFailed ? 'Not Found' : '')}",
          style: context.headlineSmall!.copyWith(
            fontStyle: FontStyle.italic,
          ),
          semanticsLabel: 'Creator',
        ),
      ],
    );
  }

  Widget _buildStoryEdit(BuildContext context, StoryState state) {
    return Column(
      children: [
        StoryTitleEdit(
          titleController: state.titleController,
        ),
        StoryCreatorEdit(
          creatorController: state.creatorController,
        ),
        MediumPicker(
          mediumController: state.mediumController,
        ),
      ],
    );
  }
}

class StoryTitleEdit extends StatelessWidget {
  const StoryTitleEdit({
    Key? key,
    required this.titleController,
  }) : super(key: key);
  final TextEditingController titleController;
  @override
  Widget build(BuildContext context) {
    return TextField(
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
}

class StoryCreatorEdit extends StatelessWidget {
  const StoryCreatorEdit({
    Key? key,
    required this.creatorController,
  }) : super(key: key);
  final TextEditingController creatorController;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
}
