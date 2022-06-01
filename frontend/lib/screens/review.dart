import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:storystains/config/themes.dart';

import 'package:storystains/modules/review/review.dart';
import 'package:storystains/utils/utils.dart';
import '../models/review.dart';

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
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.w),
                child: TextFormField(
                  controller: _ucontroller,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: TextField(
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    hintText: 'Write your article (in markdown)',
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28.sp,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onUpdate(context),
        child: Icon(
          Icons.send_rounded,
          size: 48.w,
          color: Colors.white,
        ),
        backgroundColor: appTheme.primaryColor,
      ),
    );
  }
}
