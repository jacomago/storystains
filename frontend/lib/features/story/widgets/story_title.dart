import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/utils/utils.dart';
import 'package:storystains/features/story/story.dart';

class StoryTitle extends StatelessWidget {
  const StoryTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryState>(builder: (context, state, _) {
      return state.isEdit
          ? TextField(
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
                hintText: 'Review title',
              ),
              style: context.titleMedium,
              controller: state.titleController,
            )
          : Text(
              state.story?.title ?? (state.isFailed ? 'Not Found' : ''),
              style: context.headlineSmall,
              semanticsLabel: 'Title',
            );
    });
  }
}
