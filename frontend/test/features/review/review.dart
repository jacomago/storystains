import 'package:storystains/features/review/review_model.dart';
import 'package:storystains/features/review_emotion/review_emotion.dart';

import '../auth/user.dart';
import '../story/story.dart';

Review testReview({
  String? slug,
  String? username,
  List<ReviewEmotion>? emotions,
}) =>
    Review(
      body: 'body$slug',
      createdAt: DateTime.now(),
      slug: slug ?? 'title',
      story: testStory(title: slug),
      updatedAt: DateTime.now(),
      emotions: emotions ?? [],
      user: testUserProfile(username: username),
    );
