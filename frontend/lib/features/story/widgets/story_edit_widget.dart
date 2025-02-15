import 'package:flutter/material.dart';
import '../../../common/utils/utils.dart';
import '../../mediums/medium.dart';
import '../story.dart';

/// Widget for editing a [Story]
class StoryEditWidget extends StatelessWidget {
  /// Widget for editing a [Story]
  const StoryEditWidget({
    super.key,
    required this.state,
  });

  void _onChanged() async {
    await state.search();
  }

  /// State of the [Story]
  final StoryState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          StoryFormWidget(
            state: state,
            onChanged: _onChanged,
          ),
          state.isSearching ? SearchStoryResults(state: state) : Container(),
        ],
      );
}

/// Widget for editing a [Story]
class StoryFormWidget extends StatelessWidget {
  /// Widget for editing a [Story]
  const StoryFormWidget({
    super.key,
    required this.state,
    required this.onChanged,
  });

  /// State of the [Story]
  final StoryState state;

  /// What to do on change of inputs
  final Function onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(
            height: 5,
          ),
          StoryTextEdit(
            textController: state.titleController,
            onChanged: (_) {
              onChanged();
            },
            label: context.locale.title,
            hint: context.locale.title,
          ),
          const SizedBox(
            height: 10,
          ),
          StoryTextEdit(
            textController: state.creatorController,
            onChanged: (_) {
              onChanged();
            },
            label: context.locale.creator,
            hint: context.locale.creatorHint,
          ),
          const SizedBox(
            height: 10,
          ),
          MediumPicker(
            mediumController: state.mediumController,
            onChanged: (_) {
              onChanged();
            },
          ),
        ],
      );
}

/// Widget for editing a [Story] title
class StoryTextEdit extends StatelessWidget {
  /// Widget for editing a [Story] title
  const StoryTextEdit({
    super.key,
    required this.textController,
    required this.onChanged,
    required this.label,
    required this.hint,
  });

  /// Label Text
  final String label;

  /// Hint Text
  final String hint;

  /// contoller of title
  final TextEditingController textController;

  /// callback for on changed
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: context.locale.field(label),
          hintText: hint,
        ),
        style: context.titleMedium,
        controller: textController,
        onChanged: onChanged,
        maxLines: 2,
      );
}
