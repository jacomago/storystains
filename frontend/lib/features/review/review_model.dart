import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../review_emotion/review_emotion_model.dart';
import '../story/story.dart';
import '../user/user_model.dart';

part 'review_model.g.dart';

/// Main representation of a review
@JsonSerializable()
class Review {
  /// Long form text body
  String? body;

  /// time of creation
  @JsonKey(name: 'created_at')
  DateTime createdAt;

  /// slug of url
  String slug;

  /// story attached review to
  Story story;

  /// time of update
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  /// emotions attached to review
  List<ReviewEmotion> emotions;

  /// user who created review
  UserProfile user;

  /// Main representation of a review
  Review({
    required this.body,
    required this.createdAt,
    required this.slug,
    required this.story,
    required this.updatedAt,
    required this.emotions,
    required this.user,
  });

  /// Main representation of a review from json
  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  /// Main representation of a review to json
  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  String toString() => json.encode(toJson());
}

/// request for new review wrapper
@JsonSerializable()
class CreateReview {
  /// request for new review wrapper
  NewReview review;

  /// request for new review wrapper
  CreateReview({required this.review});

  /// request for new review wrapper from json
  factory CreateReview.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewFromJson(json);

  /// request for new review wrapper to json
  Map<String, dynamic> toJson() => _$CreateReviewToJson(this);
}

/// request for new review
@JsonSerializable()
class NewReview {
  /// request for new review body
  String? body;

  /// request for new review story
  Story story;

  /// request for new review
  NewReview({
    required this.body,
    required this.story,
  });

  /// request for new review from json
  factory NewReview.fromJson(Map<String, dynamic> json) =>
      _$NewReviewFromJson(json);

  /// request for new review wrapper to sjon
  Map<String, dynamic> toJson() => _$NewReviewToJson(this);
}

/// response for [Review] response
@JsonSerializable()
class ReviewResp {
  /// response for [Review] response
  Review review;

  /// response for [Review] response
  ReviewResp({required this.review});

  /// response for [Review] response from json
  factory ReviewResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewRespFromJson(json);

  /// response for [Review] response to json
  Map<String, dynamic> toJson() => _$ReviewRespToJson(this);
}
