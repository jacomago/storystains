import 'package:json_annotation/json_annotation.dart';
import '../review/review_model.dart';

part 'reviews_model.g.dart';

/// Model for rest api of reviews in a list
@JsonSerializable()
class ReviewsResp {
  /// List of reviews
  List<Review> reviews;

  /// Model for rest api of reviews in a list
  ReviewsResp({required this.reviews});

  /// Model for rest api of reviews in a list from json
  factory ReviewsResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewsRespFromJson(json);

  /// Model for rest api of reviews in a list to json
  Map<String, dynamic> toJson() => _$ReviewsRespToJson(this);
}
