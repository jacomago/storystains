
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/features/review/review.dart';
import 'package:storystains/utils/extensions.dart';
import 'package:storystains/utils/utils.dart';
import '../../features/auth/auth_state.dart';

class ReviewArguement {
  final String slug;
  ReviewArguement(this.slug);
}

class EditReview extends StatelessWidget {
  const EditReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReviewArguement;

    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService(), args.slug),
      child: ReviewEditPage(),
    );
  }
}

class CreateReview extends StatelessWidget {
  const CreateReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewState(ReviewService()),
      child: ReviewEditPage(),
    );
  }
}

class ReviewEditPage extends StatelessWidget {
  ReviewEditPage({Key? key}) : super(key: key);

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  void editReview(BuildContext context) async {
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

    if (state.isCreate) {
      await state.create(
        title,
        body,
      );
    } else {
      await state.update(title, body);
    }

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
            title: const Text('Review'),
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
            onPressed: () => editReview(context),
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
