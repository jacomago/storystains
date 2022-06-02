import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:storystains/modules/review/review.dart';
import 'package:storystains/utils/utils.dart';
import '../models/review.dart';
import '../widgets/buttons.dart';

class ReviewEdit extends StatelessWidget {
  ReviewEdit({Key? key}) : super(key: key);

  final TextEditingController _ucontroller = TextEditingController();
  final TextEditingController _rcontroller = TextEditingController();

  void _onUpdate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final review = context.read<ReviewState>();
    final title = _ucontroller.text;
    final review_text = _rcontroller.text;
    final empty = title.isEmpty || review_text.isEmpty;

    if (empty) {
      context.snackbar('Wrong title or review_text.');
      return;
    }

    await review.add(EditReview(title: title, review: review_text));

    if (review.isChanged) {
      context.pop();
      context.snackbar('Edited Review ${review.review?.title}');
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => (_rcontroller.clear()));
      context.snackbar('Edit failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextFormField(
                    controller: _ucontroller,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    textInputAction: TextInputAction.next,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Review',
                      alignLabelWithHint: true,
                      hintText: 'Write your review (in markdown)',
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                    ),
                    controller: _rcontroller,
                    minLines: 5,
                    maxLines: 50,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: UpdateButton('Update', onUpdate: _onUpdate));
  }
}
