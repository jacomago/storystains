import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widget/widget.dart';
import '../review.dart';

/// Display edit review body or disply review body
class ReviewBody extends StatelessWidget {
  /// Display edit review body or disply review body
  const ReviewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<ReviewState>(
        builder: (context, state, _) => state.isEdit
            ? MarkdownEdit(
                bodyController: state.bodyController,
                title: context.locale.body,
                hint: context.locale.markdownBody,
              )
            : MarkdownBody(
                data: state.review?.body ?? '',
                selectable: true,
              ),
      );
}
