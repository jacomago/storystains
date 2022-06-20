import 'package:storystains/model/entity/review.dart';

import 'user.dart';

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
      user: testUserProfile(username),
    );
