import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/utils/extensions.dart';
import 'package:storystains/utils/utils.dart';
import '../../features/auth/auth_state.dart';

class ReviewPostPage extends StatelessWidget {
  ReviewPostPage({Key? key}) : super(key: key);

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  void postReview(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthState>();
    final state = context.read<ReviewState>();
    final body = bodyController.value.text;
    final title = titleController.value.text;

    if (title.isEmpty) {
      context.snackbar('Title can\'t be blank');
      return;
    } else if (body.isEmpty) {
      context.snackbar('Content can\'t be blank');
      return;
    }

    final postResp = await state.create(
      title,
      body,
    );

    if (state.isUpdated) {
      context.pop();
      context.snackbar('Created Review');
    } else {
      context.snackbar('Review creation failed, please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReviewState, AuthState>(
      builder: (context, reivew, auth, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('New Review'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Title',
                        hintText: 'Review title',
                      ),
                      style: context.headlineMedium,
                      controller: titleController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Content',
                        alignLabelWithHint: true,
                        hintText: 'Write your review (in markdown)',
                      ),
                      style: context.bodySmall,
                      controller: bodyController,
                      minLines: 5,
                      maxLines: 50,
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => postReview(context),
            backgroundColor: context.colors.primary,
            child: Icon(
              Icons.send_rounded,
              color: context.colors.onBackground,
            ),
          ),
        );
      },
    );
  }
}
