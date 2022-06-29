import 'package:storystains/features/review/review_model.dart';

import '../auth/user.dart';

Review testReview({
  String? slug,
  String? username,
}) =>
    Review(
      body: "body$slug",
      createdAt: DateTime.now(),
      slug: slug ?? "title",
      title: slug ?? "title",
      updatedAt: DateTime.now(),
      emotions: [],
      user: testUserProfile(username: username),
    );
