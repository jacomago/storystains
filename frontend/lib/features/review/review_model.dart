import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:storystains/features/review_emotion/review_emotion_model.dart';
import 'package:storystains/features/auth/auth_model.dart';

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
  String title;
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;
  List<ReviewEmotion> emotions;
  UserProfile user;

  Review({
    required this.body,
    required this.createdAt,
    required this.slug,
    required this.title,
    required this.updatedAt,
    required this.emotions,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  @override
  String toString() {
    return json.encode(toJson());
  }
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
  String title;

  NewReview({
    required this.body,
    required this.title,
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
