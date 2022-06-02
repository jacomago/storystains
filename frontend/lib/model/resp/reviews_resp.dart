import 'package:json_annotation/json_annotation.dart';

import '../entity/review.dart';

part 'reviews_resp.g.dart';

@JsonSerializable()
class ReviewsResp {
  List<Review> reviews;

  ReviewsResp({required this.reviews});

  factory ReviewsResp.fromJson(Map<String, dynamic> json) =>
      _$ReviewsRespFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewsRespToJson(this);
}
