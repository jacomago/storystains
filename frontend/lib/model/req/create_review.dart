import 'package:json_annotation/json_annotation.dart';

part 'create_review.g.dart';

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
