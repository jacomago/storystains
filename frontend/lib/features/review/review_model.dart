import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../auth/auth_model.dart';
import '../review_emotion/review_emotion_model.dart';
import '../story/story.dart';

part 'review_model.g.dart';

class ReviewArguement {
  final Review review;
  ReviewArguement(this.review);
}

@JsonSerializable()
class Review {
  String body;
  @JsonKey(name: 'created_at')
  DateTime createdAt;
  String slug;
  Story story;
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;
  List<ReviewEmotion> emotions;
  UserProfile user;

  Review({
    required this.body,
    required this.createdAt,
    required this.slug,
    required this.story,
    required this.updatedAt,
    required this.emotions,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  String toString() => json.encode(toJson());
}

@JsonSerializable()
class CreateReview {
  NewReview review;

  CreateReview({required this.review});

  factory CreateReview.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReviewToJson(this);
}

@JsonSerializable()
class NewReview {
  String body;
  Story story;

  NewReview({
    required this.body,
    required this.story,
  });

  factory NewReview.fromJson(Map<String, dynamic> json) =>
      _$NewReviewFromJson(json);

  Map<String, dynamic> toJson() => _$NewReviewToJson(this);
}

@JsonSerializable()
class ReviewResp {
  Review review;

  ReviewResp({required this.review});

  factory ReviewResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewRespFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRespToJson(this);
}
