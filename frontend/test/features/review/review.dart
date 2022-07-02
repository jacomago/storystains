import 'package:storystains/features/review/review_model.dart';
import 'package:storystains/features/story/story.dart';

import '../auth/user.dart';

Review testReview({
  String? slug,
  String? username,
}) =>
    Review(
      body: "body$slug",
      createdAt: DateTime.now(),
      slug: slug ?? "title",
      story: Story(
        title: slug ?? "title",
        creator: 'Anonymous',
        medium: 'Book',
      ),
      updatedAt: DateTime.now(),
      emotions: [],
      user: testUserProfile(username: username),
    );
