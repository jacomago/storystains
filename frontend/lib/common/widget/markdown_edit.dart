import 'package:flutter/material.dart';
import '../utils/utils.dart';

/// Wrapper around Text field when editing a long text with
/// markdown
class MarkdownEdit extends StatelessWidget {
  /// controller of the text
  final TextEditingController bodyController;

  /// title of the widget
  final String title;

  ///Hint text on empty widget
  final String hint;

  /// Wrapper around Text field when editing a long text with
  /// markdown
  const MarkdownEdit({
    super.key,
    required this.bodyController,
    required this.title,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => TextField(
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: context.locale.field(title),
          alignLabelWithHint: true,
          hintText: hint,
        ),
        style: context.bodySmall,
        controller: bodyController,
        minLines: 5,
        maxLines: 50,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
      );
}
