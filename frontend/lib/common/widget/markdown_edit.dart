import 'package:flutter/material.dart';
import '../utils/utils.dart';

class MarkdownEdit extends StatelessWidget {
  final TextEditingController bodyController;
  final String title;
  final String hint;
  const MarkdownEdit({
    Key? key,
    required this.bodyController,
    required this.title,
    required this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TextField(
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
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
      );
}
