import 'package:storystains/features/review/review_model.dart';

import '../auth/user.dart';
import '../story/story.dart';

Review testReview({
  String? slug,
  String? username,
}) =>
    Review(
      body: "body$slug",
      createdAt: DateTime.now(),
      slug: slug ?? "title",
      story: testStory(title: slug),
      updatedAt: DateTime.now(),
      emotions: [],
      user: testUserProfile(username: username),
    );
