import 'package:flutter/material.dart';
import 'package:storystains/common/utils/utils.dart';

class MarkdownEdit extends StatelessWidget {
  final TextEditingController bodyController;
  final String title;
  final String hint;
  const MarkdownEdit({
    Key? key,
    required this.bodyController,
    this.title = 'Notes',
    this.hint = 'Write your review (in markdown)',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: title,
        alignLabelWithHint: true,
        hintText: hint,
      ),
      style: context.bodySmall,
      controller: bodyController,
      minLines: 5,
      maxLines: 50,
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
    );
  }
}